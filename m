From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Fix delay handling
Date: Thu, 01 Oct 2009 12:04:41 +0200
Message-ID: <4AC47EB9.6070809@gmail.com>
References: <20090922224902.17ed6cc4@nehalam>	<20090923174141.1d350103@s6510>	<4AC3E3C5.1090108@gmail.com> <20090930172532.2c2d1d42@s6510> <4AC47AB6.9000501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43826 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbZJAKEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 06:04:41 -0400
In-Reply-To: <4AC47AB6.9000501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> After last pktgen changes, delay handling is wrong.
>=20
> pktgen actually sends packets at full line speed.
>=20
> Fix is to update pkt_dev->next_tx even if spin() returns early,
> so that next spin() calls have a chance to see a positive delay.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Oh well, I hit this bug on linux-2.6 git tree, but I did the patch on n=
et-next-2.6

But it appears net/core/pktgen.c is different on net-next-2.6

Stephen, David, I am a bit lost here, something went wrong in a merge p=
rocess ?

In any case, here is the patch against Linus tree, where bug is present=
=2E

Thanks

[PATCH] pktgen: Fix delay handling

After last pktgen changes, delay handling is wrong.

pktgen actually sends packets at full line speed.

=46ix is to update pkt_dev->next_tx even if spin() returns early,
so that next spin() calls have a chance to see a positive delay.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 4d11c28..b694552 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2105,15 +2105,17 @@ static void pktgen_setup_inject(struct pktgen_d=
ev *pkt_dev)
 static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 {
 	ktime_t start_time, end_time;
-	s32 remaining;
+	s64 remaining;
 	struct hrtimer_sleeper t;
=20
 	hrtimer_init_on_stack(&t.timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	hrtimer_set_expires(&t.timer, spin_until);
=20
 	remaining =3D ktime_to_us(hrtimer_expires_remaining(&t.timer));
-	if (remaining <=3D 0)
+	if (remaining <=3D 0) {
+		pkt_dev->next_tx =3D ktime_add_ns(spin_until, pkt_dev->delay);
 		return;
+	}
=20
 	start_time =3D ktime_now();
 	if (remaining < 100)
