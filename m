From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next-2.6] net_sched: sch_sfq: add backlog info in
 sfq_dump_class_stats()
Date: Thu, 16 Dec 2010 11:18:35 +0100
Message-ID: <1292494715.2883.83.camel@edumazet-laptop>
References: <20101216081621.GA7338@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36175 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab0LPKSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 05:18:40 -0500
Received: by wwa36 with SMTP id 36so2250895wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 02:18:38 -0800 (PST)
In-Reply-To: <20101216081621.GA7338@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 08:16 +0000, Jarek Poplawski a =C3=
=A9crit :

> I don't think you can walk this list without the qdisc lock.
>=20

I assumed it was already the case, but I did not check


Me confused...

If I use following patch, I get a recursive lock :

 net/sched/sch_sfq.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3cf478d..a2cde03 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -547,9 +547,20 @@ static int sfq_dump_class_stats(struct Qdisc *sch,=
 unsigned long cl,
 				struct gnet_dump *d)
 {
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
-	sfq_index idx =3D q->ht[cl-1];
-	struct gnet_stats_queue qs =3D { .qlen =3D q->qs[idx].qlen };
-	struct tc_sfq_xstats xstats =3D { .allot =3D q->allot[idx] };
+	sfq_index idx;
+	struct gnet_stats_queue qs =3D { 0 };
+	struct tc_sfq_xstats xstats =3D { 0 };
+	struct sk_buff_head *list;
+	struct sk_buff *skb;
+
+	spin_lock_bh(qdisc_root_sleeping_lock(sch));
+	idx =3D q->ht[cl - 1];
+	list =3D &q->qs[idx];
+	xstats.allot =3D q->allot[idx];
+	qs.qlen =3D list->qlen;
+	skb_queue_walk(list, skb)
+		qs.backlog +=3D qdisc_pkt_len(skb);
+	spin_unlock_bh(qdisc_root_sleeping_lock(sch));
=20
 	if (gnet_stats_copy_queue(d, &qs) < 0)
 		return -1;


Dec 16 10:49:34 edumdev kernel: [  616.452080] sch->qstats.backlog=3D18=
5420
Dec 16 10:49:34 edumdev kernel: [  616.452146]=20
Dec 16 10:49:34 edumdev kernel: [  616.452147] =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Dec 16 10:49:34 edumdev kernel: [  616.452265] [ INFO: possible recursi=
ve locking detected ]
Dec 16 10:49:34 edumdev kernel: [  616.452329] 2.6.37-rc1-01820-g4be897=
6-dirty #456
Dec 16 10:49:34 edumdev kernel: [  616.452425] ------------------------=
---------------------
Dec 16 10:49:34 edumdev kernel: [  616.452489] tc/8747 is trying to acq=
uire lock:
Dec 16 10:49:34 edumdev kernel: [  616.452550]  (&qdisc_tx_lock){+.-...=
}, at: [<ffffffffa01331d5>] sfq_dump_class_stats+0x65/0x160 [sch_sfq]
Dec 16 10:49:34 edumdev kernel: [  616.452753]=20
Dec 16 10:49:34 edumdev kernel: [  616.452754] but task is already hold=
ing lock:
Dec 16 10:49:34 edumdev kernel: [  616.452867]  (&qdisc_tx_lock){+.-...=
}, at: [<ffffffff8145474a>] gnet_stats_start_copy_compat+0x4a/0xc0
Dec 16 10:49:34 edumdev kernel: [  616.453068]=20
Dec 16 10:49:34 edumdev kernel: [  616.453069] other info that might he=
lp us debug this:
Dec 16 10:49:34 edumdev kernel: [  616.453184] 2 locks held by tc/8747:
Dec 16 10:49:34 edumdev kernel: [  616.453243]  #0:  (rtnl_mutex){+.+.+=
=2E}, at: [<ffffffff8149dbc2>] netlink_dump+0x52/0x1e0
Dec 16 10:49:34 edumdev kernel: [  616.453510]  #1:  (&qdisc_tx_lock){+=
=2E-...}, at: [<ffffffff8145474a>] gnet_stats_start_copy_compat+0x4a/0x=
c0
Dec 16 10:49:34 edumdev kernel: [  616.453745]=20
Dec 16 10:49:35 edumdev kernel: [  616.453746] stack backtrace:
Dec 16 10:49:35 edumdev kernel: [  616.453857] Pid: 8747, comm: tc Tain=
ted: G        W   2.6.37-rc1-01820-g4be8976-dirty #456
Dec 16 10:49:35 edumdev kernel: [  616.453943] Call Trace:
Dec 16 10:49:35 edumdev kernel: [  616.454004]  [<ffffffff8107bd1e>] va=
lidate_chain+0x10be/0x1330
Dec 16 10:49:35 edumdev kernel: [  616.454072]  [<ffffffff8107b144>] ? =
validate_chain+0x4e4/0x1330
Dec 16 10:49:35 edumdev kernel: [  616.454142]  [<ffffffff810cd6cc>] ? =
get_page_from_freelist+0x2bc/0x730
Dec 16 10:49:35 edumdev kernel: [  616.454211]  [<ffffffff81079200>] ? =
trace_hardirqs_on_caller+0x110/0x190
Dec 16 10:49:35 edumdev kernel: [  616.454281]  [<ffffffff8107c3e9>] __=
lock_acquire+0x459/0xbe0
Dec 16 10:49:35 edumdev kernel: [  616.454379]  [<ffffffff8107cc10>] lo=
ck_acquire+0xa0/0x140
Dec 16 10:49:35 edumdev kernel: [  616.454446]  [<ffffffffa01331d5>] ? =
sfq_dump_class_stats+0x65/0x160 [sch_sfq]
Dec 16 10:49:35 edumdev kernel: [  616.454520]  [<ffffffff815aee46>] _r=
aw_spin_lock_bh+0x36/0x50
Dec 16 10:49:35 edumdev kernel: [  616.454586]  [<ffffffffa01331d5>] ? =
sfq_dump_class_stats+0x65/0x160 [sch_sfq]
Dec 16 10:49:35 edumdev kernel: [  616.454657]  [<ffffffffa01331d5>] sf=
q_dump_class_stats+0x65/0x160 [sch_sfq]
Dec 16 10:49:35 edumdev kernel: [  616.454727]  [<ffffffff81202ef4>] ? =
nla_put+0x34/0x40
Dec 16 10:49:35 edumdev kernel: [  616.454794]  [<ffffffff8145478f>] ? =
gnet_stats_start_copy_compat+0x8f/0xc0
Dec 16 10:49:35 edumdev kernel: [  616.454865]  [<ffffffff8147a2f1>] tc=
_fill_tclass+0x1b1/0x250
Dec 16 10:49:35 edumdev kernel: [  616.454932]  [<ffffffff8147a3ce>] qd=
isc_class_dump+0x3e/0x40
Dec 16 10:49:35 edumdev kernel: [  616.454999]  [<ffffffff81483a68>] ? =
cbq_walk+0x78/0xc0
Dec 16 10:49:35 edumdev kernel: [  616.455064]  [<ffffffffa013228c>] sf=
q_walk+0x5c/0x90 [sch_sfq]
Dec 16 10:49:35 edumdev kernel: [  616.455131]  [<ffffffff81479f3a>] tc=
_dump_tclass_qdisc+0xba/0x110
Dec 16 10:49:35 edumdev kernel: [  616.455199]  [<ffffffff8147a390>] ? =
qdisc_class_dump+0x0/0x40
Dec 16 10:49:35 edumdev kernel: [  616.455266]  [<ffffffff8147a00f>] tc=
_dump_tclass_root+0x7f/0xa0
Dec 16 10:49:35 edumdev kernel: [  616.455332]  [<ffffffff8147a0bc>] tc=
_dump_tclass+0x8c/0x110
Dec 16 10:49:35 edumdev kernel: [  616.455426]  [<ffffffff8149dbdd>] ne=
tlink_dump+0x6d/0x1e0
Dec 16 10:49:35 edumdev kernel: [  616.455494]  [<ffffffff814a0c0c>] ne=
tlink_dump_start+0x19c/0x210
Dec 16 10:49:35 edumdev kernel: [  616.455562]  [<ffffffff8147a030>] ? =
tc_dump_tclass+0x0/0x110
Dec 16 10:49:35 edumdev kernel: [  616.455628]  [<ffffffff8147a030>] ? =
tc_dump_tclass+0x0/0x110
Dec 16 10:49:35 edumdev kernel: [  616.455694]  [<ffffffff8146bfa9>] rt=
netlink_rcv_msg+0xb9/0x260
Dec 16 10:49:35 edumdev kernel: [  616.455763]  [<ffffffff8146bef0>] ? =
rtnetlink_rcv_msg+0x0/0x260
Dec 16 10:49:35 edumdev kernel: [  616.455832]  [<ffffffff8149ef29>] ne=
tlink_rcv_skb+0x99/0xc0
Dec 16 10:49:35 edumdev kernel: [  616.455898]  [<ffffffff8146bed5>] rt=
netlink_rcv+0x25/0x40
Dec 16 10:49:35 edumdev kernel: [  616.455963]  [<ffffffff8149ea95>] ? =
netlink_unicast+0xf5/0x2d0
Dec 16 10:49:35 edumdev kernel: [  616.456030]  [<ffffffff8149ec42>] ne=
tlink_unicast+0x2a2/0x2d0
Dec 16 10:49:35 edumdev kernel: [  616.456098]  [<ffffffff810e8cb3>] ? =
might_fault+0x53/0xb0
Dec 16 10:49:35 edumdev kernel: [  616.456163]  [<ffffffff81451fed>] ? =
memcpy_fromiovec+0x6d/0x90
Dec 16 10:49:35 edumdev kernel: [  616.456231]  [<ffffffff8149fbdd>] ne=
tlink_sendmsg+0x24d/0x390
Dec 16 10:49:35 edumdev kernel: [  616.456299]  [<ffffffff814463d0>] so=
ck_sendmsg+0xc0/0xf0
Dec 16 10:49:36 edumdev kernel: [  616.456390]  [<ffffffff810e8cb3>] ? =
might_fault+0x53/0xb0
Dec 16 10:49:36 edumdev kernel: [  616.456457]  [<ffffffff814767ce>] ? =
verify_compat_iovec+0x6e/0x110
Dec 16 10:49:36 edumdev kernel: [  616.456526]  [<ffffffff81447164>] sy=
s_sendmsg+0x194/0x320
Dec 16 10:49:36 edumdev kernel: [  616.456593]  [<ffffffff815b2e02>] ? =
do_page_fault+0x102/0x4e0
Dec 16 10:49:36 edumdev kernel: [  616.456661]  [<ffffffff8107cd4d>] ? =
lock_release_non_nested+0x9d/0x2e0
Dec 16 10:49:36 edumdev kernel: [  616.456729]  [<ffffffff810e8cb3>] ? =
might_fault+0x53/0xb0
Dec 16 10:49:36 edumdev kernel: [  616.456796]  [<ffffffff810e8cb3>] ? =
might_fault+0x53/0xb0
Dec 16 10:49:36 edumdev kernel: [  616.456863]  [<ffffffff81476154>] co=
mpat_sys_sendmsg+0x14/0x20
Dec 16 10:49:36 edumdev kernel: [  616.456929]  [<ffffffff814770fe>] co=
mpat_sys_socketcall+0x1be/0x210
Dec 16 10:49:36 edumdev kernel: [  616.457000]  [<ffffffff8102f1d0>] sy=
senter_dispatch+0x7/0x33
Dec 16 10:49:36 edumdev kernel: [  616.457067]  [<ffffffff815ae9a9>] ? =
trace_hardirqs_on_thunk+0x3a/0x3f


