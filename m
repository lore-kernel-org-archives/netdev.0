From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] netfilter: conntrack race between dump_table and destroy
Date: Thu, 25 Nov 2010 08:13:34 +0100
Message-ID: <1290669214.2798.109.camel@edumazet-laptop>
References: <20101124222716.437c5547@nehalam>
	 <1290666873.2798.89.camel@edumazet-laptop>
	 <20101124230004.1dc28e5a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61782 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab0KYHNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 02:13:40 -0500
In-Reply-To: <20101124230004.1dc28e5a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 novembre 2010 =C3=A0 23:00 -0800, Stephen Hemminger a =C3=
=A9crit :
> On Thu, 25 Nov 2010 07:34:33 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le mercredi 24 novembre 2010 =C3=A0 22:27 -0800, Stephen Hemminger =
a =C3=A9crit :
> > > A customer reported a crash and the backtrace showed that
> > > ctnetlink_dump_table was running while a conntrack entry was
> > > being destroyed.  It looks like the code for walking the table
> > > with hlist_nulls_for_each_entry_rcu is not correctly handling the
> > > case where it finds a deleted entry.
> > >=20
> > > According to RCU documentation, when using hlist_nulls the reader
> > > must handle the case of seeing a deleted entry and not proceed
> > > further down the linked list.  For lookup the correct behavior wo=
uld
> > > be to restart the scan, but that would generate duplicate entries=
=2E
> > >=20
> > > This patch is the simplest one of three alternatives:
> > >   1) if dead entry detected, skip the rest of the hash chain (see=
 below)
> > >   2) remember skb location at start of hash chain and rescan that=
 chain
> > >   3) switch to using a full lock when scanning rather than RCU.
> > > It all depends on the amount of effort versus consistency of resu=
lts.
> > >=20
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > >=20
> > >=20
> > > --- a/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:11:27.66=
1682148 -0800
> > > +++ b/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:22:28.43=
1980247 -0800
> > > @@ -651,8 +651,12 @@ restart:
> > >  			if (NF_CT_DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
> > >  				continue;
> > >  			ct =3D nf_ct_tuplehash_to_ctrack(h);
> > > +
> > > +			/* if entry is being deleted then can not proceed
> > > +			 * past this point. */
> > >  			if (!atomic_inc_not_zero(&ct->ct_general.use))
> > > -				continue;
> > > +				break;
> > > +
> > >  			/* Dump entries of a given L3 protocol number.
> > >  			 * If it is not specified, ie. l3proto =3D=3D 0,
> > >  			 * then dump everything. */
> > > --
> >=20
> > Hmm...
> >=20
> > How restarting the loop can be a problem ?=20
>=20
> At this point in the loop, some entries have been placed in the netli=
nk
> dump buffer. Restarting the loop will cause duplicate entries.
>=20

Then this is another problem.

We cannot use RCU at all here.

Or we miss valid entries in the chain.

> > There must be a bug somewhere else that your patch try to avoid, no=
t to
> > really fix.
> >=20
> > Normally, destroyed ct is removed eventually from the chain, so thi=
s
> > lookup should stop.
>=20
> Because hlist_nulls it is possible to walk into a dead entry, in that
> case the next pointer is no longer valid.
>=20

RCU should be used where needed, in fast path only, to find one entry,
not to find _all_ entries.

=46or example, we cannot use it for UDP multicast delivery for the same
reasons : If we find a deleted or moved socket, we must restart the loo=
p
and forget all accumulated sockets.

If netlink dumps each entry in the final destination container, then we
cannot restart loop, and cannot use RCU for chain lookup.



