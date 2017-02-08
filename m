From: Robin Murphy <robin.murphy@arm.com>
Subject: Re: [net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 8 Feb 2017 16:03:43 +0000
Message-ID: <87d96521-9d1f-f8e3-cea4-155b7522107e@arm.com>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Mao Wenan <maowenan@huawei.com>,
        Catalin Marinas <Catalin.Marinas@arm.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:52456 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932423AbdBHQ7C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 11:59:02 -0500
In-Reply-To: <20170201024643.2050-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We're seeing a new boot-time crash[1] on SMSC911x hardware from this
patch in today's HEAD (as cafe8df8b9bc)...

On 01/02/17 02:46, Florian Fainelli wrote:
> From: Mao Wenan <maowenan@huawei.com>
> 
> There is currently no reference count being held on the PHY driver,
> which makes it possible to remove the PHY driver module while the PHY
> state machine is running and polling the PHY. This could cause crashes
> similar to this one to show up:
> 
> [   43.361162] BUG: unable to handle kernel NULL pointer dereference at 0000000000000140
> [   43.361162] IP: phy_state_machine+0x32/0x490
> [   43.361162] PGD 59dc067
> [   43.361162] PUD 0
> [   43.361162]
> [   43.361162] Oops: 0000 [#1] SMP
> [   43.361162] Modules linked in: dsa_loop [last unloaded: broadcom]
> [   43.361162] CPU: 0 PID: 1299 Comm: kworker/0:3 Not tainted 4.10.0-rc5+ #415
> [   43.361162] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS Ubuntu-1.8.2-1ubuntu2 04/01/2014
> [   43.361162] Workqueue: events_power_efficient phy_state_machine
> [   43.361162] task: ffff880006782b80 task.stack: ffffc90000184000
> [   43.361162] RIP: 0010:phy_state_machine+0x32/0x490
> [   43.361162] RSP: 0018:ffffc90000187e18 EFLAGS: 00000246
> [   43.361162] RAX: 0000000000000000 RBX: ffff8800059e53c0 RCX:
> ffff880006a15c60
> [   43.361162] RDX: ffff880006782b80 RSI: 0000000000000000 RDI:
> ffff8800059e5428
> [   43.361162] RBP: ffffc90000187e48 R08: ffff880006a15c40 R09:
> 0000000000000000
> [   43.361162] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff8800059e5428
> [   43.361162] R13: ffff8800059e5000 R14: 0000000000000000 R15:
> ffff880006a15c40
> [   43.361162] FS:  0000000000000000(0000) GS:ffff880006a00000(0000)
> knlGS:0000000000000000
> [   43.361162] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   43.361162] CR2: 0000000000000140 CR3: 0000000005979000 CR4:
> 00000000000006f0
> [   43.361162] Call Trace:
> [   43.361162]  process_one_work+0x1b4/0x3e0
> [   43.361162]  worker_thread+0x43/0x4d0
> [   43.361162]  ? __schedule+0x17f/0x4e0
> [   43.361162]  kthread+0xf7/0x130
> [   43.361162]  ? process_one_work+0x3e0/0x3e0
> [   43.361162]  ? kthread_create_on_node+0x40/0x40
> [   43.361162]  ret_from_fork+0x29/0x40
> [   43.361162] Code: 56 41 55 41 54 4c 8d 67 68 53 4c 8d af 40 fc ff ff
> 48 89 fb 4c 89 e7 48 83 ec 08 e8 c9 9d 27 00 48 8b 83 60 ff ff ff 44 8b
> 73 98 <48> 8b 90 40 01 00 00 44 89 f0 48 85 d2 74 08 4c 89 ef ff d2 8b
> 
> Keep references on the PHY driver module right before we are going to
> utilize it in phy_attach_direct(), and conversely when we don't use it
> anymore in phy_detach().
> 
> Signed-off-by: Mao Wenan <maowenan@huawei.com>
> [florian: rebase, rework commit message]
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/phy_device.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 92b08383cafa..0d8f4d3847f6 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -920,6 +920,11 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  		return -EIO;
>  	}
>  
> +	if (!try_module_get(d->driver->owner)) {

...because d->driver is NULL here. I'm a little surprised static
checking hasn't picked this up, because right below we test "if
(d->driver)".

I won't pretend to understand this code and its interaction with the
SMSC driver anywhere near enough to suggest a patch myself, so consider
this just a panic bug report in the hope of preventing 4.10 being
horribly broken.

Thanks,
Robin.

[1]:
[    4.689360] Unable to handle kernel NULL pointer dereference at
virtual address 00000010
[    4.697371] pgd = ffffff80092bd000
[    4.700740] [00000010] *pgd=00000009ffffe003, *pud=00000009ffffe003,
*pmd=0000000000000000
[    4.708936] Internal error: Oops: 96000005 [#1] PREEMPT SMP
[    4.714446] Modules linked in:
[    4.717467] CPU: 2 PID: 1 Comm: swapper/0 Tainted: G        W
4.10.0-rc7+ #1577
[    4.725214] Hardware name: ARM Juno development board (r1) (DT)
[    4.731070] task: ffffffc976850000 task.stack: ffffffc976858000
[    4.736929] PC is at phy_attach_direct+0x98/0x1c8
[    4.741581] LR is at phy_attach_direct+0x94/0x1c8
[    4.746233] pc : [<ffffff80085e0340>] lr : [<ffffff80085e033c>]
pstate: 60000145
[    4.753548] sp : ffffffc97685bb30
[    4.756823] x29: ffffffc97685bb30 x28: ffffff8008c16040
[    4.762078] x27: ffffff8008e65c20 x26: ffffff8008c9045c
[    4.767333] x25: 0000000000000000 x24: 0000000000000001
[    4.772587] x23: ffffffc976b25000 x22: 0000000000000000
[    4.777841] x21: ffffff8008684818 x20: ffffffc976b25800
[    4.783095] x19: ffffffc976825000 x18: 0000000000000010
[    4.788349] x17: 0000000000000000 x16: 0000000000000001
[    4.793602] x15: 0000000000000006 x14: ffffff8088e5ad4f
[    4.798855] x13: ffffff8008e5ad5d x12: ffffff8008e5d160
[    4.804109] x11: ffffffc97685b890 x10: ffffff8008d889d8
[    4.809362] x9 : ffffff80084bee48 x8 : 2020202020203030
[    4.814616] x7 : 3835326236373963 x6 : 00000000000001e2
[    4.819870] x5 : ffffff8008e5c9e8 x4 : 0000000000000000
[    4.825123] x3 : 0000000000000000 x2 : ffffff8008d9ee68
[    4.830376] x1 : ffffffc976850000 x0 : 0000000000000000
[    4.835629]
[    4.837098] Process swapper/0 (pid: 1, stack limit = 0xffffffc976858000)
[    4.843727] Stack: (0xffffffc97685bb30 to 0xffffffc97685c000)
[    4.849411] bb20:                                   ffffffc97685bb80
ffffff80085e0570
[    4.857158] bb40: ffffffc976b25800 ffffffc976825800 ffffff8008684818
ffffffc976825048
[    4.864906] bb60: 0000000000001002 ffffffc976825000 0000000000001002
0000000000000000
[    4.872653] bb80: ffffffc97685bbb0 ffffff8008685e68 ffffffc976825000
ffffffc976825800
[    4.880400] bba0: ffffff80089db328 ffffffc976825800 ffffffc97685bc40
ffffff800880aff8
[    4.888147] bbc0: ffffffc976825000 0000000000000000 ffffff80089db328
ffffffc976825048
[    4.895894] bbe0: 0000000000001002 ffffff8008a0c000 0000000000001002
ffffff8008c9045c
[    4.903640] bc00: ffffff8008e65c20 ffffff8008c16040 ffffffc97685bc40
ffffff800880af78
[    4.911387] bc20: ffffffc976b25800 0000000000001003 ffffff80089db328
0000000000000000
[    4.919134] bc40: ffffffc97685bc80 ffffff800880b2d0 ffffffc976825000
0000000000001003
[    4.926881] bc60: 0000000000000001 0000000000000000 ffffffc976825000
ffffffc976825000
[    4.934628] bc80: ffffffc97685bcc0 ffffff800880b3a0 ffffffc976825000
0000000000001002
[    4.942375] bca0: ffffff8008d11488 0000000000000000 ffffff8008e40000
ffffff8008c11ba8
[    4.950121] bcc0: ffffffc97685bcf0 ffffff8008cda728 ffffff8008d11000
ffffffc976825000
[    4.957868] bce0: ffffff8008d11488 0000000000000001 ffffffc97685bdd0
ffffff80080830f8
[    4.958250] atkbd serio0: keyboard reset failed on 1c060000.kmi
[    4.971466] bd00: ffffff8008cda554 ffffffc976850000 0000000000000000
ffffff8008ce0ad8
[    4.979213] bd20: ffffff8008c7e8f0 ffffff8008ce0ad0 ffffff8008e53000
ffffff8008c9045c
[    4.986960] bd40: ffffff8008d4d2f0 0000000000000000 0000000000000000
ffffff8008ce0ad8
[    4.994707] bd60: ffffff8008c7e8f0 ffffff800834f940 ffffffc97685bda0
ffffff800823a964
[    5.002454] bd80: 000000027685bdc0 ffffff8008e40a18 ffffff8008cd8d58
0000000176850000
[    5.010200] bda0: 0000000000000000 ffffff8008ce0ad8 ffffff8008c7e8f0
ffffff80080830f8
[    5.017947] bdc0: ffffffc97685bdd0 ffffff80080830f8 ffffffc97685be40
ffffff8008c90ca0
[    5.025694] bde0: 0000000000000133 ffffff8008e53000 0000000000000007
ffffff8008ce0ad8
[    5.033441] be00: ffffff8008d4d100 0000000000000000 0000000000000000
ffffff8008b5ae60
[    5.041188] be20: 0000000700000007 ffffff8008c9045c 0000000000000000
ffffff8008c7e8f0
[    5.048934] be40: ffffffc97685bea0 ffffff80088cdca0 ffffff80088cdc90
0000000000000000
[    5.056681] be60: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.064427] be80: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.072174] bea0: 0000000000000000 ffffff8008082ec0 ffffff80088cdc90
0000000000000000
[    5.079920] bec0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.087666] bee0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.095412] bf00: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.103159] bf20: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.110905] bf40: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.118651] bf60: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.126397] bf80: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.134144] bfa0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    5.141890] bfc0: 0000000000000000 0000000000000005 0000000000000000
0000000000000000
[    5.149637] bfe0: 0000000000000000 0000000000000000 0800410001480110
0010001001080000
[    5.157382] Call trace:
[    5.159797] Exception stack(0xffffffc97685b960 to 0xffffffc97685ba90)
[    5.166169] b960: ffffffc976825000 0000008000000000 ffffffc97685bb30
ffffff80085e0340
[    5.173916] b980: ffffff8008b5c3e8 ffffff8008d4e000 ffffff8008e5c9e8
ffffff8008e11760
[    5.181662] b9a0: ffffff8008e5ad50 0000000108e5a7e8 ffffffc97685ba50
ffffff80081012b4
[    5.189409] b9c0: ffffffc976825000 ffffffc976b25800 ffffff8008684818
0000000000000000
[    5.197156] b9e0: ffffffc976b25000 0000000000000001 0000000000000000
ffffff8008c9045c
[    5.204902] ba00: 0000000000000000 ffffffc976850000 ffffff8008d9ee68
0000000000000000
[    5.212649] ba20: 0000000000000000 ffffff8008e5c9e8 00000000000001e2
3835326236373963
[    5.220396] ba40: 2020202020203030 ffffff80084bee48 ffffff8008d889d8
ffffffc97685b890
[    5.228143] ba60: ffffff8008e5d160 ffffff8008e5ad5d ffffff8088e5ad4f
0000000000000006
[    5.235888] ba80: 0000000000000001 0000000000000000
[    5.240713] [<ffffff80085e0340>] phy_attach_direct+0x98/0x1c8
[    5.246396] [<ffffff80085e0570>] phy_connect_direct+0x20/0x78
[    5.252081] [<ffffff8008685e68>] smsc911x_open+0x578/0xa50
[    5.257508] [<ffffff800880aff8>] __dev_open+0xb8/0x128
[    5.262589] [<ffffff800880b2d0>] __dev_change_flags+0x98/0x148
[    5.268358] [<ffffff800880b3a0>] dev_change_flags+0x20/0x60
[    5.273871] [<ffffff8008cda728>] ip_auto_config+0x1d4/0xeb0
[    5.279384] [<ffffff80080830f8>] do_one_initcall+0x38/0x120
[    5.284896] [<ffffff8008c90ca0>] kernel_init_freeable+0x144/0x1e8
[    5.290923] [<ffffff80088cdca0>] kernel_init+0x10/0x100
[    5.296090] [<ffffff8008082ec0>] ret_from_fork+0x10/0x50
[    5.301344] Code: 90002f80 91328000 97edd06a f9404680 (f9400800)
[    5.307423] ---[ end trace 69bc6e46c6317a9c ]---
[    5.312053] Kernel panic - not syncing: Attempted to kill init!
exitcode=0x0000000b

> +		dev_err(&dev->dev, "failed to get the device driver module\n");
> +		return -EIO;
> +	}
> +
>  	get_device(d);
>  
>  	/* Assume that if there is no driver, that it doesn't
> @@ -977,6 +982,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  error:
>  	phy_detach(phydev);
>  	put_device(d);
> +	module_put(d->driver->owner);
>  	if (ndev_owner != bus->owner)
>  		module_put(bus->owner);
>  	return err;
> @@ -1059,6 +1065,7 @@ void phy_detach(struct phy_device *phydev)
>  	bus = phydev->mdio.bus;
>  
>  	put_device(&phydev->mdio.dev);
> +	module_put(phydev->mdio.dev.driver->owner);
>  	if (ndev_owner != bus->owner)
>  		module_put(bus->owner);
>  }
> 
