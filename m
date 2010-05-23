From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: Fix qdisc_notify()
Date: Sun, 23 May 2010 08:37:44 +0200
Message-ID: <1274596664.5020.40.camel@edumazet-laptop>
References: <20100521224243.GD10247@nicira.com>
	 <1274512687.5020.21.camel@edumazet-laptop>  <4BF7A929.2090007@trash.net>
	 <1274531509.12793.7.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, Ben Pfaff <blp@nicira.com>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:49453 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab0EWGht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 02:37:49 -0400
Received: by wwb13 with SMTP id 13so317640wwb.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 23:37:47 -0700 (PDT)
In-Reply-To: <1274531509.12793.7.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 22 mai 2010 =C3=A0 08:31 -0400, jamal a =C3=A9crit :
> On Sat, 2010-05-22 at 11:51 +0200, Patrick McHardy wrote:
>=20
> >=20
> > We already use TCQ_F_BUILTIN in tc_qdisc_dump_ignore(), so I
> > think it would be more consistent than checking for a handle
> > to use it here as well.
>=20
> Agree - it is more semantically correct..
>=20
> I wonder though if it is better to do the check in tc_get_qdisc()
> and tc_modify_qdisc()?

Lets check tc_qdisc_dump_ignore() before tc_fill_qdisc(), its more
consistent ;)

David, this is a stable candidate (2.6.26 and up)

Thanks

[PATCH] net_sched: Fix qdisc_notify()

Ben Pfaff reported a kernel oops and provided a test program to
reproduce it.

https://kerneltrap.org/mailarchive/linux-netdev/2010/5/21/6277805

tc_fill_qdisc() should not be called for builtin qdisc, or it
dereference a NULL pointer to get device ifindex.

=46ix is to always use tc_qdisc_dump_ignore() before calling
tc_fill_qdisc().

Reported-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_api.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fe35c1f..b9e8c3b 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1195,6 +1195,11 @@ nla_put_failure:
 	return -1;
 }
=20
+static bool tc_qdisc_dump_ignore(struct Qdisc *q)
+{
+	return (q->flags & TCQ_F_BUILTIN) ? true : false;
+}
+
 static int qdisc_notify(struct net *net, struct sk_buff *oskb,
 			struct nlmsghdr *n, u32 clid,
 			struct Qdisc *old, struct Qdisc *new)
@@ -1206,11 +1211,11 @@ static int qdisc_notify(struct net *net, struct=
 sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
=20
-	if (old && old->handle) {
+	if (old && !tc_qdisc_dump_ignore(old)) {
 		if (tc_fill_qdisc(skb, old, clid, pid, n->nlmsg_seq, 0, RTM_DELQDISC=
) < 0)
 			goto err_out;
 	}
-	if (new) {
+	if (new && !tc_qdisc_dump_ignore(new)) {
 		if (tc_fill_qdisc(skb, new, clid, pid, n->nlmsg_seq, old ? NLM_F_REP=
LACE : 0, RTM_NEWQDISC) < 0)
 			goto err_out;
 	}
@@ -1223,11 +1228,6 @@ err_out:
 	return -EINVAL;
 }
=20
-static bool tc_qdisc_dump_ignore(struct Qdisc *q)
-{
-	return (q->flags & TCQ_F_BUILTIN) ? true : false;
-}
-
 static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			      struct netlink_callback *cb,
 			      int *q_idx_p, int s_q_idx)


