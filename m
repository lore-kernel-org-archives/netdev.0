From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 4/8] net/mlx5e: Properly enforce disallowing of partial field re-write offload
Date: Tue, 23 May 2017 17:16:06 +0300
Message-ID: <20170523141610.27833-5-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44678 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936349AbdEWOQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:31 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Currently we don't support partial header re-writes through TC pedit
action offloading. However, the code that enforces that wasn't err-ing
on cases where the first and last bits of the mask are set but there is
some zero bit between them, such as in the below example, fix that!

tc filter add dev enp1s0 protocol ip parent ffff: prio 10 flower
	ip_proto udp dst_port 2001 skip_sw
	action pedit munge ip src set 1.0.0.1 retain 0xff0000ff

Fixes: d79b6df6b10a ('net/mlx5e: Add parsing of TC pedit actions to HW format')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 9dd83c7e4c51..0387c321f0a2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -926,7 +926,7 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 				struct mlx5e_tc_flow_parse_attr *parse_attr)
 {
 	struct pedit_headers *set_masks, *add_masks, *set_vals, *add_vals;
-	int i, action_size, nactions, max_actions, first, last;
+	int i, action_size, nactions, max_actions, first, last, first_z;
 	void *s_masks_p, *a_masks_p, *vals_p;
 	u32 s_mask, a_mask, val;
 	struct mlx5_fields *f;
@@ -985,9 +985,10 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 		memcpy(&val, vals_p, f->size);
 
 		field_bsize = f->size * BITS_PER_BYTE;
+		first_z = find_first_zero_bit(&mask, field_bsize);
 		first = find_first_bit(&mask, field_bsize);
 		last  = find_last_bit(&mask, field_bsize);
-		if (first > 0 || last != (field_bsize - 1)) {
+		if (first > 0 || last != (field_bsize - 1) || first_z < last) {
 			printk(KERN_WARNING "mlx5: partial rewrite (mask %lx) is currently not offloaded\n",
 			       mask);
 			return -EOPNOTSUPP;
-- 
2.11.0
