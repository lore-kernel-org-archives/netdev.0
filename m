From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 0/2] net: phy: Prevent an MDIO bus from being unloaded while
 in use
Date: Mon, 21 Jul 2014 11:42:38 -0700
Message-ID: <CAGVrzcYo7BKmjxLMfB7u8rkgE1o+CDkDkWvCSL4kZ8S3whx=hw@mail.gmail.com>
References: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:64904 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135AbaGUSua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 14:50:30 -0400
Received: by mail-oa0-f42.google.com with SMTP id n16so8019699oag.15
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 11:50:29 -0700 (PDT)
In-Reply-To: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ezequiel,

2014-07-21 11:26 GMT-07:00 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>:
> Hi all,
>
> This small patchset is a first proposal to fix the current lack of relationship
> between an ethernet driver and the MDIO bus behind the PHY device.
>
> In such cases, we would find no visible link between the drivers:
>
>   $ lsmod
>   Module                  Size  Used by    Not tainted
>   mvmdio                  2941  0
>   mvneta                 22069  0
>
> Which means nothing prevents the MDIO driver from being removed:
>
>   $ modprobe -r mvmdio
>
>   # Unable to handle kernel NULL pointer dereference at virtual address 00000060
>   pgd = c0004000
>   [00000060] *pgd=00000000
>   Internal error: Oops: 17 [#1] SMP ARM
>   Modules linked in: mvneta [last unloaded: mvmdio]
>   CPU: 0 PID: 22 Comm: kworker/0:1 Not tainted 3.16.0-rc5-01127-g62c0816-dirty #608
>   Workqueue: events_power_efficient phy_state_machine
>   task: df5ec840 ti: df67a000 task.ti: df67a000
>   PC is at phy_state_machine+0x1c/0x468
>   LR is at phy_state_machine+0x18/0x468
>   [snip]
>
> This patchset fixes this by calling module_{get,put} in the ethernet driver.
> After this patch, the mvmdio driver is no longer removable:
>
>   $ modprobe -r mvmdio
>   modprobe: can't unload module mvmdio: Resource temporarily unavailable
>
> Of course, we can expect a few drivers to have the same need and therefore
> we could argue about moving this to be part of the phydev connection.

Right, that's exactly what jumps to mind when I take a look at your
patch set. As long as a PHY device connected to a particular MDIO bus
is in used, we should make sure its refcount does not hit zero.

BTW, neither mvmdio nor mvneta seems to set their 'owner' field, is
that intentional?

>
> Ezequiel Garcia (2):
>   net: phy: Set the driver when registering an MDIO bus device
>   net: mvneta: Ensure the MDIO bus module is held
>
>  drivers/net/ethernet/marvell/mvneta.c | 12 ++++++++++++
>  drivers/net/phy/mdio_bus.c            |  1 +
>  2 files changed, 13 insertions(+)
>
> --
> 2.0.1
>



-- 
Florian
