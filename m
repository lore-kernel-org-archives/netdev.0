From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc: RTM_GETQDISC causes kernel OOPS
Date: Sat, 22 May 2010 09:18:06 +0200
Message-ID: <1274512687.5020.21.camel@edumazet-laptop>
References: <20100521224243.GD10247@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:41723 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab0EVHSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 03:18:12 -0400
Received: by wwi18 with SMTP id 18so1220318wwi.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 00:18:10 -0700 (PDT)
In-Reply-To: <20100521224243.GD10247@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 mai 2010 =C3=A0 15:42 -0700, Ben Pfaff a =C3=A9crit :
> Hi.  While working on some library code for working with qdiscs and
> classes I came upon a kernel OOPS.  Originally I came across it with =
a
> 2.6.26 kernel, but I can also reproduce it with unmodified v2.6.34 fr=
om
> kernel.org.
>=20
> At the end of this mail I'm appending both an example of the OOPS and=
 a
> simple test program that reliably reproduces the problem for me when =
I
> invoke it with "lo" as argument.  The program does not need to be run=
 as
> root.
>=20
> After the OOPS, a lot of networking and other system functions stop
> working, so it seems to me a serious issue.
>=20
> The null pointer dereference that causes the OOPS is the dereference =
of
> the return value of qdisc_dev() in tc_fill_qdisc() in
> net/sched/sch_api.c line 1163:
>=20
>     1161	tcm->tcm__pad1 =3D 0;
>     1162	tcm->tcm__pad2 =3D 0;
>     1163	tcm->tcm_ifindex =3D qdisc_dev(q)->ifindex;
>     1164	tcm->tcm_parent =3D clid;
>     1165	tcm->tcm_handle =3D q->handle;
>=20
> I am pretty sure about that, because if I add "WARN_ON(!qdisc_dev(q))=
;"
> just before line 1163 then that warning triggers.
>=20
> Thanks,

Indeed, thanks for this very useful report !

We could add a check for TCQ_F_BUILTIN flag, or just make=20
qdisc_notify() checks consistent for both old and new qdisc

What other people thinks ?

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fe35c1f..e454c73 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1210,7 +1210,7 @@ static int qdisc_notify(struct net *net, struct s=
k_buff *oskb,
 		if (tc_fill_qdisc(skb, old, clid, pid, n->nlmsg_seq, 0, RTM_DELQDISC=
) < 0)
 			goto err_out;
 	}
-	if (new) {
+	if (new && new->handle) {
 		if (tc_fill_qdisc(skb, new, clid, pid, n->nlmsg_seq, old ? NLM_F_REP=
LACE : 0, RTM_NEWQDISC) < 0)
 			goto err_out;
 	}






