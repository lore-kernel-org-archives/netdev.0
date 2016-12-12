From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net:phy fix driver reference count error when attach and
 detach phy device
Date: Mon, 12 Dec 2016 08:33:24 -0800
Message-ID: <c4fce3bf-4105-c7f2-fc67-be4316a2004a@gmail.com>
References: <1480501378-10172-1-git-send-email-maowenan@huawei.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0232613@AcuExch.aculab.com>
 <0cef0798-7b0d-734d-17a3-bebffe6206c7@huawei.com>
 <7902ba31-de5d-27cf-f631-4a88a78b246f@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: maowenan <maowenan@huawei.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dingtianhong@huawei.com" <dingtianhong@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36023 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752831AbcLLQd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:33:26 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so1439275pgx.3
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 08:33:26 -0800 (PST)
In-Reply-To: <7902ba31-de5d-27cf-f631-4a88a78b246f@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2016 12:49 AM, maowenan wrote:
> 
> 
> On 2016/12/5 16:47, maowenan wrote:
>>
>>
>> On 2016/12/2 17:45, David Laight wrote:
>>> From: Mao Wenan
>>>> Sent: 30 November 2016 10:23
>>>> The nic in my board use the phy dev from marvell, and the system will
>>>> load the marvell phy driver automatically, but when I remove the phy
>>>> drivers, the system immediately panic:
>>>> Call trace:
>>>> [ 2582.834493] [<ffff800000715384>] phy_state_machine+0x3c/0x438 [
>>>> 2582.851754] [<ffff8000000db3b8>] process_one_work+0x150/0x428 [
>>>> 2582.868188] [<ffff8000000db7d4>] worker_thread+0x144/0x4b0 [
>>>> 2582.883882] [<ffff8000000e1d0c>] kthread+0xfc/0x110
>>>>
>>>> there should be proper reference counting in place to avoid that.
>>>> I found that phy_attach_direct() forgets to add phy device driver
>>>> reference count, and phy_detach() forgets to subtract reference count.
>>>> This patch is to fix this bug, after that panic is disappeared when remove
>>>> marvell.ko
>>>>
>>>> Signed-off-by: Mao Wenan <maowenan@huawei.com>
>>>> ---
>>>>  drivers/net/phy/phy_device.c | 7 +++++++
>>>>  1 file changed, 7 insertions(+)
>>>>
>>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>>>> index 1a4bf8a..a7ec7c2 100644
>>>> --- a/drivers/net/phy/phy_device.c
>>>> +++ b/drivers/net/phy/phy_device.c
>>>> @@ -866,6 +866,11 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>>>>  		return -EIO;
>>>>  	}
>>>>
>>>> +	if (!try_module_get(d->driver->owner)) {
>>>> +		dev_err(&dev->dev, "failed to get the device driver module\n");
>>>> +		return -EIO;
>>>> +	}
>>>
>>> If this is the phy code, what stops the phy driver being unloaded
>>> before the try_module_get() obtains a reference.
>>> If it isn't the phy driver then there ought to be a reference count obtained
>>> when the phy driver is located (by whatever decides which phy driver to use).
>>> Even if that code later releases its reference (it probably shouldn't on success)
>>> then you can't fail to get an extra reference here.
>>
>> [Mao Wenan]Yes, this is phy code, in function phy_attach_direct(), drivers/net/phy/phy_device.c.
>> when one NIC driver to do probe behavior, it will attach one matched phy driver. phy_attach_direct()
>> is to obtain phy driver reference and bind phy driver, if try_module_get() execute on success, the reference
>> count is added; if failed, the driver can't be attached to this NIC, and it can't added the phy driver
>> reference count. So before try_module_get obtains a reference, phy driver can't can't be bound to this NIC.
>> when the phy driver is attached to NIC, the reference count is added, if someone remove phy driver directly,
>> it will be failed because reference count is not equal to 0.
>>
>> An example of call trace when there is NIC driver to attch one phy driver:
>> hns_nic_dev_probe->hns_nic_try_get_ae->hns_nic_init_phy->of_phy_connect->phy_connect_direct->phy_attach_direct
>>
>> Consider the steps of phy driver(marvell.ko) added and removed, and NIC driver(hns_enet_drv.ko) added and removed:
>> 1)insmod marvell       ref=0
>> 2)insmod hns_enet_drv  ref=1
>> 3)rmmod marvell        (should not on success, ref=1)
>> 4)rmmod hns_enet_drv   ref=0
>> 5)rmmod marvell        (should on success, because ref=0)
>>
>> if we don't add the reference count in phy_attach_direct(the second step ref=0), so the third step rmmod marvell will
>> be panic, because there is one user remain use marvell driver and phy_stat_machine use the NULL drv pointer.
>>
>>>
>>>> +
>>>>  	get_device(d);
>>>>
>>>>  	/* Assume that if there is no driver, that it doesn't
>>>> @@ -921,6 +926,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>>>>
>>>>  error:
>>>>  	put_device(d);
>>>> +	module_put(d->driver->owner);
>>>
>>> Are those two in the wrong order ?
>>>
>>>>  	module_put(bus->owner);
>>>>  	return err;
>>>>  }
>>>> @@ -998,6 +1004,7 @@ void phy_detach(struct phy_device *phydev)
>>>>  	bus = phydev->mdio.bus;
>>>>
>>>>  	put_device(&phydev->mdio.dev);
>>>> +	module_put(phydev->mdio.dev.driver->owner);
>>>>  	module_put(bus->owner);
>>>
>>> Where is this code called from?
>>> You can't call it from the phy driver because the driver can be unloaded
>>> as soon as the last reference is removed.
>>> At that point the code memory is freed.
>>
>> [Mao Wenan] it is called by NIC when it is removed, which aims to disconnect one bound phy driver. If this phy driver
>> is not used for this NIC, reference count should be subtracted, and phy driver can be removed if there is no user.
>> hns_nic_dev_remove->phy_disconnect->phy_detach
>>
>>
>>
>>>
>>>>  }
>>>>  EXPORT_SYMBOL(phy_detach);
>>>> --
>>>> 2.7.0
>>>>
>>>
>>>
>>> .
>>>
> 
> @Florian Fainelli, what's your comments about this patch?

I am trying to reproduce what you are seeing, but at first glance is
looks like an appropriate solution to me. Do you mind giving me a couple
more days?

Thanks!
-- 
Florian
