From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: DSA driver - how to glue to a PCI based NIC's mdio?
Date: Fri, 2 Oct 2015 16:44:33 -0700
Message-ID: <CAJ+vNU3-chBy_MbN6jw387ZEZ4DNVJHroerzqMYiJoCYJ2CZaw@mail.gmail.com>
References: <CAJ+vNU2rf0r9V3DfF1-=hpEhdqxkDHz-LmHWOJqscLdsw2EDEA@mail.gmail.com>
	<20150930211210.GD20219@lunn.ch>
	<CAJ+vNU2SUpsQ+7dwPfR6EHVofpvVFF42KO=YUDaarLaDwWvXFw@mail.gmail.com>
	<20150930214052.GG20219@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35045 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbbJBXoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 19:44:34 -0400
Received: by obbzf10 with SMTP id zf10so93540398obb.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 16:44:33 -0700 (PDT)
In-Reply-To: <20150930214052.GG20219@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 2:40 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> > information to the NIC's device driver. Better would be to have a
>> > small shim driver which is loaded on your PCI_ID/DEVICE_ID. That would
>> > instantiate the NIC driver, and insert a DSA platform device.
>>
>> I was thinking of this as well, but then I would still need that shim
>> to know the netdevice that the driver I'm shimming creates so I can't
>> figure a way to do it without touching the PCI driver.
>
> You can probably get that from the PCI information you have:
>
> # /sys/devices/pci0000:00/0000:00:1c.2/0000:06:00.0 is the PCIe device. And it has
>
> # /sys/devices/pci0000:00/0000:00:1c.2/0000:06:00.0/net$ ls -l
> total 0
> drwxr-xr-x 5 root root 0 Aug 19 18:23 eth0
>
> So the linking is there.
>
>    Andrew

Andrew,

I read over the thread in April (https://lkml.org/lkml/2015/4/21/195)
regarding a USB Ethernet device with a switch attached as it discusses
a similar issue to mine where you do not have device-tree handles to
the mii bus or netdev and the device is enumerated. It does not seem
that any resolution was found there.

Do you know of any example of a 'shim' for a PCI device driver? I was
thinking you were talking about a PCI fixup or something that operated
on the device at enumeration time but in order to get hold of the
associated netdev I would need to instantiate the original NIC drive
then somehow get its mii_bus and netdev after its probe completed. I'm
not clear how to do that. How can I from my own PCI device driver, get
another PCI device driver's probe to fire, and following that, how
could I find that devices netdev and mdio_bus structures?

Another possibility discussed in that thread, that I have thought of
as well is doing this through a phylib driver. My device also has some
phy's hanging off two of the MV88E6xxx switch ports that need some
configuration so I 'already' have a phylib driver. However I haven't
figured out how to get hold of the netdev in order to register a DSA
platform device from there. The phylib probe function passes a
phy_device struct which gives me the mdio bus, but at that point the
attached_dev is NULL and remains that way until the NIC is brought up.
Currently I have a workqueue firing at 1Hz that checks for
fiber/copper/SFP state changes and in there I can check to see if the
phy_device has an attached_dev and when it does I can register a DSA
platform device and that works with the caviot that you have to bring
up the NIC that is attached to the switch in order for DSA to probe.

Regards,

Tim
