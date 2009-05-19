From: Chaitanya Lala <clala@riverbed.com>
Subject: Re: [net-next PATCH 1/1] e1000e: Expose MDI-X state via sysfs
Date: Tue, 19 May 2009 15:22:30 -0700
Message-ID: <4A133126.10608@riverbed.com>
References: <20090519210553.GA2491@clala-laptop> <9929d2390905191455i3103ead3p13c0b4c51be29b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:42100 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbZESWWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:22:00 -0400
In-Reply-To: <9929d2390905191455i3103ead3p13c0b4c51be29b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> On Tue, May 19, 2009 at 2:05 PM, Chaitanya Lala <clala@riverbed.com> wrote:
>   
>> While debugging network connectivity problems, it is often helpful
>> to report the MDI-X state. The is_mdix variable holds the current
>> state which we expose on a per-interface basis as a sysfs attribute.
>> We use sysfs over methods such as netlink due to the convenience of
>> reading a file (using the cat command) as opposed to connecting to a
>> netlink socket. If we use a fiber PHY then is_mdix will always be zero
>> as the mdi-x feature only applies to copper PHYs.
>>
>> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
>> Signed-off-by: Arthur Jones <ajones@riverbed.com>
>> ---
>>     
>
> NAK.  We do not want to be adding sysfs entries for every little piece
> of information in the driver.  Instead, I would suggest looking at
> enhancing existing tools like ethtool to get that sort of information
> in a more generic way which is not driver specific.
>
>   
The MDI-X setting is a non-standard piece of information & every driver 
may or may-not have it. But still this is an important de-bugging tool & 
we would want to use this information from the drivers that do provide 
this facility.  So what would be a standard way to do this via something 
like ethtool ? Any pointers would be helpful.

Thanks,
Chaitanya
>>  drivers/net/e1000e/netdev.c |   35 +++++++++++++++++++++++++++++++++++
>>  1 files changed, 35 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
>> index ccaaee0..1c131b6 100644
>> --- a/drivers/net/e1000e/netdev.c
>> +++ b/drivers/net/e1000e/netdev.c
>> @@ -4765,6 +4765,32 @@ static const struct net_device_ops e1000e_netdev_ops = {
>>  #endif
>>  };
>>
>> +static ssize_t e1000e_show_is_mdix(struct device *dev,
>> +    struct device_attribute *attr, char *buf)
>> +{
>> +       struct net_device *netdev = container_of(dev, struct net_device, dev);
>> +       struct e1000_adapter *adapter;
>> +       struct e1000_hw *hw;
>> +       ssize_t ret = -EINVAL;
>> +
>> +       if (!buf)
>> +               goto err;
>> +
>> +       read_lock(&dev_base_lock);
>> +       if (NETREG_REGISTERED == netdev->reg_state) {
>> +               adapter = netdev_priv(netdev);
>> +               hw = &adapter->hw;
>> +               ret = sprintf(buf, "%d\n", (hw->phy.is_mdix ? 1 : 0));
>> +       }
>> +       read_unlock(&dev_base_lock);
>> +err:
>> +       return ret;
>> +}
>> +
>> +/* Export attributes for the device */
>> +static struct device_attribute device_attr_is_mdix =
>> +    __ATTR(is_mdix, S_IRUGO, e1000e_show_is_mdix, NULL);
>> +
>>  /**
>>  * e1000_probe - Device Initialization Routine
>>  * @pdev: PCI device information struct
>> @@ -5046,6 +5072,10 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>>        if (err)
>>                goto err_register;
>>
>> +       err = device_create_file(&netdev->dev, &device_attr_is_mdix);
>> +       if (err)
>> +               goto err_sys_attr;
>> +
>>        /* carrier off reporting is important to ethtool even BEFORE open */
>>        netif_carrier_off(netdev);
>>
>> @@ -5053,6 +5083,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>>
>>        return 0;
>>
>> +err_sys_attr:
>> +       unregister_netdev(netdev);
>> +
>>  err_register:
>>        if (!(adapter->flags & FLAG_HAS_AMT))
>>                e1000_release_hw_control(adapter);
>> @@ -5105,6 +5138,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
>>
>>        flush_scheduled_work();
>>
>> +       device_remove_file(&netdev->dev, &device_attr_is_mdix);
>> +
>>        /*
>>         * Release control of h/w to f/w.  If f/w is AMT enabled, this
>>         * would have already happened in close and is redundant.
>> --
>> 1.6.0.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>     
>
>
>
>   

