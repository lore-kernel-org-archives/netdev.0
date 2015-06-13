From: sfeldma@gmail.com
Subject: [PATCH net-next] rocker: fix neigh tbl index increment race
Date: Fri, 12 Jun 2015 21:24:40 -0700
Message-ID: <1434169480-62863-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35779 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbFMEWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:22:44 -0400
Received: by pacyx8 with SMTP id yx8so32732323pac.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:22:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

rocker->neigh_tbl_next_index is used to generate unique indices for neigh
entries programmed into the device.  The way new indices were generated was
racy with the new prepare-commit transaction model.  A simple fix here
removes the race.  The race was with two processes getting the same index,
one process using prepare-commit, the other not:

Proc A					Proc B

PREPARE phase
get neigh_tbl_next_index

					NONE phase
					get neigh_tbl_next_index
					neigh_tbl_next_index++

COMMIT phase
neigh_tbl_next_index++

Both A and B got the same index.  The fix is to store and increment
neigh_tbl_next_index in the PREPARE (or NONE) phase and use value in COMMIT
phase:

Proc A					Proc B

PREPARE phase
get neigh_tbl_next_index
neigh_tbl_next_index++

					NONE phase
					get neigh_tbl_next_index
					neigh_tbl_next_index++

COMMIT phase
// use value stashed in PREPARE phase

Reported-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index c6a6e3c..a9d1559 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2901,10 +2901,10 @@ static void _rocker_neigh_add(struct rocker *rocker,
 			      enum switchdev_trans trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	entry->index = rocker->neigh_tbl_next_index;
+	if (trans != SWITCHDEV_TRANS_COMMIT)
+		entry->index = rocker->neigh_tbl_next_index++;
 	if (trans == SWITCHDEV_TRANS_PREPARE)
 		return;
-	rocker->neigh_tbl_next_index++;
 	entry->ref_count++;
 	hash_add(rocker->neigh_tbl, &entry->entry,
 		 be32_to_cpu(entry->ip_addr));
-- 
1.7.10.4
