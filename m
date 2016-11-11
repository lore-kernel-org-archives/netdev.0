From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 1/2] mlxsw: spectrum: Fix refcount bug on span entries
Date: Fri, 11 Nov 2016 16:34:25 +0100
Message-ID: <1478878466-3141-2-git-send-email-jiri@resnulli.us>
References: <1478878466-3141-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, arkadis@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35588 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756816AbcKKPea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 10:34:30 -0500
Received: by mail-wm0-f65.google.com with SMTP id a20so10239200wme.2
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 07:34:29 -0800 (PST)
In-Reply-To: <1478878466-3141-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

When binding port to a newly created span entry, its refcount is
initialized to zero even though it has a bound port. That leads
to unexpected behaviour when the user tries to delete that port
from the span entry.

Fix this by initializing the reference count to 1.

Also add a warning to put function.

Fixes: 763b4b70afcd ("mlxsw: spectrum: Add support in matchall mirror TC offloading")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- fix this rather by initializing refcount to 1
- fix typo in description
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1ec0a4c..dda5761 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -231,7 +231,7 @@ mlxsw_sp_span_entry_create(struct mlxsw_sp_port *port)
 
 	span_entry->used = true;
 	span_entry->id = index;
-	span_entry->ref_count = 0;
+	span_entry->ref_count = 1;
 	span_entry->local_port = local_port;
 	return span_entry;
 }
@@ -270,6 +270,7 @@ static struct mlxsw_sp_span_entry
 
 	span_entry = mlxsw_sp_span_entry_find(port);
 	if (span_entry) {
+		/* Already exists, just take a reference */
 		span_entry->ref_count++;
 		return span_entry;
 	}
@@ -280,6 +281,7 @@ static struct mlxsw_sp_span_entry
 static int mlxsw_sp_span_entry_put(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_span_entry *span_entry)
 {
+	WARN_ON(!span_entry->ref_count);
 	if (--span_entry->ref_count == 0)
 		mlxsw_sp_span_entry_destroy(mlxsw_sp, span_entry);
 	return 0;
-- 
2.7.4
