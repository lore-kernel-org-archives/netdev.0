From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Query: Is it possible  to lose interrupts between vhost and
 virtio_net during migration?
Date: Thu, 14 Aug 2014 12:02:31 +0200
Message-ID: <20140814100231.GB30944@redhat.com>
References: <53DA2CCC.1040606@huawei.com>
 <20140731143100.GA3834@redhat.com>
 <20140731143725.GA3875@redhat.com>
 <53DB705F.2000405@redhat.com>
 <53DB76A9.8010305@redhat.com>
 <53E079C8.7050700@huawei.com>
 <20140805094957.GB24619@redhat.com>
 <53E0CAA4.8010303@huawei.com>
 <53E37561.5060302@huawei.com>
 <53EC78D8.6070405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Zhangjie (HZ)" <zhangjie14@huawei.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, qinchuanyu@huawei.com,
	liuyongan@huawei.com, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51699 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbaHNKHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 06:07:18 -0400
Content-Disposition: inline
In-Reply-To: <53EC78D8.6070405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 04:52:40PM +0800, Jason Wang wrote:
> On 08/07/2014 08:47 PM, Zhangjie (HZ) wrote:
> > On 2014/8/5 20:14, Zhangjie (HZ) wrote:
> >> On 2014/8/5 17:49, Michael S. Tsirkin wrote:
> >>> On Tue, Aug 05, 2014 at 02:29:28PM +0800, Zhangjie (HZ) wrote:
> >>>> Jason is right, the new order is not the cause of network unreachable.
> >>>> Changing order seems not work. After about 40 times, the problem occurs again.
> >>>> Maybe there is other hidden reasons for that.
> >> I modified the code to change the order myself yesterday.
> >> This result is about my code.
> >>> To make sure, you tested the patch that I posted to list:
> >>> "vhost_net: stop guest notifiers after backend"?
> >>>
> >>> Please confirm.
> >>>
> >> OK, I will test with your patch "vhost_net: stop guest notifiers after backend".
> >>
> > Unfortunately, after using the patch "vhost_net: stop guest notifiers after backend",
> > Linux VMs stopt themselves a few minutes after they were started.
> >> @@ -308,6 +308,12 @@ int vhost_net_start(VirtIODevice *dev, NetClientState *ncs,
> >>         goto err;
> >>     }
> >>
> >> +    r = k->set_guest_notifiers(qbus->parent, total_queues * 2, true);
> >> +    if (r < 0) {
> >> +        error_report("Error binding guest notifier: %d", -r);
> >> +        goto err;
> >> +    }
> >> +
> >>     for (i = 0; i < total_queues; i++) {
> >>         r = vhost_net_start_one(get_vhost_net(ncs[i].peer), dev, i * 2);
> >>
> >> @@ -316,12 +322,6 @@ int vhost_net_start(VirtIODevice *dev, NetClientState *ncs,
> >>         }
> >>     }
> >>
> >> -    r = k->set_guest_notifiers(qbus->parent, total_queues * 2, true);
> >> -    if (r < 0) {
> >> -        error_report("Error binding guest notifier: %d", -r);
> >> -        goto err;
> >> -    }
> >> -
> >>     return 0;
> > I wonder if k->set_guest_notifiers should be called after "hdev->started = true;" in vhost_dev_start.
> 
> Michael, can we just remove those assertions? Since you may want to set
> guest notifiers before starting the backend.

Which assertions?

> Another question for virtio_pci_vector_poll(): why not using
> msix_notify() instead of msix_set_pending().

We can do that but the effect will be same since we know
vector is masked.

> If so, there's no need to
> change the vhost_net_start() ?

Confused, don't see the connection.

> Zhang Jie, is this a regression? If yes, could you please do a bisection
> to find the first bad commit.
> 
> Thanks

Pretty sure it's the mq patch: a9f98bb5ebe6fb1869321dcc58e72041ae626ad8

    Since we may have many vhost/net devices for a virtio-net device.  The setting of
    guest notifiers were moved out of the starting/stopping of a specific vhost
    thread. The vhost_net_{start|stop}() were renamed to
    vhost_net_{start|stop}_one(), and a new vhost_net_{start|stop}() were introduced
    to configure the guest notifiers and start/stop all vhost/vhost_net devices.

-- 
MST
