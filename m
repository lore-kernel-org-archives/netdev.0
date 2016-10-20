From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 4/4] mlxsw: pci: Fix reset wait for SwitchX2
Date: Thu, 20 Oct 2016 16:05:45 +0200
Message-ID: <1476972345-31568-5-git-send-email-jiri@resnulli.us>
References: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35668 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753299AbcJTOFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 10:05:55 -0400
Received: by mail-lf0-f66.google.com with SMTP id x79so177507lff.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 07:05:55 -0700 (PDT)
In-Reply-To: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

SwitchX2 firmware does not implement reset done yet. Moreover, when
busy-polled for ready magic, that slows down firmware and reset takes
longer than the defined timeout, causing initialization to fail.
So restore the previous behaviour and just sleep in this case.

Fixes: 233fa44bd67a ("mlxsw: pci: Implement reset done check")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index e742bd4..912f71f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1838,11 +1838,17 @@ static const struct mlxsw_bus mlxsw_pci_bus = {
 	.cmd_exec		= mlxsw_pci_cmd_exec,
 };
 
-static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci)
+static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci,
+			      const struct pci_device_id *id)
 {
 	unsigned long end;
 
 	mlxsw_pci_write32(mlxsw_pci, SW_RESET, MLXSW_PCI_SW_RESET_RST_BIT);
+	if (id->device == PCI_DEVICE_ID_MELLANOX_SWITCHX2) {
+		msleep(MLXSW_PCI_SW_RESET_TIMEOUT_MSECS);
+		return 0;
+	}
+
 	wmb(); /* reset needs to be written before we read control register */
 	end = jiffies + msecs_to_jiffies(MLXSW_PCI_SW_RESET_TIMEOUT_MSECS);
 	do {
@@ -1909,7 +1915,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	mlxsw_pci->pdev = pdev;
 	pci_set_drvdata(pdev, mlxsw_pci);
 
-	err = mlxsw_pci_sw_reset(mlxsw_pci);
+	err = mlxsw_pci_sw_reset(mlxsw_pci, id);
 	if (err) {
 		dev_err(&pdev->dev, "Software reset failed\n");
 		goto err_sw_reset;
-- 
2.5.5
