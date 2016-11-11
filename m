From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum: Fix refcount bug on span entries
Date: Fri, 11 Nov 2016 11:20:41 +0100
Message-ID: <1478859642-2918-2-git-send-email-jiri@resnulli.us>
References: <1478859642-2918-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, arkadis@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33527 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755292AbcKKKUq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 05:20:46 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so8374951wmu.0
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 02:20:45 -0800 (PST)
In-Reply-To: <1478859642-2918-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

When binding port to a newly created span entry, its refcount is set 0
even though it has a bound port. That leeds to unexpected behaviour when
the user tries to delete that port from the span entry.

Change the binding process to increase the refcount of the bound entry
even if the entry is newly created, and add warning on the process of
removing bound port from entry when its refcount is 0.

Fixes: 763b4b70afcd3 ("mlxsw: spectrum: Add support in matchall mirror TC offloading")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1ec0a4c..d75c1ff 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -269,17 +269,18 @@ static struct mlxsw_sp_span_entry
 	struct mlxsw_sp_span_entry *span_entry;
 
 	span_entry = mlxsw_sp_span_entry_find(port);
-	if (span_entry) {
-		span_entry->ref_count++;
-		return span_entry;
-	}
+	if (!span_entry)
+		span_entry = mlxsw_sp_span_entry_create(port);
 
-	return mlxsw_sp_span_entry_create(port);
+	span_entry->ref_count++;
+	return span_entry;
 }
 
 static int mlxsw_sp_span_entry_put(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_span_entry *span_entry)
 {
+	WARN_ON(!span_entry->ref_count);
+
 	if (--span_entry->ref_count == 0)
 		mlxsw_sp_span_entry_destroy(mlxsw_sp, span_entry);
 	return 0;
-- 
2.7.4
