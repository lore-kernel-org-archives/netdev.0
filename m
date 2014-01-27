From: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Mon, 27 Jan 2014 19:34:40 +0400
Message-ID: <CABjd4Yz2Kfed_qBfSAEXoAcVxfsmhTBA-83YJ9_iSwPZ+r1qYQ@mail.gmail.com>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-4-git-send-email-alchark@gmail.com>
	<1390834654.2735.148.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tony Prisk <linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roger Luethi <rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390834654.2735.148.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014/1/27 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>:
> On Mon, 2014-01-27 at 15:51 +0400, Alexey Charkov wrote:
>> This should make the driver usable with VIA/WonderMedia ARM-based
>> Systems-on-Chip integrated Rhine III adapters. Note that these
>> are always in MMIO mode, and don't have any known EEPROM.
> [...]
>> --- a/drivers/net/ethernet/via/Kconfig
>> +++ b/drivers/net/ethernet/via/Kconfig
>> @@ -19,7 +19,7 @@ if NET_VENDOR_VIA
>>
>>  config VIA_RHINE
>>         tristate "VIA Rhine support"
>> -       depends on PCI
>> +       depends on (PCI || USE_OF)
>>         select CRC32
>>         select MII
>>         ---help---
>
> This seems like the right thing to do, but it means you need to add
> #ifdef CONFIG_PCI and #ifdef CONFIG_USE_OF around the driver structures
> and related functions.

Frankly, I would like to avoid that if possible (as pointed out in the
cover email), as I believe we would get a cleaner driver without
#ifdef. This is also the way it was done in via-velocity, and it works
just fine.

> You should compile-test in configurations that have just one of those
> dependencies enabled.

This has been compile-tested and runtime-tested in OF-only
configuration on WM8950, and Roger also tested it in PCI-only
configuration, so it seems to work fine.

> [...]
>> --- a/drivers/net/ethernet/via/via-rhine.c
>> +++ b/drivers/net/ethernet/via/via-rhine.c
> [...]
>> @@ -847,7 +856,8 @@ static void rhine_hw_init(struct net_device *dev, long pioaddr)
>>               msleep(5);
>>
>>       /* Reload EEPROM controlled bytes cleared by soft reset */
>> -     rhine_reload_eeprom(pioaddr, dev);
>> +     if (!strncmp(dev->dev.parent->bus->name, "pci", 3))
>> +             rhine_reload_eeprom(pioaddr, dev);
> [...]
>
> Ew.  I think you should use dev_is_pci(), although you might also need
> to guard that with #ifdef CONFIG_PCI.

Oh, cool. Didn't realize it existed :) Will adjust, thanks.

I believe the #ifdef is not strictly required, though, as we include
the PCI header anyway (and the macro expands to just a simple test).
Any specific concerns why we should do that, apart from the +3.8%
module size increase?

Thanks,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
