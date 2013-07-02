From: Shuah Khan <shuah.kh@samsung.com>
Subject: Re: [PATCH] wireless: Convert mwifiex/pcie to dev_pm_ops from legacy
 pm ops
Date: Tue, 02 Jul 2013 19:24:25 +0000
Message-ID: <B8EFE96D1287C24090BAD9D858E15E61734462@sisaex02sj>
References: <1372778675-2909-1-git-send-email-shuah.kh@samsung.com>
 <51D32116.4010109@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "bzhao@marvell.com" <bzhao@marvell.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"rjw@sisk.pl" <rjw@sisk.pl>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shuahkhan@gmail.com" <shuahkhan@gmail.com>,
	Shuah Khan <shuah.kh@samsung.com>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02/2013 12:51 PM, Hauke Mehrtens wrote:
> On 07/02/2013 05:24 PM, Shuah Khan wrote:
>> Convert the mwifiex/pci driver to use dev_pm_ops for power management and
>> remove Legacy PM handling. This change re-uses existing suspend and resume
>> interfaces for dev_pm_ops.
>>
>> Signed-off-by: Shuah Khan <shuah.kh@samsung.com>
>> ---
>>   drivers/net/wireless/mwifiex/pcie.c |   34 ++++++++++++++++++++++++++++------
>>   1 file changed, 28 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
>> index 20c9c4c..b169318 100644
>> --- a/drivers/net/wireless/mwifiex/pcie.c
>> +++ b/drivers/net/wireless/mwifiex/pcie.c
>> @@ -85,7 +85,7 @@ static bool mwifiex_pcie_ok_to_access_hw(struct mwifiex_adapter *adapter)
>>    * If already not suspended, this function allocates and sends a host
>>    * sleep activate request to the firmware and turns off the traffic.
>>    */
>> -static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
>> +static int __mwifiex_pcie_suspend(struct pci_dev *pdev)
>>   {
>>   	struct mwifiex_adapter *adapter;
>>   	struct pcie_service_card *card;
>> @@ -112,6 +112,13 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
>>   	return 0;
>>   }
>>
>> +static int mwifiex_pcie_suspend(struct device *dev)
>> +{
>> +	struct pci_dev *pdev = to_pci_dev(dev);
>> +
>> +	return __mwifiex_pcie_suspend(pdev);
>> +}
>> +
>
> For what do you need __mwifiex_pcie_suspend() ? Why not make one
> function out of these two?

Originally, the reason is to keep __mwifiex_pcie_suspend() and 
__mwifiex_pcie_resume() parameters the same so there will be no 
confusion. However, I didn't think about using 
mwifiex_pcie_resume(&pdev->dev) as you mentioned below. Yes, I can make 
the change and not add two additional routines and send a v2 patch.

>
>>   /*
>>    * Kernel needs to suspend all functions separately. Therefore all
>>    * registered functions must have drivers with suspend and resume
>> @@ -120,7 +127,7 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
>>    * If already not resumed, this function turns on the traffic and
>>    * sends a host sleep cancel request to the firmware.
>>    */
>> -static int mwifiex_pcie_resume(struct pci_dev *pdev)
>> +static int __mwifiex_pcie_resume(struct pci_dev *pdev)
>>   {
>>   	struct mwifiex_adapter *adapter;
>>   	struct pcie_service_card *card;
>> @@ -150,6 +157,13 @@ static int mwifiex_pcie_resume(struct pci_dev *pdev)
>>
>>   	return 0;
>>   }
>> +
>> +static int mwifiex_pcie_resume(struct device *dev)
>> +{
>> +	struct pci_dev *pdev = to_pci_dev(dev);
>> +
>> +	return __mwifiex_pcie_resume(pdev);
>> +}
>>   #endif
>>
>>   /*
>> @@ -213,7 +227,7 @@ static void mwifiex_pcie_remove(struct pci_dev *pdev)
>>   	if (user_rmmod) {
>>   #ifdef CONFIG_PM
>>   		if (adapter->is_suspended)
>> -			mwifiex_pcie_resume(pdev);
>> +			__mwifiex_pcie_resume(pdev);
>
> You could use mwifiex_pcie_resume(&pdev->dev) here and then the extra
> function __mwifiex_pcie_resume() is not needed any more.

Yes. That would eliminate the need for additional routine. I didn't 
think about that option.

>
>>   #endif
>>
>>   		for (i = 0; i < adapter->priv_num; i++)
>> @@ -249,6 +263,14 @@ static DEFINE_PCI_DEVICE_TABLE(mwifiex_ids) = {
>>
>>   MODULE_DEVICE_TABLE(pci, mwifiex_ids);
>>
>> +#ifdef CONFIG_PM
>> +/* Power Management Hooks */
>> +static const struct dev_pm_ops mwifiex_pcie_pm_ops = {
>> +	.suspend = mwifiex_pcie_suspend,
>> +	.resume = mwifiex_pcie_resume,
>> +};
>> +#endif
>> +
>
> Is it intended that you do not use SIMPLE_DEV_PM_OPS() like most of the
> other wifi drivers?

So the reason for this is SIMPLE_DEV_PM_OPS() is defined only when 
CONFIG_PM_SLEEP is enabled. This driver doesn't defines suspend and 
resume when CONFIG_PM is enabled and I didn't want to change that. Hope 
that helps understand why I didn't use SIMPLE_DEV_PM_OPS()

>
>>   /* PCI Device Driver */
>>   static struct pci_driver __refdata mwifiex_pcie = {
>>   	.name     = "mwifiex_pcie",
>> @@ -256,9 +278,9 @@ static struct pci_driver __refdata mwifiex_pcie = {
>>   	.probe    = mwifiex_pcie_probe,
>>   	.remove   = mwifiex_pcie_remove,
>>   #ifdef CONFIG_PM
>> -	/* Power Management Hooks */
>> -	.suspend  = mwifiex_pcie_suspend,
>> -	.resume   = mwifiex_pcie_resume,
>> +	.driver   = {
>> +		.pm = &mwifiex_pcie_pm_ops,
>> +	},
>>   #endif
>>   };
>>
>>
>
>

-- Shuah

Shuah Khan, Linux Kernel Developer - Open Source Group Samsung Research 
America (Silicon Valley) shuah.kh@samsung.com | (970) 672-0658
