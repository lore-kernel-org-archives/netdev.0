From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH] endianness bug in ip6_tunnel
Date: Sat, 21 Jul 2007 09:12:31 +0100
Message-ID: <20070721081231.GM21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56501 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbXGUIMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 04:12:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPV6_TCLASS_MASK is net-endian; what happens here is that we take
a value and shove it into bits 20--27 of net-endian 32bit word.
IOW, it's misannotated (it's really htonl, not ntohl) *and* the
mask should be applied after conversion to net-endian, not before it.
The former is harmless, the latter gives the wrong value on little-endian;
As the matter of fact, on l-e it gives 0 - IPV6_TCLASS_MASK will be
htonl(0x0ff00000), i.e. on little-endian we have (something << 20) & 0xff0...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -962,8 +962,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	dsfield = ipv4_get_dsfield(iph);
 
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
-		fl.fl6_flowlabel |= ntohl(((__u32)iph->tos << IPV6_TCLASS_SHIFT)
-					  & IPV6_TCLASS_MASK);
+		fl.fl6_flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
+					  & IPV6_TCLASS_MASK;
 
 	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
 	if (err != 0) {
