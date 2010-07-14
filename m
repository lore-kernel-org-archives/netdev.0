From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Wed, 14 Jul 2010 12:17:57 +0800
Message-ID: <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
	<1279078875.2444.103.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35104 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab0GNESS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 00:18:18 -0400
Received: by vws5 with SMTP id 5so6727784vws.19
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 21:18:18 -0700 (PDT)
In-Reply-To: <1279078875.2444.103.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 14, 2010 at 11:41 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mercredi 14 juillet 2010 =E0 11:17 +0800, Changli Gao a =E9crit :
>> I want to know if I can assign the sk to skb as nf_tproxy_core does =
to avoid
>> the duplicate search later. Thanks.
>>
>
> I suggest we first correct bugs before adding new features.
>
> For me, tproxy is a high suspect at this moment, I would not use it o=
n
> production machine.
>
>> act_cpu: packet distributing
>>
>> This TC action can be used to redirect packets to the CPU:
>> =A0* specified by the cpuid option
>> =A0* specified by the class minor ID obtained previously
>> =A0* on which the corresponding application runs
>>
>> It supports the similar functions of RPS and RFS, but is more flexib=
le.
>>
>
> Thins kind of claims is disgusting.
>
> No documentation, =A0I have no idea how you setup the thing.

for example:

redirect packets to the CPU on which the corresponding application runs

tc qdisc add dev eth0 ingress
tc filter add dev eth0 parent ffff:0 protocol ip basic action cpu socke=
t

redirect packets to special CPU.

tc filter add dev eth0 parent ffff:0 protocol ip basic action cpu cpuid=
 1

sport hash packet distributing among CPU 0-1.

tc filter add dev eth0 parent ffff:0 protocol ip handle 1 flow hash
keys proto-src divisor 2 action cpu map 1

>> +static inline void sock_save_cpu(struct sock *sk)
>> +{
>> +#if defined(CONFIG_NET_ACT_CPU) || defined(CONFIG_NET_ACT_CPU_MODUL=
E)
>> + =A0 =A0 int cpu =3D get_cpu();
>> + =A0 =A0 if (sk->sk_cpu !=3D cpu)
>> + =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_cpu =3D cpu;
>> + =A0 =A0 put_cpu();
>
> sk->sk_cpu =3D raw_smp_processor_id();

Thanks.

>
> Why doing the search again, in case skb->sk already set by another
> module before you, like tproxy ?
>

Although it is unlikely skb->sk is non null, as tc is before
netfilter, I will handle this case. Thanks.

>> +static int tcf_cpu(struct sk_buff *skb, struct tc_action *a,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct tcf_result *res)
>> +{
>> + =A0 =A0 struct tcf_cpu *p =3D a->priv;
>> + =A0 =A0 u32 type;
>> + =A0 =A0 u32 value;
>> + =A0 =A0 int cpu, action;
>> + =A0 =A0 struct sk_buff *nskb;
>> + =A0 =A0 unsigned int qtail;
>> +
>> + =A0 =A0 spin_lock(&p->tcf_lock);
>
> Ok, the big lock...
>
> We have a lockless TCP/UDP input path, and this modules adds a lock
> again.
>
>> + =A0 =A0 p->tcf_tm.lastuse =3D jiffies;
>> + =A0 =A0 p->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
>> + =A0 =A0 p->tcf_bstats.packets++;
>> + =A0 =A0 type =3D p->type;
>> + =A0 =A0 value =3D p->value;
>> + =A0 =A0 action =3D p->tcf_action;
>> + =A0 =A0 spin_unlock(&p->tcf_lock);
>> +
>
> Please change all this crap =A0(legacy crap, copied from other tc
> modules), by modern one, using RCU and no locking in hot path.
>

Thanks, I'll try. It is a write critical section, and for me it is
difficult to convert this lock to RCU. Could you show me some
examples?
 Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
