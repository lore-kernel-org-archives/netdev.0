From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] macsec: set actual real device for xmit when !protect_frames
Date: Fri,  1 Jul 2016 00:00:54 +0200
Message-ID: <920063998328f5014b267defd80eec862f181ad8.1467323773.git.daniel@iogearbox.net>
Cc: sd@queasysnail.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52188 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbcF3WBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 18:01:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid recursions of dev_queue_xmit() to the wrong net device when
frames are unprotected, since at that time skb->dev still points to
our own macsec dev and unlike macsec_encrypt_finish() dev pointer
doesn't get updated to real underlying device.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 0e7eff7..8bcd78f 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2640,6 +2640,7 @@ static netdev_tx_t macsec_start_xmit(struct sk_buff *skb,
 		u64_stats_update_begin(&secy_stats->syncp);
 		secy_stats->stats.OutPktsUntagged++;
 		u64_stats_update_end(&secy_stats->syncp);
+		skb->dev = macsec->real_dev;
 		len = skb->len;
 		ret = dev_queue_xmit(skb);
 		count_tx(dev, ret, len);
-- 
1.9.3
