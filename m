From: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Subject: [PATCH 2/2] ehea: Fix kernel deadlock in DLPAR-mem processing
Date: Tue, 15 Jun 2010 17:35:42 +0200
Message-ID: <201006151735.43144.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, tklein@linux.ibm.com,
	Andre Detsch <adetsch@br.ibm.com>, themann@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:48959 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758105Ab0FOPfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:35:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port reset operations and memory add/remove operations need to 
be serialized to avoid a kernel deadlock. The deadlock is caused
by calling the napi_disable() function twice.
Therefore we have to employ the dlpar_mem_lock in the ehea_reset_port
function as well


Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
created against kernel-2.6.35-rc3

 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |    8 +++-----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 0630980..0060e42 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0103"
+#define DRV_VERSION	"EHEA_0105"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index fd890fa..8b92acb 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2860,6 +2860,7 @@ static void ehea_reset_port(struct work_struct *work)
 		container_of(work, struct ehea_port, reset_task);
 	struct net_device *dev = port->netdev;
 
+	mutex_lock(&dlpar_mem_lock);
 	port->resets++;
 	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
@@ -2882,6 +2883,7 @@ static void ehea_reset_port(struct work_struct *work)
 	netif_wake_queue(dev);
 out:
 	mutex_unlock(&port->port_lock);
+	mutex_unlock(&dlpar_mem_lock);
 }
 
 static void ehea_rereg_mrs(struct work_struct *work)
@@ -3543,10 +3545,7 @@ static int ehea_mem_notifier(struct notifier_block *nb,
 	int ret = NOTIFY_BAD;
 	struct memory_notify *arg = data;
 
-	if (!mutex_trylock(&dlpar_mem_lock)) {
-		ehea_info("ehea_mem_notifier must not be called parallelized");
-		goto out;
-	}
+	mutex_lock(&dlpar_mem_lock);
 
 	switch (action) {
 	case MEM_CANCEL_OFFLINE:
@@ -3575,7 +3574,6 @@ static int ehea_mem_notifier(struct notifier_block *nb,
 
 out_unlock:
 	mutex_unlock(&dlpar_mem_lock);
-out:
 	return ret;
 }
 
-- 
1.7.0

