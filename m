From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: fix ethtool stats
Date: Wed, 21 Jul 2010 22:47:59 +0200
Message-ID: <1279745279.2405.5.camel@edumazet-laptop>
References: <1279646906.2498.103.camel@edumazet-laptop>
	 <AANLkTik7JrI3HrtvQRTgrRU30fFb2lrgGxUJsWXedBL0@mail.gmail.com>
	 <1279679904.2492.20.camel@edumazet-laptop>
	 <AANLkTinqcK+xO1GH9fA2Wc=2_5W_RBcfS8NyHdxvbwbm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57697 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab0GUUsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:48:04 -0400
Received: by wyf19 with SMTP id 19so21525wyf.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:48:03 -0700 (PDT)
In-Reply-To: <AANLkTinqcK+xO1GH9fA2Wc=2_5W_RBcfS8NyHdxvbwbm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 juillet 2010 =C3=A0 13:17 -0700, Jeff Kirsher a =C3=A9cr=
it :
> On Tue, Jul 20, 2010 at 19:38, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> > Le mardi 20 juillet 2010 =C3=A0 15:06 -0700, Jeff Kirsher a =C3=A9c=
rit :
> >> On Tue, Jul 20, 2010 at 10:28, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >> > Note : I am currently unable to test following patch, could you =
please
> >> > Intel guys test it and Ack (or Nack) it ?
> >> >
> >> > Thanks !
> >> >
> >> > [PATCH net-next-2.6] ixgbe: fix ethtool stats
> >> >
> >> > In latest changes about 64bit stats on 32bit arches,
> >> > [commit 28172739f0a276eb8 (net: fix 64 bit counters on 32 bit ar=
ches)],
> >> > I missed ixgbe uses a bit of magic in its ixgbe_gstrings_stats
> >> > definition.
> >> >
> >> > IXGBE_NETDEV_STAT() must now assume offsets relative to
> >> > rtnl_link_stats64, not relative do dev->stats.
> >> >
> >> > As a bonus, we also get 64bit stats on ethtool -S
> >> >
> >> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> > ---
> >> >  drivers/net/ixgbe/ixgbe_ethtool.c |   42 ++++++++++++++--------=
------
> >> >  1 file changed, 21 insertions(+), 21 deletions(-)
> >> >
> >>
> >> Thanks Eric, I have added it to my queue.
> >>
> >
> > Thanks !
> >
> > By the way, my ixgbe conf doesnt like net-next-2.6 at all.
> > (No link is established in my fiber loop configuration)
> >
> > current linux-2.6 git runs correctly, link at 10Gb, so there is a
> > regression somewhere.
> >
> > As this machine is quite slow (I dont have anymore my Nehalem dev
> > machine, had to use an old setup), a bisection would take one month=
=2E..
> >
> >
>=20
> Eric - can you send your setup and .config so that we can take a look
> at why your not getting a link?
>=20

It seems trying to use two ports of same card in back to back is
problematic.

=46inally, I tested this patch, with two machines and two dual port car=
ds
[82599EB 10-Gigabit Network Connection (rev 01)]
(courtesy from Intel), and everything is fine.

Tested-by: Eric Dumazet <eric.dumazet@gmail.com>

# ethtool -S eth1
NIC statistics:
     rx_packets: 2750925
     tx_packets: 2747612
     rx_bytes: 1668189088
     tx_bytes: 1667871060
     rx_pkts_nic: 2750926
     tx_pkts_nic: 2747612
     rx_bytes_nic: 1679192890
     tx_bytes_nic: 1678861724

I'll submit another patch because this driver updates
netdev->stats.rx_bytes/rx_packets in a racy way (several cpus can do
these updates concurrently)

Implementing a get_stats() method to fold rx_ring counters will solve
this and brings 64bit counters as well for RX side.
(TX counters are already 64bit enabled)



