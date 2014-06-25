From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [RFT 0/3] cxgb4: use request_firmware_nowait()
Date: Wed, 25 Jun 2014 23:51:13 +0200
Message-ID: <20140625215113.GA27687@wotan.suse.de>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com> <53A87AC8.7010305@chelsio.com> <20140624002941.GD27687@wotan.suse.de> <53A99F71.2060308@chelsio.com> <53A9A88B.2000006@chelsio.com> <20140624233951.GH27687@wotan.suse.de> <20140625020019.GJ27687@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	hariprasad@chelsio.com, poswald@suse.com, santosh@chelsio.com,
	jcheung@suse.com, dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140625020019.GJ27687@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 04:00:19AM +0200, Luis R. Rodriguez wrote:
> On Wed, Jun 25, 2014 at 01:39:51AM +0200, Luis R. Rodriguez wrote:
> > On Tue, Jun 24, 2014 at 09:34:19AM -0700, Casey Leedom wrote:
> > > On 06/24/14 08:55, Casey Leedom wrote:
> > >> On 06/23/14 17:29, Luis R. Rodriguez wrote:
> > >   So I just did this for a normal modprobe (after the system is up):
> > >
> > > Jiffies    Process
> > > -----------------------------------------------------------------------
> > >       0    begin firmware load process
> > >       3    request_firmware() returns
> > >       7    start looking at the adapter
> > >      10    finish reading the first sector of existing adapter firmware
> > >      26    we've decided that we're going to upgrade the firmware
> > >      28    actual firmware upgrade process starts
> > >     448    we've finished halting the adapter processor
> > >     451    we enter the firmware write routine
> > >   8,470    we've finished erasing the firmware FLASH sectors
> > >  14,336    write of new firmware is complete
> > >  14,340    the new firmware load is complete
> > >  14,949    the adapter processor has been restarted; new firmware running
> > >  14,952    firmware upgrade process complete
> > >
> > > Maybe request_firmware() takes more time during the boot phase but as we 
> > > can see from the above timings, it's the actual firmware upgrade process 
> > > which takes the most time ...
> > 
> > OK so yeah the kernel work on request_firmware() isn't what takes over a
> > minute, its the actual hardware poking with the firmware it gets, and then
> > doing all the things you mentioned (a port for each netdevice, etc).  This is a
> > particularly interesting driver, apart from this I see some code about bus
> > master and loading firmware only once. Can you elaborate a bit on how that is
> > designed to work? Is it that only one PCI bus master device is allowed, and
> > that will do the request_firmware() for all PCI devices? I'm a bit confused
> > about this part, are we sure the bus master device will probe first? We can
> > surely keep all this code on the driver but it seems that if all these
> > complexitities might become the norm we should consider an API for sharing a
> > clean framework for it.

Casey here was the first series of questions.

> > As you noted the complexities on firmware loading, the number of different
> > netdevices one device might actually have would make it impractical to try
> > to do any completion on firmware on the ndo_init() with request_firmware_nowait().
> > Apart from a netdev specific API to handle all this cleanly, I wonder if
> > drivers like these merit getting placed by default onto the deferred_probe_active_list.
> > Typically this is triggered when drivers don't have a resource a subsystem
> > hasn't yet brought up, the driver returns -EPROBE_DEFER and the core driver
> > infrastructure later probes these devices on a secondary list. Greg?
> 
> Actually another option to clean this up is to use platform_device_register_simple()
> after the initial firmware load and start poking at stuff there. Check out
> drivers/net/ethernet/8390/ne.c for an example with probe and all. I think
> that can help split up the code paths quite nicely and let you do your
> pre port thing there. Thoughts?

And here was the other one, what your thoughts are on splitting things up
a bit more for probe as ports part of a platform driver?

In the meantime I'll go and hunt down to see if there are any timeouts other
than the one embedded within request_firmware() (or udev if used). As we have
clarified now the 60s timeout is a timeout embedded as part of the filesystem
lookup of the firmware, not the actual loading of the firmware onto the device.

I for instance can introduce a huge delay on purpose right after
request_firmware() say 3 minutes on a test driver and it loads just fine, but
on my OpenSUSE 13.1 system. I'll go ahead and test this on the other
distribution you mentioned you had issues, curious what could trigger a timeout
failure there that would be distribution specific.

ergon:~ # ls > /lib/firmware/fake.bin

mcgrof@ergon ~/devel/fake-firmware-delay $ cat Makefile
all: modules

.PHONY: modules
modules:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

.PHONY: clean
clean:
	make -C /lib/modules/$(shell uname -r)/build clean M=$(PWD)

obj-m += test.o

mcgrof@ergon ~/devel/fake-firmware-delay $ cat test.c
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/firmware.h>
#include <linux/platform_device.h>
#include <linux/delay.h>

static struct platform_device *pdev;

static int __init test_init(void)
{
	int ret;
	const struct firmware *config;

	pdev = platform_device_register_simple("fake-dev", 0, NULL, 0);
	if (IS_ERR(pdev))
		return PTR_ERR(pdev);

	ret = request_firmware(&config, "fake.bin", &pdev->dev);
	if (ret < 0) {
		dev_set_uevent_suppress(&pdev->dev, true);
		platform_device_unregister(pdev);
		return ret;
	}

	ssleep(180);

	release_firmware(config);

	return 0;
}

static void __exit test_exit(void)
{
	dev_set_uevent_suppress(&pdev->dev, true);
	platform_device_unregister(pdev);
}

module_init(test_init)
module_exit(test_exit)
MODULE_LICENSE("GPL");

  Luis
