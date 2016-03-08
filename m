From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 2/3] rocker: set FDB cleanup timer according to lowest ageing time
Date: Tue,  8 Mar 2016 12:59:34 -0800
Message-ID: <1457470775-32224-3-git-send-email-stephen@networkplumber.org>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org, Ido Schimmel <idosch@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33120 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbcCHU7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:59:25 -0500
Received: by mail-pf0-f180.google.com with SMTP id 124so21282611pfg.0
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 12:59:25 -0800 (PST)
In-Reply-To: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In rocker, ageing time is a per-port attribute, so the next time the FDB
cleanup timer fires should be set according to the lowest ageing time.

This will later allow us to delete the BR_MIN_AGEING_TIME macro, which was
added to guarantee minimum ageing time in the bridge layer, thereby breaking
existing behavior.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 166a7fc..19c65503 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -239,6 +239,7 @@ struct rocker {
 	struct {
 		u64 id;
 	} hw;
+	unsigned long ageing_time;
 	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
@@ -3704,7 +3705,7 @@ static void rocker_fdb_cleanup(unsigned long data)
 	struct rocker_port *rocker_port;
 	struct rocker_fdb_tbl_entry *entry;
 	struct hlist_node *tmp;
-	unsigned long next_timer = jiffies + BR_MIN_AGEING_TIME;
+	unsigned long next_timer = jiffies + rocker->ageing_time;
 	unsigned long expires;
 	unsigned long lock_flags;
 	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE |
@@ -4367,8 +4368,12 @@ static int rocker_port_bridge_ageing_time(struct rocker_port *rocker_port,
 					  struct switchdev_trans *trans,
 					  u32 ageing_time)
 {
+	struct rocker *rocker = rocker_port->rocker;
+
 	if (!switchdev_trans_ph_prepare(trans)) {
 		rocker_port->ageing_time = clock_t_to_jiffies(ageing_time);
+		if (rocker_port->ageing_time < rocker->ageing_time)
+			rocker->ageing_time = rocker_port->ageing_time;
 		mod_timer(&rocker_port->rocker->fdb_cleanup_timer, jiffies);
 	}
 
@@ -5206,6 +5211,7 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_init_tbls;
 	}
 
+	rocker->ageing_time = BR_DEFAULT_AGEING_TIME;
 	setup_timer(&rocker->fdb_cleanup_timer, rocker_fdb_cleanup,
 		    (unsigned long) rocker);
 	mod_timer(&rocker->fdb_cleanup_timer, jiffies);
-- 
2.1.4
