From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_core: Disable BF when write combining is not available
Date: Wed,  1 Oct 2014 17:54:42 +0300
Message-ID: <1412175282-25212-3-git-send-email-ogerlitz@mellanox.com>
References: <1412175282-25212-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moshe Lazer <moshel@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39568 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751976AbaJAOyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 10:54:51 -0400
In-Reply-To: <1412175282-25212-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@mellanox.com>

In mlx4 for better latency, we write send descriptors to a write-combining
(WC) mapped buffer instead of ringing a doorbell and having the HW fetch
the descriptor from system memory.

However, if write-combining is not supported on the host, then we
obtain better latency by using the doorbell-ring/HW fetch mechanism.

The mechanism that uses WC is called Blue-Flame (BF). BF is beneficial
only when the system supports write combining. When the BF buffer is
mapped as a write-combine buffer, the HCA receives data in multi-word
bursts. However, if the BF buffer is mapped only as non-cached, the
HCA receives data in individual dword chunks, which harms performance.

Therefore, disable blueflame when write combining is not available.

Signed-off-by: Moshe Lazer <moshel@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 2e88a23..f7bb548 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -671,7 +671,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->min_page_sz = 1 << field;
 
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_BF_OFFSET);
-	if (field & 0x80) {
+	if ((field & 0x80) && writecombine_available()) {
 		MLX4_GET(field, outbox, QUERY_DEV_CAP_LOG_BF_REG_SZ_OFFSET);
 		dev_cap->bf_reg_size = 1 << (field & 0x1f);
 		MLX4_GET(field, outbox, QUERY_DEV_CAP_LOG_MAX_BF_REGS_PER_PAGE_OFFSET);
-- 
1.7.1
