From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [RFT 0/3] cxgb4: use request_firmware_nowait()
Date: Tue, 24 Jun 2014 02:29:41 +0200
Message-ID: <20140624002941.GD27687@wotan.suse.de>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com> <53A87AC8.7010305@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	hariprasad@chelsio.com, poswald@suse.com, santosh@chelsio.com,
	jcheung@suse.com, dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53A87AC8.7010305@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 23, 2014 at 12:06:48PM -0700, Casey Leedom wrote:
>   I've looked through the patch and I might be wrong, but it appears that 
> all the uses of the asynchronous request_firmware_nowait() are followed 
> immediately by wait_for_completion() calls which essentially would be the 
> same as the previous code with an added layer of mechanism.  Am I missing 
> something?

No you're right and I frailed to mention my original goal really is to
see if we can instead move that to ndo_init().

>   We do have a problem with initialization of multiple adapters with 
> external PHYs since, for each adapter we can check to see if the main 
> adapter firmware needs updating, and then load the PHY firmware.  If the 
> main firmware needs updating on more than one adapter, the combined time to 
> update each adapter's main firmware plus load the PHY firmware can exceed 
> some Distribution's default limits for a driver module's load time (since 
> the kernel seems to be processing the PCI Probe of each device 
> sequentially).

I noticed that for configuration updates it is optional for these configuration
updates to exist, in which case then if udev is enabled the driver will wait
quite a long time unncessarily. To fix that it seems request_firmware_direct()
would be better.

>   It seems to me that it's unfortunate that the limit isn't on a per device 
> basis since a system could have an arbitrary number of devices managed by a 
> driver module. 

The timeout is for the amount of time it takes the kernel to get the firemware,
not for device initialization, so its unclear to me that the 60 timeout thing
is actually causing an issue here.

> Also, it might be useful if there was a way for the driver 
> module to "tell" the timeout mechanism that forward progress _is_ being 
> made so it doesn't blow away the driver module load.

Indeed if this is actually needed, but believe the issue here for the
huge delays might be instead the lack of not using request_firmware_direct()
and actual device initialization time, which I do not believe we penalize,
we should be penalizing only the amount of time it takes either the
kernel or udev to read the firmware from the filesystem.

>  And maybe, if I'm 
> right regarding the sequential nature of the introduction of devices to 
> driver modules, it might make sense for a driver module to be able to 
> "tell" the kernel that it has no per-device dependencies and multiple 
> devices may be probed simultaneously ...

What if just configuration updates use request_firmware_direct() and
for the actual firmware which is required a request_firmware_nowait()
with a proper wait_for_completion() on the ndo_init() ?

  Luis
