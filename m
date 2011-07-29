From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 39372] New: Problems with HFSC Scheduler
Date: Fri, 29 Jul 2011 16:00:52 +0200
Message-ID: <1311948052.2843.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <bug-39372-10286@https.bugzilla.kernel.org/>
	 <20110714151425.844b7738.akpm@linux-foundation.org>
	 <4E32A796.8060104@ziu.info>
	 <1311946060.2843.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>, lucas.bocchi@gmail.com,
	Patrick McHardy <kaber@trash.net>, 631945@bugs.debian.org,
	00bormoj@gmail.com, fdelawarde@wirelessmundi.com
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35743 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab1G2OCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:02:06 -0400
Received: by wwg11 with SMTP id 11so4965679wwg.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 07:02:04 -0700 (PDT)
In-Reply-To: <1311946060.2843.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 15:27 +0200, Eric Dumazet a =C3=A9cr=
it :
> Le vendredi 29 juillet 2011 =C3=A0 14:29 +0200, Michal Soltys a =C3=A9=
crit :
> > On 11-07-15 00:14, Andrew Morton wrote:
> > >=20
> > > (switched to email.  Please respond via emailed reply-to-all, not=
 via
> > > the bugzilla web interface).
> > >=20
> > >=20
> > > Here: WARN_ON(next_time =3D=3D 0);
> > >=20
> >=20
> > From the other thread on netfilter-devel:
> >=20
> > > On 11-07-22 11:58, Michal Pokrywka wrote: After bisecting 2.6.39.=
1 it
> > > turned out that the bug is caused independently by two patches:
> > >=20
> > > commit b262a5da755cc6ed0cb4fba230cd9bf4037e1096 sch_sfq: fix peek=
()
> > > implementation
> > >=20
> > > and
> > >=20
> > > commit 9df49f2bfe862573911a080c75a6d81113c5c81d sch_sfq: avoid gi=
ving
> > > spurious NET_XMIT_CN signals
> > >=20
> > > Reverting these patches makes HFSC work again.
> > >=20
> >=20
> > This one (upstream 8efa885406359af300d46910642b50ca82c0fe47) seems =
to be
> > the culprit (does reverting only that one cures the problem ?)
> >=20
> > It allows SFQ to return success on enqueuing, when the packet reall=
y
> > replaced some other packet in some other flow. This confuses outer =
qdisc
> > (in this particular case HFSC) which thinks new packet was actually
> > added each time such situation happes.
> >=20
>=20
> Technically speaking, _this_ packet was successfuly enqueued.
>=20
> Returning NET_XMIT_CN or NET_XMIT_SUCCESS should not trigger a bug in
> caller.
>=20
> > This in turn causes additional dequeues and ends with attempt
> > to schedule non-existent packets, and triggers the warning.
> >=20
>=20
> Then its probably a bug in HFSC : It doesnt understand SFQ lost a
> packet.
>=20
> I'll take a look, thanks for the report.
>=20
>=20

Oh well, it seems one qdisc_tree_decrease_qlen(sch, 1) is missing

Maybe following patch would help...


diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 4536ee6..2a2d287 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -410,7 +410,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch=
)
 	/* Return Congestion Notification only if we dropped a packet
 	 * from this flow.
 	 */
-	return (qlen !=3D slot->qlen) ? NET_XMIT_CN : NET_XMIT_SUCCESS;
+	if (qlen !=3D slot->qlen)
+		return NET_XMIT_CN;
+
+	/* as we dropped a packet, better let upper stack know this */
+	qdisc_tree_decrease_qlen(sch, 1);
+	return NET_XMIT_SUCCESS;
 }
=20
 static struct sk_buff *


