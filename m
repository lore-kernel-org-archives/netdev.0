From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] netfilter: conntrack race between dump_table and destroy
Date: Thu, 25 Nov 2010 07:34:33 +0100
Message-ID: <1290666873.2798.89.camel@edumazet-laptop>
References: <20101124222716.437c5547@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101124222716.437c5547@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 24 novembre 2010 =C3=A0 22:27 -0800, Stephen Hemminger a =C3=
=A9crit :
> A customer reported a crash and the backtrace showed that
> ctnetlink_dump_table was running while a conntrack entry was
> being destroyed.  It looks like the code for walking the table
> with hlist_nulls_for_each_entry_rcu is not correctly handling the
> case where it finds a deleted entry.
>=20
> According to RCU documentation, when using hlist_nulls the reader
> must handle the case of seeing a deleted entry and not proceed
> further down the linked list.  For lookup the correct behavior would
> be to restart the scan, but that would generate duplicate entries.
>=20
> This patch is the simplest one of three alternatives:
>   1) if dead entry detected, skip the rest of the hash chain (see bel=
ow)
>   2) remember skb location at start of hash chain and rescan that cha=
in
>   3) switch to using a full lock when scanning rather than RCU.
> It all depends on the amount of effort versus consistency of results.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> --- a/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:11:27.661682=
148 -0800
> +++ b/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:22:28.431980=
247 -0800
> @@ -651,8 +651,12 @@ restart:
>  			if (NF_CT_DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
>  				continue;
>  			ct =3D nf_ct_tuplehash_to_ctrack(h);
> +
> +			/* if entry is being deleted then can not proceed
> +			 * past this point. */
>  			if (!atomic_inc_not_zero(&ct->ct_general.use))
> -				continue;
> +				break;
> +
>  			/* Dump entries of a given L3 protocol number.
>  			 * If it is not specified, ie. l3proto =3D=3D 0,
>  			 * then dump everything. */
> --

Hmm...

How restarting the loop can be a problem ?=20

There must be a bug somewhere else that your patch try to avoid, not to
really fix.

Normally, destroyed ct is removed eventually from the chain, so this
lookup should stop.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
