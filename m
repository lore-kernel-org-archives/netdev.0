From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Add a mutex around ethtools operations
Date: Thu, 06 Aug 2009 07:46:02 +0900
Message-ID: <4A7A0BAA.7020104@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Rene Mayrhofer <rene@mayrhofer.eu.org>,
	Richard Leitner <leitner@esys.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:62695 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbZHEWtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 18:49:06 -0400
Received: by rv-out-0506.google.com with SMTP id f6so131725rvb.1
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 15:49:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As multiple sky2 devices share some of the same hardware, and ethtool
operations are per device, access to transmit timers, eeprom access,
 coalesce, etc. should be serialized.

Only tested on a single port card, as my sky2 doesn't have dual ports.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   15 +++++++++++++++
 drivers/net/sky2.h |    1 +
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 1415a83..96aad19 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3923,6 +3923,18 @@ static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom
 	return sky2_vpd_write(sky2->hw, cap, data, eeprom->offset, eeprom->len);
 }
 
+static int sky2_ethtool_begin(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	mutex_lock(&sky2->hw->ethtool_mutex);
+	return 0;
+}
+
+static void sky2_ethtool_complete(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	mutex_unlock(&sky2->hw->ethtool_mutex);
+}
 
 static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_settings	= sky2_get_settings,
@@ -3954,6 +3966,8 @@ static const struct ethtool_ops sky2_ethtool_ops = {
 	.phys_id	= sky2_phys_id,
 	.get_sset_count = sky2_get_sset_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
+	.begin		= sky2_ethtool_begin,
+	.complete	= sky2_ethtool_complete,
 };
 
 #ifdef CONFIG_SKY2_DEBUG
@@ -4485,6 +4499,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	}
 
 	hw->pdev = pdev;
+	mutex_init(&hw->ethtool_mutex);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 4486b06..199fb4a 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2087,6 +2087,7 @@ struct sky2_hw {
 	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
 	wait_queue_head_t    msi_wait;
+	struct mutex	     ethtool_mutex;
 };
 
 static inline int sky2_is_copper(const struct sky2_hw *hw)
-- 
1.5.6.5

