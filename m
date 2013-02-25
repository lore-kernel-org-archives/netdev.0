From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/2] IP_GRE: Fix GRE_CSUM case.
Date: Sun, 24 Feb 2013 22:05:05 -0800
Message-ID: <1361772305-1665-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, dmitry@broadcom.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:40103 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750706Ab3BYGFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 01:05:53 -0500
Received: by mail-pb0-f69.google.com with SMTP id rp8so3830375pbb.0
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2013 22:05:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit "ip_gre: allow CSUM capable devices to handle packets"
aa0e51cdda005cd37e2, broke GRE_CSUM case.
GRE_CSUM needs checksum computed for inner packet. Therefore
csum-calculation can not be offloaded if tunnel device requires
GRE_CSUM.  Following patch fixes it by computing inner packet checksum
for GRE_CSUM type, for all other type of GRE devices csum is offloaded.

CC: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_gre.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5ef4da7..9b4996d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -735,7 +735,7 @@ drop:
 	return 0;
 }
 
-static struct sk_buff *handle_offloads(struct sk_buff *skb)
+static struct sk_buff *handle_offloads(struct ip_tunnel *tunnel, struct sk_buff *skb)
 {
 	int err;
 
@@ -745,8 +745,12 @@ static struct sk_buff *handle_offloads(struct sk_buff *skb)
 			goto error;
 		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
 		return skb;
-	}
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL &&
+		   tunnel->parms.o_flags&GRE_CSUM) {
+		err = skb_checksum_help(skb);
+		if (unlikely(err))
+			goto error;
+	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
 		skb->ip_summed = CHECKSUM_NONE;
 
 	return skb;
@@ -776,7 +780,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	int    err;
 	int    pkt_len;
 
-	skb = handle_offloads(skb);
+	skb = handle_offloads(tunnel, skb);
 	if (IS_ERR(skb)) {
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
-- 
1.7.1
