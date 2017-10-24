From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 4/7] mlxsw: pci: Add support for performing bus reset
Date: Tue, 24 Oct 2017 11:22:42 +0200
Message-ID: <20171024092245.1386-5-jiri@resnulli.us>
References: <20171024092245.1386-1-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:51353 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751769AbdJXJWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:51 -0400
Received: by mail-wr0-f194.google.com with SMTP id j15so7807320wre.8
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:50 -0700 (PDT)
In-Reply-To: <20171024092245.1386-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This is a preparation stage before introducing hot reload. During the
reload process the ASIC should be resetted by accessing the PCI BAR due
to unavailability of the mailbox/emad interfaces.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h |  1 +
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 56 +++++++++++++++++++++++-------
 2 files changed, 44 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 6e966af..34dda96 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -332,6 +332,7 @@ struct mlxsw_bus {
 		    const struct mlxsw_config_profile *profile,
 		    struct mlxsw_res *res);
 	void (*fini)(void *bus_priv);
+	void (*reset)(void *bus_priv);
 	bool (*skb_transmit_busy)(void *bus_priv,
 				  const struct mlxsw_tx_info *tx_info);
 	int (*skb_transmit)(void *bus_priv, struct sk_buff *skb,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 23f7d82..00c9155 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -154,6 +154,7 @@ struct mlxsw_pci {
 		} comp;
 	} cmd;
 	struct mlxsw_bus_info bus_info;
+	const struct pci_device_id *id;
 };
 
 static void mlxsw_pci_queue_tasklet_schedule(struct mlxsw_pci_queue *q)
@@ -1622,16 +1623,6 @@ static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
 	return err;
 }
 
-static const struct mlxsw_bus mlxsw_pci_bus = {
-	.kind			= "pci",
-	.init			= mlxsw_pci_init,
-	.fini			= mlxsw_pci_fini,
-	.skb_transmit_busy	= mlxsw_pci_skb_transmit_busy,
-	.skb_transmit		= mlxsw_pci_skb_transmit,
-	.cmd_exec		= mlxsw_pci_cmd_exec,
-	.features		= MLXSW_BUS_F_TXRX,
-};
-
 static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci,
 			      const struct pci_device_id *id)
 {
@@ -1655,6 +1646,44 @@ static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci,
 	return 0;
 }
 
+static void mlxsw_pci_free_irq_vectors(struct mlxsw_pci *mlxsw_pci)
+{
+	pci_free_irq_vectors(mlxsw_pci->pdev);
+}
+
+static int mlxsw_pci_alloc_irq_vectors(struct mlxsw_pci *mlxsw_pci)
+{
+	int err;
+
+	err = pci_alloc_irq_vectors(mlxsw_pci->pdev, 1, 1, PCI_IRQ_MSIX);
+	if (err < 0) {
+		dev_err(&mlxsw_pci->pdev->dev, "MSI-X init failed\n");
+		return err;
+	}
+
+	return 0;
+}
+
+static void mlxsw_pci_reset(void *bus_priv)
+{
+	struct mlxsw_pci *mlxsw_pci = bus_priv;
+
+	mlxsw_pci_free_irq_vectors(mlxsw_pci);
+	mlxsw_pci_sw_reset(mlxsw_pci, mlxsw_pci->id);
+	mlxsw_pci_alloc_irq_vectors(mlxsw_pci);
+}
+
+static const struct mlxsw_bus mlxsw_pci_bus = {
+	.kind			= "pci",
+	.init			= mlxsw_pci_init,
+	.fini			= mlxsw_pci_fini,
+	.skb_transmit_busy	= mlxsw_pci_skb_transmit_busy,
+	.skb_transmit		= mlxsw_pci_skb_transmit,
+	.cmd_exec		= mlxsw_pci_cmd_exec,
+	.features		= MLXSW_BUS_F_TXRX,
+	.reset			= mlxsw_pci_reset,
+};
+
 static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	const char *driver_name = pdev->driver->name;
@@ -1716,7 +1745,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_sw_reset;
 	}
 
-	err = pci_alloc_irq_vectors(pdev, 1, 1, PCI_IRQ_MSIX);
+	err = mlxsw_pci_alloc_irq_vectors(mlxsw_pci);
 	if (err < 0) {
 		dev_err(&pdev->dev, "MSI-X init failed\n");
 		goto err_msix_init;
@@ -1725,6 +1754,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	mlxsw_pci->bus_info.device_kind = driver_name;
 	mlxsw_pci->bus_info.device_name = pci_name(mlxsw_pci->pdev);
 	mlxsw_pci->bus_info.dev = &pdev->dev;
+	mlxsw_pci->id = id;
 
 	err = mlxsw_core_bus_device_register(&mlxsw_pci->bus_info,
 					     &mlxsw_pci_bus, mlxsw_pci);
@@ -1736,7 +1766,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_bus_device_register:
-	pci_free_irq_vectors(mlxsw_pci->pdev);
+	mlxsw_pci_free_irq_vectors(mlxsw_pci);
 err_msix_init:
 err_sw_reset:
 	iounmap(mlxsw_pci->hw_addr);
@@ -1756,7 +1786,7 @@ static void mlxsw_pci_remove(struct pci_dev *pdev)
 	struct mlxsw_pci *mlxsw_pci = pci_get_drvdata(pdev);
 
 	mlxsw_core_bus_device_unregister(mlxsw_pci->core);
-	pci_free_irq_vectors(mlxsw_pci->pdev);
+	mlxsw_pci_free_irq_vectors(mlxsw_pci);
 	iounmap(mlxsw_pci->hw_addr);
 	pci_release_regions(mlxsw_pci->pdev);
 	pci_disable_device(mlxsw_pci->pdev);
-- 
2.9.5
