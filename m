From: sfeldma@gmail.com
Subject: [PATCH net-next 5/7] rocker: add FDB cleanup timer
Date: Fri, 18 Sep 2015 12:55:49 -0700
Message-ID: <1442606151-50429-6-git-send-email-sfeldma@gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33040 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbbIRTxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 15:53:12 -0400
Received: by pacex6 with SMTP id ex6so59216816pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 12:53:12 -0700 (PDT)
In-Reply-To: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add a timer to each rocker switch to do FDB entry cleanup by ageing out
expired entries.  The timer scheduling algo is copied from the bridge
driver, for the most part, to keep the firing of the timer to a minimum.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   41 ++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index eba22f5..232df69 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -248,6 +248,7 @@ struct rocker {
 	u64 flow_tbl_next_cookie;
 	DECLARE_HASHTABLE(group_tbl, 16);
 	spinlock_t group_tbl_lock;		/* for group tbl accesses */
+	struct timer_list fdb_cleanup_timer;
 	DECLARE_HASHTABLE(fdb_tbl, 16);
 	spinlock_t fdb_tbl_lock;		/* for fdb tbl accesses */
 	unsigned long internal_vlan_bitmap[ROCKER_INTERNAL_VLAN_BITMAP_LEN];
@@ -3706,6 +3707,41 @@ err_out:
 	return err;
 }
 
+static void rocker_fdb_cleanup(unsigned long data)
+{
+	struct rocker *rocker = (struct rocker *)data;
+	struct rocker_port *rocker_port;
+	struct rocker_fdb_tbl_entry *entry;
+	struct hlist_node *tmp;
+	unsigned long next_timer = jiffies + BR_MIN_AGEING_TIME;
+	unsigned long expires;
+	unsigned long lock_flags;
+	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE |
+		    ROCKER_OP_FLAG_LEARNED;
+	int bkt;
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
+
+	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, entry, entry) {
+		if (!entry->learned)
+			continue;
+		rocker_port = entry->key.rocker_port;
+		expires = entry->touched + rocker_port->ageing_time;
+		if (time_before_eq(expires, jiffies)) {
+			rocker_port_fdb_learn(rocker_port, SWITCHDEV_TRANS_NONE,
+					      flags, entry->key.addr,
+					      entry->key.vlan_id);
+			hash_del(&entry->entry);
+		} else if (time_before(expires, next_timer)) {
+			next_timer = expires;
+		}
+	}
+
+	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
+
+	mod_timer(&rocker->fdb_cleanup_timer, round_jiffies_up(next_timer));
+}
+
 static int rocker_port_router_mac(struct rocker_port *rocker_port,
 				  enum switchdev_trans trans, int flags,
 				  __be16 vlan_id)
@@ -5191,6 +5227,10 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_init_tbls;
 	}
 
+	setup_timer(&rocker->fdb_cleanup_timer, rocker_fdb_cleanup,
+		    (unsigned long) rocker);
+	mod_timer(&rocker->fdb_cleanup_timer, jiffies);
+
 	err = rocker_probe_ports(rocker);
 	if (err) {
 		dev_err(&pdev->dev, "failed to probe ports\n");
@@ -5203,6 +5243,7 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_probe_ports:
+	del_timer(&rocker->fdb_cleanup_timer);
 	rocker_free_tbls(rocker);
 err_init_tbls:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
-- 
1.7.10.4
