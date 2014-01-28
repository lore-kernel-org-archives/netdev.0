From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Tue, 28 Jan 2014 19:18:49 +0200
Message-ID: <20140128171849.GA20177@redhat.com>
References: <52E766D4.4070901@huawei.com>
 <20140128083459.GB16833@redhat.com>
 <52E77506.1080604@huawei.com>
 <20140128094138.GA17332@redhat.com>
 <52E78416.50000@huawei.com>
 <20140128103325.GA17794@redhat.com>
 <20140128085834.0325cd9f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Qin Chuanyu <qinchuanyu@huawei.com>, jasowang@redhat.com,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932165AbaA1ROB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jan 2014 12:14:01 -0500
Content-Disposition: inline
In-Reply-To: <20140128085834.0325cd9f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 28, 2014 at 08:58:34AM -0800, Stephen Hemminger wrote:
> On Tue, 28 Jan 2014 12:33:25 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Tue, Jan 28, 2014 at 06:19:02PM +0800, Qin Chuanyu wrote:
> > > On 2014/1/28 17:41, Michael S. Tsirkin wrote:
> > > >>>I think it's okay - IIUC this way we are processing xmit directly
> > > >>>instead of going through softirq.
> > > >>>Was meaning to try this - I'm glad you are looking into this.
> > > >>>
> > > >>>Could you please check latency results?
> > > >>>
> > > >>netperf UDP_RR 512
> > > >>test model: VM->host->host
> > > >>
> > > >>modified before : 11108
> > > >>modified after  : 11480
> > > >>
> > > >>3% gained by this patch
> > > >>
> > > >>
> > > >Nice.
> > > >What about CPU utilization?
> > > >It's trivially easy to speed up networking by
> > > >burning up a lot of CPU so we must make sure it's
> > > >not doing that.
> > > >And I think we should see some tests with TCP as well, and
> > > >try several message sizes.
> > > >
> > > >
> > > Yes, by burning up more CPU we could get better performance easily.
> > > So I have bond vhost thread and interrupt of nic on CPU1 while testing.
> > > 
> > > modified before, the idle of CPU1 is 0%-1% while testing.
> > > and after modify, the idle of CPU1 is 2%-3% while testing
> > > 
> > > TCP also could gain from this, but pps is less than UDP, so I think
> > > the improvement would be not so obviously.
> > 
> > Still need to test this doesn't regress but overall looks convincing to me.
> > Could you send a patch, accompanied by testing results for
> > throughput latency and cpu utilization for tcp and udp
> > with various message sizes?
> > 
> > Thanks!
> > 
> 
> There are a couple potential problems with this. The primary one is
> that now you are violating the explicit assumptions about when netif_receive_skb()
> can be called and because of that it may break things all over the place.

Specifically http://patchwork.ozlabs.org/patch/52963/
mentions cls_cgroup_classify which has this code:
        if (in_serving_softirq()) {
                /* If there is an sk_classid we'll use that. */
                if (!skb->sk)
                        return -1;
                classid = skb->sk->sk_classid;
        }

in_serving_softirq now checks flag so we could thinkably set it
just like softirq does.

>  *
>  *	netif_receive_skb() is the main receive data processing function.
>  *	It always succeeds. The buffer may be dropped during processing
>  *	for congestion control or by the protocol layers.
>  *
>  *	This function may only be called from softirq context and interrupts
>  *	should be enabled.
> 
> At a minimum, softirq (BH) and preempt must be disabled.

Yes.

> Another potential problem is that since a softirq is not used, the kernel stack
> maybe much larger.

tun itself is pretty modest in its stack use -
as thread linked above says it might not be a big issue.

> Maybe a better way would be implementing some form of NAPI in the TUN device?
> 

We can't always do this.

regular devices get skbs from card or RAM so they can do this
in softirq context.
tun gets skbs from userspace memory so it needs to run in
process context, at least sometimes.

-- 
MST
