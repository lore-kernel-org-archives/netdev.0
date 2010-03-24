From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Wed, 24 Mar 2010 15:24:56 +0100
Message-ID: <1269440696.3213.53.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:60313 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756412Ab0CXOZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 10:25:05 -0400
Received: by bwz25 with SMTP id 25so4611538bwz.28
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 07:25:02 -0700 (PDT)
In-Reply-To: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 13:25 -0700, Alexander Duyck a =C3=A9crit =
:
> The qdisc layer shows a significant issue when you start transmitting=
 from
> multiple CPUs.  The issue is that the transmit rate drops significant=
ly, and I
> believe it is due to the fact that the spinlock is shared between the=
 1
> dequeue, and n-1 enqueue cpu threads.  In order to improve this situa=
tion I am
> adding one additional lock which will need to be obtained during the =
enqueue
> portion of the path.  This essentially allows sch_direct_xmit to jump=
 to
> near the head of the line when attempting to obtain the lock after
> completing a transmit.
>=20

This two stages lock permits to dequeue cpu to have 50% of chance to ge=
t
q.lock, since all other cpus (but one) are competing in enqueue_lock.

> Running the script below I saw an increase from 200K packets per seco=
nd to
> 1.07M packets per second as a result of this patch.
>=20
> for j in `seq 0 15`; do
> 	for i in `seq 0 7`; do
> 		netperf -H <ip> -t UDP_STREAM -l 600 -N -T $i -- -m 6 &
> 	done
> done
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>=20
>  include/net/sch_generic.h |    3 ++-
>  net/core/dev.c            |    7 ++++++-
>  net/sched/sch_generic.c   |    1 +
>  3 files changed, 9 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 67dc08e..f5088a9 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -51,7 +51,6 @@ struct Qdisc {
>  	struct list_head	list;
>  	u32			handle;
>  	u32			parent;
> -	atomic_t		refcnt;
>  	struct gnet_stats_rate_est	rate_est;
>  	int			(*reshape_fail)(struct sk_buff *skb,
>  					struct Qdisc *q);
> @@ -65,6 +64,8 @@ struct Qdisc {
>  	struct netdev_queue	*dev_queue;
>  	struct Qdisc		*next_sched;
> =20
> +	atomic_t		refcnt;
> +	spinlock_t		enqueue_lock;
>  	struct sk_buff		*gso_skb;
>  	/*


Could you at least try to not fill the hole, but place enqueue_lock
right after "struct sk_buff_head q;" ?

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 67dc08e..6079c70 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -71,6 +71,7 @@ struct Qdisc {
         */
        unsigned long           state;
        struct sk_buff_head     q;
+       spinlock_t              enqueue_lock;
        struct gnet_stats_basic_packed bstats;
        struct gnet_stats_queue qstats;
 };


So that on x86_64, all these fields use one cache line instead of two.

offsetof(struct Qdisc, state)=3D0x80
offsetof(struct Qdisc, q)=3D0x88
offsetof(struct Qdisc, enqueue_lock)=3D0xa0

It would be nice to have a benchmark for non pathological cases (one cp=
u
doing a flood xmit of small packets)



