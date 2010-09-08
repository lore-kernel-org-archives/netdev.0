From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 15:47:35 +0530
Message-ID: <OFAA7EBCA4.A8F764FD-ON65257798.0035E8C2-65257798.00385450@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <4C873F96.5020203@redhat.com> <OF2EF80349.03D44EF4-ON65257798.002D0021-65257798.003352A5@in.ibm.com> <4C875735.9050808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:50120 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab0IHKPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 06:15:23 -0400
In-Reply-To: <4C875735.9050808@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avi Kivity <avi@redhat.com> wrote on 09/08/2010 02:58:21 PM:

> >>> 1. This feature was first implemented with a single vhost.
> >>>      Testing showed 3-8% performance gain for upto 8 netperf
> >>>      sessions (and sometimes 16), but BW dropped with more
> >>>      sessions.  However, implementing per-txq vhost improved
> >>>      BW significantly all the way to 128 sessions.
> >> Why were vhost kernel changes required?  Can't you just instantiate
more
> >> vhost queues?
> > I did try using a single thread processing packets from multiple
> > vq's on host, but the BW dropped beyond a certain number of
> > sessions.
>
> Oh - so the interface has not changed (which can be seen from the
> patch).  That was my concern, I remembered that we planned for vhost-net
> to be multiqueue-ready.
>
> The new guest and qemu code work with old vhost-net, just with reduced
> performance, yes?

Yes, I have tested new guest/qemu with old vhost but using
#numtxqs=1 (or not passing any arguments at all to qemu to
enable MQ). Giving numtxqs > 1 fails with ENOBUFS in vhost,
since vhost_net_set_backend in the unmodified vhost checks
for boundary overflow.

I have also tested running an unmodified guest with new
vhost/qemu, but qemu should not specify numtxqs>1.

> > Are you suggesting this
> > combination:
> >    IRQ on guest:
> >       40: CPU0
> >       41: CPU1
> >       42: CPU2
> >       43: CPU3 (all CPUs are on socket #0)
> >    vhost:
> >       thread #0:  CPU0
> >       thread #1:  CPU1
> >       thread #2:  CPU2
> >       thread #3:  CPU3
> >    qemu:
> >       thread #0:  CPU4
> >       thread #1:  CPU5
> >       thread #2:  CPU6
> >       thread #3:  CPU7 (all CPUs are on socket#1)
>
> May be better to put vcpu threads and vhost threads on the same socket.
>
> Also need to affine host interrupts.
>
> >    netperf/netserver:
> >       Run on CPUs 0-4 on both sides
> >
> > The reason I did not optimize anything from user space is because
> > I felt showing the default works reasonably well is important.
>
> Definitely.  Heavy tuning is not a useful path for general end users.
> We need to make sure the the scheduler is able to arrive at the optimal
> layout without pinning (but perhaps with hints).

OK, I will see if I can get results with this.

Thanks for your suggestions,

- KK

