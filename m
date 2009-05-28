From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 2/2] cxgb3: link fault fixes
Date: Thu, 28 May 2009 14:23:08 -0700
Message-ID: <20090528212308.28184.39504.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26708 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763846AbZE1VXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 17:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Do not call t3_link_fault() under spinlock, as it calls msleep().
Besides, only the access to pi->link_fault needs to be serialized.

Also initialize local variables before checking the link status,
link state fields might otherwise end up containing garbage.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    8 +++++---
 drivers/net/cxgb3/t3_hw.c      |    5 +++++
 2 files changed, 10 insertions(+), 3 deletions(-)


diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7ea4841..17858b9 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2496,14 +2496,16 @@ static void check_link_status(struct adapter *adapter)
 	for_each_port(adapter, i) {
 		struct net_device *dev = adapter->port[i];
 		struct port_info *p = netdev_priv(dev);
+		int link_fault;
 
 		spin_lock_irq(&adapter->work_lock);
-		if (p->link_fault) {
+		link_fault = p->link_fault;
+		spin_unlock_irq(&adapter->work_lock);
+
+		if (link_fault) {
 			t3_link_fault(adapter, i);
-			spin_unlock_irq(&adapter->work_lock);
 			continue;
 		}
-		spin_unlock_irq(&adapter->work_lock);
 
 		if (!(p->phy.caps & SUPPORTED_IRQ) && netif_running(dev)) {
 			t3_xgm_intr_disable(adapter, i);
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 4f68aeb..4950d5d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1274,6 +1274,11 @@ void t3_link_fault(struct adapter *adapter, int port_id)
 				 A_XGM_INT_STATUS + mac->offset);
 	link_fault &= F_LINKFAULTCHANGE;
 
+	link_ok = lc->link_ok;
+	speed = lc->speed;
+	duplex = lc->duplex;
+	fc = lc->fc;
+
 	phy->ops->get_link_status(phy, &link_ok, &speed, &duplex, &fc);
 
 	if (link_fault) {

