From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Fri, 17 Jul 2015 15:53:54 +0000
Message-ID: <BY2PR0301MB16542B6DF558055287B1B7F1A0980@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <1437074222-13020-1-git-send-email-kys@microsoft.com>
 <87a8uuoot9.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Dexuan Cui <decui@microsoft.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a8uuoot9.fsf@vitty.brq.redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Friday, July 17, 2015 7:13 AM
> To: KY Srinivasan
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; Dexuan Cui
> Subject: Re: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
> processed during probe
> 
> "K. Y. Srinivasan" <kys@microsoft.com> writes:
> 
> > The current code returns from probe without waiting for the proper
> handling
> > of subchannels that may be requested. If the netvsc driver were to be
> rapidly
> > loaded/unloaded, we can  trigger a panic as the unload will be tearing
> > down state that may not have been fully setup yet. We fix this issue by
> making
> > sure that we return from the probe call only after ensuring that the
> > sub-channel offers in flight are properly handled.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > Reviewed-and-tested-by: Haiyang Zhang <haiyangz@microsoft.com
> > ---
> >  drivers/net/hyperv/hyperv_net.h   |    2 ++
> >  drivers/net/hyperv/rndis_filter.c |   25 +++++++++++++++++++++++++
> >  2 files changed, 27 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> b/drivers/net/hyperv/hyperv_net.h
> > index 26cd14c..925b75d 100644
> > --- a/drivers/net/hyperv/hyperv_net.h
> > +++ b/drivers/net/hyperv/hyperv_net.h
> > @@ -671,6 +671,8 @@ struct netvsc_device {
> >  	u32 send_table[VRSS_SEND_TAB_SIZE];
> >  	u32 max_chn;
> >  	u32 num_chn;
> > +	spinlock_t sc_lock; /* Protects num_sc_offered variable */
> > +	u32 num_sc_offered;
> >  	atomic_t queue_sends[NR_CPUS];
> >
> >  	/* Holds rndis device info */
> > diff --git a/drivers/net/hyperv/rndis_filter.c
> b/drivers/net/hyperv/rndis_filter.c
> > index 2e40417..2e09f3f 100644
> > --- a/drivers/net/hyperv/rndis_filter.c
> > +++ b/drivers/net/hyperv/rndis_filter.c
> > @@ -984,9 +984,16 @@ static void netvsc_sc_open(struct vmbus_channel
> *new_sc)
> >  	struct netvsc_device *nvscdev;
> >  	u16 chn_index = new_sc->offermsg.offer.sub_channel_index;
> >  	int ret;
> > +	unsigned long flags;
> >
> >  	nvscdev = hv_get_drvdata(new_sc->primary_channel->device_obj);
> >
> > +	spin_lock_irqsave(&nvscdev->sc_lock, flags);
> > +	nvscdev->num_sc_offered--;
> > +	spin_unlock_irqrestore(&nvscdev->sc_lock, flags);
> > +	if (nvscdev->num_sc_offered == 0)
> > +		complete(&nvscdev->channel_init_wait);
> > +
> >  	if (chn_index >= nvscdev->num_chn)
> >  		return;
> >
> > @@ -1015,8 +1022,10 @@ int rndis_filter_device_add(struct hv_device
> *dev,
> >  	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
> >  	u32 mtu, size;
> >  	u32 num_rss_qs;
> > +	u32 sc_delta;
> >  	const struct cpumask *node_cpu_mask;
> >  	u32 num_possible_rss_qs;
> > +	unsigned long flags;
> >
> >  	rndis_device = get_rndis_device();
> >  	if (!rndis_device)
> > @@ -1039,6 +1048,8 @@ int rndis_filter_device_add(struct hv_device
> *dev,
> >  	net_device->max_chn = 1;
> >  	net_device->num_chn = 1;
> >
> > +	spin_lock_init(&net_device->sc_lock);
> > +
> >  	net_device->extension = rndis_device;
> >  	rndis_device->net_dev = net_device;
> >
> > @@ -1116,6 +1127,9 @@ int rndis_filter_device_add(struct hv_device
> *dev,
> >  	num_possible_rss_qs = cpumask_weight(node_cpu_mask);
> >  	net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
> >
> > +	num_rss_qs = net_device->num_chn - 1;
> > +	net_device->num_sc_offered = num_rss_qs;
> > +
> >  	if (net_device->num_chn == 1)
> >  		goto out;
> >
> > @@ -1157,11 +1171,22 @@ int rndis_filter_device_add(struct hv_device
> *dev,
> >
> >  	ret = rndis_filter_set_rss_param(rndis_device, net_device-
> >num_chn);
> >
> > +	/*
> > +	 * Wait for the host to send us the sub-channel offers.
> > +	 */
> > +	spin_lock_irqsave(&net_device->sc_lock, flags);
> > +	sc_delta = net_device->num_chn - 1 - num_rss_qs;
> > +	net_device->num_sc_offered -= sc_delta;
> > +	spin_unlock_irqrestore(&net_device->sc_lock, flags);
> > +
> > +	if (net_device->num_sc_offered != 0)
> > +		wait_for_completion(&net_device->channel_init_wait);
> 
> I'd suggest we add an essentian timeout (big, let's say 30 sec.)
> here. In case something goes wrong we don't really want to hang the
> whole kernel for forever. Such bugs are hard to debug as if a 'kernel
> hangs' is reported we can't be sure which wait caused it. We can even
> have something like:
> 
>  t = wait_for_completion_timeout(&net_device->channel_init_wait, 30*HZ);
>  BUG_ON(t == 0);
> 
> This is much better as we'll be sure what went wrong. (I know other
> pieces of hyper-v code use wait_for_completion() without a timeout, this
> is rather a general suggestion for all of them).

There is some history here. Initially, I had timeout for calls where we could reasonably
rollback state if we timed out. Some calls were subsequently changed to unconditional
wait because under some load conditions, these timeouts would trigger (granted I did not
have 30 second timeout; it was a 5 second timeout).

Greg was opposed to calls to BUG_ON() in general for drivers. Consequently, I have chosen to
wait unconditionally in cases where there is no sensible rollback if we were to timeout (rather
thank bug checking).

In this specific case though, we can have a timeout and we don't need to bug check if we timeout.

I will make this change and resubmit.

Thanks,

K. Y 
> 
> >  out:
> >  	if (ret) {
> >  		net_device->max_chn = 1;
> >  		net_device->num_chn = 1;
> >  	}
> > +
> >  	return 0; /* return 0 because primary channel can be used alone */
> >
> >  err_dev_remv:
> 
> --
>   Vitaly
