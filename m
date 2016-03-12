From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] rocker: move ageing_time from struct rocker to struct ofdpa
Date: Sat, 12 Mar 2016 12:03:27 +0100
Message-ID: <1457780607-21264-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33854 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbcCLLDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 06:03:30 -0500
Received: by mail-wm0-f44.google.com with SMTP id p65so46925068wmp.1
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 03:03:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is OF-DPA specific, used only there, similar to
ofdpa_port->ageing_time. So move it to OF-DPA code.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h       |  1 -
 drivers/net/ethernet/rocker/rocker_main.c  |  2 --
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 11 +++++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 011f1b6..1ab995f 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -63,7 +63,6 @@ struct rocker {
 	struct {
 		u64 id;
 	} hw;
-	unsigned long ageing_time;
 	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index c8b1bf4..28b775e 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2733,8 +2733,6 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	rocker->hw.id = rocker_read64(rocker, SWITCH_ID);
 
-	rocker->ageing_time = BR_DEFAULT_AGEING_TIME;
-
 	err = rocker_probe_ports(rocker);
 	if (err) {
 		dev_err(&pdev->dev, "failed to probe ports\n");
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index cfde525..0e758bc 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -188,6 +188,7 @@ struct ofdpa {
 	DECLARE_HASHTABLE(neigh_tbl, 16);
 	spinlock_t neigh_tbl_lock;		/* for neigh tbl accesses */
 	u32 neigh_tbl_next_index;
+	unsigned long ageing_time;
 };
 
 struct ofdpa_port {
@@ -2105,7 +2106,7 @@ static void ofdpa_fdb_cleanup(unsigned long data)
 	struct ofdpa_port *ofdpa_port;
 	struct ofdpa_fdb_tbl_entry *entry;
 	struct hlist_node *tmp;
-	unsigned long next_timer = jiffies + ofdpa->rocker->ageing_time;
+	unsigned long next_timer = jiffies + ofdpa->ageing_time;
 	unsigned long expires;
 	unsigned long lock_flags;
 	int flags = OFDPA_OP_FLAG_NOWAIT | OFDPA_OP_FLAG_REMOVE |
@@ -2492,6 +2493,8 @@ static int ofdpa_init(struct rocker *rocker)
 		    (unsigned long) ofdpa);
 	mod_timer(&ofdpa->fdb_cleanup_timer, jiffies);
 
+	ofdpa->ageing_time = BR_DEFAULT_AGEING_TIME;
+
 	return 0;
 }
 
@@ -2648,12 +2651,12 @@ ofdpa_port_attr_bridge_ageing_time_set(struct rocker_port *rocker_port,
 				       struct switchdev_trans *trans)
 {
 	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
-	struct rocker *rocker = rocker_port->rocker;
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
 
 	if (!switchdev_trans_ph_prepare(trans)) {
 		ofdpa_port->ageing_time = clock_t_to_jiffies(ageing_time);
-		if (ofdpa_port->ageing_time < rocker->ageing_time)
-			rocker->ageing_time = ofdpa_port->ageing_time;
+		if (ofdpa_port->ageing_time < ofdpa->ageing_time)
+			ofdpa->ageing_time = ofdpa_port->ageing_time;
 		mod_timer(&ofdpa_port->ofdpa->fdb_cleanup_timer, jiffies);
 	}
 
-- 
2.5.0
