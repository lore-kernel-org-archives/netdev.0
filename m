From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2 1/2] net: phy: Set the driver when registering an MDIO
 bus device
Date: Mon, 4 Aug 2014 23:55:22 -0300
Message-ID: <CAOMZO5CH0VystNR+qpXQFB_1f9=0DZzm7xxD5Fxy+uxFmAa-0Q@mail.gmail.com>
References: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1406144852-7379-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Shawn Guo <shawn.guo@freescale.com>,
	=?UTF-8?B?TWFyZWsgVmHFoXV0?= <marex@denx.de>,
	Sascha Hauer <kernel@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:61310 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235AbaHECzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:55:24 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so226020lbi.27
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:55:22 -0700 (PDT)
In-Reply-To: <1406144852-7379-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ezequiel,

On Wed, Jul 23, 2014 at 4:47 PM, Ezequiel Garcia
<ezequiel.garcia@free-electrons.com> wrote:
> mdiobus_register() registers a device which is already bound to a driver.
> Hence, the driver pointer should be set properly in order to track down
> the driver associated to the MDIO bus.
>
> This will be used to allow ethernet driver to pin down a MDIO bus driver,
> preventing it from being unloaded while the PHY device is running.
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> ---
>  drivers/net/phy/mdio_bus.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 4eaadcf..203651e 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -255,6 +255,7 @@ int mdiobus_register(struct mii_bus *bus)
>
>         bus->dev.parent = bus->parent;
>         bus->dev.class = &mdio_bus_class;
> +       bus->dev.driver = bus->parent->driver;
>         bus->dev.groups = NULL;
>         dev_set_name(&bus->dev, "%s", bus->id);

This patches causes the following regression in 3.16 (tested on mx5/mx6):

root@imx6qsabresd:~# echo mem > /sys/power/state
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.003 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.002 seconds) done.
Unable to handle kernel NULL pointer dereference at virtual address 0000002c
pgd = bcd14000
[0000002c] *pgd=4d9e0831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] SMP ARM
Modules linked in:
CPU: 0 PID: 617 Comm: sh Not tainted 3.16.0 #17
task: bc0c4e00 ti: bceb6000 task.ti: bceb6000
PC is at fec_suspend+0x10/0x70
LR is at dpm_run_callback.isra.7+0x34/0x6c
pc : [<803f8a98>]    lr : [<80361f44>]    psr: 600f0013
sp : bceb7d70  ip : bceb7d88  fp : bceb7d84
r10: 8091523c  r9 : 00000000  r8 : bd88f478
r7 : 803f8a88  r6 : 81165988  r5 : 00000000  r4 : 00000000
r3 : 00000000  r2 : 00000000  r1 : bd88f478  r0 : bd88f478
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c5387d  Table: 4cd1404a  DAC: 00000015
Process sh (pid: 617, stack limit = 0xbceb6240)
Stack: (0xbceb7d70 to 0xbceb8000)
7d60:                                     00000000 00000000 bceb7dbc bceb7d88
7d80: 80361f44 803f8a94 80671c98 80067974 00000000 00000000 00000000 bd88f478
7da0: 00000000 81165988 00000002 bd88f4ac bceb7dec bceb7dc0 80362bc4 80361f1c
7dc0: bd88f52c 0088f478 8092fefc bd88f52c bd88f478 8092fefc 81165988 8092ff64
7de0: bceb7e34 bceb7df0 80363b2c 80362aa8 c8717e25 00000003 80363f58 00000002
7e00: c8717e25 00000003 00000000 00000002 00000003 809153f4 bd7dad80 8091541c
7e20: 00000004 807e1bd4 bceb7e4c bceb7e38 80363fd4 80363ad4 81110000 00000003
7e40: bceb7e8c bceb7e50 8006c508 80363f80 bceb7e7c bceb7e60 80668bc0 8006ed58
7e60: 807e5b54 bceb7e84 00000000 00000003 809153f4 bd7dad80 8091541c 807e1bd4
7e80: bceb7eac bceb7e90 8006ca98 8006c474 0000006d 80915414 00000003 00000003
7ea0: bceb7edc bceb7eb0 8006b57c 8006c834 00000004 bdb2b000 00000004 bd7dad80
7ec0: bceb7f78 00000004 bdb2b00c bdb2b000 bceb7eec bceb7ee0 8029def8 8006b510
7ee0: bceb7f0c bceb7ef0 8014754c 8029dee8 801474f8 00000000 00000000 bd7dad80
7f00: bceb7f44 bceb7f10 8014688c 80147504 00000000 00000000 00000001 bdbf9680
7f20: 00000004 00c95fd8 bceb7f78 00000004 bceb6000 00c95fd8 bceb7f74 bceb7f48
7f40: 800e4d6c 801467d0 800ffbb4 800ffb34 00000000 00000000 bdbf9680 bdbf9680
7f60: 00000004 00c95fd8 bceb7fa4 bceb7f78 800e5190 800e4cd0 00000000 00000000
7f80: 00000004 00c95fd8 00000001 00000004 8000ed24 00000000 00000000 bceb7fa8
7fa0: 8000eb60 800e5158 00000004 00c95fd8 00000001 00c95fd8 00000004 00000000
7fc0: 00000004 00c95fd8 00000001 00000004 00000020 00c9428c 0007e640 7eda9848
7fe0: 00000000 7eda9614 00012b94 466c73ac 600f0010 00000001 00000000 00000000
Backtrace:
[<803f8a88>] (fec_suspend) from [<80361f44>] (dpm_run_callback.isra.7+0x34/0x6c)
 r4:00000000 r3:00000000
