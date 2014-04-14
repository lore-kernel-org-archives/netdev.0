From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 net] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Mon, 14 Apr 2014 09:50:30 +0800
Message-ID: <20140414015029.GA5374@richard>
References: <1397359333-8378-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <534A6FA2.90800@cogentembedded.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <534A6FA2.90800@cogentembedded.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 13, 2014 at 03:06:10PM +0400, Sergei Shtylyov wrote:
>Hello.

Thanks for the comments.

Changed accordingly and will send another version.

>
>On 13-04-2014 7:22, Wei Yang wrote:
>
>>pci_match_id() just match the static pci_device_id, which may return NULL if
>>someone binds the driver to a device manually using
>>/sys/bus/pci/drivers/.../new_id.
>
>>This patch wrap up a helper function __mlx4_remove_one() which does the tear
>>down function but preserve the drv_data. Functions like
>>mlx4_pci_err_detected() and mlx4_restart_one() will call this one with out
>>releasing drvdata.
>
>>Fixes: 97a5221 "net/mlx4_core: pass pci_device_id.driver_data to __mlx4_init_one during reset".
>
>>CC: Bjorn Helgaas <bhelgaas@google.com>
>>CC: Amir Vadai <amirv@mellanox.com>
>>CC: Jack Morgenstein <jackm@dev.mellanox.co.il>
>>CC: Or Gerlitz <ogerlitz@mellanox.com>
>>Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>>Acked-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>
>[...]
>
>>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>>index f0ae95f..b6d60e2 100644
>>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>[...]
>>@@ -2604,85 +2598,112 @@ err_disable_pdev:
>>
>>  static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
>>  {
>>+	struct mlx4_priv *priv;
>>+	struct mlx4_dev *dev;
>>+
>>  	printk_once(KERN_INFO "%s", mlx4_version);
>>
>>+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
>>+	if (!priv) {
>>+		return -ENOMEM;
>>+	}
>
>   {} not needed here.
>
>[...]
>>+	/* in SRIOV it is not allowed to unload the pf's
>>+	 * driver while there are alive vf's */
>>+	if (mlx4_is_master(dev)) {
>>+		if (mlx4_how_many_lives_vf(dev))
>
>   Could be folded into single *if*.
>
>>+			printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
>>+	}
>>+	mlx4_stop_sense(dev);
>>+	mlx4_unregister_device(dev);
>[...]
>>+	for (p = 1; p <= dev->caps.num_ports; p++) {
>>+		mlx4_cleanup_port_info(&priv->port[p]);
>>+		mlx4_CLOSE_PORT(dev, p);
>>+	}
>>+
>>+	if (mlx4_is_master(dev))
>>+		mlx4_free_resource_tracker(dev,
>>+				   RES_TR_FREE_SLAVES_ONLY);
>
>   Please re-align this line so that it starts right under 'dev'.
>
>[...]
>>
>>-		if (!mlx4_is_slave(dev))
>>-			mlx4_free_ownership(dev);
>>+	if (mlx4_is_master(dev))
>>+		mlx4_free_resource_tracker(dev,
>>+				   RES_TR_FREE_STRUCTS_ONLY);
>
>   Likewise.
>
>[...]
>>@@ -2755,11 +2776,13 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>>
>>  static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>>  {
>>-	const struct pci_device_id *id;
>>-	int ret;
>>+	struct mlx4_dev	 *dev  = pci_get_drvdata(pdev);
>>+	struct mlx4_priv *priv = mlx4_priv(dev);
>>+	int		  pci_dev_data;
>
>   Doesn't seem that this variable is necessary.
>
>>+	int               ret;
>>
>>-	id = pci_match_id(mlx4_pci_table, pdev);
>>-	ret = __mlx4_init_one(pdev, id->driver_data);
>>+	pci_dev_data = priv->pci_dev_data;
>>+	ret = __mlx4_init_one(pdev, pci_dev_data);
>>
>>  	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
>>  }
>[...]
>
>WBR, Sergei

-- 
Richard Yang
Help you, Help me
