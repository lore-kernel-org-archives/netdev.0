From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] rocker: linearize skb in case frags would not fit into tx descriptor
Date: Sun,  2 Aug 2015 20:56:38 +0200
Message-ID: <1438541798-1725-2-git-send-email-jiri@resnulli.us>
References: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38148 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbbHBS4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 14:56:43 -0400
Received: by wibxm9 with SMTP id xm9so88546377wib.1
        for <netdev@vger.kernel.org>; Sun, 02 Aug 2015 11:56:42 -0700 (PDT)
In-Reply-To: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 730bdc0..4cd5a71 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4157,8 +4157,11 @@ static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
 					  skb->data, skb_headlen(skb));
 	if (err)
 		goto nest_cancel;
-	if (skb_shinfo(skb)->nr_frags > ROCKER_TX_FRAGS_MAX)
-		goto nest_cancel;
+	if (skb_shinfo(skb)->nr_frags > ROCKER_TX_FRAGS_MAX) {
+		err = skb_linearize(skb);
+		if (err)
+			goto unmap_frags;
+	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-- 
1.9.3
