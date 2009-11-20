From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 15:45:42 +0100
Message-ID: <4B06AB96.8040805@gmail.com>
References: <20091120133245.GA9038@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39669 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbZKTOpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 09:45:44 -0500
In-Reply-To: <20091120133245.GA9038@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On 20-11-2009 00:46, Eric Dumazet wrote:
>> Here is first version of XPS.
>>
>> Goal of XPS is to free TX completed skbs by the cpu that submitted t=
he transmit.
>=20
> But why?... OK, you write in another message about sock_wfree(). Then
> how about users, who don't sock_wfree (routers)? Will there be any wa=
y
> to disable it?


This is open for discussion, but I saw no problem with routing workload=
s.

sock_wfree() is not that expensive for tcp anyway.
You also have a cost of kfreeing() two blocks of memory per skb, if all=
ocation was done by another cpu.

If this happens to be a problem, we can immediately free packet if it=20
has no destructors :

At xmit time, initialize skb->sending_cpu like that

skb->sending_cpu =3D (skb->destructor) ? smp_processor_id() : 0xFFFF;

to make sure we dont touch too many cache lines at tx completion time.


>> +/*
>> + * XPS : Xmit Packet Steering
>> + *
>> + * TX completion packet freeing is performed on cpu that sent packe=
t.
>> + */
>> +#if defined(CONFIG_SMP)
>=20
> Shouldn't it be in the Makefile?

It is in Makefile too, I let it in prelim code to make it clear this wa=
s CONFIG_SMP only.

>=20
> ...
>> +/*
>> + * called at end of net_rx_action()
>> + * preemption (and cpu migration/offline/online) disabled
>> + */
>> +void xps_flush(void)
>> +{
>> +	int cpu, prevlen;
>> +	struct sk_buff_head *head =3D per_cpu_ptr(xps_array, smp_processor=
_id());
>> +	struct xps_pcpu_queue *q;
>> +	struct sk_buff *skb;
>> +
>> +	for_each_cpu_mask_nr(cpu, __get_cpu_var(xps_cpus)) {
>> +		q =3D &per_cpu(xps_pcpu_queue, cpu);
>> +		if (cpu_online(cpu)) {
>> +			spin_lock(&q->list.lock);
>=20
> This lock probably needs irq disabling: let's say 2 cpus run this at
> the same time and both are interrupted with these (previously
> scheduled) IPIs?

Repeat after me :

lockdep is my friend, lockdep is my friend, lockdep is my friend... :)

Seriously, I must think again on this locking schem.

>> +static void remote_free_skb_list(void *arg)
>> +{
>> +	struct sk_buff *last;
>> +	struct softnet_data *sd;
>> +	struct xps_pcpu_queue *q =3D arg; /* &__get_cpu_var(xps_pcpu_queue=
); */
>> +
>> +	spin_lock(&q->list.lock);
>> +
>> +	last =3D q->list.prev;
>=20
> Is q->list handled in case this cpu goes down before this IPI is
> triggered?


[block migration] (how ? this is the question)

if (cpu_online(cpu)) {=20
	give_work_to_cpu(cpu);
	trigger IPI
} else {
	handle_work_ourself()
}

[unblock migration]

General problem is : what guards cpu going off line between the if (cpu=
_online(cpu))
and the IPI.
I dont know yet, but it seems that disabling preemption is enough to ge=
t this
guarantee. This seems strange.

We can add a notifier (or better call a function from existing one : de=
v_cpu_callback()) to=20
flush this queue when necessary.

Thanks

