From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netfilter: xtables: inclusion of xt_TEE
Date: Thu, 01 Apr 2010 13:54:43 +0200
Message-ID: <4BB48983.909@trash.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-4-git-send-email-jengelh@medozas.de> <4BB47698.6070102@trash.net> <alpine.LSU.2.01.1004011304350.17429@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1004011304350.17429@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2010-04-01 12:34, Patrick McHardy wrote:
>>> +static bool
>>> +tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *inf=
o)
>>> +{
>>> +	const struct iphdr *iph =3D ip_hdr(skb);
>>> +	struct rtable *rt;
>>> +	struct flowi fl;
>>> +	int err;
>>> +
>>> +	memset(&fl, 0, sizeof(fl));
>>> +	fl.iif  =3D skb->skb_iif;
>> I'm not sure you really should set iif here. We usually (tunnels, RE=
JECT
>> etc) packets generated locally as new packets.
>>> +	fl.mark =3D skb->mark;
>> The same applies to mark.
>=20
> If you use TEE in PREROUTING or INPUT, teeing acts more like FORWARD =
than
> OUTPUT, though. All TEE does is lookup a route to a new fl.dst, but i=
t keeps
> the original src address in fl.src, so if somebody has some source-ba=
sed policy
> routing, it could suddenly behave different. What do you think?

That might make it unnessarily complicated to use src-based routing
when using TEE. I guess you'd usually have a host for logging or IDS
somewhere on a private network and TEE packets there. So specifying
oif and gateway seems most useful to me.

>>> +/*
>>> + * To detect and deter routed packet loopback when using the --tee=
 option, we
>>> + * take a page out of the raw.patch book: on the copied skb, we se=
t up a fake
>>> + * ->nfct entry, pointing to the local &route_tee_track. We skip r=
outing
>>> + * packets when we see they already have that ->nfct.
>> So without conntrack, people may create loops? If that's the case,
>> I'd suggest to simply forbid TEE'ing packets to loopback. That
>> doesn't seem to be very useful anyways.
>=20
>>> +#ifdef WITH_CONNTRACK
>>> +	if (skb->nfct =3D=3D &tee_track.ct_general)
>>> +		/*
>>> +		 * Loopback - a packet we already routed, is to be
>>> +		 * routed another time. Avoid that, now.
>>> +		 */
> 	printk("loopback - dropped\n");
>>> +		return NF_DROP;
>>> +#endif
>=20
> We are looking at a historic piece of code - and comments, which
> traces back to when xt_NOTRACK was still in POM.
>=20
> {
>     =E2=86=92   /* Previously seen (loopback)? Ignore. */
>     =E2=86=92   if ((*pskb)->nfct !=3D NULL)
>     =E2=86=92       =E2=86=92   return IPT_CONTINUE;
>=20
>     =E2=86=92   /* Attach fake conntrack entry.=C2=B7
>     =E2=86=92      If there is a real ct entry correspondig to this p=
acket,=C2=B7
>     =E2=86=92      it'll hang aroun till timing out. We don't deal wi=
th it
>     =E2=86=92      for performance reasons. JK */
>     =E2=86=92   (*pskb)->nfct =3D &ip_conntrack_untracked.infos[IP_CT=
_NEW];
>     =E2=86=92   nf_conntrack_get((*pskb)->nfct);
>=20
>     =E2=86=92   return IPT_CONTINUE;
> }
>=20
> Let's look at the condition "skb->nfct =3D=3D &tee_track.ct_general" =
in detail. An
> skb can only already have tee_track when it has been teed.
>=20
> The teed packet however never traversed Xtables at all. Of course tha=
t changes
> once the nesting patch is applied. But was someone really thinking of=
 this, 6
> years ago?
>=20
> That actually made me wonder and dig in history, and it turns out tha=
t
> ipt_ROUTE allowed the packet to be fed back into netif_rx (commit
> bee4e80167e3d024bdb80f400f4ecc8de47cfb03 in pom-ng.git), which would
> explain all the loopback stuff. Since modern xt_TEE does not do
> that evil thing, the comment is a walnut-hard remainder of past times=
=2E
>=20
> I shall remove it now that it has been spotted.

Yeah, but currently it does allow packets to be looped back. These
packets will also go through the netfilter hooks again.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
