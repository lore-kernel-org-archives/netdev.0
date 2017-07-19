From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V2 net-next 01/21] net-next/hinic: Initialize hw interface
Date: Thu, 20 Jul 2017 00:27:40 +0200
Message-ID: <20170719222740.GA1755@electric-eye.fr.zoreil.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <0febc61414e7908a7c8c0c2fa7c2b06b0f7524f7.1500454998.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bc.y@huawei.com, victor.gissin@huawei.com,
        zhaochen6@huawei.com, tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0febc61414e7908a7c8c0c2fa7c2b06b0f7524f7.1500454998.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aviad Krawczyk <aviad.krawczyk@huawei.com> :
[...]
> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
> new file mode 100644
> index 0000000..fbc9de4
> --- /dev/null
> +++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
[...]
> +/**
> + * hinic_init_hwdev - Initialize the NIC HW
> + * @hwdev: the NIC HW device that is returned from the initialization
> + * @pdev: the NIC pci device
> + *
> + * Return 0 - Success, negative - Failure
> + *
> + * Initialize the NIC HW device and return a pointer to it in the first arg
> + **/

Return a pointer and use ERR_PTR / IS_ERR ?

> +int hinic_init_hwdev(struct hinic_hwdev **hwdev, struct pci_dev *pdev)
> +{
> +	struct hinic_pfhwdev *pfhwdev;
> +	struct hinic_hwif *hwif;
> +	int err;
> +
> +	hwif = devm_kzalloc(&pdev->dev, sizeof(*hwif), GFP_KERNEL);
> +	if (!hwif)
> +		return -ENOMEM;
> +
> +	err = hinic_init_hwif(hwif, pdev);
> +	if (err) {
> +		dev_err(&pdev->dev, "Failed to init HW interface\n");
> +		return err;
> +	}
> +
> +	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
> +		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
> +		err = -EFAULT;
> +		goto func_type_err;
> +	}
> +
> +	pfhwdev = devm_kzalloc(&pdev->dev, sizeof(*pfhwdev), GFP_KERNEL);
> +	if (!pfhwdev) {
> +		err = -ENOMEM;
> +		goto pfhwdev_alloc_err;

Intel, Mellanox, Broadcom, Amazon and friends use "err_xyz" labels.

Please consider using the same style.

[...]
> +void hinic_free_hwdev(struct hinic_hwdev *hwdev)
> +{
> +	struct hinic_hwif *hwif = hwdev->hwif;
> +	struct pci_dev *pdev = hwif->pdev;
> +	struct hinic_pfhwdev *pfhwdev;
> +
> +	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
> +		dev_err(&pdev->dev, "unsupported PCI Function type\n");
> +		return;
> +	}

If it succeeded in hinic_init_hwdev, how could it fail here ?

If it failed in hinic_init_hwdev, hinic_free_hwdev should not even
be called.

-> remove ?

[...]
> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
> new file mode 100644
> index 0000000..c61c769
> --- /dev/null
> +++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
[...]
> +static void hinic_remove(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct hinic_dev *nic_dev;
> +
> +	if (!netdev)
> +		return;

Your driver is flawed if this test can ever succeed.

[...]
> +static int __init hinic_init(void)
> +{
> +	return pci_register_driver(&hinic_driver);
> +}
> +
> +static void __exit hinic_exit(void)
> +{
> +	pci_unregister_driver(&hinic_driver);
> +}

Use module_pci_driver(hinic_driver).

Remove hinic_init() and hinic_exit().

> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_pci_id_tbl.h b/drivers/net/ethernet/huawei/hinic/hinic_pci_id_tbl.h
> new file mode 100644
> index 0000000..1d92617
> --- /dev/null
> +++ b/drivers/net/ethernet/huawei/hinic/hinic_pci_id_tbl.h
[...]
> +#ifndef HINIC_PCI_ID_TBL_H
> +#define HINIC_PCI_ID_TBL_H
> +
> +#ifndef PCI_VENDOR_ID_HUAWEI
> +#define PCI_VENDOR_ID_HUAWEI            0x19e5
> +#endif

Useless: it duplicates include/linux/pci_ids.h

> +
> +#ifndef PCI_DEVICE_ID_HI1822_PF
> +#define PCI_DEVICE_ID_HI1822_PF         0x1822
> +#endif

Please move it to the .c file where it is actually used.


Extra:

grep -E 'void\ \*' drivers/net/ethernet/huawei/hinic/* makes me nervous.

At some point one function will be fed with a wrong pointer and the
compiler won't notice it.

For instance hinic_sq_read_wqe is only called with &skb. There's no
reason to declare it using a 'void **' argument.

-- 
Ueimor
