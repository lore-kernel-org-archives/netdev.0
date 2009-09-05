From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] IXP42x HSS support for setting internal clock rate
Date: Sat, 05 Sep 2009 15:59:49 +0200
Message-ID: <m3ab19cx0q.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37438 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbZIEN7u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 09:59:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HSS usually uses external clocks, so it's not a big deal. Internal cloc=
k
is used for direct DTE-DTE connections and when the DCE doesn't provide
it's own clock.

This also depends on the oscillator frequency. Intel seems to have
calculated the clock register settings for 33.33 MHz (66.66 MHz timer
base). Their settings seem quite suboptimal both in terms of average
frequency (60 ppm is unacceptable for G.703 applications, their primary
intended usage(?)) and jitter.

Many (most?) platforms use a 33.333 MHz oscillator, a 10 ppm difference
from Intel's base.

Instead of creating static tables, I've created a procedure to program
the HSS clock register. The register consists of 3 parts (A, B, C).
The average frequency (=3D bit rate) is:
66.66x MHz / (A  + (B + 1) / (C + 1))
The procedure aims at the closest average frequency, possibly at the
cost of increased jitter. Nobody would be able to directly drive an
unbufferred transmitter with a HSS anyway, and the frequency error is
what it really counts.

I've verified the above with an oscilloscope on IXP425. It seems IXP46x
and possibly IXP43x use a bit different clock generation algorithm - it
looks like the avg frequency is:
(on IXP465) 66.66x MHz / (A  + B / (C + 1)).
Also they use much greater precomputed A and B - on IXP425 it would
simply result in more jitter, but I don't know how does it work on
IXP46x (perhaps 3 least significant bits aren't used?).

Anyway it looks that they were aiming for exactly +60 ppm or -60 ppm,
while <1 ppm is typically possible (with a synchronized clock, of
course).

The attached patch makes it possible to set almost any bit rate
(my IXP425 533 MHz quits at > 22 Mb/s if a single port is used, and the
minimum is ca. 65 Kb/s).

This is independent of MVIP (multi-E1/T1 on one HSS) mode.

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/arch/arm/mach-ixp4xx/common.c b/arch/arm/mach-ixp4xx/commo=
n.c
index 1e93dfe..5083f03 100644
--- a/arch/arm/mach-ixp4xx/common.c
+++ b/arch/arm/mach-ixp4xx/common.c
@@ -416,6 +416,7 @@ static struct clocksource clocksource_ixp4xx =3D {
 };
=20
 unsigned long ixp4xx_timer_freq =3D FREQ;
+EXPORT_SYMBOL(ixp4xx_timer_freq);
 static int __init ixp4xx_clocksource_init(void)
 {
 	clocksource_ixp4xx.mult =3D
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.=
c
index bb719b6..c705046 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -166,6 +166,29 @@
 #define CLK46X_SPEED_4096KHZ	((   16 << 22) | (280 << 12) | 1023)
 #define CLK46X_SPEED_8192KHZ	((    8 << 22) | (280 << 12) | 2047)
=20
+/*
+ * HSS_CONFIG_CLOCK_CR register consists of 3 parts:
+ *     A (10 bits), B (10 bits) and C (12 bits).
+ * IXP42x HSS clock generator operation (verified with an oscilloscope=
):
+ * Each clock bit takes 7.5 ns (1 / 133.xx MHz).
+ * The clock sequence consists of (C - B) states of 0s and 1s, each st=
ate is
+ * A bits wide. It's followed by (B + 1) states of 0s and 1s, each sta=
te is
+ * (A + 1) bits wide.
+ *
+ * The resulting average clock frequency (assuming 33.333 MHz oscillat=
or) is:
+ * freq =3D 66.666 MHz / (A + (B + 1) / (C + 1))
+ * minumum freq =3D 66.666 MHz / (A + 1)
+ * maximum freq =3D 66.666 MHz / A
+ *
+ * Example: A =3D 2, B =3D 2, C =3D 7, CLOCK_CR register =3D 2 << 22 |=
 2 << 12 | 7
+ * freq =3D 66.666 MHz / (2 + (2 + 1) / (7 + 1)) =3D 28.07 MHz (Mb/s).
+ * The clock sequence is: 1100110011 (5 doubles) 000111000 (3 triples)=
=2E
+ * The sequence takes (C - B) * A + (B + 1) * (A + 1) =3D 5 * 2 + 3 * =
3 bits
+ * =3D 19 bits (each 7.5 ns long) =3D 142.5 ns (then the sequence repe=
ats).
+ * The sequence consists of 4 complete clock periods, thus the average
+ * frequency (=3D clock rate) is 4 / 142.5 ns =3D 28.07 MHz (Mb/s).
+ * (max specified clock rate for IXP42x HSS is 8.192 Mb/s).
+ */
=20
 /* hss_config, LUT entries */
 #define TDMMAP_UNASSIGNED	0
@@ -239,6 +262,7 @@ struct port {
 	unsigned int clock_type, clock_rate, loopback;
 	unsigned int initialized, carrier;
 	u8 hdlc_cfg;
+	u32 clock_reg;
 };
=20
 /* NPE message structure */
@@ -393,7 +417,7 @@ static void hss_config(struct port *port)
 	msg.cmd =3D PORT_CONFIG_WRITE;
 	msg.hss_port =3D port->id;
 	msg.index =3D HSS_CONFIG_CLOCK_CR;
-	msg.data32 =3D CLK42X_SPEED_2048KHZ /* FIXME */;
+	msg.data32 =3D port->clock_reg;
 	hss_npe_send(port, &msg, "HSS_SET_CLOCK_CR");
=20
 	memset(&msg, 0, sizeof(msg));
@@ -1160,6 +1184,62 @@ static int hss_hdlc_attach(struct net_device *de=
v, unsigned short encoding,
 	}
 }
=20
+static u32 check_clock(u32 rate, u32 a, u32 b, u32 c,
+		       u32 *best, u32 *best_diff, u32 *reg)
+{
+	/* a is 10-bit, b is 10-bit, c is 12-bit */
+	u64 new_rate;
+	u32 new_diff;
+
+	new_rate =3D ixp4xx_timer_freq * (u64)(c + 1);
+	do_div(new_rate, a * (c + 1) + b + 1);
+	new_diff =3D abs((u32)new_rate - rate);
+
+	if (new_diff < *best_diff) {
+		*best =3D new_rate;
+		*best_diff =3D new_diff;
+		*reg =3D (a << 22) | (b << 12) | c;
+	}
+	return new_diff;
+}
+
+static void find_best_clock(u32 rate, u32 *best, u32 *reg)
+{
+	u32 a, b, diff =3D 0xFFFFFFFF;
+
+	a =3D ixp4xx_timer_freq / rate;
+
+	if (a > 0x3FF) { /* 10-bit value - we can go as slow as ca. 65 kb/s *=
/
+		check_clock(rate, 0x3FF, 1, 1, best, &diff, reg);
+		return;
+	}
+	if (a =3D=3D 0) { /* > 66.666 MHz */
+		a =3D 1; /* minimum divider is 1 (a =3D 0, b =3D 1, c =3D 1) */
+		rate =3D ixp4xx_timer_freq;
+	}
+
+	if (rate * a =3D=3D ixp4xx_timer_freq) { /* don't divide by 0 later *=
/
+		check_clock(rate, a - 1, 1, 1, best, &diff, reg);
+		return;
+	}
+
+	for (b =3D 0; b < 0x400; b++) {
+		u64 c =3D (b + 1) * (u64)rate;
+		do_div(c, ixp4xx_timer_freq - rate * a);
+		c--;
+		if (c >=3D 0xFFF) { /* 12-bit - no need to check more 'b's */
+			if (b =3D=3D 0 && /* also try a bit higher rate */
+			    !check_clock(rate, a - 1, 1, 1, best, &diff, reg))
+				return;
+			check_clock(rate, a, b, 0xFFF, best, &diff, reg);
+			return;
+		}
+		if (!check_clock(rate, a, b, c, best, &diff, reg))
+			return;
+		if (!check_clock(rate, a, b, c + 1, best, &diff, reg))
+			return;
+	}
+}
=20
 static int hss_hdlc_ioctl(struct net_device *dev, struct ifreq *ifr, i=
nt cmd)
 {
@@ -1182,7 +1262,7 @@ static int hss_hdlc_ioctl(struct net_device *dev,=
 struct ifreq *ifr, int cmd)
 		}
 		memset(&new_line, 0, sizeof(new_line));
 		new_line.clock_type =3D port->clock_type;
