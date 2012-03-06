From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 5/8] net/mlx4: fixing sparse warnings when copying
 mac, address to gid entry
Date: Tue, 6 Mar 2012 16:04:26 +0200
Message-ID: <4F56196A.6040203@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:60767 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1030696Ab2CFOEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:04:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

The mac should be written as __be64 the gid. The warning was because
we changed the mac parameter, which is u64, by writing result of cpu_to_be64
into it. Fixing by using new variable of type __be64.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 575839d..98e7762 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -79,13 +79,14 @@ static int mlx4_uc_steer_add(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 {
 	struct mlx4_qp qp;
 	u8 gid[16] = {0};
+	__be64 be_mac;
 	int err;
 
 	qp.qpn = *qpn;
 
 	mac &= 0xffffffffffffULL;
-	mac = cpu_to_be64(mac << 16);
-	memcpy(&gid[10], &mac, ETH_ALEN);
+	be_mac = cpu_to_be64(mac << 16);
+	memcpy(&gid[10], &be_mac, ETH_ALEN);
 	gid[5] = port;
 
 	err = mlx4_unicast_attach(dev, &qp, gid, 0, MLX4_PROT_ETH);
@@ -100,11 +101,12 @@ static void mlx4_uc_steer_release(struct mlx4_dev *dev, u8 port,
 {
 	struct mlx4_qp qp;
 	u8 gid[16] = {0};
+	__be64 be_mac;
 
 	qp.qpn = qpn;
 	mac &= 0xffffffffffffULL;
-	mac = cpu_to_be64(mac << 16);
-	memcpy(&gid[10], &mac, ETH_ALEN);
+	be_mac = cpu_to_be64(mac << 16);
+	memcpy(&gid[10], &be_mac, ETH_ALEN);
 	gid[5] = port;
 
 	mlx4_unicast_detach(dev, &qp, gid, MLX4_PROT_ETH);
-- 
1.7.7
