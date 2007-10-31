From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Wed, 31 Oct 2007 16:31:46 -0700 (PDT)
Message-ID: <20071031.163146.92277507.davem@davemloft.net>
References: <20071031194924.2436843e.dada1@cosmosbay.com>
	<m1hck7hrd1.fsf@ebiederm.dsl.xmission.com>
	<4729047B.3080003@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, xemul@openvz.org, netdev@vger.kernel.org,
	devel@openvz.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40464
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753450AbXJaXbr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 19:31:47 -0400
In-Reply-To: <4729047B.3080003@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 31 Oct 2007 23:40:59 +0100

> Eric W. Biederman a =E9crit :
> > Eric Dumazet <dada1@cosmosbay.com> writes:
> >=20
> >=20
> >> Definitly wanted here. Thank you.
> >> One more refcounting on each socket creation/deletion was expensiv=
e.
> >=20
> > Really?  Have you actually measured that?  If the overhead is
> > measurable and expensive we may want to look at per cpu counters or
> > something like that.  So far I don't have any numbers that say any
> > of the network namespace work inherently has any overhead.
>=20
> It seems that on some old opterons (two 246 for example),
> "if (atomic_dec_and_test(&net->count))" is rather expensive yes :(

P4 chips are generally very poor at mispredicted branches and
atomics.  So every atomic you remove from the socket paths
gives a noticable improvement on them.

Network device reference counting is such a stupid problem.  There has
to be a way to get rid of it on the packet side.

I think we could get rid of all of the device refcounting from packets
if we:

1) Formalize "SKB roots".  This is every place a packet
   could sit in the transmit path.

2) On device unregister:

	a) wait for RCU quiesce period
	b) stop_machine_run(skb_walk_roots, netdev, NR_CPUS);

   skb_walk_roots is a function that walks all the places in
   #1, rewriting the packet to point to loopback or whatever
   instead of 'netdev' which we are trying to unregister.

This gives us two things.

=46irst, we no longer would need to rectount net devices
for packet references.

Second, we have a debugging framework for all those dreaded SKB leaks
that keep devices from being unloadable.  As we walk the roots
we'll see where all packets referencing a device actually are.
