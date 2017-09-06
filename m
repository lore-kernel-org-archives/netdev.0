From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: fix deadlock on hotplug
Date: Wed, 6 Sep 2017 16:23:45 +0000
Message-ID: <DM5PR21MB0475451095CC657BB54C4E50CA970@DM5PR21MB0475.namprd21.prod.outlook.com>
References: <20170906151925.15221-1-sthemmin@microsoft.com>
 <20170906151925.15221-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>, KY Srinivasan
 <kys@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170906151925.15221-2-sthemmin@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, September 6, 2017 11:19 AM
> To: KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; Stephen Hemminger <sthemmin@microsoft.com>
> Cc: devel@linuxdriverproject.org; netdev@vger.kernel.org
> Subject: [PATCH net-next 1/1] hv_netvsc: fix deadlock on hotplug
> 
> When a virtual device is added dynamically (via host console), then
> the vmbus sends an offer message for the primary channel. The processing
> of this message for networking causes the network device to then
> initialize the sub channels.
> 
> The problem is that setting up the sub channels needs to wait until
> the subsequent subchannel offers have been processed. These offers
> come in on the same ring buffer and work queue as where the primary
> offer is being processed; leading to a deadlock.
> 
> This did not happen in older kernels, because the sub channel waiting
> logic was broken (it wasn't really waiting).
> 
> The solution is to do the sub channel setup in its own work queue
> context that is scheduled by the primary channel setup; and then
> happens later.
> 
> Fixes: 732e49850c5e ("netvsc: fix race on sub channel creation")
> Reported-by: Dexuan Cui <decui@microsoft.com>
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
> Should also go to stable, but this version does not apply cleanly
> to 4.13. Have another patch for that.
> 
>  drivers/net/hyperv/hyperv_net.h   |   1 +
>  drivers/net/hyperv/netvsc_drv.c   |   8 +--
>  drivers/net/hyperv/rndis_filter.c | 106 ++++++++++++++++++++++++++-----
> -------
>  3 files changed, 74 insertions(+), 41 deletions(-)

The patch looks overall. I just have a question:

With this patch, after module load and probe is done, there may still be
subchannels being processed. If rmmod immediately, the subchannel offers 
may hit half-way removed device structures... Do we also need to add 
cancel_work_sync(&dev->subchan_work) to the top of netvsc_remove()?

unregister_netdevice() includes device close, but it's only called later
in the netvsc_remove() when rndis is already removed.

Thanks,
- Haiyang
