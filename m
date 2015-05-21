From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v4 net-next 3/4] rocker: do not make neighbour entry changes when preparing transactions
Date: Thu, 21 May 2015 12:40:16 +0900
Message-ID: <1432179617-26642-4-git-send-email-simon.horman@netronome.com>
References: <1432179617-26642-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36286 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788AbbEUDko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 23:40:44 -0400
Received: by pdfh10 with SMTP id h10so92568073pdf.3
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 20:40:42 -0700 (PDT)
In-Reply-To: <1432179617-26642-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rocker_port_ipv4_nh() and in turn rocker_port_ipv4_neigh() may be
be called with trans == SWITCHDEV_TRANS_PREPARE and then
trans == SWITCHDEV_TRANS_COMMIT from switchdev_port_obj_set() via
fib_table_insert().

The first time that rocker_port_ipv4_nh() is called, with
trans == SWITCHDEV_TRANS_PREPARE, _rocker_neigh_add() adds a new entry to
the neigh table.

And the second time  rocker_port_ipv4_nh() is called, with
trans == SWITCHDEV_TRANS_COMMIT, that entry is found. This causes
rocker_port_ipv4_nh() to believe it is not adding an entry and thus it
frees "entry", which is still present in rocker driver's neigh table.

This problem does not appear to affect deletion as my analysis is that
deletion is always performed with trans == SWITCHDEV_TRANS_NONE.

For completeness _rocker_neigh_{add,del,prepare} are updated not to
manipulate fib table entries if trans == SWITCHDEV_TRANS_PREPARE.

Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Acked-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v4
* Added Jiri Pirko's ack
* As suggested by Toshiaki Makita do not guard entry->index assignment
  in _rocker_neigh_add()

v3
* Corrected inverted logic in _rocker_neigh_update()
  as suggested by Scott Feldman
* Added Scott Feldman's ack

v2
* As suggested by Scott Feldman only guard ref_count adjustment
  with (trans == SWITCHDEV_TRANS_PREPARE) in _rocker_neigh_update.
* Updated changelog to note that an entry is freed but left
  in the neigh table. Thanks to Toshiaki Makita.
---
 drivers/net/ethernet/rocker/rocker.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 89d22bdcbdc4..51744764acd7 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2909,9 +2909,13 @@ static struct rocker_neigh_tbl_entry *
 }
 
 static void _rocker_neigh_add(struct rocker *rocker,
+			      enum switchdev_trans trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	entry->index = rocker->neigh_tbl_next_index++;
+	entry->index = rocker->neigh_tbl_next_index;
+	if (trans == SWITCHDEV_TRANS_PREPARE)
+		return;
+	rocker->neigh_tbl_next_index++;
 	entry->ref_count++;
 	hash_add(rocker->neigh_tbl, &entry->entry,
 		 be32_to_cpu(entry->ip_addr));
@@ -2921,6 +2925,8 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
 			      enum switchdev_trans trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
+	if (trans == SWITCHDEV_TRANS_PREPARE)
+		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
 		rocker_port_kfree(rocker_port, trans, entry);
@@ -2928,12 +2934,13 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
 }
 
 static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
+				 enum switchdev_trans trans,
 				 u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = ttl_check;
-	} else {
+	} else if (trans != SWITCHDEV_TRANS_PREPARE) {
 		entry->ref_count++;
 	}
 }
@@ -2973,12 +2980,12 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 		entry->dev = rocker_port->dev;
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = true;
-		_rocker_neigh_add(rocker, entry);
+		_rocker_neigh_add(rocker, trans, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
 		_rocker_neigh_del(rocker_port, trans, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, eth_dst, true);
+		_rocker_neigh_update(found, trans, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
 	} else {
 		err = -ENOENT;
@@ -3089,13 +3096,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	if (adding) {
 		entry->ip_addr = ip_addr;
 		entry->dev = rocker_port->dev;
-		_rocker_neigh_add(rocker, entry);
+		_rocker_neigh_add(rocker, trans, entry);
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
 		_rocker_neigh_del(rocker_port, trans, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, NULL, false);
+		_rocker_neigh_update(found, trans, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
 	} else {
 		err = -ENOENT;
-- 
2.1.4
