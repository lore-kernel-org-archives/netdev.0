From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v3 1/2] xen/pvhvm: If xen_platform_pci=0 is
 set don't blow up (v3).
Date: Tue, 17 Dec 2013 16:23:33 -0500
Message-ID: <20131217212333.GA31966@phenom.dumpdata.com>
References: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>
 <1387206250-13963-2-git-send-email-konrad.wilk@oracle.com>
 <52B01F67.1030108@m2r.biz>
 <20131217145150.GC4683@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: axboe@kernel.dk, stefano.stabellini@eu.citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, leosilva@linux.vnet.ibm.com,
	ashley@ashleylai.com, peterhuewe@gmx.de, mail@srajiv.net,
	tpmdd@selhorst.net, dmitry.torokhov@gmail.com, bhelgaas@google.com,
	plagnioj@jcrosoft.com, tomi.valkeinen@ti.com,
	tpmdd-devel@lists.sourceforge.net, linux-input@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-fbdev@vger.kernel.org
To: Fabio Fantoni <fabio.fantoni@m2r.biz>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131217145150.GC4683@phenom.dumpdata.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 17, 2013 at 09:51:50AM -0500, Konrad Rzeszutek Wilk wrote:
> On Tue, Dec 17, 2013 at 10:54:47AM +0100, Fabio Fantoni wrote:
> > Il 16/12/2013 16:04, Konrad Rzeszutek Wilk ha scritto:
> > >The user has the option of disabling the platform driver:
> > >00:02.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)
> > >
> > >which is used to unplug the emulated drivers (IDE, Realtek 8169, etc)
> > >and allow the PV drivers to take over. If the user wishes
> > >to disable that they can set:
> > >
> > >   xen_platform_pci=0
> > >   (in the guest config file)
> > >
> > >or
> > >   xen_emul_unplug=never
> > >   (on the Linux command line)
> > >
> > >except it does not work properly. The PV drivers still try to
> > >load and since the Xen platform driver is not run - and it
> > >has not initialized the grant tables, most of the PV drivers
> > >stumble upon:
> > >
> > >input: Xen Virtual Keyboard as /devices/virtual/input/input5
> > >input: Xen Virtual Pointer as /devices/virtual/input/input6M
> > >------------[ cut here ]------------
> > >kernel BUG at /home/konrad/ssd/konrad/linux/drivers/xen/grant-table.c:1206!
> > >invalid opcode: 0000 [#1] SMP
> > >Modules linked in: xen_kbdfront(+) xenfs xen_privcmd
> > >CPU: 6 PID: 1389 Comm: modprobe Not tainted 3.13.0-rc1upstream-00021-ga6c892b-dirty #1
> > >Hardware name: Xen HVM domU, BIOS 4.4-unstable 11/26/2013
> > >RIP: 0010:[<ffffffff813ddc40>]  [<ffffffff813ddc40>] get_free_entries+0x2e0/0x300
> > >Call Trace:
> > >  [<ffffffff8150d9a3>] ? evdev_connect+0x1e3/0x240
> > >  [<ffffffff813ddd0e>] gnttab_grant_foreign_access+0x2e/0x70
> > >  [<ffffffffa0010081>] xenkbd_connect_backend+0x41/0x290 [xen_kbdfront]
> > >  [<ffffffffa0010a12>] xenkbd_probe+0x2f2/0x324 [xen_kbdfront]
> > >  [<ffffffff813e5757>] xenbus_dev_probe+0x77/0x130
> > >  [<ffffffff813e7217>] xenbus_frontend_dev_probe+0x47/0x50
> > >  [<ffffffff8145e9a9>] driver_probe_device+0x89/0x230
> > >  [<ffffffff8145ebeb>] __driver_attach+0x9b/0xa0
> > >  [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
> > >  [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
> > >  [<ffffffff8145cf1c>] bus_for_each_dev+0x8c/0xb0
> > >  [<ffffffff8145e7d9>] driver_attach+0x19/0x20
> > >  [<ffffffff8145e260>] bus_add_driver+0x1a0/0x220
> > >  [<ffffffff8145f1ff>] driver_register+0x5f/0xf0
> > >  [<ffffffff813e55c5>] xenbus_register_driver_common+0x15/0x20
> > >  [<ffffffff813e76b3>] xenbus_register_frontend+0x23/0x40
> > >  [<ffffffffa0015000>] ? 0xffffffffa0014fff
> > >  [<ffffffffa001502b>] xenkbd_init+0x2b/0x1000 [xen_kbdfront]
> > >  [<ffffffff81002049>] do_one_initcall+0x49/0x170
> > >
> > >.. snip..
> > >
> > >which is hardly nice. This patch fixes this by having each
> > >PV driver check for:
> > >  - if running in PV, then it is fine to execute (as that is their
> > >    native environment).
> > >  - if running in HVM, check if user wanted 'xen_emul_unplug=never',
> > >    in which case bail out and don't load any PV drivers.
> > >  - if running in HVM, and if PCI device 5853:0001 (xen_platform_pci)
> > >    does not exist, then bail out and not load PV drivers.
> > >  - (v2) if running in HVM, and if the user wanted 'xen_emul_unplug=disks',
> > >    then bail out for all PV devices _except_ the block one.
> > >    Ditto for the network one ('nics').
> > >  - (v2) if running in HVM, and if the user wanted 'xen_emul_unplug=unnecessary'
> > >    then load block PV driver, and also setup the legacy IDE paths.
> > >    In (v3) make it actually load PV drivers.
> > >
> > >Reported-by: Sander Eikelenboom <linux@eikelenboom.it
> > >Reported-by: Anthony PERARD <anthony.perard@citrix.com>
> > >Reported-by: Fabio Fantoni <fabio.fantoni@m2r.biz>
> > >Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > >[v2: Add extra logic to handle the myrid ways 'xen_emul_unplug'
> > >can be used per Ian and Stefano suggestion]
> > >[v3: Make the unnecessary case work properly]
> > >Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
> > 
> > I tested this patch with all possible cases that I know, no crash or
> > calltrace found.
> > 
> > I don't understand the utility of 'xen_emul_unplug=unnecessary' but
> > probably it is working correctly, it shows both pv and not pv for
> > blocks and nics.
> 
> Great!
> > 
> > About 'xen_emul_unplug=disks' and 'xen_emul_unplug=nics' probably
> > there is something wrong.
> > With 'xen_emul_unplug=nics' it shows pv nic (this should be correct)
> > and about disks it shows the same disk twice, as pv and not pv (xvda
> > and sda) with different device number.
> 
> Good.
> > With 'xen_emul_unplug=disks' it shows pv block (this should be
> > correct) and it seems to show the pv nic too (this should be wrong).
> 
> Correct. You should see only the PV disk and all other PV devices
> should not function. Let me dig in this and see whether there is
> another bug. Thank you!

That is because 'disks' is incorrect. It should have been 'ide-disks'

[    0.000000] unrecognised option 'disks' in parameter 'xen_emul_unplug'

With the 'ide-disks' it should work. I will update the description to
mention 'ide-disks' instead of 'disks'. Thank you for finding this!
