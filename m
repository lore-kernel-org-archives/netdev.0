From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFT 3/4] netfilter: use sequence number synchronization for
 counters
Date: Wed, 28 Jan 2009 07:17:04 +0100
Message-ID: <497FF860.9080406@cosmosbay.com>
References: <20090127235310.159946902@vyatta.com> <20090127235508.952787501@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090127235508.952787501@vyatta.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> Change how synchronization is done on the iptables counters. Use seqc=
ount
> wrapper instead of depending on reader/writer lock.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
>  =20
> --- a/net/ipv4/netfilter/ip_tables.c	2009-01-27 14:48:41.567879095 -0=
800
> +++ b/net/ipv4/netfilter/ip_tables.c	2009-01-27 15:45:05.766673246 -0=
800
> @@ -366,7 +366,9 @@ ipt_do_table(struct sk_buff *skb,
>  			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) !=3D 0)
>  				goto no_match;
> =20
> +			write_seqcount_begin(&e->seq);
>  			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
> +			write_seqcount_end(&e->seq);
>  =20
Its not very good to do it like this, (one seqcount_t per rule per cpu)

> =20
>  			t =3D ipt_get_target(e);
>  			IP_NF_ASSERT(t->u.kernel.target);
> @@ -758,6 +760,7 @@ check_entry_size_and_hooks(struct ipt_en
>  	   < 0 (not IPT_RETURN). --RR */
> =20
>  	/* Clear counters and comefrom */
> +	seqcount_init(&e->seq);
>  	e->counters =3D ((struct xt_counters) { 0, 0 });
>  	e->comefrom =3D 0;
> =20
> @@ -915,14 +918,17 @@ get_counters(const struct xt_table_info=20
>  			  &i);
> =20
>  	for_each_possible_cpu(cpu) {
> +		struct ipt_entry *e =3D t->entries[cpu];
> +		unsigned int start;
> +
>  		if (cpu =3D=3D curcpu)
>  			continue;
>  		i =3D 0;
> -		IPT_ENTRY_ITERATE(t->entries[cpu],
> -				  t->size,
> -				  add_entry_to_counter,
> -				  counters,
> -				  &i);
> +		do {
> +			start =3D read_seqcount_begin(&e->seq);
> +			IPT_ENTRY_ITERATE(e, t->size,
> +					  add_entry_to_counter, counters, &i);
> +		} while (read_seqcount_retry(&e->seq, start));
>  =20
This will never complete on a loaded machine and a big set of rules.
When we reach the end of IPT_ENTRY_ITERATE, we notice many packets came=
=20
while doing the iteration and restart,
with wrong accumulated values (no rollback of what was done to accumula=
tor)

You want to do the seqcount_begin/end in the leaf function=20
(add_entry_to_counter()), and make accumulate a value pair (bytes/count=
er)
only once you are sure they are correct.

Using one seqcount_t per rule (struct ipt_entry) is very expensive.=20
(This is 4 bytes per rule X num_possible_cpus())

You need one seqcount_t per cpu


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
