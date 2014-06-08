From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_core: Keep only one driver entry release mlx4_priv
Date: Sun,  8 Jun 2014 13:49:46 +0300
Message-ID: <1402224586-21187-3-git-send-email-ogerlitz@mellanox.com>
References: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46327 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752506AbaFHKt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 06:49:57 -0400
In-Reply-To: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>

Following commit befdf89 "net/mlx4_core: Preserve pci_dev_data after
__mlx4_remove_one()", there are two mlx4 pci callbacks which will
attempt to release the mlx4_priv object -- .shutdown and .remove.

This leads to a use-after-free access to the already freed mlx4_priv
instance and trigger a "Kernel access of bad area" crash when both
.shutdown and .remove are called.

During reboot or kexec, .shutdown is called, with the VFs probed to
the host going through shutdown first and then the PF. Later, the PF
will trigger VFs' .remove since VFs still have driver attached.

Fix that by keeping only one driver entry which releases mlx4_priv.

Fixes: befdf89 ('net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()')
CC: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 19606a4..703121a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2757,7 +2757,7 @@ static struct pci_driver mlx4_driver = {
 	.name		= DRV_NAME,
 	.id_table	= mlx4_pci_table,
 	.probe		= mlx4_init_one,
-	.shutdown	= mlx4_remove_one,
+	.shutdown	= __mlx4_remove_one,
 	.remove		= mlx4_remove_one,
 	.err_handler    = &mlx4_err_handler,
 };
-- 
1.7.1
