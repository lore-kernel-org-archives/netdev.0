From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH 2/6] atm br2684: add callback for carrier signal changes.
Date: Fri,  2 Jul 2010 19:47:06 +0200
Message-ID: <1278092830-10473-3-git-send-email-karl@hiramoto.org>
References: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:34428 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757430Ab0GBRsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 13:48:05 -0400
Received: from homiemail-a32.g.dreamhost.com (caiajhbdcaid.dreamhost.com [208.97.132.83])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 5A9231793B2
	for <netdev@vger.kernel.org>; Fri,  2 Jul 2010 10:48:01 -0700 (PDT)
In-Reply-To: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a signal change event occurs call netif_carrier_on/off.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 net/atm/br2684.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 6719af6..e0136ec 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -448,6 +448,17 @@ free_skb:
 	dev_kfree_skb(skb);
 }
 
+static void br2684_signal_change(struct atm_vcc *atmvcc)
+{
+	struct br2684_vcc *brvcc = BR2684_VCC(atmvcc);
+	struct net_device *net_dev = brvcc->device;
+
+	if (atmvcc->dev->signal == ATM_PHY_SIG_LOST)
+		netif_carrier_off(net_dev);
+	else
+		netif_carrier_on(net_dev);
+}
+
 /*
  * Assign a vcc to a dev
  * Note: we do not have explicit unassign, but look at _push()
@@ -514,6 +525,7 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	barrier();
 	atmvcc->push = br2684_push;
 	atmvcc->pop = br2684_pop;
+	atmvcc->signal_change = br2684_signal_change;
 
 	__skb_queue_head_init(&queue);
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
@@ -530,6 +542,7 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 
 		br2684_push(atmvcc, skb);
 	}
+	br2684_signal_change(atmvcc); /* initialize netdev carrier state */
 	__module_get(THIS_MODULE);
 	return 0;
 
-- 
1.7.1

