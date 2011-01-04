From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 2/2] net_sched: implement a root
 container qdisc sch_mclass
Date: Tue, 04 Jan 2011 07:46:43 +0100
Message-ID: <1294123603.2711.33.camel@edumazet-laptop>
References: <20110104030553.13187.69135.stgit@jf-dev1-dcblab>
	 <20110104030558.13187.27076.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jarkao2@gmail.com, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f66.google.com ([74.125.82.66]:54306 "EHLO
	mail-ww0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab1ADGqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 01:46:49 -0500
Received: by wwb24 with SMTP id 24so4898899wwb.1
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 22:46:48 -0800 (PST)
In-Reply-To: <20110104030558.13187.27076.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 janvier 2011 =C3=A0 19:05 -0800, John Fastabend a =C3=A9cri=
t :
> This implements a mqprio queueing discipline that by default creates
> a pfifo_fast qdisc per tx queue and provides the needed configuration
> interface.


> +static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct net_device *dev =3D qdisc_dev(sch);
> +	struct mqprio_sched *priv =3D qdisc_priv(sch);
> +	unsigned char *b =3D skb_tail_pointer(skb);
> +	struct tc_mqprio_qopt opt;
> +	struct Qdisc *qdisc;
> +	unsigned int i;
> +
> +	sch->q.qlen =3D 0;
> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
> +
> +	for (i =3D 0; i < dev->num_tx_queues; i++) {
> +		qdisc =3D netdev_get_tx_queue(dev, i)->qdisc;
> +		spin_lock_bh(qdisc_lock(qdisc));
> +		sch->q.qlen		+=3D qdisc->q.qlen;
> +		sch->bstats.bytes	+=3D qdisc->bstats.bytes;
> +		sch->bstats.packets	+=3D qdisc->bstats.packets;
> +		sch->qstats.qlen	+=3D qdisc->qstats.qlen;
> +		sch->qstats.backlog	+=3D qdisc->qstats.backlog;
> +		sch->qstats.drops	+=3D qdisc->qstats.drops;
> +		sch->qstats.requeues	+=3D qdisc->qstats.requeues;
> +		sch->qstats.overlimits	+=3D qdisc->qstats.overlimits;
> +		spin_unlock_bh(qdisc_lock(qdisc));
> +	}
> +

I understand this code already exists in mq, I just want to note that
some qdiscs update their stats in their dump() subroutine, because thei=
r
enqueue()/dequeue() doesnt update all fields.

We might add a gather_stats() method, eventually, to get rid of all
oddities we currently have with 0 backlogs (or qlen) here and here ;)

=46or example, I am not even sure qdisc->qstats.qlen should not be
replaced by to qdisc->qstats.qlen in your loop, as done in
mqprio_dump_class_stats()

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


