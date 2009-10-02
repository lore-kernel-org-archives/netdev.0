From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC take2] pkt_sched: gen_estimator: Dont report fake rate estimators
Date: Fri, 02 Oct 2009 14:39:07 +0200
Message-ID: <4AC5F46B.6030308@gmail.com>
References: <20091002070819.GA9694@ff.dom.local> <4AC5D78D.3030400@gmail.com> <20091002112514.GA14100@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56487 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756674AbZJBMjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 08:39:07 -0400
In-Reply-To: <20091002112514.GA14100@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :

> So you prefer the additional parameter version, but since these
> _active tests are not needed e.g. for HTB classes, which got it
> active by default, so maybe bstats =3D=3D NULL would let skip such a =
test?
>=20
> ...
>> --- a/include/net/gen_stats.h
>> +++ b/include/net/gen_stats.h
>> @@ -30,6 +30,7 @@ extern int gnet_stats_start_copy_compat(struct sk_=
buff *skb, int type,
>>  extern int gnet_stats_copy_basic(struct gnet_dump *d,
>>  				 struct gnet_stats_basic_packed *b);
>>  extern int gnet_stats_copy_rate_est(struct gnet_dump *d,
>> +				    const struct gnet_stats_basic_packed *bstats,
>=20
> It seems these *b/*bstats defs could look more consistent. Otherwise
> it looks OK to me.

Agreed, here is the updated version, I added your Signoff if you dont m=
ind :)

[RFC] pkt_sched: gen_estimator: Dont report fake rate estimators

We currently send TCA_STATS_RATE_EST elements to netlink users, even if=
 no estimator
is running.

# tc -s -d qdisc
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 112833764978 bytes 1495081739 pkt (dropped 0, overlimits 0 requeu=
es 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

User has no way to tell if the "rate 0bit 0pps" is a real estimation, o=
r a fake
one (because no estimator is active)

After this patch, tc command output is :
$ tc -s -d qdisc
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 561075 bytes 1196 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

We add a parameter to gnet_stats_copy_rate_est() function so that
it can use gen_estimator_active(bstats, r), as suggested by Jarek.

This parameter can be NULL if check is not necessary, (htb for
example has a mandatory rate estimator)


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 include/net/gen_stats.h |    1 +
 net/core/gen_stats.c    |    7 ++++++-
 net/sched/act_api.c     |    2 +-
 net/sched/sch_api.c     |    2 +-
 net/sched/sch_cbq.c     |    2 +-
 net/sched/sch_drr.c     |    2 +-
 net/sched/sch_hfsc.c    |    2 +-
 net/sched/sch_htb.c     |    2 +-
 8 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index c148855..eb87a14 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -30,6 +30,7 @@ extern int gnet_stats_start_copy_compat(struct sk_buf=
f *skb, int type,
 extern int gnet_stats_copy_basic(struct gnet_dump *d,
 				 struct gnet_stats_basic_packed *b);
 extern int gnet_stats_copy_rate_est(struct gnet_dump *d,
+				    const struct gnet_stats_basic_packed *b,
 				    struct gnet_stats_rate_est *r);
 extern int gnet_stats_copy_queue(struct gnet_dump *d,
 				 struct gnet_stats_queue *q);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 8569310..054a49c 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -136,8 +136,13 @@ gnet_stats_copy_basic(struct gnet_dump *d, struct =
gnet_stats_basic_packed *b)
  * if the room in the socket buffer was not sufficient.
  */
 int
-gnet_stats_copy_rate_est(struct gnet_dump *d, struct gnet_stats_rate_e=
st *r)
+gnet_stats_copy_rate_est(struct gnet_dump *d,
+			 const struct gnet_stats_basic_packed *b,
+			 struct gnet_stats_rate_est *r)
 {
+	if (b && !gen_estimator_active(b, r))
+		return 0;
+
 	if (d->compat_tc_stats) {
 		d->tc_stats.bps =3D r->bps;
 		d->tc_stats.pps =3D r->pps;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2dfb3e7..2b0d5ee 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -618,7 +618,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, stru=
ct tc_action *a,
 			goto errout;
=20
 	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &h->tcf_rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &h->tcf_bstats, &h->tcf_rate_est) < =
0 ||
 	    gnet_stats_copy_queue(&d, &h->tcf_qstats) < 0)
 		goto errout;
=20
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 903e418..1acfd29 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1179,7 +1179,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, str=
uct Qdisc *q, u32 clid,
 		goto nla_put_failure;
=20
 	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &q->bstats, &q->rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
 		goto nla_put_failure;
=20
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 5b132c4..3846d65 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1609,7 +1609,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned =
long arg,
 		cl->xstats.undertime =3D cl->undertime - q->now;
=20
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
=20
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 5a888af..a65604f 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -280,7 +280,7 @@ static int drr_dump_class_stats(struct Qdisc *sch, =
unsigned long arg,
 	}
=20
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
 		return -1;
=20
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 2c5c76b..b38b39c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1375,7 +1375,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned=
 long arg,
 	xstats.rtwork  =3D cl->cl_cumul;
=20
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
=20
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 85acab9..2e38d1a 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1105,7 +1105,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned =
long arg, struct gnet_dump *d)
 	cl->xstats.ctokens =3D cl->ctokens;
=20
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
=20
