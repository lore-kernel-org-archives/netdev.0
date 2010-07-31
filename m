From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] ip_fragment: fix subtracting PPPOE_SES_HLEN from mtu twice
Date: Sun,  1 Aug 2010 07:25:08 +0800
Message-ID: <1280618708-9241-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Bart De Schuymer <bdschuym@pandora.be>,
	netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:39748 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab0HAG5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Aug 2010 02:57:20 -0400
Received: by pvc7 with SMTP id 7so1010107pvc.19
        for <netdev@vger.kernel.org>; Sat, 31 Jul 2010 23:57:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

6c79bf0f2440fd250c8fce8d9b82fcf03d4e8350 subtracts PPPOE_SES_HLEN from mtu at
the front of ip_fragment(). So the later subtraction should be removed. The
MTU of 802.1q is also 1500, so MTU should not be changed.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/ip_output.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6652bd9..04b6989 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -446,7 +446,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	int ptr;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	unsigned int mtu, hlen, left, len, ll_rs, pad;
+	unsigned int mtu, hlen, left, len, ll_rs;
 	int offset;
 	__be16 not_last_frag;
 	struct rtable *rt = skb_rtable(skb);
@@ -585,9 +585,7 @@ slow_path:
 	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
 	 * we need to make room for the encapsulating header
 	 */
-	pad = nf_bridge_pad(skb);
-	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, pad);
-	mtu -= pad;
+	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
 
 	/*
 	 *	Fragment the datagram.
