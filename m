From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 2/2] nfp: process MTU updates from firmware flower app
Date: Wed, 16 Aug 2017 09:37:44 +0200
Message-ID: <1502869064-25842-3-git-send-email-simon.horman@netronome.com>
References: <1502869064-25842-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38300 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdHPHh5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 03:37:57 -0400
Received: by mail-wm0-f47.google.com with SMTP id f15so26640957wmg.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 00:37:57 -0700 (PDT)
In-Reply-To: <1502869064-25842-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that control message processing occurs in a workqueue rather than a BH
handler MTU updates received from the firmware may be safely processed.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index 6c8c22491fe7..806924b82adc 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -150,10 +150,17 @@ nfp_flower_cmsg_portmod_rx(struct nfp_app *app, struct sk_buff *skb)
 		return;
 	}
 
-	if (link)
+	if (link) {
+		u16 mtu = be16_to_cpu(msg->mtu);
+
 		netif_carrier_on(netdev);
-	else
+
+		/* An MTU of 0 from the firmware should be ignored */
+		if (mtu)
+			dev_set_mtu(netdev, mtu);
+	} else {
 		netif_carrier_off(netdev);
+	}
 	rcu_read_unlock();
 }
 
-- 
2.1.4
