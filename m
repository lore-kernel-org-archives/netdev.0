From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH V2 net 06/20] net/ena: fix NULL dereference when removing
 the driver after device reset faild
Date: Mon, 5 Dec 2016 20:30:44 +0200
Message-ID: <1d2c91e8-4bbe-5cbf-7d35-d682e5de6aa5@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-7-git-send-email-netanel@annapurnalabs.com>
 <20161205042915.GH4310@u54ee753d2d1854bda401.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, dwmw@amazon.com, zorik@annapurnalabs.com,
        alex@annapurnalabs.com, saeed@annapurnalabs.com, msw@amazon.com,
        aliguori@amazon.com, nafea@annapurnalabs.com
To: Matt Wilson <msw@amzn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f176.google.com ([209.85.210.176]:35127 "EHLO
        mail-wj0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752683AbcLESat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:30:49 -0500
Received: by mail-wj0-f176.google.com with SMTP id v7so298140677wjy.2
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 10:30:49 -0800 (PST)
In-Reply-To: <20161205042915.GH4310@u54ee753d2d1854bda401.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/05/2016 06:29 AM, Matt Wilson wrote:
> On Sun, Dec 04, 2016 at 03:19:24PM +0200, Netanel Belgazal wrote:
>> If for some reason the device stop responding and the device reset failed
>> to recover the device, the mmio register read datastructure will not be
>> reinitialized.
> If for some reason the device stops responding, and the device reset
> fails to recover the device, the MMIO register read data structure
> will not be reinitialized.

OK
>
>> On driver removal, the driver will also tries to reset the device
>> but this time the mmio data structure will be NULL.
> On driver removal, the driver will also try to reset the device, but
> this time the MMIO data structure will be NULL.
OK
>> To solve this issue perform the device reset in the remove function only if
>> the device is runnig.
> To solve this issue, perform the device reset in the remove function
> only if the device is running.
>
> Do you have an example of the NULL pointer dereference that you can
> paste in? It can be helpful for those searching for a fix for a bug
> they've experienced.
I'll add a crash dump.

> --msw
>
>> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
>> ---
>>   drivers/net/ethernet/amazon/ena/ena_netdev.c | 6 +++++-
>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> index 224302c..ad5f78f 100644
>> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> @@ -2516,6 +2516,8 @@ static void ena_fw_reset_device(struct work_struct *work)
>>   err:
>>   	rtnl_unlock();
>>   
>> +	clear_bit(ENA_FLAG_DEVICE_RUNNING, &adapter->flags);
>> +
>>   	dev_err(&pdev->dev,
>>   		"Reset attempt failed. Can not reset the device\n");
>>   }
>> @@ -3126,7 +3128,9 @@ static void ena_remove(struct pci_dev *pdev)
>>   
>>   	cancel_work_sync(&adapter->resume_io_task);
>>   
>> -	ena_com_dev_reset(ena_dev);
>> +	/* Reset the device only if the device is running. */
>> +	if (test_bit(ENA_FLAG_DEVICE_RUNNING, &adapter->flags))
>> +		ena_com_dev_reset(ena_dev);
>>   
>>   	ena_free_mgmnt_irq(adapter);
>>   
