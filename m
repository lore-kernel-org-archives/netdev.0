From: Rajib Karmakar <rajibkit@gmail.com>
Subject: Re: Multiple DSA switch on shared MII
Date: Thu, 27 Nov 2014 10:17:13 +0530
Message-ID: <CAOi_9k_3+9U4q=SHdeEJOi_efHkRvYdTQ=UBqZtafgDAv_oOHg@mail.gmail.com>
References: <CAOi_9k8NwpVFxg=9VOagVt3m6hn2uLKuCZ_0-+4PciJNRWuTmA@mail.gmail.com>
	<CAGVrzcaG_uYpmmgC252ObHJ9Cmt91-BUtB3uOfPJHV6RhkRU1Q@mail.gmail.com>
	<CAOi_9k8WySmjm5cdFn1kJQuE7cJ1rDyM9SV2RvbcmbB+UeTVdQ@mail.gmail.com>
	<547636B7.3060706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37245 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817AbaK0ErO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 23:47:14 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so4238529pab.34
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 20:47:13 -0800 (PST)
In-Reply-To: <547636B7.3060706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2014 at 1:53 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 25/11/14 23:33, Rajib Karmakar wrote:
>> Hello Florian,
>>
>> Thanks for your reply.
>>
>> On Wed, Nov 26, 2014 at 10:52 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> 2014-11-25 20:52 GMT-08:00 Rajib Karmakar <rajibkit@gmail.com>:
>>>> Hello,
>>>>
>>>> I am developing a DSA driver for Marvell 6172 and need to create 2 dsa
>>>> switch chip (one for WAN and one for LAN).
>>>
>>> This is not typically how it is designed to work, you would register
>>> one dsa switch chip with the ports assignment in this data structure.
>>> Right now, DSA does not support a dual Ethernet MAC configuration,
>>> although you could probably do per-port VLAN membership and create two
>>> default VLANs to allow that.
>>>
>>>>
>>>> My device has 2 MACs and one shared mii_bus. I have added two
>>>> dsa_platform_data structures and registered them but cannot probe as
>>>> dsa_probe tries mdio_register() on the same bus and fails.
>>>>
>>>> Is it possible to create two DSA switch on same (shared) mii?
>>>
>>> Not in its current form, and I am not exactly sure how we would support that.
>>
>> Yes, not with the current DSA implementation, but I can manage to
>> solve this by a small (ugly) patch - renamed the slave mii bus as
>> "<master_bus->id>:<pd->sw_addr>:<platform_device->id>" instead of
>> "<master_bus->id>:<pd->sw_addr>". Though I am not yet sure enough if
>> this could have any negative impact or not.
>
> This will register two virtual slave mii buses backed by the same real
> mdio bus driver, although that is not necessarily a problem, you want to
> make sure that they are not going to poll the same PHYs in the switch
> driver.
>
> This is probably the easiest way to achieve what you want, can you just
> introduce a check on the "id" being >= 0 (using -1 with platform_devices
> is valid when there is just one device in the system).
>
> Thanks!
>

yes, I handled that later. Thanks for your reply

>>
>> Comments please.
>>
>>>
>>>>
>>>> Regards,
>>>> Rajib
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>>
>>> --
>>> Florian
>>
>> ----
>> diff -rup org/net/dsa/dsa.c mod/net/dsa/dsa.c
>> --- org/net/dsa/dsa.c
>> +++ mod/net/dsa/dsa.c
>> @@ -68,7 +68,7 @@ dsa_switch_probe(struct mii_bus *bus, in
>>
>>  /* basic switch operations **************************************************/
>>  static struct dsa_switch *
>> -dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>> +dsa_switch_setup(struct dsa_switch_tree *dst, int index, int id,
>>   struct device *parent, struct mii_bus *bus)
>>  {
>>   struct dsa_chip_data *pd = dst->pd->chip + index;
>> @@ -156,7 +156,7 @@ dsa_switch_setup(struct dsa_switch_tree
>>   ret = -ENOMEM;
>>   goto out;
>>   }
>> - dsa_slave_mii_bus_init(ds);
>> + dsa_slave_mii_bus_init(ds, id);
>>
>>   ret = mdiobus_register(ds->slave_mii_bus);
>>   if (ret < 0)
>> @@ -349,7 +349,7 @@ static int dsa_probe(struct platform_dev
>>   continue;
>>   }
>>
>> - ds = dsa_switch_setup(dst, i, &pdev->dev, bus);
>> + ds = dsa_switch_setup(dst, i, pdev->id, &pdev->dev, bus);
>>   if (IS_ERR(ds)) {
>>   printk(KERN_ERR "%s[%d]: couldn't create dsa switch "
>>   "instance (error %ld)\n", dev->name, i,
>> diff -rup org/net/dsa/dsa_priv.h mod/net/dsa/dsa_priv.h
>> --- org/net/dsa/dsa_priv.h
>> +++ mod/net/dsa/dsa_priv.h
>> @@ -163,7 +163,7 @@ void register_switch_driver(struct dsa_s
>>  void unregister_switch_driver(struct dsa_switch_driver *type);
>>
>>  /* slave.c */
>> -void dsa_slave_mii_bus_init(struct dsa_switch *ds);
>> +void dsa_slave_mii_bus_init(struct dsa_switch *ds, int id);
>>  struct net_device *dsa_slave_create(struct dsa_switch *ds,
>>      struct device *parent,
>>      int port, char *name);
>> diff -rup org/net/dsa/slave.c mod/net/dsa/slave.c
>> --- org/net/dsa/slave.c
>> +++ mod/net/dsa/slave.c
>> @@ -35,14 +35,14 @@ static int dsa_slave_phy_write(struct mi
>>   return 0;
>>  }
>>
>> -void dsa_slave_mii_bus_init(struct dsa_switch *ds)
>> +void dsa_slave_mii_bus_init(struct dsa_switch *ds, int id)
>>  {
>>   ds->slave_mii_bus->priv = (void *)ds;
>>   ds->slave_mii_bus->name = "dsa slave smi";
>>   ds->slave_mii_bus->read = dsa_slave_phy_read;
>>   ds->slave_mii_bus->write = dsa_slave_phy_write;
>> - snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s:%.2x",
>> - ds->master_mii_bus->id, ds->pd->sw_addr);
>> + snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s:%.2x:%.1x",
>> + ds->master_mii_bus->id, ds->pd->sw_addr, id);
>>   ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
>>  }
>>
>
