From: Gregory Haskins <ghaskins@novell.com>
Subject: [NET PATCH 5/9] venet: cache the ringlen values at init
Date: Wed, 14 Oct 2009 11:59:12 -0400
Message-ID: <20091014155912.18864.83106.stgit@dev.haskins.net>
References: <20091014154457.18864.28382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761920AbZJNQJt@vger.kernel.org>
In-Reply-To: <20091014154457.18864.28382.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We want to prevent the condition where changes to the module-params
could affect the run-time validity of the ringstate

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/vbus-enet.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
index 63237f3..fe9eeca 100644
--- a/drivers/net/vbus-enet.c
+++ b/drivers/net/vbus-enet.c
@@ -50,6 +50,7 @@ module_param(sg_enabled, int, 0444);
 struct vbus_enet_queue {
 	struct ioq              *queue;
 	struct ioq_notifier      notifier;
+	unsigned long            count;
 };
 
 struct vbus_enet_priv {
@@ -94,6 +95,8 @@ queue_init(struct vbus_enet_priv *priv,
 		q->queue->notifier = &q->notifier;
 	}
 
+	q->count = ringsize;
+
 	return 0;
 }
 
@@ -222,7 +225,7 @@ tx_setup(struct vbus_enet_priv *priv)
 	/* pre-allocate our descriptor pool if pmtd is enabled */
 	if (priv->pmtd.enabled) {
 		struct vbus_device_proxy *dev = priv->vdev;
-		size_t poollen = len * tx_ringlen;
+		size_t poollen = len * priv->txq.count;
 		char *pool;
 		int shmid;
 
@@ -251,7 +254,7 @@ tx_setup(struct vbus_enet_priv *priv)
 	/*
 	 * Now populate each descriptor with an empty SG descriptor
 	 */
-	for (i = 0; i < tx_ringlen; i++) {
+	for (i = 0; i < priv->txq.count; i++) {
 		struct venet_sg *vsg;
 
 		if (priv->pmtd.enabled) {
