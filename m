From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v3 1/2] xen/pvhvm: If xen_platform_pci=0 is
 set don't blow up (v3).
Date: Thu, 2 Jan 2014 15:09:44 +0000
Message-ID: <52C58138.1030301@citrix.com>
References: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>	<1387206250-13963-2-git-send-email-konrad.wilk@oracle.com>	<52B01F67.1030108@m2r.biz>	<20131217145150.GC4683@phenom.dumpdata.com>	<20131217212333.GA31966@phenom.dumpdata.com> <20131231143258.GA3018@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Fabio Fantoni <fabio.fantoni@m2r.biz>, <axboe@kernel.dk>,
	<leosilva@linux.vnet.ibm.com>, <linux-fbdev@vger.kernel.org>,
	<dmitry.torokhov@gmail.com>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-pci@vger.kernel.org>,
	<netdev@vger.kernel.org>, <ashley@ashleylai.com>,
	<tpmdd@selhorst.net>, <linux-kernel@vger.kernel.org>,
	<mail@srajiv.net>, <tpmdd-devel@lists.sourceforge.net>,
	<tomi.valkeinen@ti.com>, <david.vrabel@citrix.com>,
	<linux-input@vger.kernel.org>, <bhelgaas@google.com>,
	<xen-devel@lists.xenproject.org>, <boris.ostrovsky@oracle.com>,
	<plagnioj@jcrosoft.com>, <peterhuewe@gmx.de>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <20131231143258.GA3018@phenom.dumpdata.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/12/13 14:32, Konrad Rzeszutek Wilk wrote:
>> That is because 'disks' is incorrect. It should have been 'ide-disks'
>>
>> [    0.000000] unrecognised option 'disks' in parameter 'xen_emul_unplug'
>>
>> With the 'ide-disks' it should work. I will update the description to
>> mention 'ide-disks' instead of 'disks'. Thank you for finding this!
>>
> 
> I've v4 with said update and will push it to Linus shortly.
> 
> Thanks!
> 
> P.S.
> Here is v4:
> 
>>From 275a81e7496d3532e5b4752703c50a7c8355a6c7 Mon Sep 17 00:00:00 2001
> From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Date: Tue, 26 Nov 2013 15:05:40 -0500
> Subject: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't blow up (v4).
> 
> The user has the option of disabling the platform driver:
> 00:02.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)
> 
> which is used to unplug the emulated drivers (IDE, Realtek 8169, etc)
> and allow the PV drivers to take over. If the user wishes
> to disable that they can set:
> 
>   xen_platform_pci=0
>   (in the guest config file)
> 
> or
>   xen_emul_unplug=never
>   (on the Linux command line)
> 
> except it does not work properly. The PV drivers still try to
> load and since the Xen platform driver is not run - and it
> has not initialized the grant tables, most of the PV drivers
> stumble upon:
> 
> input: Xen Virtual Keyboard as /devices/virtual/input/input5
> input: Xen Virtual Pointer as /devices/virtual/input/input6M
> ------------[ cut here ]------------
> kernel BUG at /home/konrad/ssd/konrad/linux/drivers/xen/grant-table.c:1206!
> invalid opcode: 0000 [#1] SMP
> Modules linked in: xen_kbdfront(+) xenfs xen_privcmd
> CPU: 6 PID: 1389 Comm: modprobe Not tainted 3.13.0-rc1upstream-00021-ga6c892b-dirty #1
> Hardware name: Xen HVM domU, BIOS 4.4-unstable 11/26/2013
> RIP: 0010:[<ffffffff813ddc40>]  [<ffffffff813ddc40>] get_free_entries+0x2e0/0x300
> Call Trace:
>  [<ffffffff8150d9a3>] ? evdev_connect+0x1e3/0x240
>  [<ffffffff813ddd0e>] gnttab_grant_foreign_access+0x2e/0x70
>  [<ffffffffa0010081>] xenkbd_connect_backend+0x41/0x290 [xen_kbdfront]
>  [<ffffffffa0010a12>] xenkbd_probe+0x2f2/0x324 [xen_kbdfront]
>  [<ffffffff813e5757>] xenbus_dev_probe+0x77/0x130
>  [<ffffffff813e7217>] xenbus_frontend_dev_probe+0x47/0x50
>  [<ffffffff8145e9a9>] driver_probe_device+0x89/0x230
>  [<ffffffff8145ebeb>] __driver_attach+0x9b/0xa0
>  [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
>  [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
>  [<ffffffff8145cf1c>] bus_for_each_dev+0x8c/0xb0
>  [<ffffffff8145e7d9>] driver_attach+0x19/0x20
>  [<ffffffff8145e260>] bus_add_driver+0x1a0/0x220
>  [<ffffffff8145f1ff>] driver_register+0x5f/0xf0
>  [<ffffffff813e55c5>] xenbus_register_driver_common+0x15/0x20
>  [<ffffffff813e76b3>] xenbus_register_frontend+0x23/0x40
>  [<ffffffffa0015000>] ? 0xffffffffa0014fff
>  [<ffffffffa001502b>] xenkbd_init+0x2b/0x1000 [xen_kbdfront]
>  [<ffffffff81002049>] do_one_initcall+0x49/0x170
> 
> .. snip..
> 
> which is hardly nice. This patch fixes this by having each
> PV driver check for:
>  - if running in PV, then it is fine to execute (as that is their
>    native environment).
>  - if running in HVM, check if user wanted 'xen_emul_unplug=never',
>    in which case bail out and don't load any PV drivers.
>  - if running in HVM, and if PCI device 5853:0001 (xen_platform_pci)
>    does not exist, then bail out and not load PV drivers.
>  - (v2) if running in HVM, and if the user wanted 'xen_emul_unplug=ide-disks',
>    then bail out for all PV devices _except_ the block one.
>    Ditto for the network one ('nics').
>  - (v2) if running in HVM, and if the user wanted 'xen_emul_unplug=unnecessary'
>    then load block PV driver, and also setup the legacy IDE paths.
>    In (v3) make it actually load PV drivers.
[...]
> --- a/arch/x86/xen/platform-pci-unplug.c
> +++ b/arch/x86/xen/platform-pci-unplug.c
> @@ -69,6 +69,80 @@ static int check_platform_magic(void)
>  	return 0;
>  }
>  
> +bool xen_has_pv_devices()
> +{
> +	if (!xen_domain())
> +		return false;
> +
> +	/* PV domains always have them. */
> +	if (xen_pv_domain())
> +		return true;
> +
> +	/* And user has xen_platform_pci=0 set in guest config as
> +	 * driver did not modify the value. */
> +	if (xen_platform_pci_unplug == 0)
> +		return false;
> +
> +	if (xen_platform_pci_unplug & XEN_UNPLUG_NEVER)
> +		return false;
> +
> +	if (xen_platform_pci_unplug & XEN_UNPLUG_ALL)
> +		return true;
> +
> +	/* This is an odd one - we are going to run legacy
> +	 * and PV drivers at the same time. */
> +	if (xen_platform_pci_unplug & XEN_UNPLUG_UNNECESSARY)
> +		return true;
> +
> +	/* And the caller has to follow with xen_pv_{disk,nic}_devices
> +	 * to be certain which driver can load. */
> +	return false;

This may result in:

xen_has_pv_devices() == false
xen_has_pv_disk_devices() == true

which looks odd to me.  Surely xen_has_pv_*_devices() is a subset of
xen_has_pv_devices()?

David
