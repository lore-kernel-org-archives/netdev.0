From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Process for subsystem maintainers to get Hyper-V code out of
 staging.
Date: Tue, 15 Feb 2011 05:21:32 -0500
Message-ID: <20110215102132.GA9077@infradead.org>
References: <8AFC7968D54FB448A30D8F38F259C56233F95737@TK5EX14MBXC114.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	"Jame.Bottomley@HansenPartnership.com"
	<Jame.Bottomley@HansenPartnership.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Hashir Abdi <habdi@microsoft.com>,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"gregkh@suse.de" <gregkh@suse.de>
To: Hank Janssen <hjanssen@microsoft.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8AFC7968D54FB448A30D8F38F259C56233F95737@TK5EX14MBXC114.redmond.corp.microsoft.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please give all the driver a unique prefix, hv_ is a bit to generic.
mshv might be better.

What's the point of the blksvc driver?  It is implemented as a block
driver, steals the major number of the IDE driver, which is a big no-no
and speaks a SCSI-like protocol to the host.  In what way does this
protocol differ from the full SCSI protocol in the storvsc driver?

As far as the storsvc driver is converned: please merge the storvsc.c
and storvsc_drv.c, as they are only used together.  Also please try to
clean up the way you use function pointers.  E.g. the
OnDeviceAdd/OnDeviceRemove/OnCleanup methods should be part of a
mshv_driver structure, and not store into individual objects.

Please get rid of the *_context structure that only have a single
intance anyway.  In generaly a Linux driver should not have any global
state except for maybe module paramters or a list of devices in cases
where the device model can't handle that.

Please clean up the calling convention for the init code, there is
absolutely no reason to pass stor_vsc_initialize as a function pointer
to storvsc_drv_init instead of calling it directly, and in fact there
is no reason to not just inline both of those into storvsc_init.  One
all the function pointers are moved into a driver struct and the global
context is gone there will be almost no code left in there anyway.

Similarly the exit routine is implemented entirely wrong.  The core
bus layer should iterate over all devices for the driver beeing
unregister and call back into the ->remove callback just for that
device.  Try to follow common real hardware busses like pci, usb or for
a really simple one eisa in your design.

There is no reason to have a per-device slab cache, a global one is
enough.  But for per-I/O allocations you'll need a mempool to make it
deadlock-free.

Do you really need scsi_scan_host for a virtualized scsi transport?  Is
there no way for the host to tell you which LUNs actually are present?

Why do you bother to linearize S/G lists?  If your host can't handle it
just tell the scsi layer that you have a sg_tablesize of 1, which means
you'll never get multiple S/G elements.  (Not doing SG is really, really
sad for new virtual hardware btw, please take the crack away from the
person who designed it).

Also can you please avoid forward declaration of functions as much as
possible?  They really make the code hard to read if used as much as in
these drivers.

That's it for the first round, I'm pretty sure there will be more
comments once the code is better structured and more readabke.
