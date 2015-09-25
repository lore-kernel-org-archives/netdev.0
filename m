From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/8] net/mlx5_core: Fix notification of page supplement error
Date: Fri, 25 Sep 2015 10:49:13 +0300
Message-ID: <1443167356-32095-6-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39307 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754652AbbIYHto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:49:44 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Some errors did not result with notifying firmware that the page request
could not be fulfilled. Fix this and put the notification logic into a
separate function.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    | 63 +++++++++++++---------
 1 file changed, 37 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index 8a64542..76432a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -275,12 +275,36 @@ out_alloc:
 
 	return err;
 }
+
+static void page_notify_fail(struct mlx5_core_dev *dev, u16 func_id)
+{
+	struct mlx5_manage_pages_inbox *in;
+	struct mlx5_manage_pages_outbox out;
+	int err;
+
+	in = kzalloc(sizeof(*in), GFP_KERNEL);
+	if (!in)
+		return;
+
+	memset(&out, 0, sizeof(out));
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_MANAGE_PAGES);
+	in->hdr.opmod = cpu_to_be16(MLX5_PAGES_CANT_GIVE);
+	in->func_id = cpu_to_be16(func_id);
+	err = mlx5_cmd_exec(dev, in, sizeof(*in), &out, sizeof(out));
+	if (!err)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+	if (err)
+		mlx5_core_warn(dev, "page notify failed\n");
+
+	kfree(in);
+}
+
 static int give_pages(struct mlx5_core_dev *dev, u16 func_id, int npages,
 		      int notify_fail)
 {
 	struct mlx5_manage_pages_inbox *in;
 	struct mlx5_manage_pages_outbox out;
-	struct mlx5_manage_pages_inbox *nin;
 	int inlen;
 	u64 addr;
 	int err;
@@ -289,8 +313,9 @@ static int give_pages(struct mlx5_core_dev *dev, u16 func_id, int npages,
 	inlen = sizeof(*in) + npages * sizeof(in->pas[0]);
 	in = mlx5_vzalloc(inlen);
 	if (!in) {
+		err = -ENOMEM;
 		mlx5_core_warn(dev, "vzalloc failed %d\n", inlen);
-		return -ENOMEM;
+		goto out_free;
 	}
 	memset(&out, 0, sizeof(out));
 
@@ -316,43 +341,29 @@ retry:
 	if (err) {
 		mlx5_core_warn(dev, "func_id 0x%x, npages %d, err %d\n",
 			       func_id, npages, err);
-		goto out_alloc;
+		goto out_4k;
 	}
 	dev->priv.fw_pages += npages;
 
-	if (out.hdr.status) {
-		err = mlx5_cmd_status_to_err(&out.hdr);
-		if (err) {
-			mlx5_core_warn(dev, "func_id 0x%x, npages %d, status %d\n",
-				       func_id, npages, out.hdr.status);
-			goto out_alloc;
-		}
+	err = mlx5_cmd_status_to_err(&out.hdr);
+	if (err) {
+		mlx5_core_warn(dev, "func_id 0x%x, npages %d, status %d\n",
+			       func_id, npages, out.hdr.status);
+		goto out_4k;
 	}
 
 	mlx5_core_dbg(dev, "err %d\n", err);
 
-	goto out_free;
-
-out_alloc:
-	if (notify_fail) {
-		nin = kzalloc(sizeof(*nin), GFP_KERNEL);
-		if (!nin) {
-			mlx5_core_warn(dev, "allocation failed\n");
-			goto out_4k;
-		}
-		memset(&out, 0, sizeof(out));
-		nin->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_MANAGE_PAGES);
-		nin->hdr.opmod = cpu_to_be16(MLX5_PAGES_CANT_GIVE);
-		if (mlx5_cmd_exec(dev, nin, sizeof(*nin), &out, sizeof(out)))
-			mlx5_core_warn(dev, "page notify failed\n");
-		kfree(nin);
-	}
+	kvfree(in);
+	return 0;
 
 out_4k:
 	for (i--; i >= 0; i--)
 		free_4k(dev, be64_to_cpu(in->pas[i]));
 out_free:
 	kvfree(in);
+	if (notify_fail)
+		page_notify_fail(dev, func_id);
 	return err;
 }
 
-- 
2.3.7
