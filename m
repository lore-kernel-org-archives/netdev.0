From: Feng Gao <kernel.goter@gmail.com>
Subject: Re: [PATCH] ip_fragment:kernel may panic when replay big packet with
 RST flag
Date: Wed, 23 Mar 2011 19:34:31 +0800
Message-ID: <AANLkTik5=zcsVHwLsFqMvRvoLyPdhK=1dRUny5+jqoxf@mail.gmail.com>
References: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com>
	<1300878116.3063.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44780 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932242Ab1CWLec convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 07:34:32 -0400
Received: by yxs7 with SMTP id 7so3280256yxs.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 04:34:32 -0700 (PDT)
In-Reply-To: <1300878116.3063.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I will google it.
I find this problem in 2.4.35. and then I read the Latest code,maybe
it has the same problem too.

diff -Nur skbuff.h skbuff.h.frag
--- skbuff.h    2008-08-21 02:16:14.000000000 +0800
+++ skbuff.h.frag       2011-03-23 19:30:20.000000000 +0800
@@ -1754,6 +1754,20 @@
        __nf_copy(dst, src);
 }

+/* This func for ip_fragment deal with RST packet */
+static inline void nf_copy_rst(struct sk_buff *dst, const struct sk_bu=
ff *src)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+       nf_conntrack_put(dst->nfct);
+       nf_conntrack_put_reasm(dst->nfct_reasm);
+#endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+       nf_bridge_put(dst->nf_bridge);
+       dst->nf_bridge  =3D src->nf_bridge;
+       nf_bridge_get(src->nf_bridge);
+#endif
+}
+
 #ifdef CONFIG_NETWORK_SECMARK
 static inline void skb_copy_secmark(struct sk_buff *to, const struct
sk_buff *from)
 {

diff -Nur ip_output.c ip_output.c.frag
--- ip_output.c 2008-08-21 02:16:14.000000000 +0800
+++ ip_output.c.frag    2011-03-23 19:27:57.000000000 +0800
@@ -413,7 +413,14 @@
 #ifdef CONFIG_NET_SCHED
        to->tc_index =3D from->tc_index;
 #endif
-       nf_copy(to, from);
+       struct tcphdr *th =3D (struct tcphdr *)((char *)iph + (iph->ihl=
 << 2));
+       if(iph->protocol =3D=3D IPPROTO_TCP && th->rst){
+               /*RST packet*/
+               nf_copy_rst(to, from);
+       }else{
+                /*Other packet*/
+               nf_copy(to, from);
+       }
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
        to->nf_trace =3D from->nf_trace;

2011/3/23 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 23 mars 2011 =E0 18:49 +0800, Feng Gao a =E9crit :
>> Hello everyone:
>>
>> PC(A)-linux(B)-PC(C)
>> computer(linux B) with two net interface,eth0 and eth1.
>> PC(A) send syn to PC(C) =A0though linux B.
>> then PC(C) replay a big packet =A0with RST flag(use tcpsic or other =
tools).
>>
>> This RST packet(1480) come in from eth0(mtu 1500) and go out from
>> eth1(mtu 700), so this RST packet should fragment.
>>
>> BUT in tcp_packet func: if the connection has no reply packet,and
>> receive the RST packet.ip_conntrack should =A0destroy.
>> =A0 if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If only reply is a RST, we can co=
nsider ourselves not to
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0have an established connectio=
n: this is a fairly common
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0problem case, so we can delet=
e the conntrack
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0immediately. =A0--RR */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (th->rst) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nf_ct_kill_acct(ct, =
ctinfo, skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 }
>>
>> BUT the skb->nfct is not set NULL in func nf_ct_kill_acct.
>> so when this RST packet goto ip_fragment,ip_fragment call nf_copy, i=
n
>> __nf_copy func
>> the fragment skb->nfct point to the destory mem.
>> dst->nfct =3D src->nfct;
>> nf_conntrack_get(src->nfct);
>>
>> SO finally.kfree_skb call destroy_conntrack again. this may result i=
n
>> LINUX B kernel panic.
>>
>>
>> here is the patch,sorry ,i dont know how to use diff to generate pat=
ch.
>> :-D
>>
>
> Hi Feng
>
> Oh well, please learn how to do this. If you are able to make such
> analysis, you sure can learn how to use diff !!!
>
> What is the version of linux you use ?
>
>
>
>
