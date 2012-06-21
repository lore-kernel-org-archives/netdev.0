From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: IPV6 ndisc::  Bad NIC causing  IPV6 NDP to stop working
Date: Thu, 21 Jun 2012 11:16:30 +0200
Message-ID: <1340270190.4604.4640.camel@edumazet-glaptop>
References: <D8C50530D6022F40A817A35C40CC06A70B34DBEFCF@DUBX7MCDUB01.EMEA.DELL.COM>
	 <1340266972.4604.4404.camel@edumazet-glaptop>
	 <D8C50530D6022F40A817A35C40CC06A70B34DBF05D@DUBX7MCDUB01.EMEA.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Menny_Hamburger@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41421 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759122Ab2FUJQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 05:16:35 -0400
Received: by eeit10 with SMTP id t10so109491eei.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 02:16:34 -0700 (PDT)
In-Reply-To: <D8C50530D6022F40A817A35C40CC06A70B34DBF05D@DUBX7MCDUB01.EMEA.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please don't top post on this list.

On Thu, 2012-06-21 at 09:43 +0100, Menny_Hamburger@Dell.com wrote:
> For high availability reasons, the machines discussed run with a
> number of NICs per subnet, where our own proprietary service fixes up
> routing when a NIC goes wild.
> We schedule a fix in the field but our goal is to eliminate as many
> single points of failure as we can, so that our systems will still run
> properly when something goes wrong.

Even if a NIC does memory corruption or some nasty bug ?
That sounds great :)

> We encountered this issue on some proprietary NICs but also with bnx2,
> where we get "chip not in correct endian mode" errors (This is another
> problem that may require a separate discussion).

Until very recently, we used to orphan skb before giving them to device
transmit. So you probably use a very old kernel.

I guess we could just do a regular alloc_skb(), it makes no sense to
limit in-flight ND skbs, we have Qdisc/device limits anyway.

BTW, I have no idea why ndisc_build_skb() is EXPORTed

 net/ipv6/ndisc.c |   24 ++++++------------------
 1 file changed, 6 insertions(+), 18 deletions(-)


diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 69a6330..f149d85 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -429,7 +429,6 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	int hlen = LL_RESERVED_SPACE(dev);
 	int tlen = dev->needed_tailroom;
 	int len;
-	int err;
 	u8 *opt;
 
 	if (!dev->addr_len)
@@ -439,15 +438,10 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (llinfo)
 		len += ndisc_opt_addr_space(dev);
 
-	skb = sock_alloc_send_skb(sk,
-				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + hlen + tlen),
-				  1, &err);
-	if (!skb) {
-		ND_PRINTK(0, err, "ND: %s failed to allocate an skb, err=%d\n",
-			  __func__, err);
+	skb = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + len + hlen + tlen,
+			GFP_ATOMIC);
+	if (!skb)
 		return NULL;
-	}
 
 	skb_reserve(skb, hlen);
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
@@ -1550,16 +1544,10 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
-	buff = sock_alloc_send_skb(sk,
-				   (MAX_HEADER + sizeof(struct ipv6hdr) +
-				    len + hlen + tlen),
-				   1, &err);
-	if (buff == NULL) {
-		ND_PRINTK(0, err,
-			  "Redirect: %s failed to allocate an skb, err=%d\n",
-			  __func__, err);
+	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + len + hlen + tlen,
+			 GFP_ATOMIC);
+	if (!buff)
 		goto release;
-	}
 
 	skb_reserve(buff, hlen);
 	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
