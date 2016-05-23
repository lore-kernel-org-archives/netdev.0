From: Alexander Aring <aar@pengutronix.de>
Subject: [RFC 06/12] ndisc: get rid off dev parameter in ndisc_fill_addr_option
Date: Mon, 23 May 2016 21:22:02 +0200
Message-ID: <1464031328-17524-7-git-send-email-aar@pengutronix.de>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37286 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753354AbcEWTXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 15:23:10 -0400
In-Reply-To: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the net_device parameter from ndisc_fill_addr_option
function. This can be useful for calling such functionality which
doesn't depends on dev parameter. For current existing functionality
which depends on dev parameter, we introduce ndisc_dev_fill_addr_option to have
an easy replacement for the ndisc_fill_addr_option function.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
 net/ipv6/ndisc.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d6f28d5..d794d64 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -150,10 +150,9 @@ struct neigh_table nd_tbl = {
 };
 EXPORT_SYMBOL_GPL(nd_tbl);
 
-static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
+static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
+				   int data_len, int pad)
 {
-	int pad = ndisc_addr_option_pad(skb->dev->type);
-	int data_len = skb->dev->addr_len;
 	int space = ndisc_opt_addr_space(data_len, pad);
 	u8 *opt = skb_put(skb, space);
 
@@ -172,6 +171,13 @@ static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
 		memset(opt, 0, space);
 }
 
+static inline void ndisc_dev_fill_addr_option(struct sk_buff *skb, int type,
+					      const struct net_device *dev)
+{
+	ndisc_fill_addr_option(skb, type, dev->dev_addr, dev->addr_len,
+			       ndisc_addr_option_pad(dev->type));
+}
+
 static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 					    struct nd_opt_hdr *end)
 {
@@ -527,8 +533,7 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 	};
 
 	if (inc_opt)
-		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR,
-				       dev->dev_addr);
+		ndisc_dev_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR, dev);
 
 
 	ndisc_send_skb(skb, daddr, src_addr);
@@ -589,8 +594,7 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 	};
 
 	if (inc_opt)
-		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
-				       dev->dev_addr);
+		ndisc_dev_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR, dev);
 
 	ndisc_send_skb(skb, daddr, saddr);
 }
@@ -640,8 +644,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	};
 
 	if (send_sllao)
-		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
-				       dev->dev_addr);
+		ndisc_dev_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR, dev);
 
 	ndisc_send_skb(skb, daddr, saddr);
 }
@@ -1596,7 +1599,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	 */
 
 	if (ha)
-		ndisc_fill_addr_option(buff, ND_OPT_TARGET_LL_ADDR, ha);
+		ndisc_fill_addr_option(buff, ND_OPT_TARGET_LL_ADDR, ha,
+				       dev->addr_len,
+				       ndisc_addr_option_pad(dev->type));
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.
-- 
2.8.2
