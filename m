From: Alexandre Bounine <alexandre.bounine@idt.com>
Subject: [PATCH 11/30] rapidio/rionet: add shutdown event handling
Date: Fri,  5 Feb 2016 18:19:27 -0500
Message-ID: <1454714386-15259-12-git-send-email-alexandre.bounine@idt.com>
References: <1454714386-15259-1-git-send-email-alexandre.bounine@idt.com>
Cc: Alexandre Bounine <alexandre.bounine@idt.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Aurelien Jacquiot <a-jacquiot@ti.com>,
	Andre van Herk <andre.van.herk@prodrive-technologies.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454714386-15259-1-git-send-email-alexandre.bounine@idt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add shutdown notification handler which terminates active connections
with remote RapidIO nodes. This prevents remote nodes from sending packets
to the powered off node and eliminates hardware error events on remote
nodes.

Signed-off-by: Alexandre Bounine <alexandre.bounine@idt.com>
Cc: Matt Porter <mporter@kernel.crashing.org>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
Cc: Andre van Herk <andre.van.herk@prodrive-technologies.com>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/rionet.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index d3d6e35..f994fa1 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -24,6 +24,7 @@
 #include <linux/skbuff.h>
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
+#include <linux/reboot.h>
 
 #define DRV_NAME        "rionet"
 #define DRV_VERSION     "0.3"
@@ -599,6 +600,30 @@ out:
 	return rc;
 }
 
+static int rionet_shutdown(struct notifier_block *nb, unsigned long code,
+			   void *unused)
+{
+	struct rionet_peer *peer, *tmp;
+	int i;
+
+	pr_debug("%s: %s\n", DRV_NAME, __func__);
+
+	for (i = 0; i < RIONET_MAX_NETS; i++) {
+		if (!nets[i].ndev)
+			continue;
+
+		list_for_each_entry_safe(peer, tmp, &nets[i].peers, node) {
+			if (nets[i].active[peer->rdev->destid]) {
+				rio_send_doorbell(peer->rdev,
+						  RIONET_DOORBELL_LEAVE);
+				nets[i].active[peer->rdev->destid] = NULL;
+			}
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
 #ifdef MODULE
 static struct rio_device_id rionet_id_table[] = {
 	{RIO_DEVICE(RIO_ANY_ID, RIO_ANY_ID)},
@@ -615,8 +640,20 @@ static struct subsys_interface rionet_interface = {
 	.remove_dev	= rionet_remove_dev,
 };
 
+static struct notifier_block rionet_notifier = {
+	.notifier_call = rionet_shutdown,
+};
+
 static int __init rionet_init(void)
 {
+	int ret;
+
+	ret = register_reboot_notifier(&rionet_notifier);
+	if (ret) {
+		pr_err("%s: failed to register reboot notifier (err=%d)\n",
+		       DRV_NAME, ret);
+		return ret;
+	}
 	return subsys_interface_register(&rionet_interface);
 }
 
@@ -648,6 +685,7 @@ static void __exit rionet_exit(void)
 		}
 	}
 
+	unregister_reboot_notifier(&rionet_notifier);
 	subsys_interface_unregister(&rionet_interface);
 }
 
-- 
1.7.8.4
