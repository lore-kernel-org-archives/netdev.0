From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [RFT 0/3] cxgb4: use request_firmware_nowait()
Date: Tue, 24 Jun 2014 08:55:29 -0700
Message-ID: <53A99F71.2060308@chelsio.com>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com> <53A87AC8.7010305@chelsio.com> <20140624002941.GD27687@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	hariprasad@chelsio.com, poswald@suse.com, santosh@chelsio.com,
	jcheung@suse.com, dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140624002941.GD27687@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 06/23/14 17:29, Luis R. Rodriguez wrote:
> On Mon, Jun 23, 2014 at 12:06:48PM -0700, Casey Leedom wrote:
>>    I've looked through the patch and I might be wrong, but it appears that
>> all the uses of the asynchronous request_firmware_nowait() are followed
>> immediately by wait_for_completion() calls which essentially would be the
>> same as the previous code with an added layer of mechanism.  Am I missing
>> something?
> No you're right and I frailed to mention my original goal really is to
> see if we can instead move that to ndo_init().

   Okay, thanks for confirming that.  I thought I was being very stupid.

   The problem I think with ndo_init() is that comes off a Network 
Device (struct net_device) and you can't have Network Devices till you 
talk to the adpater, discover how many ports you have, what their MAC 
Addresses are, etc.  And of course you'd then have to be prepared for an 
ndo_init() call on every instantiated Network Device on an adapter and 
only do the device initialization for the first (while holding off any 
and all activity on the others), etc.  All doable but a bit more 
complicated than doing this at Device Probe time.

>>    We do have a problem with initialization of multiple adapters with
>> external PHYs since, for each adapter we can check to see if the main
>> adapter firmware needs updating, and then load the PHY firmware.  If the
>> main firmware needs updating on more than one adapter, the combined time to
>> update each adapter's main firmware plus load the PHY firmware can exceed
>> some Distribution's default limits for a driver module's load time (since
>> the kernel seems to be processing the PCI Probe of each device
>> sequentially).
> I noticed that for configuration updates it is optional for these configuration
> updates to exist, in which case then if udev is enabled the driver will wait
> quite a long time unncessarily. To fix that it seems request_firmware_direct()
> would be better.

   Hhmmm, I'm unfamiliar with all of this.  I hadn't looked that far 
under the covers of request_firmware() to know that any of these 
variants existed, what their semantics were and when one over the other 
was the preferred API.

>>    It seems to me that it's unfortunate that the limit isn't on a per device
>> basis since a system could have an arbitrary number of devices managed by a
>> driver module.
> The timeout is for the amount of time it takes the kernel to get the firemware,
> not for device initialization, so its unclear to me that the 60 timeout thing
> is actually causing an issue here.

   Are you sure about that?  I just loaded firmware on two of my 
T4-based adapters and each took about 15 seconds to complete.  The 
firmware is ~0.5MB and needs to be written to the on-adapter FLASH. The 
PHY firmware takes a bit less but not a lot.  Add that to the time to do 
general adapter initialization and you're cruising close to 1 minute for 
two adapters ...  Thus, my comment that whatever timeout is present 
should really be per-adapter based ... and it would be nice if the 
driver could inform the kernel as to the expected maximum device probe 
initialization time so we didn't have to have a huge inappropriate 
timeout for all devices ...

>> Also, it might be useful if there was a way for the driver
>> module to "tell" the timeout mechanism that forward progress _is_ being
>> made so it doesn't blow away the driver module load.
> Indeed if this is actually needed, but believe the issue here for the
> huge delays might be instead the lack of not using request_firmware_direct()
> and actual device initialization time, which I do not believe we penalize,
> we should be penalizing only the amount of time it takes either the
> kernel or udev to read the firmware from the filesystem.

   If you want I can time the actual phases of loading new firmware: 
request_firmware(), writing it to FLASH, release_firmware() ...

>>   And maybe, if I'm
>> right regarding the sequential nature of the introduction of devices to
>> driver modules, it might make sense for a driver module to be able to
>> "tell" the kernel that it has no per-device dependencies and multiple
>> devices may be probed simultaneously ...
> What if just configuration updates use request_firmware_direct() and
> for the actual firmware which is required a request_firmware_nowait()
> with a proper wait_for_completion() on the ndo_init() ?

   I'm not quite sure I understand what you're asking here.  The cxgb4 
driver attaches to the firmware in the probe() stage and, if the 
firmware is older then the supported version, upgrades the firmware and 
RESETs the device.  Then, for adapters with external PHYs (10Gb/s BT 
predominantly), the same process can happen for the PHY firmware (or on 
some adapters which have no PHY-attached FLASH, this happens for every 
driver load).  It's conceivable that we could defer the PHY firmware 
load till the first ndo_open() but we'd still be stuck with the 
seemingly broken idea that a simple timeout for a driver module load is 
good enough when what we seem to need is a timeout per device ...

Casey
