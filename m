From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 21:04:34 +0100
Message-ID: <20091120200434.GB2688@ami.dom.local>
References: <20091120133245.GA9038@ff.dom.local>
 <4B06AB96.8040805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:64559 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbZKTUEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:04:43 -0500
Received: by bwz27 with SMTP id 27so3727625bwz.21
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 12:04:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B06AB96.8040805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 03:45:42PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On 20-11-2009 00:46, Eric Dumazet wrote:
> >> Here is first version of XPS.
> >>
> >> Goal of XPS is to free TX completed skbs by the cpu that submitted=
 the transmit.
> >=20
> > But why?... OK, you write in another message about sock_wfree(). Th=
en
> > how about users, who don't sock_wfree (routers)? Will there be any =
way
> > to disable it?
>=20
>=20
> This is open for discussion, but I saw no problem with routing worklo=
ads.

IMHO, it should depend on testing: if you can  prove there is a
distinct gain in "common" use case (which isn't probably a numa box
used e.g. for google.com or even kernel.org yet), and no visible
slowdown for such a router, then we could probably forget about
disabling, and look more at optimizations of the fast path.

>=20
> sock_wfree() is not that expensive for tcp anyway.
> You also have a cost of kfreeing() two blocks of memory per skb, if a=
llocation was done by another cpu.
>=20
> If this happens to be a problem, we can immediately free packet if it=
=20
> has no destructors :
>=20
> At xmit time, initialize skb->sending_cpu like that
>=20
> skb->sending_cpu =3D (skb->destructor) ? smp_processor_id() : 0xFFFF;
>=20
> to make sure we dont touch too many cache lines at tx completion time=
=2E
>=20
>=20
> >> +/*
> >> + * XPS : Xmit Packet Steering
> >> + *
> >> + * TX completion packet freeing is performed on cpu that sent pac=
ket.
> >> + */
> >> +#if defined(CONFIG_SMP)
> >=20
> > Shouldn't it be in the Makefile?
>=20
> It is in Makefile too, I let it in prelim code to make it clear this =
was CONFIG_SMP only.

Aha! Now it's clear why I made this mistake. ;-)
>=20
> >=20
> > ...
> >> +/*
> >> + * called at end of net_rx_action()
> >> + * preemption (and cpu migration/offline/online) disabled
> >> + */
> >> +void xps_flush(void)
> >> +{
> >> +	int cpu, prevlen;
> >> +	struct sk_buff_head *head =3D per_cpu_ptr(xps_array, smp_process=
or_id());
> >> +	struct xps_pcpu_queue *q;
> >> +	struct sk_buff *skb;
> >> +
> >> +	for_each_cpu_mask_nr(cpu, __get_cpu_var(xps_cpus)) {
> >> +		q =3D &per_cpu(xps_pcpu_queue, cpu);
> >> +		if (cpu_online(cpu)) {
> >> +			spin_lock(&q->list.lock);
> >=20
> > This lock probably needs irq disabling: let's say 2 cpus run this a=
t
> > the same time and both are interrupted with these (previously
> > scheduled) IPIs?
>=20
> Repeat after me :
>=20
> lockdep is my friend, lockdep is my friend, lockdep is my friend... :=
)

Hmm... Actually, why did I have to do lockdep's job...
>=20
> Seriously, I must think again on this locking schem.
>=20
> >> +static void remote_free_skb_list(void *arg)
> >> +{
> >> +	struct sk_buff *last;
> >> +	struct softnet_data *sd;
> >> +	struct xps_pcpu_queue *q =3D arg; /* &__get_cpu_var(xps_pcpu_que=
ue); */
> >> +
> >> +	spin_lock(&q->list.lock);
> >> +
> >> +	last =3D q->list.prev;
> >=20
> > Is q->list handled in case this cpu goes down before this IPI is
> > triggered?
>=20
>=20
> [block migration] (how ? this is the question)
>=20
> if (cpu_online(cpu)) {=20
> 	give_work_to_cpu(cpu);
> 	trigger IPI
> } else {
> 	handle_work_ourself()
> }
>=20
> [unblock migration]
>=20
> General problem is : what guards cpu going off line between the if (c=
pu_online(cpu))
> and the IPI.
> I dont know yet, but it seems that disabling preemption is enough to =
get this
> guarantee. This seems strange.
>=20
> We can add a notifier (or better call a function from existing one : =
dev_cpu_callback()) to=20
> flush this queue when necessary.

Using dev_cpu_callback() looks quite obvious to me.

Jarek P.
