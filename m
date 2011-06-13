From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [net-next 13/13] ixgbe: use per NUMA node lock for FCoE DDP
Date: Mon, 13 Jun 2011 16:59:12 -0700
Message-ID: <1308009552.31900.80.camel@vi2.jf.intel.com>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307761341-5267-14-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307769482.2872.62.camel@edumazet-laptop>
	 <1307770931.2872.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56928 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab1FMX7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 19:59:13 -0400
In-Reply-To: <1307770931.2872.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-06-11 at 07:42 +0200, Eric Dumazet wrote:
> Le samedi 11 juin 2011 =C3=A0 07:18 +0200, Eric Dumazet a =C3=A9crit =
:
> > >  /**
> > > diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/i=
xgbe_fcoe.h
> > > index d876e7a..8618892 100644
> > > --- a/drivers/net/ixgbe/ixgbe_fcoe.h
> > > +++ b/drivers/net/ixgbe/ixgbe_fcoe.h
> > > @@ -69,6 +69,7 @@ struct ixgbe_fcoe {
> > >  	struct pci_pool **pool;
> > >  	atomic_t refcnt;
> > >  	spinlock_t lock;
> > > +	struct spinlock **node_lock;
> >=20
> > Wont this read_mostly pointer sits in often modified cache line ?
> >=20
> > >  	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
> > >  	unsigned char *extra_ddp_buffer;
> > >  	dma_addr_t extra_ddp_buffer_dma;
> >=20
>=20
> This patch seems overkill to me, have you tried the more simple way I
> did in commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527
> (net: add additional lock to qdisc to increase throughput )
>=20

Conceptually this patch does same as referred patch from you, in your
case added Qdisc busylock worked fine with multiple tx/Qdisc  but for
fcoe a single ixgbe_fcoe instance is used and therefore this patch
required to setup per node lock similar to Qdisc busylock and that was
the only additional code here and rest is similar.

> (remember you must place ->busylock in a separate cache line, to not
> slow down the two cpus that have access to ->lock)
>=20
> struct ixgbe_fcoe could probably be more carefuly reordered to lower
> false sharing
>=20

I did optimize ixgbe_fcoe due to added node_lock using pahole and not t=
o
stepped on any mostly modified line beside also reducing holes, but
moving far away in the struct on new cacheline boundary is even better
and I'll do that in updated patch.

> I kindly ask you guys provide actual perf numbers between
>=20
> 1) before any patch
> 2) After your multilevel per numanode locks
> 3) A more simple way (my suggestion of adding a single 'busylock')
>=20

I'm retracting this patch for now and in case of updated patch I'll get
number by just this change, earlier I had number w/ and w/o three DDP
related improvements patches in this series and that had net 26% IOPS
increase for 512Bytes reads but that is mainly from other patch adding
per CPU pci pool. The two sockets systems had about same IOPS w/ or w/o
just this patch and so may be this will work better w/ more sockets, so
I'll will respin this patch only if I see any justifiable gain by just
this patch.

Thanks
Vasu

> Thanks
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

