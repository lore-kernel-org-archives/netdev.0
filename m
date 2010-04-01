From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 3/5] netfilter: xtables: inclusion of xt_TEE
Date: Thu, 1 Apr 2010 13:39:01 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004011304350.17429@obet.zrqbmnf.qr>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-4-git-send-email-jengelh@medozas.de> <4BB47698.6070102@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BB47698.6070102@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-04-01 12:34, Patrick McHardy wrote:
>> +static bool
>> +tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info=
)
>> +{
>> +	const struct iphdr *iph =3D ip_hdr(skb);
>> +	struct rtable *rt;
>> +	struct flowi fl;
>> +	int err;
>> +
>> +	memset(&fl, 0, sizeof(fl));
>> +	fl.iif  =3D skb->skb_iif;
>
>I'm not sure you really should set iif here. We usually (tunnels, REJE=
CT
>etc) packets generated locally as new packets.
>> +	fl.mark =3D skb->mark;
>
>The same applies to mark.

If you use TEE in PREROUTING or INPUT, teeing acts more like FORWARD th=
an
OUTPUT, though. All TEE does is lookup a route to a new fl.dst, but it =
keeps
the original src address in fl.src, so if somebody has some source-base=
d policy
routing, it could suddenly behave different. What do you think?

>> +/*
>> + * To detect and deter routed packet loopback when using the --tee =
option, we
>> + * take a page out of the raw.patch book: on the copied skb, we set=
 up a fake
>> + * ->nfct entry, pointing to the local &route_tee_track. We skip ro=
uting
>> + * packets when we see they already have that ->nfct.
>
>So without conntrack, people may create loops? If that's the case,
>I'd suggest to simply forbid TEE'ing packets to loopback. That
>doesn't seem to be very useful anyways.

>> +#ifdef WITH_CONNTRACK
>> +	if (skb->nfct =3D=3D &tee_track.ct_general)
>> +		/*
>> +		 * Loopback - a packet we already routed, is to be
>> +		 * routed another time. Avoid that, now.
>> +		 */
	printk("loopback - dropped\n");
>> +		return NF_DROP;
>> +#endif

We are looking at a historic piece of code - and comments, which
traces back to when xt_NOTRACK was still in POM.

{
    =E2=86=92   /* Previously seen (loopback)? Ignore. */
    =E2=86=92   if ((*pskb)->nfct !=3D NULL)
    =E2=86=92       =E2=86=92   return IPT_CONTINUE;

    =E2=86=92   /* Attach fake conntrack entry.=C2=B7
    =E2=86=92      If there is a real ct entry correspondig to this pac=
ket,=C2=B7
    =E2=86=92      it'll hang aroun till timing out. We don't deal with=
 it
    =E2=86=92      for performance reasons. JK */
    =E2=86=92   (*pskb)->nfct =3D &ip_conntrack_untracked.infos[IP_CT_N=
EW];
    =E2=86=92   nf_conntrack_get((*pskb)->nfct);

    =E2=86=92   return IPT_CONTINUE;
}

Let's look at the condition "skb->nfct =3D=3D &tee_track.ct_general" in=
 detail. An
skb can only already have tee_track when it has been teed.

The teed packet however never traversed Xtables at all. Of course that =
changes
once the nesting patch is applied. But was someone really thinking of t=
his, 6
years ago?

That actually made me wonder and dig in history, and it turns out that
ipt_ROUTE allowed the packet to be fed back into netif_rx (commit
bee4e80167e3d024bdb80f400f4ecc8de47cfb03 in pom-ng.git), which would
explain all the loopback stuff. Since modern xt_TEE does not do
that evil thing, the comment is a walnut-hard remainder of past times.

I shall remove it now that it has been spotted.

>> +	/*
>> +	 * If we are in PREROUTING/INPUT, the checksum must be recalculate=
d
>> +	 * since the length could have changed as a result of defragmentat=
ion.
>> +	 *
>> +	 * We also decrease the TTL to mitigate potential TEE loops
>> +	 * between two hosts.
>> +	 *
>> +	 * Set %IP_DF so that the original source is notified of a potenti=
ally
>> +	 * decreased MTU on the clone route. IPv6 does this too.
>> +	 */
>> +	iph =3D ip_hdr(skb);
>> +	iph->frag_off |=3D htons(IP_DF);
>> +	if (par->hooknum =3D=3D NF_INET_PRE_ROUTING ||
>> +	    par->hooknum =3D=3D NF_INET_LOCAL_IN)
>> +		--iph->ttl;
>> +	ip_send_check(iph);
>
>Shouldn't this only be done in PRE_ROUTING/INPUT as stated above?

The csum needs to be recomputed due to the addition of the DF flag.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
