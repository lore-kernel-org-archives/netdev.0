From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion notification at
 enqueue time
Date: Thu, 28 Jun 2012 16:52:17 -0700
Message-ID: <CAB_+Fg7x2pV72Wa45QLuokHTVPuzdmrMfwiuLjS_vi02vtasAA@mail.gmail.com>
References: <1340903237.13187.151.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>,
	codel@lists.bufferbloat.net, Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34905 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab2F1XwS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:52:18 -0400
Received: by qcro28 with SMTP id o28so1441939qcr.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 16:52:18 -0700 (PDT)
In-Reply-To: <1340903237.13187.151.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As you know I really like this idea. My main concern is that the same
packet could cause TCP to reduce cwnd twice within an RTT - first on
enqueue and then if this packet is ECN marked on dequeue. I don't
think this is the desired behavior. Can we avoid it?

On Thu, Jun 28, 2012 at 10:07 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> At enqueue time, check sojourn time of packet at head of the queue,
> and return NET_XMIT_CN instead of NET_XMIT_SUCCESS if this sejourn
> time is above codel @target.
>
> This permits local TCP stack to call tcp_enter_cwr() and reduce its c=
wnd
> without drops (for example if ECN is not enabled for the flow)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Dave Taht <dave.taht@bufferbloat.net>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Matt Mathis <mattmathis@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
> =A0include/linux/pkt_sched.h | =A0 =A01 +
> =A0include/net/codel.h =A0 =A0 =A0 | =A0 =A02 +-
> =A0net/sched/sch_fq_codel.c =A0| =A0 19 +++++++++++++++----
> =A03 files changed, 17 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 32aef0a..4d409a5 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -714,6 +714,7 @@ struct tc_fq_codel_qd_stats {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0__u32 =A0 new_flows_len; =A0/* count of flows in new l=
ist */
> =A0 =A0 =A0 =A0__u32 =A0 old_flows_len; =A0/* count of flows in old l=
ist */
> + =A0 =A0 =A0 __u32 =A0 congestion_count;
> =A0};
>
> =A0struct tc_fq_codel_cl_stats {
> diff --git a/include/net/codel.h b/include/net/codel.h
> index 550debf..8c7d6a7 100644
> --- a/include/net/codel.h
> +++ b/include/net/codel.h
> @@ -148,7 +148,7 @@ struct codel_vars {
> =A0* struct codel_stats - contains codel shared variables and stats
> =A0* @maxpacket: largest packet we've seen so far
> =A0* @drop_count: =A0 =A0 =A0 =A0temp count of dropped packets in deq=
ueue()
> - * ecn_mark: =A0 number of packets we ECN marked instead of dropping
> + * @ecn_mark: =A0number of packets we ECN marked instead of dropping
> =A0*/
> =A0struct codel_stats {
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 maxpacket;
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 9fc1c62..c0485a0 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -62,6 +62,7 @@ struct fq_codel_sched_data {
> =A0 =A0 =A0 =A0struct codel_stats cstats;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 drop_overlimit;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 new_flow_count;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 congestion_count;
>
> =A0 =A0 =A0 =A0struct list_head new_flows; =A0 =A0 /* list of new flo=
ws */
> =A0 =A0 =A0 =A0struct list_head old_flows; =A0 =A0 /* list of old flo=
ws */
> @@ -196,16 +197,25 @@ static int fq_codel_enqueue(struct sk_buff *skb=
, struct Qdisc *sch)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flow->deficit =3D q->quantum;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flow->dropped =3D 0;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 if (++sch->q.qlen < sch->limit)
> + =A0 =A0 =A0 if (++sch->q.qlen < sch->limit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 codel_time_t hdelay =3D codel_get_enque=
ue_time(skb) -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 codel_get_enqueue_time(flow->head);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If this flow is congested, tell the =
caller ! */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (codel_time_after(hdelay, q->cparams=
=2Etarget)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->congestion_count++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_XMIT_CN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NET_XMIT_SUCCESS;
> -
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0q->drop_overlimit++;
> =A0 =A0 =A0 =A0/* Return Congestion Notification only if we dropped a=
 packet
> =A0 =A0 =A0 =A0 * from this flow.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (fq_codel_drop(sch) =3D=3D idx)
> + =A0 =A0 =A0 if (fq_codel_drop(sch) =3D=3D idx) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->congestion_count++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NET_XMIT_CN;
> -
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0/* As we dropped a packet, better let upper stack know=
 this */
> =A0 =A0 =A0 =A0qdisc_tree_decrease_qlen(sch, 1);
> =A0 =A0 =A0 =A0return NET_XMIT_SUCCESS;
> @@ -467,6 +477,7 @@ static int fq_codel_dump_stats(struct Qdisc *sch,=
 struct gnet_dump *d)
>
> =A0 =A0 =A0 =A0st.qdisc_stats.maxpacket =3D q->cstats.maxpacket;
> =A0 =A0 =A0 =A0st.qdisc_stats.drop_overlimit =3D q->drop_overlimit;
> + =A0 =A0 =A0 st.qdisc_stats.congestion_count =3D q->congestion_count=
;
> =A0 =A0 =A0 =A0st.qdisc_stats.ecn_mark =3D q->cstats.ecn_mark;
> =A0 =A0 =A0 =A0st.qdisc_stats.new_flow_count =3D q->new_flow_count;
>
>
>
