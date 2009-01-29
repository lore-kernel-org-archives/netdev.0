From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 5/5] netfilter: convert x_tables to use RCU
Date: Thu, 29 Jan 2009 15:16:24 -0800
Message-ID: <20090129151624.37dce05e@extreme>
References: <20090129062521.092861272@vyatta.com>
	<20090129062549.364601936@vyatta.com>
	<498235F0.3010806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43212 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758026AbZA2XQ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 18:16:26 -0500
In-Reply-To: <498235F0.3010806@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jan 2009 00:04:16 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Replace existing reader/writer lock with Read-Copy-Update to
> > elminate the overhead of a read lock on each incoming packet.
> > This should reduce the overhead of iptables especially on SMP
> > systems.
> >=20
> > The previous code used a reader-writer lock for two purposes.
> > The first was to ensure that the xt_table_info reference was not in
> > process of being changed. Since xt_table_info is only freed via one
> > routine, it was a direct conversion to RCU.
> >=20
> > The other use of the reader-writer lock was to to block changes
> > to counters while they were being read. This synchronization was
> > fixed by the previous patch.  But still need to make sure table inf=
o
> > isn't going away.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> >=20
> > ---
> >  include/linux/netfilter/x_tables.h |   10 ++++++-
> >  net/ipv4/netfilter/arp_tables.c    |   12 ++++-----
> >  net/ipv4/netfilter/ip_tables.c     |   12 ++++-----
> >  net/ipv6/netfilter/ip6_tables.c    |   12 ++++-----
> >  net/netfilter/x_tables.c           |   48 ++++++++++++++++++++++++=
++-----------
> >  5 files changed, 60 insertions(+), 34 deletions(-)
> >=20
> > --- a/include/linux/netfilter/x_tables.h	2009-01-28 22:04:39.316517=
913 -0800
> > +++ b/include/linux/netfilter/x_tables.h	2009-01-28 22:14:54.648490=
491 -0800
> > @@ -352,8 +352,8 @@ struct xt_table
> >  	/* What hooks you will enter on */
> >  	unsigned int valid_hooks;
> > =20
> > -	/* Lock for the curtain */
> > -	rwlock_t lock;
> > +	/* Lock for curtain */
> > +	spinlock_t lock;
> > =20
> >  	/* Man behind the curtain... */
> >  	struct xt_table_info *private;
> > @@ -386,6 +386,12 @@ struct xt_table_info
> >  	/* Secret compartment */
> >  	seqcount_t *seq;
> > =20
> > +	/* For the dustman... */
> > +	union {
> > +		struct rcu_head rcu;
> > +		struct work_struct work;
> > +	};
> > +
> >  	/* ipt_entry tables: one per CPU */
> >  	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ *=
/
> >  	char *entries[1];
> > --- a/net/ipv4/netfilter/arp_tables.c	2009-01-28 22:13:16.423490077=
 -0800
> > +++ b/net/ipv4/netfilter/arp_tables.c	2009-01-28 22:14:54.648490491=
 -0800
> > @@ -238,8 +238,8 @@ unsigned int arpt_do_table(struct sk_buf
> >  	indev =3D in ? in->name : nulldevname;
> >  	outdev =3D out ? out->name : nulldevname;
> > =20
> > -	read_lock_bh(&table->lock);
> > -	private =3D table->private;
> > +	rcu_read_lock_bh();
> > +	private =3D rcu_dereference(table->private);
> >  	table_base =3D (void *)private->entries[smp_processor_id()];
> >  	seq =3D per_cpu_ptr(private->seq, smp_processor_id());
> >  	e =3D get_entry(table_base, private->hook_entry[hook]);
> > @@ -315,7 +315,7 @@ unsigned int arpt_do_table(struct sk_buf
> >  			e =3D (void *)e + e->next_offset;
> >  		}
> >  	} while (!hotdrop);
> > -	read_unlock_bh(&table->lock);
> > +	rcu_read_unlock_bh();
> > =20
> >  	if (hotdrop)
> >  		return NF_DROP;
> > @@ -1163,8 +1163,8 @@ static int do_add_counters(struct net *n
> >  		goto free;
> >  	}
> > =20
> > -	write_lock_bh(&t->lock);
> > -	private =3D t->private;
> > +	rcu_read_lock_bh();
> > +	private =3D rcu_dereference(t->private);
> >  	if (private->number !=3D num_counters) {
> >  		ret =3D -EINVAL;
> >  		goto unlock_up_free;
> > @@ -1179,7 +1179,7 @@ static int do_add_counters(struct net *n
> >  			   paddc,
> >  			   &i);
> >   unlock_up_free:
> > -	write_unlock_bh(&t->lock);
> > +	rcu_read_unlock_bh();
> >  	xt_table_unlock(t);
> >  	module_put(t->me);
> >   free:
> > --- a/net/ipv4/netfilter/ip_tables.c	2009-01-28 22:06:10.596739805 =
-0800
> > +++ b/net/ipv4/netfilter/ip_tables.c	2009-01-28 22:14:54.648490491 =
-0800
> > @@ -348,9 +348,9 @@ ipt_do_table(struct sk_buff *skb,
> >  	mtpar.family  =3D tgpar.family =3D NFPROTO_IPV4;
> >  	tgpar.hooknum =3D hook;
> > =20
> > -	read_lock_bh(&table->lock);
> > +	rcu_read_lock_bh();
> >  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
> > -	private =3D table->private;
> > +	private =3D rcu_dereference(table->private);
> >  	table_base =3D (void *)private->entries[smp_processor_id()];
> >  	seq =3D per_cpu_ptr(private->seq, smp_processor_id());
> >  	e =3D get_entry(table_base, private->hook_entry[hook]);
> > @@ -449,7 +449,7 @@ ipt_do_table(struct sk_buff *skb,
> >  		}
> >  	} while (!hotdrop);
> > =20
> > -	read_unlock_bh(&table->lock);
> > +	rcu_read_unlock_bh();
> > =20
> >  #ifdef DEBUG_ALLOW_ALL
> >  	return NF_ACCEPT;
> > @@ -1408,8 +1408,8 @@ do_add_counters(struct net *net, void __
> >  		goto free;
> >  	}
> > =20
> > -	write_lock_bh(&t->lock);
> > -	private =3D t->private;
> > +	rcu_read_lock_bh();
> > +	private =3D rcu_dereference(t->private);
>=20
> I feel litle bit nervous seeing a write_lock_bh() changed to a rcu_re=
ad_lock()

=46acts, it is only updating entries on current cpu

> Also, add_counter_to_entry() is not using seqcount protection, so ano=
ther thread
> doing an iptables -L in parallel with this thread will possibly get c=
orrupted counters.
add_counter_to_entry is local to current CPU.


> (With write_lock_bh(), this corruption could not occur)
>=20
>=20
