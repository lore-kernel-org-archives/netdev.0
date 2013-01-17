From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_core: Set number of msix vectors under SRIOV mode to firmware defaults
Date: Thu, 17 Jan 2013 17:30:43 +0200
Message-ID: <1358436643-1326-3-git-send-email-ogerlitz@mellanox.com>
References: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:34821 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755930Ab3AQPa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:30:57 -0500
In-Reply-To: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lines

	if (mlx4_is_mfunc(dev)) {
		nreq = 2;
	} else {

which hard code the number of requested msi-x vectors under multi-function
mode to two can be removed completely, since the firmware sets num_eqs and
reserved_eqs appropriately Thus, the code line:

	nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs, nreq);

is by itself sufficient and correct for all cases. Currently, for mfunc
mode num_eqs = 32 and reserved_eqs = 28, hence four vectors will be enabled.

This triples (one vector is used for the async events and commands EQ) the
horse power provided for processing of incoming packets on netdev RSS scheme,
IO initiators/targets commands processing flows, etc.

Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index e1bafff..a6542d7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1790,15 +1790,8 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	int i;
 
 	if (msi_x) {
-		/* In multifunction mode each function gets 2 msi-X vectors
-		 * one for data path completions anf the other for asynch events
-		 * or command completions */
-		if (mlx4_is_mfunc(dev)) {
-			nreq = 2;
-		} else {
-			nreq = min_t(int, dev->caps.num_eqs -
-				     dev->caps.reserved_eqs, nreq);
-		}
+		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
+			     nreq);
 
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
-- 
1.7.1
