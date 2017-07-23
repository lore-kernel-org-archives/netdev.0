From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V2 net-next 01/21] net-next/hinic: Initialize hw interface
Date: Sun, 23 Jul 2017 13:30:53 +0300
Message-ID: <33fbbf34-cdbe-81a8-dc33-2cd6cb6cf4ee@huawei.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <0febc61414e7908a7c8c0c2fa7c2b06b0f7524f7.1500454998.git.aviad.krawczyk@huawei.com>
 <20170719222740.GA1755@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <bc.y@huawei.com>,
        <victor.gissin@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719222740.GA1755@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

ERR_PTR / IS ERR - we will change it

err_xyz labels - we will change it according to other companies style.

hinic_free_hwdev - It is there to mark us changes for VF code. We will remove it,
it can't be failed.

hinic_remove - If insmod failed and someone calls rmmod, we will get a crash because
the resource are already free. Therefore we test if the device exists, please tell me
if you meant to something different

pci_id_tbl - will be moved to the .c file.

void* - usually void * is something to avoid.

The priv data is in type void * because the
caller can use any struct that it wants, like the priv data in Linux
(netdev, irq, tasklet, work..) -

we can change it but if we will pass different struct
in the future, we will have to change the prototype of the functions.

According to the other void *:
The wq struct is used for cmdq, sq and rq. Therefore the wqe is in type
void *. There are 4 operations get_wqe, write_wqe, read_wqe and put_wqe - there
is no option that one function will be fed with a wrong pointer because the caller
should use what it got in get_wqe function.

When something is used as multiple types, it can be used as void * or union.
Usually, I would prefer union. But, in this case if we will use union, maybe there is a chance
of using the wrong wqe type in the wrong work queue type.
Another option is to use a wrapper for each wq type operations, so only the basic wq ops will
use void *.

Then, there will be cmdq, rq, sq operations with the correct wqe type and wq operations that
will use void *.

I will be glad to hear your opinion about the preferred style and about hinic_remove issue you mentioned
above.

Thanks for your time and review,
Aviad



On 7/20/2017 1:27 AM, Francois Romieu wrote:
> Aviad Krawczyk <aviad.krawczyk@huawei.com> :
> [...]
>> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>> new file mode 100644
>> index 0000000..fbc9de4
>> --- /dev/null
>> +++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
> [...]
>> +/**
>> + * hinic_init_hwdev - Initialize the NIC HW
>> + * @hwdev: the NIC HW device that is returned from the initialization
>> + * @pdev: the NIC pci device
>> + *
>> + * Return 0 - Success, negative - Failure
>> + *
>> + * Initialize the NIC HW device and return a pointer to it in the first arg
>> + **/
> 
> Return a pointer and use ERR_PTR / IS_ERR ?
> 
>> +int hinic_init_hwdev(struct hinic_hwdev **hwdev, struct pci_dev *pdev)
>> +{
>> +	struct hinic_pfhwdev *pfhwdev;
>> +	struct hinic_hwif *hwif;
>> +	int err;
>> +
>> +	hwif = devm_kzalloc(&pdev->dev, sizeof(*hwif), GFP_KERNEL);
>> +	if (!hwif)
>> +		return -ENOMEM;
>> +
>> +	err = hinic_init_hwif(hwif, pdev);
>> +	if (err) {
>> +		dev_err(&pdev->dev, "Failed to init HW interface\n");
>> +		return err;
>> +	}
>> +
>> +	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
>> +		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
>> +		err = -EFAULT;
>> +		goto func_type_err;
>> +	}
>> +
>> +	pfhwdev = devm_kzalloc(&pdev->dev, sizeof(*pfhwdev), GFP_KERNEL);
>> +	if (!pfhwdev) {
>> +		err = -ENOMEM;
>> +		goto pfhwdev_alloc_err;
> 
> Intel, Mellanox, Broadcom, Amazon and friends use "err_xyz" labels.
> 
> Please consider using the same style.
> 
> [...]
>> +void hinic_free_hwdev(struct hinic_hwdev *hwdev)
>> +{
>> +	struct hinic_hwif *hwif = hwdev->hwif;
>> +	struct pci_dev *pdev = hwif->pdev;
>> +	struct hinic_pfhwdev *pfhwdev;
>> +
>> +	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
>> +		dev_err(&pdev->dev, "unsupported PCI Function type\n");
>> +		return;
>> +	}
> 
> If it succeeded in hinic_init_hwdev, how could it fail here ?
> 
> If it failed in hinic_init_hwdev, hinic_free_hwdev should not even
> be called.
> 
> -> remove ?
> 
> [...]
>> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
>> new file mode 100644
>> index 0000000..c61c769
>> --- /dev/null
>> +++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
> [...]
>> +static void hinic_remove(struct pci_dev *pdev)
>> +{
>> +	struct net_device *netdev = pci_get_drvdata(pdev);
>> +	struct hinic_dev *nic_dev;
>> +
>> +	if (!netdev)
>> +		return;
> 
> Your driver is flawed if this test can ever succeed.
> 
> [...]
>> +static int __init hinic_init(void)
>> +{
>> +	return pci_register_driver(&hinic_driver);
>> +}
>> +
>> +static void __exit hinic_exit(void)
>> +{
>> +	pci_unregister_driver(&hinic_driver);
>> +}
> 
> Use module_pci_driver(hinic_driver).
> 
> Remove hinic_init() and hinic_exit().
> 
>> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_pci_id_tbl.h b/drivers/net/ethernet/huawei/hinic/hinic_pci_id_tbl.h
>> new file mode 100644
>> index 0000000..1d92617
>> --- /dev/null
>> +++ b/drivers/net/ethernet/huawei/hinic/hinic_pci_id_tbl.h
> [...]
>> +#ifndef HINIC_PCI_ID_TBL_H
>> +#define HINIC_PCI_ID_TBL_H
>> +
>> +#ifndef PCI_VENDOR_ID_HUAWEI
>> +#define PCI_VENDOR_ID_HUAWEI            0x19e5
>> +#endif
> 
> Useless: it duplicates include/linux/pci_ids.h
> 
>> +
>> +#ifndef PCI_DEVICE_ID_HI1822_PF
>> +#define PCI_DEVICE_ID_HI1822_PF         0x1822
>> +#endif
> 
> Please move it to the .c file where it is actually used.
> 
> 
> Extra:
> 
> grep -E 'void\ \*' drivers/net/ethernet/huawei/hinic/* makes me nervous.
> 
> At some point one function will be fed with a wrong pointer and the
> compiler won't notice it.
> 
> For instance hinic_sq_read_wqe is only called with &skb. There's no
> reason to declare it using a 'void **' argument.
> 
