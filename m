From: jamal <hadi@cyberus.ca>
Subject: [PATCH] net: Fix RPF to work with policy routing
Date: Sun, 18 Oct 2009 08:12:33 -0400
Message-ID: <1255867954.4815.25.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xCIcZiN/WEirCZDcxxrV"
Cc: Atis Elsts <atis@mikrotik.com>, eric.dumazet@gmail.com,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:57268 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZJRMPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:15:35 -0400
Received: by qyk32 with SMTP id 32so2428671qyk.4
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 05:15:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xCIcZiN/WEirCZDcxxrV
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


policy routing never worked with mark.

I tested this with ping and the skbedit patch i posted a few days back.

cheers,
jamal


--=-xCIcZiN/WEirCZDcxxrV
Content-Disposition: attachment; filename=policy-mark-rpf
Content-Type: text/plain; name=policy-mark-rpf; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit f7c6fd2465d8e6f4f89c5d1262da10b4a6d499d0
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sun Oct 18 08:04:51 2009 -0400

    [PATCH] net: Fix RPF to work with policy routing
    Policy routing is not looked up by mark on reverse path filtering.
    This fixes it.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ef91fe9..4d22fab 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -210,7 +210,8 @@ extern struct fib_table *fib_get_table(struct net *net, u32 id);
 extern const struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
 extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
-			       struct net_device *dev, __be32 *spec_dst, u32 *itag);
+			       struct net_device *dev, __be32 *spec_dst,
+			       u32 *itag, u32 mark);
 extern void fib_select_default(struct net *net, const struct flowi *flp,
 			       struct fib_result *res);
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e2f9505..aa00398 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -229,14 +229,17 @@ unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
  */
 
 int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
-			struct net_device *dev, __be32 *spec_dst, u32 *itag)
+			struct net_device *dev, __be32 *spec_dst,
+			u32 *itag, u32 mark)
 {
 	struct in_device *in_dev;
 	struct flowi fl = { .nl_u = { .ip4_u =
 				      { .daddr = src,
 					.saddr = dst,
 					.tos = tos } },
+			    .mark = mark,
 			    .iif = oif };
+
 	struct fib_result res;
 	int no_addr, rpf;
 	int ret;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 278f46f..9744fc5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1852,7 +1852,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			goto e_inval;
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	} else if (fib_validate_source(saddr, 0, tos, 0,
-					dev, &spec_dst, &itag) < 0)
+					dev, &spec_dst, &itag, 0) < 0)
 		goto e_inval;
 
 	rth = dst_alloc(&ipv4_dst_ops);
@@ -1965,7 +1965,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 
 	err = fib_validate_source(saddr, daddr, tos, FIB_RES_OIF(*res),
-				  in_dev->dev, &spec_dst, &itag);
+				  in_dev->dev, &spec_dst, &itag, skb->mark);
 	if (err < 0) {
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
 					 saddr);
@@ -2139,7 +2139,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		int result;
 		result = fib_validate_source(saddr, daddr, tos,
 					     net->loopback_dev->ifindex,
-					     dev, &spec_dst, &itag);
+					     dev, &spec_dst, &itag, skb->mark);
 		if (result < 0)
 			goto martian_source;
 		if (result)
@@ -2168,7 +2168,7 @@ brd_input:
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	else {
 		err = fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag);
+					  &itag, skb->mark);
 		if (err < 0)
 			goto martian_source;
 		if (err)

--=-xCIcZiN/WEirCZDcxxrV--