-		new_line.clock_rate =3D 2048000; /* FIXME */
+		new_line.clock_rate =3D port->clock_rate;
 		new_line.loopback =3D port->loopback;
 		if (copy_to_user(line, &new_line, size))
 			return -EFAULT;
@@ -1206,7 +1286,13 @@ static int hss_hdlc_ioctl(struct net_device *dev=
, struct ifreq *ifr, int cmd)
 			return -EINVAL;
=20
 		port->clock_type =3D clk; /* Update settings */
-		/* FIXME port->clock_rate =3D new_line.clock_rate */;
+		if (clk =3D=3D CLOCK_INT)
+			find_best_clock(new_line.clock_rate, &port->clock_rate,
+					&port->clock_reg);
+		else {
+			port->clock_rate =3D 0;
+			port->clock_reg =3D CLK42X_SPEED_2048KHZ;
+		}
 		port->loopback =3D new_line.loopback;
=20
 		spin_lock_irqsave(&npe_lock, flags);
@@ -1266,7 +1352,8 @@ static int __devinit hss_init_one(struct platform=
_device *pdev)
 	dev->netdev_ops =3D &hss_hdlc_ops;
 	dev->tx_queue_len =3D 100;
 	port->clock_type =3D CLOCK_EXT;
-	port->clock_rate =3D 2048000;
+	port->clock_rate =3D 0;
+	port->clock_reg =3D CLK42X_SPEED_2048KHZ;
 	port->id =3D pdev->id;
 	port->dev =3D &pdev->dev;
 	port->plat =3D pdev->dev.platform_data;

--=20
Krzysztof Halasa
