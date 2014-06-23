From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [RFT 0/3] cxgb4: use request_firmware_nowait()
Date: Mon, 23 Jun 2014 12:06:48 -0700
Message-ID: <53A87AC8.7010305@chelsio.com>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: poswald@suse.com, santosh@chelsio.com, jcheung@suse.com,
	dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@suse.com
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	hariprasad@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

   I've looked through the patch and I might be wrong, but it appears 
that all the uses of the asynchronous request_firmware_nowait() are 
followed immediately by wait_for_completion() calls which essentially 
would be the same as the previous code with an added layer of 
mechanism.  Am I missing something?

   We do have a problem with initialization of multiple adapters with 
external PHYs since, for each adapter we can check to see if the main 
adapter firmware needs updating, and then load the PHY firmware.  If the 
main firmware needs updating on more than one adapter, the combined time 
to update each adapter's main firmware plus load the PHY firmware can 
exceed some Distribution's default limits for a driver module's load 
time (since the kernel seems to be processing the PCI Probe of each 
device sequentially).

   It seems to me that it's unfortunate that the limit isn't on a per 
device basis since a system could have an arbitrary number of devices 
managed by a driver module.  Also, it might be useful if there was a way 
for the driver module to "tell" the timeout mechanism that forward 
progress _is_ being made so it doesn't blow away the driver module 
load.  And maybe, if I'm right regarding the sequential nature of the 
introduction of devices to driver modules, it might make sense for a 
driver module to be able to "tell" the kernel that it has no per-device 
dependencies and multiple devices may be probed simultaneously ...

Casey

On 06/20/14 17:39, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>
> Its reported that loading the cxgb4 can take over 1 minute,
> use the more sane request_firmware_nowait() API call just
> in case this amount of time is causing issues. The driver
> uses the firmware API 3 times, one for the firmware, one
> for configuration and another one for flash, this provides
> the port for all cases.
>
> I don't have the hardware so please test. I did verify we
> can use this during pci probe and also during the ethtool
> flash callback.
>
> Luis R. Rodriguez (3):
>    cxgb4: make ethtool set_flash use request_firmware_nowait()
>    cxgb4: make configuration load use request_firmware_nowait()
>    cxgb4: make device firmware load use request_firmware_nowait()
>
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  13 ++
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 258 +++++++++++++++---------
>   2 files changed, 176 insertions(+), 95 deletions(-)
>
