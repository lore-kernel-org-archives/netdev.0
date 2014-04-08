From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [Patch net-next] net/mlx4_core: match pci_device_id including
 dynids
Date: Tue, 8 Apr 2014 09:52:08 +0300
Message-ID: <53439C98.8090202@mellanox.com>
References: <1396750050-7183-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <yevgenyp@mellanox.com>, <amirv@mellanox.com>,
	<bhelgaas@google.com>, <linux-pci@vger.kernel.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1396750050-7183-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/2014 05:07, Wei Yang wrote:
> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
> pci_device_id.driver_data to __mlx4_init_one during reset".
>
> pci_match_id() just match the static pci_device_id, which may return NULL if
> someone binds the driver to a device manually using
> /sys/bus/pci/drivers/.../new_id.
>
> This patch wrap up a helper function __mlx4_remove_one() which does the tear
> down function but preserve the drv_data. Functions like
> mlx4_pci_err_detected() and mlx4_restart_one() will call this one with out
> releasing drvdata.
>
> Tested on ConnectX-3.
>
> CC: Bjorn Helgaas <bhelgaas@google.com>
> CC: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/main.c |  165 +++++++++++++++--------------
>   1 file changed, 88 insertions(+), 77 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index aa54ef7..9dd23e0 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2268,13 +2268,8 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
>   	/* Allow large DMA segments, up to the firmware limit of 1 GB */
>   	dma_set_max_seg_size(&pdev->dev, 1024 * 1024 * 1024);
>   
> -	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> -	if (!priv) {
> -		err = -ENOMEM;
> -		goto err_release_regions;
> -	}
> -
> -	dev       = &priv->dev;
> +	dev       = pci_get_drvdata(pdev);
> +	priv      = mlx4_priv(dev);
>   	dev->pdev = pdev;
>   	INIT_LIST_HEAD(&priv->ctx_list);
>   	spin_lock_init(&priv->ctx_lock);

Here are some comments from Jack, please make sure to CC Jack 
Morgenstein <jackm@dev.mellanox.co.il>
on V2 of the patch -->

There is a change in behavior here, which I am concerned about.
Before this patch, __mlx4_init_one() allocated a zeroed-out structure
for priv, in all circumstances.

Now, this structure is passed "dirty" to __mlx4_init_one from some
flows (e.g., mlx4_restart_one).
There may, in fact, be fields in the structure which should be "zeroed
out" and are not, because previously there was no reason to be strict
about this.

Add a line with

memset(priv, 0, sizeof(*priv));


after setting the priv variable above

and also do NOT remove the following line:

- priv->pci_dev_data = pci_dev_data;
