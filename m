From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ip6_gre: skb_push ipv6hdr before packing the header in ip6gre_header
Date: Fri, 15 Sep 2017 12:00:07 +0800
Message-ID: <4337e23831098961437503efa2c9d7adfce96b81.1505448007.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36759 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdIOEAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 00:00:15 -0400
Received: by mail-pf0-f194.google.com with SMTP id f84so636416pfj.3
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 21:00:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now in ip6gre_header before packing the ipv6 header, it skb_push t->hlen
which only includes encap_hlen + tun_hlen. It means greh and inner header
would be over written by ipv6 stuff and ipv6h might have no chance to set
up.

Jianlin found this issue when using remote any on ip6_gre, the packets he
captured on gre dev are truncated:

22:50:26.210866 Out ethertype IPv6 (0x86dd), length 120: truncated-ip6 -\
8128 bytes missing!(flowlabel 0x92f40, hlim 0, next-header Options (0)  \
payload length: 8192) ::1:2000:0 > ::1:0:86dd: HBH [trunc] ip-proto-128 \
8184

It should also skb_push ipv6hdr so that ipv6h points to the right position
to set ipv6 stuff up.

This patch is to skb_push hlen + sizeof(*ipv6h) and also fix some indents
in ip6gre_header.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ip6_gre.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index b7a72d4..20f66f4 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -940,24 +940,25 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 }
 
 static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
-			unsigned short type,
-			const void *daddr, const void *saddr, unsigned int len)
+			 unsigned short type, const void *daddr,
+			 const void *saddr, unsigned int len)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct ipv6hdr *ipv6h = skb_push(skb, t->hlen);
-	__be16 *p = (__be16 *)(ipv6h+1);
+	struct ipv6hdr *ipv6h;
+	__be16 *p;
 
-	ip6_flow_hdr(ipv6h, 0,
-		     ip6_make_flowlabel(dev_net(dev), skb,
-					t->fl.u.ip6.flowlabel, true,
-					&t->fl.u.ip6));
+	ipv6h = skb_push(skb, t->hlen + sizeof(*ipv6h));
+	ip6_flow_hdr(ipv6h, 0, ip6_make_flowlabel(dev_net(dev), skb,
+						  t->fl.u.ip6.flowlabel,
+						  true, &t->fl.u.ip6));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
 	ipv6h->saddr = t->parms.laddr;
 	ipv6h->daddr = t->parms.raddr;
 
-	p[0]		= t->parms.o_flags;
-	p[1]		= htons(type);
+	p = (__be16 *)(ipv6h + 1);
+	p[0] = t->parms.o_flags;
+	p[1] = htons(type);
 
 	/*
 	 *	Set the source hardware address.
-- 
2.1.0
