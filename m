From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Thu, 20 Oct 2011 22:55:38 +0200
Message-ID: <1319144138.2854.33.camel@edumazet-laptop>
References: <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318946401.23980.6.camel@deadeye>
	 <1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111020.162444.559487256559727633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, daniel.turull@gmail.com,
	netdev@vger.kernel.org, robert@herjulf.net, voravit@kth.se,
	jens.laas@uadm.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40832 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab1JTUzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:55:44 -0400
Received: by wyg36 with SMTP id 36so3323161wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 13:55:43 -0700 (PDT)
In-Reply-To: <20111020.162444.559487256559727633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 16:24 -0400, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 18 Oct 2011 16:47:44 +0200
>=20
> > Le mardi 18 octobre 2011 =C3=A0 15:00 +0100, Ben Hutchings a =C3=A9=
crit :
> >=20
> >> AIUI, the reason for limits on delays is not that it's bad practic=
e to
> >> spin for so long, but that the delay calculations may overflow or
> >> otherwise become inaccurate.
> >=20
> > OK, I can understand that, then a more appropriate patch would be :
>=20
> I think doing the udelay/ndelay thing is the way to go for 'net' and
> -stable.  We can do something sophisticated with ktime et al. in
> 'net-next'.
>=20

Well, I am not sure a patch is needed for net, since there is no bug,
but maybe small inaccuracies ? Correct me if I misunderstood Daniel !

> Eric, could you please formally submit this patch with proper
> changelog etc.?

Sure !

[PATCH net-next] pktgen: remove ndelay() call

Daniel Turull reported inaccuracies in pktgen when using low packet
rates, because we call ndelay(val) with values bigger than 20000.

Instead of calling ndelay() for delays < 100us, we can instead loop
calling ktime_now() only.

Reported-by: Daniel Turull <daniel.turull@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6bbf008..0001c24 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2145,9 +2145,12 @@ static void spin(struct pktgen_dev *pkt_dev, kti=
me_t spin_until)
 	}
=20
 	start_time =3D ktime_now();
-	if (remaining < 100000)
-		ndelay(remaining);	/* really small just spin */
-	else {
+	if (remaining < 100000) {
+		/* for small delays (<100us), just loop until limit is reached */
+		do {
+			end_time =3D ktime_now();
+		} while (ktime_lt(end_time, spin_until));
+	} else {
 		/* see do_nanosleep */
 		hrtimer_init_sleeper(&t, current);
 		do {
@@ -2162,8 +2165,8 @@ static void spin(struct pktgen_dev *pkt_dev, ktim=
e_t spin_until)
 			hrtimer_cancel(&t.timer);
 		} while (t.task && pkt_dev->running && !signal_pending(current));
 		__set_current_state(TASK_RUNNING);
+		end_time =3D ktime_now();
 	}
-	end_time =3D ktime_now();
=20
 	pkt_dev->idle_acc +=3D ktime_to_ns(ktime_sub(end_time, start_time));
 	pkt_dev->next_tx =3D ktime_add_ns(spin_until, pkt_dev->delay);
