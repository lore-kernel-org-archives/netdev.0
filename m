From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 13:20:48 -0800
Message-ID: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:32817 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752769Ab3AVVT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 16:19:58 -0500
Received: by mail-qc0-f197.google.com with SMTP id x40so7045671qcs.4
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 13:19:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make copy of skb sharable data by linearizing skb. so that
csum remain consistent when skb is actually transmitted.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_gre.c |   22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7cdf1fe..20d3d37 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -738,7 +738,7 @@ drop:
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr  *old_iph = ip_hdr(skb);
+	const struct iphdr  *old_iph;
 	const struct iphdr  *tiph;
 	struct flowi4 fl4;
 	u8     tos;
@@ -752,9 +752,23 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	int    mtu;
 	u8     ttl;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    skb_checksum_help(skb))
-		goto tx_error;
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		int err;
+
+		/* Pages aren't locked and could change at any time.
+		 * If this happens after we compute the checksum, the
+		 * checksum will be wrong.  We linearize now to avoid
+		 * this problem.
+		 */
+		err = __skb_linearize(skb);
+		if (unlikely(err))
+			goto tx_error;
+
+		err = skb_checksum_help(skb);
+		if (unlikely(err))
+			goto tx_error;
+	}
+	old_iph = ip_hdr(skb);
 
 	if (dev->type == ARPHRD_ETHER)
 		IPCB(skb)->flags = 0;
-- 
1.7.10
