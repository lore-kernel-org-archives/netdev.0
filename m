From: Davide Rizzo <elpa.rizzo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Pegasus: Add MAC programmability
Date: Sat, 15 Aug 2009 08:18:10 +0200
Message-ID: <8447d6730908142318i2a3b8b2fx828e9601f4faea15@mail.gmail.com>
References: <8447d6730908130310n27f94e9agdfaf688c50fa90b@mail.gmail.com>
	 <e75fcab5ff0b69446555a633bdb1907d.squirrel@nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <e75fcab5ff0b69446555a633bdb1907d.squirrel-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

You're correct.
Because I produce embedded boards with ADM8515 controller, my purpose
was to program eeprom in full, without need to pre-program it before
assemblying the boards.
Writing MAC in eeprom is already protectected by a #ifdef
PEGASUS_WRITE_EEPROM (that should be normally disabled, I agree).
What about protecting the writing of other data with a nested #ifdef
PEGASUS_WRITE_EEPROM_HEADER ? Do you have eeprom datas for other
Pegasus chipsets to include in the source ? Or is there any dedicated
API I don't know about to make this job ?

2009/8/14  <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>:
> Why do you have to write def_eeprom[] to the eeprom along with the new MAC
> address?  This may work for 8515 based controllers, but will most likely
> break everything else that antedates it.
>
> The set address function should be much smaller/simpler and not writing to
> the eeprom in general.
>
>
>                  Petko
>
>
>> Added capability to set mac address and to program it into EEPROM
>>
>> Signed-off-by: Davide Rizzo <elpa.rizzo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> diff -urNp linux-2.6.30.4/drivers/net/usb/pegasus.c
>> linux-2.6.30.4.elpa/drivers/net/usb/pegasus.c
>> --- linux-2.6.30.4/drivers/net/usb/pegasus.c  2009-08-13 07:14:57.000000000
>> +0200
>> +++ linux-2.6.30.4.elpa/drivers/net/usb/pegasus.c     2009-08-13
>> 08:39:01.000000000 +0200
>> @@ -469,8 +467,49 @@ fail:
>>               dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
>>       return -ETIMEDOUT;
>>  }
>> +
>> +/* Got from adm 8515 starter kit */
>> +static const __u16 def_eeprom[] = {
>> +                       0x8515, 0x0170, 0x0082, 0x0409, 0x0000,
>> +     0x07a6, 0x8515, 0x100e, 0x202a, 0x380a, 0x0000, 0x0000, 0x0000,
>> +     0x030e, 0x0041, 0x0044, 0x004d, 0x0074, 0x0065, 0x006b, 0x0000,
>> +     0x001e, 0x0055, 0x0053, 0x0042, 0x0020, 0x0031, 0x0030, 0x002f,
>> +     0x032a, 0x0055, 0x0053, 0x0042, 0x0020, 0x0054, 0x006f, 0x0020,
>> +     0x004c, 0x0041, 0x004e, 0x0020, 0x0043, 0x006f, 0x006e, 0x0076,
>> +     0x0065, 0x0072, 0x0074, 0x0065, 0x0072, 0x0000, 0x0000, 0x0000,
>> +     0x030a, 0x0030, 0x0030, 0x0030, 0x0031, 0x0000, 0x0000, 0x0000,
>> +};
>>  #endif                               /* PEGASUS_WRITE_EEPROM */
>>
>> +static int pegasus_set_mac_address(struct net_device *netdev, void *p)
>> +{
>> +     struct sockaddr *addr = p;
>> +     pegasus_t *pegasus = (pegasus_t *) netdev_priv(netdev);
>> +     int i;
>> +
>> +     if (netif_running(netdev))
>> +             return -EBUSY;
>> +     memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
>> +     dbg("%s: Setting MAC address to ", netdev->name);
>> +     for (i = 0; i < 5; i++)
>> +             dbg("%02X:", netdev->dev_addr[i]);
>> +     dbg("%02X\n", netdev->dev_addr[i]);
>> +     /* Set the IDR registers. */
>> +     set_registers(pegasus, EthID, 6, netdev->dev_addr);
>> +#ifdef PEGASUS_WRITE_EEPROM
>> +     write_eprom_word(pegasus, 0,
>> +             (netdev->dev_addr[1] << 8) + netdev->dev_addr[0]);
>> +     write_eprom_word(pegasus, 1,
>> +             (netdev->dev_addr[3] << 8) + netdev->dev_addr[2]);
>> +     write_eprom_word(pegasus, 2,
>> +             (netdev->dev_addr[5] << 8) + netdev->dev_addr[4]);
>> +     for (i = 0; i < ARRAY_SIZE(def_eeprom); i++)
>> +             write_eprom_word(pegasus, i + 3, def_eeprom[i]);
>> +
>> +#endif                         /* PEGASUS_WRITE_EEPROM */
>> +     return 0;
>> +}
>> +
>>  static inline void get_node_id(pegasus_t * pegasus, __u8 * id)
>>  {
>>       int i;
>> @@ -1492,6 +1531,7 @@ static const struct net_device_ops pegas
>>       .ndo_start_xmit =               pegasus_start_xmit,
>>       .ndo_set_multicast_list =       pegasus_set_multicast,
>>       .ndo_get_stats =                pegasus_netdev_stats,
>> +     .ndo_set_mac_address =  pegasus_set_mac_address,
>>       .ndo_tx_timeout =               pegasus_tx_timeout,
>>       .ndo_change_mtu =               eth_change_mtu,
>>       .ndo_set_mac_address =          eth_mac_addr,
>>
>
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
