From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH] hyperv: Add netpoll support
Date: Tue, 8 Jul 2014 20:03:45 +0000
Message-ID: <b2835410139848be8811403e3d7fa708@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1404811947-5174-1-git-send-email-richard@nod.at>
 <9fb91c2ee32a4a59a2bec54043a6b9fd@BY2PR03MB299.namprd03.prod.outlook.com>
 <53BC3AC5.6000203@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>, Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <53BC3AC5.6000203@nod.at>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Richard Weinberger [mailto:richard@nod.at]
> Sent: Tuesday, July 8, 2014 11:39 AM
> To: KY Srinivasan; Haiyang Zhang
> Cc: devel@linuxdriverproject.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH] hyperv: Add netpoll support
> 
> Am 08.07.2014 20:01, schrieb KY Srinivasan:
> >
> >
> >> -----Original Message-----
> >> From: Richard Weinberger [mailto:richard@nod.at]
> >> Sent: Tuesday, July 8, 2014 2:32 AM
> >> To: KY Srinivasan; Haiyang Zhang
> >> Cc: devel@linuxdriverproject.org; netdev@vger.kernel.org; linux-
> >> kernel@vger.kernel.org; Richard Weinberger
> >> Subject: [PATCH] hyperv: Add netpoll support
> >>
> >> In order to have at least a netconsole to debug kernel issues on
> >> Windows Azure this patch implements netpoll support.
> >> Sending packets is easy, netvsc_start_xmit() does already everything
> >> needed.
> >> To receive we need to trigger the channel callback which is usally
> >> called via tasklet_schedule().
> >>
> >> Signed-off-by: Richard Weinberger <richard@nod.at>
> >> ---
> >>  drivers/net/hyperv/netvsc_drv.c | 14 ++++++++++++++
> >>  1 file changed, 14 insertions(+)
> >>
> >> diff --git a/drivers/net/hyperv/netvsc_drv.c
> >> b/drivers/net/hyperv/netvsc_drv.c index 4fd71b7..367b71e 100644
> >> --- a/drivers/net/hyperv/netvsc_drv.c
> >> +++ b/drivers/net/hyperv/netvsc_drv.c
> >> @@ -736,6 +736,17 @@ static int netvsc_set_mac_addr(struct net_device
> >> *ndev, void *p)
> >>  	return err;
> >>  }
> >>
> >> +#ifdef CONFIG_NET_POLL_CONTROLLER
> >> +static void netvsc_poll_controller(struct net_device *net) {
> >> +	struct net_device_context *net_device_ctx = netdev_priv(net);
> >> +	struct hv_device *dev = net_device_ctx->device_ctx;
> >> +
> >> +	local_bh_disable();
> >> +	netvsc_channel_cb(dev->channel);
> >> +	local_bh_enable();
> >> +}
> >> +#endif
> >
> > Each channel is bound to a specific VCPU in the guest and the channel
> > callback is expected to be delivered on the VCPU the channel is bound to.
> This code is not satisfying that requirement.
> 
> But struct hv_device has only one channel attribute. How does this work with
> multiple VCPUs?
> 
> Anyways, what solution to you propose?

The VCPU the channel is bound to is available in the channel state. You could use the following code
Fragment to ensure that the call is made on the "right" cpu:

smp_call_function_single(dev->channel->target_cpu,
                                         netvsc_channel_cb, dev->channel, true);

Hope this helps.

K. Y
