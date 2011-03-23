From: Feng Gao <kernel.goter@gmail.com>
Subject: Re: [PATCH] ip_fragment:kernel may panic when replay big packet with
 RST flag
Date: Wed, 23 Mar 2011 19:37:06 +0800
Message-ID: <AANLkTinLD8A1RVXUn7bF8zSdjUsCNBbF=RA6kvr2zrfi@mail.gmail.com>
References: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com>
	<1300878116.3063.101.camel@edumazet-laptop>
	<AANLkTik5=zcsVHwLsFqMvRvoLyPdhK=1dRUny5+jqoxf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43483 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932242Ab1CWLhH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 07:37:07 -0400
Received: by yxs7 with SMTP id 7so3280856yxs.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 04:37:07 -0700 (PDT)
In-Reply-To: <AANLkTik5=zcsVHwLsFqMvRvoLyPdhK=1dRUny5+jqoxf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is for 2.6.25.16.

2011/3/23 Feng Gao <kernel.goter@gmail.com>:
> Sorry, I will google it.
> I find this problem in 2.4.35. and then I read the Latest code,maybe
> it has the same problem too.
>
> diff -Nur skbuff.h skbuff.h.frag
> --- skbuff.h =A0 =A02008-08-21 02:16:14.000000000 +0800
> +++ skbuff.h.frag =A0 =A0 =A0 2011-03-23 19:30:20.000000000 +0800
> @@ -1754,6 +1754,20 @@
> =A0 =A0 =A0 =A0__nf_copy(dst, src);
> =A0}
>
> +/* This func for ip_fragment deal with RST packet */
> +static inline void nf_copy_rst(struct sk_buff *dst, const struct sk_=
buff *src)
> +{
> +#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODU=
LE)
> + =A0 =A0 =A0 nf_conntrack_put(dst->nfct);
> + =A0 =A0 =A0 nf_conntrack_put_reasm(dst->nfct_reasm);
> +#endif
> +#ifdef CONFIG_BRIDGE_NETFILTER
> + =A0 =A0 =A0 nf_bridge_put(dst->nf_bridge);
> + =A0 =A0 =A0 dst->nf_bridge =A0=3D src->nf_bridge;
> + =A0 =A0 =A0 nf_bridge_get(src->nf_bridge);
> +#endif
> +}
> +
> =A0#ifdef CONFIG_NETWORK_SECMARK
> =A0static inline void skb_copy_secmark(struct sk_buff *to, const stru=
ct
> sk_buff *from)
> =A0{
>
> diff -Nur ip_output.c ip_output.c.frag
> --- ip_output.c 2008-08-21 02:16:14.000000000 +0800
> +++ ip_output.c.frag =A0 =A02011-03-23 19:27:57.000000000 +0800
> @@ -413,7 +413,14 @@
> =A0#ifdef CONFIG_NET_SCHED
> =A0 =A0 =A0 =A0to->tc_index =3D from->tc_index;
> =A0#endif
> - =A0 =A0 =A0 nf_copy(to, from);
> + =A0 =A0 =A0 struct tcphdr *th =3D (struct tcphdr *)((char *)iph + (=
iph->ihl << 2));
> + =A0 =A0 =A0 if(iph->protocol =3D=3D IPPROTO_TCP && th->rst){
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*RST packet*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nf_copy_rst(to, from);
> + =A0 =A0 =A0 }else{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*Other packet*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nf_copy(to, from);
> + =A0 =A0 =A0 }
> =A0#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
> =A0 =A0 defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
> =A0 =A0 =A0 =A0to->nf_trace =3D from->nf_trace;
>
> 2011/3/23 Eric Dumazet <eric.dumazet@gmail.com>:
>> Le mercredi 23 mars 2011 =E0 18:49 +0800, Feng Gao a =E9crit :
>>> Hello everyone:
>>>
>>> PC(A)-linux(B)-PC(C)
>>> computer(linux B) with two net interface,eth0 and eth1.
>>> PC(A) send syn to PC(C) =A0though linux B.
>>> then PC(C) replay a big packet =A0with RST flag(use tcpsic or other=
 tools).
>>>
>>> This RST packet(1480) come in from eth0(mtu 1500) and go out from
>>> eth1(mtu 700), so this RST packet should fragment.
>>>
>>> BUT in tcp_packet func: if the connection has no reply packet,and
>>> receive the RST packet.ip_conntrack should =A0destroy.
>>> =A0 if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If only reply is a RST, we can c=
onsider ourselves not to
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0have an established connecti=
on: this is a fairly common
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0problem case, so we can dele=
te the conntrack
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0immediately. =A0--RR */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (th->rst) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nf_ct_kill_acct(ct,=
 ctinfo, skb);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> =A0 =A0 =A0 =A0 }
>>>
>>> BUT the skb->nfct is not set NULL in func nf_ct_kill_acct.
>>> so when this RST packet goto ip_fragment,ip_fragment call nf_copy, =
in
>>> __nf_copy func
>>> the fragment skb->nfct point to the destory mem.
>>> dst->nfct =3D src->nfct;
>>> nf_conntrack_get(src->nfct);
>>>
>>> SO finally.kfree_skb call destroy_conntrack again. this may result =
in
>>> LINUX B kernel panic.
>>>
>>>
>>> here is the patch,sorry ,i dont know how to use diff to generate pa=
tch.
>>> :-D
>>>
>>
>> Hi Feng
>>
>> Oh well, please learn how to do this. If you are able to make such
>> analysis, you sure can learn how to use diff !!!
>>
>> What is the version of linux you use ?
>>
>>
>>
>>
>
