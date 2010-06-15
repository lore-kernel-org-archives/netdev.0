From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] loopback: Implement 64bit stats on 32bit
 arches
Date: Tue, 15 Jun 2010 09:23:04 +0200
Message-ID: <1276586584.2541.22.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
	 <20100615064923.GF6138@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46983 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab0FOHXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 03:23:07 -0400
Received: by wyb40 with SMTP id 40so4511711wyb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 00:23:06 -0700 (PDT)
In-Reply-To: <20100615064923.GF6138@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 16:49 +1000, Nick Piggin a =C3=A9crit :
> On Mon, Jun 14, 2010 at 11:14:12PM -0700, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 14 Jun 2010 17:59:22 +0200
> >=20
> > > Uses a seqcount_t to synchronize stat producer and consumer, for =
packets
> > > and bytes counter, now u64 types.
> > >=20
> > > (dropped counter being rarely used, stay a native "unsigned long"=
 type)
> > >=20
> > > No noticeable performance impact on x86, as it only adds two incr=
ements
> > > per frame. It might be more expensive on arches where smp_wmb() i=
s not
> > > free.
> > >=20
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Applied, but I suspect we might end up eventually needing to
> > abstract this kind of technique in a common place so other
> > spots can use it.
>=20

David, I was planning adding similar stuff for SNMP, xt_RATEEST and txq
accounting, so yes, I'll probably move helpers to a common include file=
=2E

This first patch was a first shot to introduce the ground.

> Check i_size stuff in include/linux/fs.h if you consider doing this.

Yes, I was aware of this stuff.

> And keep preempt in mind too. I assume you can't be preempted at this
> point, but if you're prone to change the locking, it might be worth
> the (small) cost of doing explicit preempt_disable() (and maybe to
> help the sanity of the -rt guys too).
>=20

Yes, we cannot be preempted at this point, as ndo_start_xmit() handlers
are called with BH disabled (there is a comment for this assertion in
front of loopback_xmit())

dev_queue_xmit()=20
  rcu_read_lock_bh();
  ...
  ndo_start_xmit();

I'll take care of preempt status for following patches, but I suspect
its more a BH enable/disable question in network stack anyway.

Thanks !


