From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: Increase delay for
 RNDIS_STATUS_NETWORK_CHANGE
Date: Wed, 3 Feb 2016 15:46:41 +0000
Message-ID: <BN1PR0301MB0770CFE76823654E90579D0CCAD00@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
 <87si1ax7t9.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87si1ax7t9.fsf@vitty.brq.redhat.com>
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
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Wednesday, February 3, 2016 8:06 AM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: davem@davemloft.net; netdev@vger.kernel.org; KY Srinivasan
> <kys@microsoft.com>; olaf@aepfle.de; linux-kernel@vger.kernel.org;
> driverdev-devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for
> RNDIS_STATUS_NETWORK_CHANGE
> 
> Haiyang Zhang <haiyangz@microsoft.com> writes:
> 
> > We simulates a link down period for RNDIS_STATUS_NETWORK_CHANGE
> message to
> > trigger DHCP renew. User daemons may need multiple seconds to trigger
> the
> > link down event. (e.g. ifplugd: 5sec, network-manager: 4sec.) So update
> > this link down period to 10 sec to properly trigger DHCP renew.
> >
> 
> I probably don't follow: why do we need sucha a delay? If (with real
> hardware) you plug network cable out and in one second you plug it in
> you'll get DHCP renewed, right?
> 
> When I introduced RNDIS_STATUS_NETWORK_CHANGE handling by
> emulating a
> pair of up/down events I put 2 second delay to make link_watch happy (as
> we only handle 1 event per second there) but 10 seconds sounds to much
> to me.

In the test on Hyper-V, our software on host side  wants to trigger DHCP 
renew by sending only a RNDIS_STATUS_NETWORK_CHANGE message to 
a guest without physically unplug the cable. But, this message didn't trigger 
DHCP renew within 2 seconds. The VM is Centos 7.1 using Networkmanager, 
which needs 4 seconds after link down to renew IP. Some daemon, like 
ifplugd, needs 5 sec to renew. That's why we increase the simulated link 
down time for RNDIS_STATUS_NETWORK_CHANGE message. 


> > @@ -1009,8 +1012,11 @@ static void netvsc_link_change(struct
> work_struct *w)
> >  			netif_tx_stop_all_queues(net);
> >  			event->event = RNDIS_STATUS_MEDIA_CONNECT;
> >  			spin_lock_irqsave(&ndev_ctx->lock, flags);
> > -			list_add_tail(&event->list, &ndev_ctx-
> >reconfig_events);
> > +			list_add(&event->list, &ndev_ctx->reconfig_events);
> 
> Why? Adding to tail was here to not screw the order of events...

The RNDIS_STATUS_MEDIA_CONNECT message triggers two "half" events -- 
link down & up. After "link down", we want the paired "link up" to be the 
immediate next event. Since the function picks the next event from the list 
head, so it should be inserted to list head. Otherwise, the possible existing 
events in the list will be processed in the middle of these two "half events" 
-- link down & up.

Thanks,
- Haiyang
