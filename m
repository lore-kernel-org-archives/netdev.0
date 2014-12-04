From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 02/10] net/mlx4_core: Mask out host side virtualization features for guests
Date: Thu,  4 Dec 2014 15:13:47 +0200
Message-ID: <1417698835-11050-3-git-send-email-ogerlitz@mellanox.com>
References: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55013 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751370AbaLDNOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 08:14:00 -0500
In-Reply-To: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VFs (guests in this context) issue the QUERY_DEV_CAP command, they
need not be told that host side virtualization features such as VST, FSM
(MAC anti-spoofing) and running > 80 VFs are supported by the device.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 4251f81..8c9ea70 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -982,7 +982,7 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	u64	flags;
 	int	err = 0;
 	u8	field;
-	u32	bmme_flags;
+	u32	bmme_flags, field32;
 	int	real_port;
 	int	slave_port;
 	int	first_port;
@@ -1053,6 +1053,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field &= ~0x80;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET);
 
+	/* turn off host side virt features (VST, FSM, etc) for guests */
+	MLX4_GET(field32, outbox->buf, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
+	field32 &= ~((1 << 26) | (1 << 21) | (1 << 20));
+	MLX4_PUT(outbox->buf, field32, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
+
 	return 0;
 }
 
-- 
1.7.1