[<80361f10>] (dpm_run_callback.isra.7) from [<80362bc4>]
(__device_suspend+0x128/0x2b8)
 r8:bd88f4ac r7:00000002 r6:81165988 r5:00000000 r4:bd88f478
[<80362a9c>] (__device_suspend) from [<80363b2c>] (dpm_suspend+0x64/0x224)
 r8:8092ff64 r7:81165988 r6:8092fefc r5:bd88f478 r4:bd88f52c
[<80363ac8>] (dpm_suspend) from [<80363fd4>] (dpm_suspend_start+0x60/0x68)
 r10:807e1bd4 r9:00000004 r8:8091541c r7:bd7dad80 r6:809153f4 r5:00000003
 r4:00000002
[<80363f74>] (dpm_suspend_start) from [<8006c508>]
(suspend_devices_and_enter+0xa0/0x3c0)
 r5:00000003 r4:81110000
[<8006c468>] (suspend_devices_and_enter) from [<8006ca98>]
(pm_suspend+0x270/0x2b0)
 r10:807e1bd4 r8:8091541c r7:bd7dad80 r6:809153f4 r5:00000003 r4:00000000
[<8006c828>] (pm_suspend) from [<8006b57c>] (state_store+0x78/0xdc)
 r6:00000003 r5:00000003 r4:80915414 r3:0000006d
[<8006b504>] (state_store) from [<8029def8>] (kobj_attr_store+0x1c/0x28)
 r10:bdb2b000 r9:bdb2b00c r8:00000004 r7:bceb7f78 r6:bd7dad80 r5:00000004
 r4:bdb2b000 r3:00000004
[<8029dedc>] (kobj_attr_store) from [<8014754c>] (sysfs_kf_write+0x54/0x58)
[<801474f8>] (sysfs_kf_write) from [<8014688c>] (kernfs_fop_write+0xc8/0x188)
 r6:bd7dad80 r5:00000000 r4:00000000 r3:801474f8
[<801467c4>] (kernfs_fop_write) from [<800e4d6c>] (vfs_write+0xa8/0x1b0)
 r10:00c95fd8 r9:bceb6000 r8:00000004 r7:bceb7f78 r6:00c95fd8 r5:00000004
 r4:bdbf9680
[<800e4cc4>] (vfs_write) from [<800e5190>] (SyS_write+0x44/0x90)
 r10:00c95fd8 r8:00000004 r7:bdbf9680 r6:bdbf9680 r5:00000000 r4:00000000
[<800e514c>] (SyS_write) from [<8000eb60>] (ret_fast_syscall+0x0/0x48)
 r10:00000000 r8:8000ed24 r7:00000004 r6:00000001 r5:00c95fd8 r4:00000004
Code: e1a0c00d e92dd818 e24cb004 e5904088 (e594302c)
---[ end trace fa9dea6c9b5c5526 ]---

If I revert it then I am able to suspend/resume normally.

Is there anything I need to do in
drivers/net/ethernet/freescale/fec_main.c to fix this or should this
commit be reverted?
