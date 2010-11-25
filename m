From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] netfilter: conntrack race between dump_table and destroy
Date: Wed, 24 Nov 2010 23:00:04 -0800
Message-ID: <20101124230004.1dc28e5a@nehalam>
References: <20101124222716.437c5547@nehalam>
	<1290666873.2798.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290666873.2798.89.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Nov 2010 07:34:33 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 24 novembre 2010 =E0 22:27 -0800, Stephen Hemminger a =E9=
crit :
> > A customer reported a crash and the backtrace showed that
> > ctnetlink_dump_table was running while a conntrack entry was
> > being destroyed.  It looks like the code for walking the table
> > with hlist_nulls_for_each_entry_rcu is not correctly handling the
> > case where it finds a deleted entry.
> >=20
> > According to RCU documentation, when using hlist_nulls the reader
> > must handle the case of seeing a deleted entry and not proceed
> > further down the linked list.  For lookup the correct behavior woul=
d
> > be to restart the scan, but that would generate duplicate entries.
> >=20
> > This patch is the simplest one of three alternatives:
> >   1) if dead entry detected, skip the rest of the hash chain (see b=
elow)
> >   2) remember skb location at start of hash chain and rescan that c=
hain
> >   3) switch to using a full lock when scanning rather than RCU.
> > It all depends on the amount of effort versus consistency of result=
s.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> >=20
> > --- a/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:11:27.6616=
82148 -0800
> > +++ b/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:22:28.4319=
80247 -0800
> > @@ -651,8 +651,12 @@ restart:
> >  			if (NF_CT_DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
> >  				continue;
> >  			ct =3D nf_ct_tuplehash_to_ctrack(h);
> > +
> > +			/* if entry is being deleted then can not proceed
> > +			 * past this point. */
> >  			if (!atomic_inc_not_zero(&ct->ct_general.use))
> > -				continue;
> > +				break;
> > +
> >  			/* Dump entries of a given L3 protocol number.
> >  			 * If it is not specified, ie. l3proto =3D=3D 0,
> >  			 * then dump everything. */
> > --
>=20
> Hmm...
>=20
> How restarting the loop can be a problem ?=20

At this point in the loop, some entries have been placed in the netlink
dump buffer. Restarting the loop will cause duplicate entries.

> There must be a bug somewhere else that your patch try to avoid, not =
to
> really fix.
>=20
> Normally, destroyed ct is removed eventually from the chain, so this
> lookup should stop.

Because hlist_nulls it is possible to walk into a dead entry, in that
case the next pointer is no longer valid.

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
