From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 15 Jan 2010 14:33:25 +0530
Message-ID: <OF1B0853DD.2824263E-ON652576AC.002FA9D4-652576AC.0030AC47@in.ibm.com>
References: <20100115053352.31564.765.sendpatchset@krkumar2.in.ibm.com> <20100115.003636.199394610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:35965 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167Ab0AOIvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:51:45 -0500
In-Reply-To: <20100115.003636.199394610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> David Miller <davem@davemloft.net>
>
> Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
>
> From: Krishna Kumar <krkumar2@in.ibm.com>
> Date: Fri, 15 Jan 2010 11:03:52 +0530
>
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> >
> > Remove inline skb data in tcp_sendmsg(). For the few devices that
> > don't support NETIF_F_SG, dev_queue_xmit will call skb_linearize,
> > and pass the penalty to those slow devices (the following drivers
> > do not support NETIF_F_SG: 8139cp.c, amd8111e.c, dl2k.c, dm9000.c,
> > dnet.c, ethoc.c, ibmveth.c, ioc3-eth.c, macb.c, ps3_gelic_net.c,
> > r8169.c, rionet.c, spider_net.c, tsi108_eth.c, veth.c,
> > via-velocity.c, atlx/atl2.c, bonding/bond_main.c, can/dev.c,
> > cris/eth_v10.c).
>
> I was really surprised to see r8169.c in that list.
>
> It even has all the code in it's ->ndo_start_xmit() method
> to build fragments properly and handle segmented SKBs, it
> simply doesn't set NETIF_F_SG in dev->features for whatever
> reason.

I didn't notice this driver but had checked via-velocity and
found that it too had support but was not setting this bit.

> Bonding it on your list, but it does indeed support NETIF_F_SG
> as long as all of it's slaves do.  See bond_compute_features()
> and how it uses netdev_increment_features() over the slaves.
>
> Anyways...
>
> > This patch does not affect devices that support SG but turn off
> > via ethtool after register_netdev.
> >
> > I ran the following test cases with iperf - #threads: 1 4 8 16 32
> > 64 128 192 256, I/O sizes: 256 4K 16K 64K, each test case runs for
> > 1 minute, repeat 5 iterations. Total test run time is 6 hours.
> > System is 4-proc Opteron, with a Chelsio 10gbps NIC. Results (BW
> > figures are the aggregate across 5 iterations in mbps):
>  ...
> > Please review if the idea is acceptable.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>
> So how bad does it kill performance for a chip that doesn't
> support NETIF_F_SG?
>
> That's what people will complain about if this goes in.

I don't know how much performance will drop for those 15-18 drivers
listed above, since I don't have access to those devices.

Thanks,

- KK

