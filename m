From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Fri, 17 Jul 2015 15:33:04 +0000
Message-ID: <BY2PR0301MB1654D90488532EDD2318B7B3A0980@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <1437074222-13020-1-git-send-email-kys@microsoft.com>
 <4fd650437f864cf2a58e8334253f5dcd@SIXPR30MB031.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dexuan Cui <decui@microsoft.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>, "vkuznets@redhat.com"
 <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <4fd650437f864cf2a58e8334253f5dcd@SIXPR30MB031.064d.mgd.msft.net>
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
> From: Dexuan Cui
> Sent: Friday, July 17, 2015 3:01 AM
> To: KY Srinivasan; davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; vkuznets@redhat.com
> Cc: KY Srinivasan
> Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
> processed during probe
> 
> > From: K. Y. Srinivasan
> > Sent: Friday, July 17, 2015 3:17
> > Subject: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
> processed
> > during probe
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> b/drivers/net/hyperv/hyperv_net.h
> > ...
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
> 
> Hi KY,
> IMO here the "-= " should be "+="?
> 
> I think sc_delta is usually <= 0, meaning the host may allocate less
> subchannels than
> we expect.
> With "-=", net_device->num_sc_offered can become bigger -- this doesn't
> seem correct.
We control how many sub-channels we want the host to offer (say sc_requested). Based on this
number we begin to track how many have actually been processed - we decrement sc_requested
each time a sub-channel offer is processed. If the host were to actually offer all that we have requested,
then checking for sc_requested to be zero is sufficient to ensure that we have processed all the
potentially in-flight sub-channels. However, the host  may choose to offer less than what we had asked for
and the variable "delta" is tracking this difference. Since we are counting down from what we had asked for
we have to subtract "delta" for proper accounting.
  
> 
> Why not use
> "net_device->num_sc_offered = net_device->num_chn - 1;" directly?
> At this point, net_device->num_chn has been the number of the actual
> channels.

I am not sure what the question here is. num_sc_offered is initialized to the number we
are going to ask and this is the number that will be decremented each time a sub-channel 
is processed. Since the host may decide to offer us less than what we had asked and some 
sub-channels may have already been processed (num_sc_offerred decremented accordingly)
by the time we discover that the host has offered us less than what we asked for, we adjust
num_sc_offered accordingly.

> 
> 
> > +	spin_unlock_irqrestore(&net_device->sc_lock, flags);
> > +
> > +	if (net_device->num_sc_offered != 0)
> > +		wait_for_completion(&net_device->channel_init_wait);
> 
> BTW, I also tested the patch and I can confirm the panic I saw disappeared
> with the patch.

Thank you.

K. Y
> 
> -- Dexuan
