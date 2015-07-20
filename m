From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Mon, 20 Jul 2015 19:00:09 +0000
Message-ID: <BY2PR0301MB16542853C648EC68A154C441A0850@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <1437074222-13020-1-git-send-email-kys@microsoft.com>
 <4fd650437f864cf2a58e8334253f5dcd@SIXPR30MB031.064d.mgd.msft.net>
 <BY2PR0301MB1654D90488532EDD2318B7B3A0980@BY2PR0301MB1654.namprd03.prod.outlook.com>
 <da594b2ca2ed48f8b5119b7fb0269f2d@SIXPR30MB031.064d.mgd.msft.net>
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
In-Reply-To: <da594b2ca2ed48f8b5119b7fb0269f2d@SIXPR30MB031.064d.mgd.msft.net>
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
> Sent: Monday, July 20, 2015 2:39 AM
> To: KY Srinivasan; davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; vkuznets@redhat.com
> Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
> processed during probe
> 
> > From: KY Srinivasan
> > Sent: Friday, July 17, 2015 23:33
> > > From: Dexuan Cui
> > > Sent: Friday, July 17, 2015 3:01 AM
> > > > From: K. Y. Srinivasan
> > > > Sent: Friday, July 17, 2015 3:17
> > > > Subject: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
> > > processed
> > > > during probe
> > > > diff --git a/drivers/net/hyperv/hyperv_net.h
> > > b/drivers/net/hyperv/hyperv_net.h
> > > > ...
> > > > @@ -1116,6 +1127,9 @@ int rndis_filter_device_add(struct hv_device
> > > *dev,
> > > >  num_possible_rss_qs = cpumask_weight(node_cpu_mask);
> > > >  net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
> > > >
> > > > +num_rss_qs = net_device->num_chn - 1;
> > > > +net_device->num_sc_offered = num_rss_qs;
> > > > +
> > > >  if (net_device->num_chn == 1)
> > > >  goto out;
> > > >
> > > > @@ -1157,11 +1171,22 @@ int rndis_filter_device_add(struct
> hv_device
> > > *dev,
> > > >
> > > >  ret = rndis_filter_set_rss_param(rndis_device, net_device-
> > > >num_chn);
> > > >
> > > > +/*
> > > > + * Wait for the host to send us the sub-channel offers.
> > > > + */
> > > > +spin_lock_irqsave(&net_device->sc_lock, flags);
> > > > +sc_delta = net_device->num_chn - 1 - num_rss_qs;
> > > > +net_device->num_sc_offered -= sc_delta;
> > >
> > > Hi KY,
> > > IMO here the "-= " should be "+="?
> > >
> > > I think sc_delta is usually <= 0, meaning the host may allocate less
> > > subchannels than
> > > we expect.
> > > With "-=", net_device->num_sc_offered can become bigger -- this
> doesn't
> > > seem correct.
> > We control how many sub-channels we want the host to offer (say
> > sc_requested). Based on this
> > number we begin to track how many have actually been processed - we
> > decrement sc_requested
> > each time a sub-channel offer is processed. If the host were to actually
> offer all
> > that we have requested,
> > then checking for sc_requested to be zero is sufficient to ensure that we
> have
> > processed all the
> > potentially in-flight sub-channels. However, the host  may choose to offer
> less
> > than what we had asked for
> > and the variable "delta" is tracking this difference. Since we are counting
> down
> > from what we had asked for
> > we have to subtract "delta" for proper accounting.
> 
> Yes, I understand the rationale.
> Let me show the issue by example:
> 
> Let's assume sc_requested is 7 and the host actually only offers 3 sub-
> channels:
> 1. Just before sending the NVSP_MSG5_TYPE_SUBCHANNEL message, we
> have
> net_device->num_chn == 8,
> num_rss_qs ==  7
> net_device->num_sc_offered == 7
> 
> 2. Just after we get the reply of the message,
> net_device->num_chn == 4
> sc_delta = net_device->num_chn - 1 - num_rss_qs, so sc_delta == 4 - 1 - 7 = -
> 4
> net_device->num_sc_offered -= sc_delta, so
> net_device->num_sc_offered == 7 - (-4) = 11. It's not zero, so we sleep on
> the
> wait_for_completion().
> 
> 3. Now we process the 3 sub-channel and net_device->num_sc_offered will
> become 11 -1 -1 -1 == 8 and no complete() will be invoked!
> 
> That's why I think the "-=" in the line
> net_device->num_sc_offered -= sc_delta
> should be "+=".

Thanks Dexuan; I will fix the issue and resend.

Regards,

K. Y
