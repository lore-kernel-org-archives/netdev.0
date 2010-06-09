From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.35-rc2, CONFIG_RPS is filling the dmesg log
Date: Wed, 09 Jun 2010 15:42:33 +0200
Message-ID: <1276090953.2442.140.camel@edumazet-laptop>
References: <4C0EAE3E.4070708@canonical.com>
	 <4C0F96B4.2000307@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36598 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757646Ab0FINmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 09:42:38 -0400
Received: by wyb40 with SMTP id 40so137363wyb.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 06:42:35 -0700 (PDT)
In-Reply-To: <4C0F96B4.2000307@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 juin 2010 =C3=A0 07:27 -0600, Tim Gardner a =C3=A9crit :
> On 06/08/2010 02:55 PM, Tim Gardner wrote:
> > With 2.6.35-rc2 my dmesg log is being flooded with messages like th=
is:
> >
> > br0 received packet on queue 4, but number of RX queues is 1
> >
> > This machine is bridged for KVM and has 2 igb network adapters.
> >
> > The root cause appears to be CONFIG_RPS=3Dy and the fact that none =
of the
> > drivers that call skb_record_rx_queue() perform their net device
> > allocation using alloc_netdev_mq(), thereby initializing num_rx_que=
ues
> > to a maximum of 1.
> >
> > Given that this is early RPS days, is the warning in get_rps_cpu()
> > really necessary? It would appear that _all_ of the multi-receive q=
ueue
> > devices that call skb_record_rx_queue() will cause this log noise.
> >
> > By the way, how do you turn off CONFIG_RPS? The only way I could ge=
t it
> > disabled was to change the default in net/Kconfig to 'n'.
> >
> > rtg
>=20
> This is the route that I'm taking with Ubuntu in the short term. I'll=
=20
> have lots of server testers complaining pretty soon if I don't take c=
are=20
> of this now. It does keep my server logs from filling.
>=20
> rtg
>=20

Probably fine, but your commit message is not exact :

  So far no users of skb_record_rx_queue() use alloc_netdev_mq() for
  network device initialization, so don't print a warning about num_rx_=
queues
  imbalances in get_rps_cpu() unless they have actually been allocated.

In fact, drivers that use skb_record_rx_queue() did use alloc_netdev_mq=
().

Problem is : packets going thru bridge/bonding that are not yet
multiqueue enabled. If R[PF]S enabled for these "virtual devices",
we trigger the get_rps_cpu() warning.

Also, in a bonding setup, we still have a problem
because all tx packets will go thru tx queue 0 (dev_pick_tx() job)

(That might be good to know that for Ubuntu server testers)



