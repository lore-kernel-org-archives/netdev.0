From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_core: Cache line EQE size support
Date: Thu, 18 Sep 2014 11:51:00 +0300
Message-ID: <1411030261-12145-3-git-send-email-ogerlitz@mellanox.com>
References: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45083 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754887AbaIRIvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 04:51:07 -0400
In-Reply-To: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Enable mlx4 interrupt handler to work with EQE stride feature,
The feature may be enabled when cache line is bigger than 64B.
The EQE size will then be the cache line size, and the context
segment resides in [0-31] offset.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 2a004b3..a49c9d1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -101,21 +101,24 @@ static void eq_set_ci(struct mlx4_eq *eq, int req_not)
 	mb();
 }
 
-static struct mlx4_eqe *get_eqe(struct mlx4_eq *eq, u32 entry, u8 eqe_factor)
+static struct mlx4_eqe *get_eqe(struct mlx4_eq *eq, u32 entry, u8 eqe_factor,
+				u8 eqe_size)
 {
 	/* (entry & (eq->nent - 1)) gives us a cyclic array */
-	unsigned long offset = (entry & (eq->nent - 1)) * (MLX4_EQ_ENTRY_SIZE << eqe_factor);
-	/* CX3 is capable of extending the EQE from 32 to 64 bytes.
-	 * When this feature is enabled, the first (in the lower addresses)
+	unsigned long offset = (entry & (eq->nent - 1)) * eqe_size;
+	/* CX3 is capable of extending the EQE from 32 to 64 bytes with
+	 * strides of 64B,128B and 256B.
+	 * When 64B EQE is used, the first (in the lower addresses)
 	 * 32 bytes in the 64 byte EQE are reserved and the next 32 bytes
 	 * contain the legacy EQE information.
+	 * In all other cases, the first 32B contains the legacy EQE info.
 	 */
 	return eq->page_list[offset / PAGE_SIZE].buf + (offset + (eqe_factor ? MLX4_EQ_ENTRY_SIZE : 0)) % PAGE_SIZE;
 }
 
-static struct mlx4_eqe *next_eqe_sw(struct mlx4_eq *eq, u8 eqe_factor)
+static struct mlx4_eqe *next_eqe_sw(struct mlx4_eq *eq, u8 eqe_factor, u8 size)
 {
-	struct mlx4_eqe *eqe = get_eqe(eq, eq->cons_index, eqe_factor);
+	struct mlx4_eqe *eqe = get_eqe(eq, eq->cons_index, eqe_factor, size);
 	return !!(eqe->owner & 0x80) ^ !!(eq->cons_index & eq->nent) ? NULL : eqe;
 }
 
@@ -459,8 +462,9 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 	enum slave_port_gen_event gen_event;
 	unsigned long flags;
 	struct mlx4_vport_state *s_info;
+	int eqe_size = dev->caps.eqe_size;
 
-	while ((eqe = next_eqe_sw(eq, dev->caps.eqe_factor))) {
+	while ((eqe = next_eqe_sw(eq, dev->caps.eqe_factor, eqe_size))) {
 		/*
 		 * Make sure we read EQ entry contents after we've
 		 * checked the ownership bit.
@@ -894,8 +898,10 @@ static int mlx4_create_eq(struct mlx4_dev *dev, int nent,
 
 	eq->dev   = dev;
 	eq->nent  = roundup_pow_of_two(max(nent, 2));
-	/* CX3 is capable of extending the CQE/EQE from 32 to 64 bytes */
-	npages = PAGE_ALIGN(eq->nent * (MLX4_EQ_ENTRY_SIZE << dev->caps.eqe_factor)) / PAGE_SIZE;
+	/* CX3 is capable of extending the CQE/EQE from 32 to 64 bytes, with
+	 * strides of 64B,128B and 256B.
+	 */
+	npages = PAGE_ALIGN(eq->nent * dev->caps.eqe_size) / PAGE_SIZE;
 
 	eq->page_list = kmalloc(npages * sizeof *eq->page_list,
 				GFP_KERNEL);
@@ -997,8 +1003,10 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 	struct mlx4_cmd_mailbox *mailbox;
 	int err;
 	int i;
-	/* CX3 is capable of extending the CQE/EQE from 32 to 64 bytes */
-	int npages = PAGE_ALIGN((MLX4_EQ_ENTRY_SIZE << dev->caps.eqe_factor) * eq->nent) / PAGE_SIZE;
+	/* CX3 is capable of extending the CQE/EQE from 32 to 64 bytes, with
+	 * strides of 64B,128B and 256B
+	 */
+	int npages = PAGE_ALIGN(dev->caps.eqe_size  * eq->nent) / PAGE_SIZE;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
-- 
1.7.1
