From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Tue, 21 Feb 2012 21:46:49 +0100
Message-ID: <1329857209.18384.53.camel@edumazet-laptop>
References: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>
	 <1329851004.18384.45.camel@edumazet-laptop>
	 <20120221.140716.1396286389544946379.davem@davemloft.net>
	 <1329851756.18384.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mroos@linux.ee, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61781 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693Ab2BUUqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:46:54 -0500
Received: by wgbdt10 with SMTP id dt10so6046494wgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 12:46:53 -0800 (PST)
In-Reply-To: <1329851756.18384.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 20:15 +0100, Eric Dumazet a =C3=A9=
crit :
> Le mardi 21 f=C3=A9vrier 2012 =C3=A0 14:07 -0500, David Miller a =C3=A9=
crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 21 Feb 2012 20:03:24 +0100
> >=20
> > > But I dont know enough this code to know if the following patch i=
s the
> > > way to fix this. (and __neigh_for_each_release() can also be dele=
ted if
> > > no users left in tree)
> >=20
> > I think instead of removing the code, we need to have it iterate ov=
er
> > "arp_tbl" but only invoke the callback for devices which are of typ=
e
> > ATM.
>=20
> That makes sense...
>=20
> Or invoke callback for all entries, and filter in callback non ATM on=
es.
>=20
>=20

What about following patch ?

Meelis, can you test it please ?

[PATCH] atm: clip: remove clip_tbl

Commit 32092ecf0644 (atm: clip: Use device neigh support on top of
"arp_tbl".) introduced a bug since clip_tbl is zeroed : Crash occurs in
__neigh_for_each_release()

idle_timer_check() must use instead arp_tbl and neigh_check_cb() should
ignore non clip neighbours.

Idea from David Miller.

Reported-by: Meelis Roos <mroos@linux.ee>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/atm/clip.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index c12c258..127fe70 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -46,8 +46,8 @@
=20
 static struct net_device *clip_devs;
 static struct atm_vcc *atmarpd;
-static struct neigh_table clip_tbl;
 static struct timer_list idle_timer;
+static const struct neigh_ops clip_neigh_ops;
=20
 static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 {
@@ -123,6 +123,8 @@ static int neigh_check_cb(struct neighbour *n)
 	struct atmarp_entry *entry =3D neighbour_priv(n);
 	struct clip_vcc *cv;
=20
+	if (n->ops !=3D &clip_neigh_ops)
+		return 0;
 	for (cv =3D entry->vccs; cv; cv =3D cv->next) {
 		unsigned long exp =3D cv->last_use + cv->idle_timeout;
=20
@@ -154,10 +156,10 @@ static int neigh_check_cb(struct neighbour *n)
=20
 static void idle_timer_check(unsigned long dummy)
 {
-	write_lock(&clip_tbl.lock);
-	__neigh_for_each_release(&clip_tbl, neigh_check_cb);
+	write_lock(&arp_tbl.lock);
+	__neigh_for_each_release(&arp_tbl, neigh_check_cb);
 	mod_timer(&idle_timer, jiffies + CLIP_CHECK_INTERVAL * HZ);
-	write_unlock(&clip_tbl.lock);
+	write_unlock(&arp_tbl.lock);
 }
=20
 static int clip_arp_rcv(struct sk_buff *skb)
