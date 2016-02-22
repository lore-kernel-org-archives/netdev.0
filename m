From: Dmitrii Shcherbakov <fw.dmitrii@yandex.ru>
Subject: Re: [PATCH 1/2] [iproute2] tc/q_htb.c: remove printing of a
 deprecated overhead value previously encoded as a part of mpu field
Date: Mon, 22 Feb 2016 15:41:20 +0300
Message-ID: <1456144880.20204.19.camel@yandex.ru>
References: <3134751450538752@web30j.yandex.ru>
	 <20160217175154.4676c8c6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward19p.cmail.yandex.net ([77.88.31.22]:38135 "EHLO
	forward19p.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753819AbcBVMsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 07:48:14 -0500
In-Reply-To: <20160217175154.4676c8c6@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks!

I also noticed that there seems to be no kernel code to set the MPU
values.

# latest commit at the time of writing
administrator@UX32LN:~/src/linux$ git rev-parse HEAD
64291f7db5bd8150a74ad2036f1037e6a0428df2

Some cscope output below:

0 include/uapi/linux/pkt_sched.h 84 struct tc_ratespec {

A ratespec structure that holds an mpu value:

struct tc_ratespec {
	unsigned char	cell_log;
	__u8		linklayer; /* lower 4 bits */
	unsigned short	overhead;
	short		cell_align;
	unsigned short	mpu;
	__u32		rate;
};


0 include/net/sch_generic.h psched_l2t_ns         766 static inline u64
psched_l2t_ns(const struct psched_ratecfg *r,

An L2T (Length to Time) conversion function which returns an amount of
time in nanoseconds needed to send a packet of a specific size.
Here the length is first modified by a manually configured overhead
value - could be a good place to round the length up to mpu if it is
smaller than mpu:

static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
				unsigned int len)
{
	len +=3D r->overhead;

	if (unlikely(r->linklayer =3D=3D TC_LINKLAYER_ATM))
		return ((u64)(DIV_ROUND_UP(len,48)*53) * r->mult) >> r
->shift;

	return ((u64)len * r->mult) >> r->shift;
}

Seems like psched_l2t_ns is used in both htb and tbf and affects the
amount of tokens that are going to be consumed by a packet of a certain
size:

C symbol: psched_l2t_ns

  File                      Function              Line
0 include/net/sch_generic.h psched_l2t_ns         766 static inline u64
psched_l2t_ns(const struct psched_ratecfg *r,
1 net/sched/act_police.c    tcf_act_police_locate 221 police
->tcfp_mtu_ptoks =3D (s64) psched_l2t_ns(&police->peak,
2 net/sched/act_police.c    tcf_act_police        289 ptoks -=3D (s64)
psched_l2t_ns(&police->peak,
3 net/sched/act_police.c    tcf_act_police        295 toks -=3D (s64)
psched_l2t_ns(&police->rate, qdisc_pkt_len(skb));
4 net/sched/sch_htb.c       htb_accnt_tokens      613 toks -=3D (s64)
psched_l2t_ns(&cl->rate, bytes);
5 net/sched/sch_htb.c       htb_accnt_ctokens     626 toks -=3D (s64)
psched_l2t_ns(&cl->ceil, bytes);
6 net/sched/sch_tbf.c       tbf_dequeue           249 ptoks -=3D (s64)
psched_l2t_ns(&q->peak, len);
7 net/sched/sch_tbf.c       tbf_dequeue           254 toks -=3D (s64)
psched_l2t_ns(&q->rate, len);
8 net/sched/sch_tbf.c       tbf_change            351 buffer =3D psched=
_l
2t_ns(&rate, max_size);
9 net/sched/sch_tbf.c       tbf_change            370 mtu =3D
psched_l2t_ns(&peak, pburst);

Also found a patch (https://patchwork.ozlabs.org/patch/501666/) that
was intended to fix setting of mpu values which never got pushed.

Printing definitely deserved a fix but there is some more work to it at
the kernel side.

On =D0=A1=D1=80., 2016-02-17 at 17:51 -0800, Stephen Hemminger wrote:
> On Sat, 19 Dec 2015 18:25:52 +0300
> Dmitrii Shcherbakov <fw.dmitrii@yandex.com> wrote:
>=20
> > Remove printing according to the previously used encoding of mpu
> > and overhead values within the tc_ratespec's mpu field. This
> > encoding is no longer being used as a separate 'overhead' field in
> > the ratespec structure has been introduced.
> >=20
> > Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
> > Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Acked-by: Phil Sutter <phil@nwl.cc>
>=20
> Both applied.
>=20
> I had to fix up the commit logs.
> Many tools don't like long subject/summary lines, and it is standard
> practice
> to wrap text in commit body at 80 characters.
