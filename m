From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [RFT 0/3] cxgb4: use request_firmware_nowait()
Date: Wed, 25 Jun 2014 04:00:19 +0200
Message-ID: <20140625020019.GJ27687@wotan.suse.de>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com> <53A87AC8.7010305@chelsio.com> <20140624002941.GD27687@wotan.suse.de> <53A99F71.2060308@chelsio.com> <53A9A88B.2000006@chelsio.com> <20140624233951.GH27687@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	hariprasad@chelsio.com, poswald@suse.com, santosh@chelsio.com,
	jcheung@suse.com, dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140624233951.GH27687@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 01:39:51AM +0200, Luis R. Rodriguez wrote:
> On Tue, Jun 24, 2014 at 09:34:19AM -0700, Casey Leedom wrote:
> > On 06/24/14 08:55, Casey Leedom wrote:
> >> On 06/23/14 17:29, Luis R. Rodriguez wrote:
> >   So I just did this for a normal modprobe (after the system is up):
> >
> > Jiffies    Process
> > -----------------------------------------------------------------------
> >       0    begin firmware load process
> >       3    request_firmware() returns
> >       7    start looking at the adapter
> >      10    finish reading the first sector of existing adapter firmware
> >      26    we've decided that we're going to upgrade the firmware
> >      28    actual firmware upgrade process starts
> >     448    we've finished halting the adapter processor
> >     451    we enter the firmware write routine
> >   8,470    we've finished erasing the firmware FLASH sectors
> >  14,336    write of new firmware is complete
> >  14,340    the new firmware load is complete
> >  14,949    the adapter processor has been restarted; new firmware running
> >  14,952    firmware upgrade process complete
> >
> > Maybe request_firmware() takes more time during the boot phase but as we 
> > can see from the above timings, it's the actual firmware upgrade process 
> > which takes the most time ...
> 
> OK so yeah the kernel work on request_firmware() isn't what takes over a
> minute, its the actual hardware poking with the firmware it gets, and then
> doing all the things you mentioned (a port for each netdevice, etc).  This is a
> particularly interesting driver, apart from this I see some code about bus
> master and loading firmware only once. Can you elaborate a bit on how that is
> designed to work? Is it that only one PCI bus master device is allowed, and
> that will do the request_firmware() for all PCI devices? I'm a bit confused
> about this part, are we sure the bus master device will probe first? We can
> surely keep all this code on the driver but it seems that if all these
> complexitities might become the norm we should consider an API for sharing a
> clean framework for it.
> 
> As you noted the complexities on firmware loading, the number of different
> netdevices one device might actually have would make it impractical to try
> to do any completion on firmware on the ndo_init() with request_firmware_nowait().
> Apart from a netdev specific API to handle all this cleanly, I wonder if
> drivers like these merit getting placed by default onto the deferred_probe_active_list.
> Typically this is triggered when drivers don't have a resource a subsystem
> hasn't yet brought up, the driver returns -EPROBE_DEFER and the core driver
> infrastructure later probes these devices on a secondary list. Greg?

Actually another option to clean this up is to use platform_device_register_simple()
after the initial firmware load and start poking at stuff there. Check out
drivers/net/ethernet/8390/ne.c for an example with probe and all. I think
that can help split up the code paths quite nicely and let you do your
pre port thing there. Thoughts?

I still do have that question about bus master requirement though and ensuring
that there are no races.

  Luis
