From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: init ingress queue
Date: Sat, 4 Dec 2010 16:55:47 +0800
Message-ID: <AANLkTimFk8SDn3RpxDVacZXOS3uwnT-qz+P7GEp+Fjjn@mail.gmail.com>
References: <1291441558-3196-1-git-send-email-xiaosuo@gmail.com> <1291452427.2806.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41372 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab0LDI4I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 03:56:08 -0500
Received: by fxm20 with SMTP id 20so2919801fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 00:56:07 -0800 (PST)
In-Reply-To: <1291452427.2806.90.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 4, 2010 at 4:47 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le samedi 04 d=E9cembre 2010 =E0 13:45 +0800, Changli Gao a =E9crit :
>> The dev field of ingress queue is forgot to initialized, then NULL
>> pointer dereference happens in qdisc_alloc().
>
> < deleted oops >
>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0net/core/dev.c | =A0 =A02 ++
>> =A01 file changed, 2 insertions(+)
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index cd24374..8083c68 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5577,6 +5577,8 @@ struct netdev_queue *dev_ingress_queue_create(=
struct net_device *dev)
>> =A0 =A0 =A0 queue =3D kzalloc(sizeof(*queue), GFP_KERNEL);
>> =A0 =A0 =A0 if (!queue)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 netdev_queue_numa_node_write(queue, -1);
>> + =A0 =A0 queue->dev =3D dev;
>> =A0 =A0 =A0 netdev_init_one_queue(dev, queue, NULL);
>> =A0 =A0 =A0 queue->qdisc =3D &noop_qdisc;
>> =A0 =A0 =A0 queue->qdisc_sleeping =3D &noop_qdisc;
>
> Hi Changli, thanks for bug report and patch.
>
> IMHO there is no point to include this long Oops report in Changelog =
for
> a net-next-2.6 temporary problem, there wont be any bugzilla report.
>

OK, Thanks.

> Instead, you could say it is a followup patch for commits 1d24eb4815d=
1e0
> and f2cd2d3e9b3ef960. Two or three lines with relevant information.
>
> I suggest you submit following patch instead, as this seems cleaner t=
o
> me ?
>
> (factorize the two inits in netdev_init_one_queue())
>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cd24374..36e10b4 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5113,7 +5113,6 @@ static int netif_alloc_netdev_queues(struct net=
_device *dev)
> =A0{
> =A0 =A0 =A0 =A0unsigned int count =3D dev->num_tx_queues;
> =A0 =A0 =A0 =A0struct netdev_queue *tx;
> - =A0 =A0 =A0 int i;
>
> =A0 =A0 =A0 =A0BUG_ON(count < 1);
>
> @@ -5125,10 +5124,6 @@ static int netif_alloc_netdev_queues(struct ne=
t_device *dev)
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0dev->_tx =3D tx;
>
> - =A0 =A0 =A0 for (i =3D 0; i < count; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_queue_numa_node_write(&tx[i], -1=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx[i].dev =3D dev;
> - =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -5140,6 +5135,8 @@ static void netdev_init_one_queue(struct net_de=
vice *dev,
> =A0 =A0 =A0 =A0spin_lock_init(&queue->_xmit_lock);
> =A0 =A0 =A0 =A0netdev_set_xmit_lockdep_class(&queue->_xmit_lock, dev-=
>type);
> =A0 =A0 =A0 =A0queue->xmit_lock_owner =3D -1;
> + =A0 =A0 =A0 netdev_queue_numa_node_write(queue, -1);
> + =A0 =A0 =A0 queue->dev =3D dev;
> =A0}
>
> =A0static void netdev_init_queues(struct net_device *dev)
>
>
>

I thought about it before submitting. I am not sure if there are some
users of txq->dev before netdev_init_one_queue().

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
