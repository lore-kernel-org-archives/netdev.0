From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 6/9] net/mlx5e: Support header re-write of partial fields in TC pedit offload
Date: Sun, 11 Jun 2017 17:55:50 +0300
Message-ID: <20170611145553.14180-7-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46660 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751966AbdFKO4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:14 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Using a per field mask field, the TC pedit action supports modifying
partial fields. E.g if using the TC tool, the following example would
make the kernel to only re-write two bytes of the src ip address:

tc filter add dev enp1s0 protocol ip parent ffff: prio 30
	flower skip_sw ip_proto udp dst_port 8001
	action pedit ex munge ip src set 10.1.0.0 retain 0xffff0000

We add driver support for offload these partial re-writes, by setting
the per FW action offset-in-field and length-from-offset attributes.

The 1st bit set in the mask specifies both the offset and the right
shift to apply on the value such that the 1st bit which needs to be
set will reside in bit 0 of the FW data field.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 28 +++++++++++++++++--------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 0c7a0872b22b..f5afacfbe914 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1091,12 +1091,14 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 				struct mlx5e_tc_flow_parse_attr *parse_attr)
 {
 	struct pedit_headers *set_masks, *add_masks, *set_vals, *add_vals;
-	int i, action_size, nactions, max_actions, first, last, first_z;
+	int i, action_size, nactions, max_actions, first, last, next_z;
 	void *s_masks_p, *a_masks_p, *vals_p;
 	struct mlx5_fields *f;
 	u8 cmd, field_bsize;
 	u32 s_mask, a_mask;
 	unsigned long mask;
+	__be32 mask_be32;
+	__be16 mask_be16;
 	void *action;
 
 	set_masks = &masks[TCA_PEDIT_KEY_EX_CMD_SET];
@@ -1150,11 +1152,19 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 
 		field_bsize = f->size * BITS_PER_BYTE;
 
-		first_z = find_first_zero_bit(&mask, field_bsize);
+		if (field_bsize == 32) {
+			mask_be32 = *(__be32 *)&mask;
+			mask = (__force unsigned long)cpu_to_le32(be32_to_cpu(mask_be32));
+		} else if (field_bsize == 16) {
+			mask_be16 = *(__be16 *)&mask;
+			mask = (__force unsigned long)cpu_to_le16(be16_to_cpu(mask_be16));
+		}
+
 		first = find_first_bit(&mask, field_bsize);
+		next_z = find_next_zero_bit(&mask, field_bsize, first);
 		last  = find_last_bit(&mask, field_bsize);
-		if (first > 0 || last != (field_bsize - 1) || first_z < last) {
-			printk(KERN_WARNING "mlx5: partial rewrite (mask %lx) is currently not offloaded\n",
+		if (first < next_z && next_z < last) {
+			printk(KERN_WARNING "mlx5: rewrite of few sub-fields (mask %lx) isn't offloaded\n",
 			       mask);
 			return -EOPNOTSUPP;
 		}
@@ -1163,17 +1173,17 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 		MLX5_SET(set_action_in, action, field, f->field);
 
 		if (cmd == MLX5_ACTION_TYPE_SET) {
-			MLX5_SET(set_action_in, action, offset, 0);
+			MLX5_SET(set_action_in, action, offset, first);
 			/* length is num of bits to be written, zero means length of 32 */
-			MLX5_SET(set_action_in, action, length, field_bsize);
+			MLX5_SET(set_action_in, action, length, (last - first + 1));
 		}
 
 		if (field_bsize == 32)
-			MLX5_SET(set_action_in, action, data, ntohl(*(__be32 *)vals_p));
+			MLX5_SET(set_action_in, action, data, ntohl(*(__be32 *)vals_p) >> first);
 		else if (field_bsize == 16)
-			MLX5_SET(set_action_in, action, data, ntohs(*(__be16 *)vals_p));
+			MLX5_SET(set_action_in, action, data, ntohs(*(__be16 *)vals_p) >> first);
 		else if (field_bsize == 8)
-			MLX5_SET(set_action_in, action, data, *(u8 *)vals_p);
+			MLX5_SET(set_action_in, action, data, *(u8 *)vals_p >> first);
 
 		action += action_size;
 		nactions++;
-- 
2.11.0
