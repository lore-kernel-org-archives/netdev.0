From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v3 net-next 3/4] rocker: do not make neighbour entry changes when preparing transactions
Date: Wed, 20 May 2015 14:48:21 +0900
Message-ID: <1432100902-10187-4-git-send-email-simon.horman@netronome.com>
References: <1432100902-10187-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34012 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbbETFsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 01:48:42 -0400
Received: by pabru16 with SMTP id ru16so54364462pab.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 22:48:41 -0700 (PDT)
In-Reply-To: <1432100902-10187-1-git-send-email-simon.horman@netronome.com>
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
Reported-by: oshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Acked-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v3
* Corrected inverted logic in _rocker_neigh_update()
  as suggested by Scott Feldman
* Added Scott Feldman's ack

v2
* As suggested by Scott Feldman, only guard ref_count adjustment
  with (trans == SWITCHDEV_TRANS_PREPARE) in _rocker_neigh_update.
* Updated changelog to note that an entry is freed but left
  in the neigh table. Thanks to Toshiaki Makita.
---
 drivers/net/ethernet/rocker/rocker.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 89d22bdcbdc4..fde3186074bb 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2909,8 +2909,11 @@ static struct rocker_neigh_tbl_entry *
 }
 
 static void _rocker_neigh_add(struct rocker *rocker,
+			      enum switchdev_trans trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
+	if (trans == SWITCHDEV_TRANS_PREPARE)
+		return;
 	entry->index = rocker->neigh_tbl_next_index++;
 	entry->ref_count++;
 	hash_add(rocker->neigh_tbl, &entry->entry,
@@ -2921,6 +2924,8 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
 			      enum switchdev_trans trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
+	if (trans == SWITCHDEV_TRANS_PREPARE)
+		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
 		rocker_port_kfree(rocker_port, trans, entry);
@@ -2928,12 +2933,13 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
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
@@ -2973,12 +2979,12 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
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
@@ -3089,13 +3095,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
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
