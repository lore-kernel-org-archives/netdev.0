From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] IrDA: TOIM3232 dongle support
Date: Thu, 2 Mar 2006 00:36:23 +0200
Message-ID: <20060301223623.GA17813@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: quoted-printable
Cc: IrDA users <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

Hi David,

Here goes a patch for supporting TOIM3232 based serial IrDA dongles.
The code is based on the tekram dongle code.

It's been tested with a TOIM3232 based IRWave 320S dongle. It may work
for TOIM4232 dongles, although it's not been tested.

Cheers,
Samuel.

Signed-off-by: David Basden <davidb-irda-Q/PxBS77Xz0@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 7a08134..1b0f0d0 100644
--- a/drivers/net/irda/Kconfig
+++ a/drivers/net/irda/Kconfig
@@ -62,10 +62,18 @@ config TEKRAM_DONGLE
 	  attaches to the normal 9-pin serial port connector, and can
 	  currently only be used by IrTTY.  To activate support for Tekram
 	  dongles you will have to start irattach like this:
 	  "irattach -d tekram".
=20
+config TOIM3232_DONGLE
+	tristate "TOIM3232 IrDa dongle"
+	depends on DONGLE && IRDA
+	help
+	  Say Y here if you want to build support for the Vishay/Temic
+	  TOIM3232 and TOIM4232 based dongles.
+	  To compile it as a module, choose M here.
+
 config LITELINK_DONGLE
 	tristate "Parallax LiteLink dongle"
 	depends on DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Parallax Litelink

diff --git a/drivers/net/irda/Makefile b/drivers/net/irda/Makefile
index 72cbfdc..27ab75f 100644
--- a/drivers/net/irda/Makefile
+++ b/drivers/net/irda/Makefile
@@ -41,8 +41,9 @@ obj-$(CONFIG_LITELINK_DONGLE)	+=3D litelin
 obj-$(CONFIG_GIRBIL_DONGLE)	+=3D girbil-sir.o
 obj-$(CONFIG_OLD_BELKIN_DONGLE)	+=3D old_belkin-sir.o
 obj-$(CONFIG_MCP2120_DONGLE)	+=3D mcp2120-sir.o
 obj-$(CONFIG_ACT200L_DONGLE)	+=3D act200l-sir.o
 obj-$(CONFIG_MA600_DONGLE)	+=3D ma600-sir.o
+obj-$(CONFIG_TOIM3232_DONGLE)	+=3D toim3232-sir.o
=20
 # The SIR helper module
 sir-dev-objs :=3D sir_dev.o sir_dongle.o sir_kthread.o

diff --git a/drivers/net/irda/toim3232-sir.c b/drivers/net/irda/toim3232-=
sir.c
new file mode 100644
index 0000000..b8e275c
--- a/drivers/net/irda/toim3232-sir.c
+++ b/drivers/net/irda/toim3232-sir.c
@@ -0,0 +1,375 @@
+/*********************************************************************
+ *               =20
+ * Filename:      toim3232-sir.c
+ * Version:       1.0
+ * Description:   Implementation of dongles based on the Vishay/Temic
+ * 		  TOIM3232 SIR Endec chipset. Currently only the
+ * 		  IRWave IR320ST-2 is tested, although it should work
+ * 		  with any TOIM3232 or TOIM4232 chipset based RS232
+ * 		  dongle with minimal modification.
+ * 		  Based heavily on the Tekram driver (tekram.c),=20
+ * 		  with thanks to Dag Brattli and Martin Diehl.
+ * Status:        Experimental.
+ * Author:        David Basden <davidb-irda-Q/PxBS77Xz0@public.gmane.org>
+ * Created at:    Thu Feb 09 23:47:32 2006
+ *=20
+ *     Copyright (c) 2006 David Basden.
+ *     Copyright (c) 1998-1999 Dag Brattli,
+ *     Copyright (c) 2002 Martin Diehl,
+ *     All Rights Reserved.
+ *     =20
+ *     This program is free software; you can redistribute it and/or=20
+ *     modify it under the terms of the GNU General Public License as=20
+ *     published by the Free Software Foundation; either version 2 of=20
+ *     the License, or (at your option) any later version.
+ * =20
+ *     Neither Dag Brattli nor University of Troms=C3=B8 admit liability=
 nor
+ *     provide warranty for any of this software. This material is=20
+ *     provided "AS-IS" and at no charge.
+ *    =20
+ ********************************************************************/
+
+/*
+ * This driver has currently only been tested on the IRWave IR320ST-2
+ *=20
+ * PROTOCOL:
+ *
+ * The protocol for talking to the TOIM3232 is quite easy, and is
+ * designed to interface with RS232 with only level convertors. The
+ * BR/~D line on the chip is brought high to signal 'command mode',
+ * where a command byte is sent to select the baudrate of the RS232
+ * interface and the pulse length of the IRDA output. When BR/~D
+ * is brought low, the dongle then changes to the selected baudrate,
+ * and the RS232 interface is used for data until BR/~D is brought
+ * high again. The initial speed for the TOIMx323 after RESET is=20
+ * 9600 baud.  The baudrate for command-mode is the last selected
+ * baud-rate, or 9600 after a RESET.
+ *
+ * The  dongle I have (below) adds some extra hardware on the front end,
+ * but this is mostly directed towards pariasitic power from the RS232
+ * line rather than changing very much about how to communicate with
+ * the TOIM3232.
+ *
+ * The protocol to talk to the TOIM4232 chipset seems to be almost
+ * identical to the TOIM3232 (and the 4232 datasheet is more detailed)
+ * so this code will probably work on that as well, although I haven't
+ * tested it on that hardware.
+ *
+ * Target dongle variations that might be common:
+ *
+ * DTR and RTS function:=20
+ *   The data sheet for the 4232 has a sample implementation that hooks =
the
+ *   DTR and RTS lines to the RESET and BaudRate/~Data lines of the
+ *   chip (through line-converters). Given both DTR and RTS would have t=
o
+ *   be held low in normal operation, and the TOIMx232 requires +5V to
+ *   signal ground, most dongle designers would almost certainly choose
+ *   an implementation that kept at least one of DTR or RTS high in=20
+ *   normal operation to provide power to the dongle, but will likely
+ *   vary between designs.
+ *
+ * User specified command bits:
+ *  There are two user-controllable output lines from the TOIMx232 that
+ *  can be set low or high by setting the appropriate bits in the
+ *  high-nibble of the command byte (when setting speed and pulse length=
).
+ *  These might be used to switch on and off added hardware or extra
+ *  dongle features.
+ *
+ *
+ * Target hardware: IRWave IR320ST-2
+ *
+ * 	The IRWave IR320ST-2 is a simple dongle based on the Vishay/Temic
+ * 	TOIM3232 SIR Endec and the Vishay/Temic TFDS4500 SIR IRDA transcieve=
r.
+ * 	It uses a hex inverter and some discrete components to buffer and
+ * 	line convert the RS232 down to 5V.
+ *
+ * 	The dongle is powered through a voltage regulator, fed by a large
+ * 	capacitor. To switch the dongle on, DTR is brought high to charge=20
+ * 	the capacitor and drive the voltage regulator. DTR isn't associated
+ * 	with any control lines on the TOIM3232. Parisitic power is also take=
n
+ * 	from the RTS, TD and RD lines when brought high, but through resisto=
rs.=20
+ * 	When DTR is low, the circuit might lose power even with RTS high.
+ *
+ * 	RTS is inverted and attached to the BR/~D input pin. When RTS
+ * 	is high, BR/~D is low, and the TOIM3232 is in the normal 'data' mode.
+ * 	RTS is brought low, BR/~D is high, and the TOIM3232 is in 'command=20
+ * 	mode'.
+ *
+ * 	For some unknown reason, the RESET line isn't actually connected
+ * 	to anything. This means to reset the dongle to get it to a known
+ * 	state (9600 baud) you must drop DTR and RTS low, wait for the power
+ * 	capacitor to discharge, and then bring DTR (and RTS for data mode)
+ * 	high again, and wait for the capacitor to charge, the power supply
+ * 	to stabilise, and the oscillator clock to stabilise.=20
+ *
+ * 	Fortunately, if the current baudrate is known, the chipset can
+ * 	easily change speed by entering command mode without having to
+ * 	reset the dongle first.
+ *
+ * 	Major Components:
+ *
+ * 	- Vishay/Temic TOIM3232 SIR Endec to change RS232 pulse timings=20
+ * 	  to IRDA pulse timings
+ * 	- 3.6864MHz crystal to drive TOIM3232 clock oscillator
+ * 	- DM74lS04M Inverting Hex line buffer for RS232 input buffering
+ * 	  and level conversion
+ * 	- PJ2951AC 150mA voltage regulator
+ * 	- Vishay/Temic TFDS4500	SIR IRDA front-end transceiver
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/init.h>=20
+
+#include <net/irda/irda.h>
+
+#include "sir-dev.h"
+
+MODULE_PARM(toim3232delay, "i");
+MODULE_PARM_DESC(toim3232delay, "toim3232 dongle write complete delay");
+static int toim3232delay =3D 150;	/* default is 150 ms */
+
+#if 0
+MODULE_PARM(toim3232flipdtr, "i");
+MODULE_PARM_DESC(toim3232flipdtr, "toim3232 dongle invert DTR (Reset)");
+static int toim3232flipdtr =3D 0;	/* default is DTR high to reset */
+
+MODULE_PARM(toim3232fliptrs, "i");
+MODULE_PARM_DESC(toim3232fliprts, "toim3232 dongle invert RTS (BR/D)");
+static int toim3232fliprts =3D 0;	/* default is RTS high for baud change=
 */
+#endif
+
+static int toim3232_open(struct sir_dev *);
+static int toim3232_close(struct sir_dev *);
+static int toim3232_change_speed(struct sir_dev *, unsigned);
+static int toim3232_reset(struct sir_dev *);
+
+#define TOIM3232_115200 0x00
+#define TOIM3232_57600  0x01
+#define TOIM3232_38400  0x02
+#define TOIM3232_19200  0x03
+#define TOIM3232_9600   0x06
+#define TOIM3232_2400   0x0A
+
+#define TOIM3232_PW     0x10 /* Pulse select bit */
+
+static struct dongle_driver toim3232 =3D {
+	.owner		=3D THIS_MODULE,
+	.driver_name	=3D "Vishay TOIM3232",
+	.type		=3D IRDA_TOIM3232_DONGLE,
+	.open		=3D toim3232_open,
+	.close		=3D toim3232_close,
+	.reset		=3D toim3232_reset,
+	.set_speed	=3D toim3232_change_speed,
+};
+
+static int __init toim3232_sir_init(void)
+{
+	if (toim3232delay < 1  ||  toim3232delay > 500)
+		toim3232delay =3D 200;
+	IRDA_DEBUG(1, "%s - using %d ms delay\n",
+		toim3232.driver_name, toim3232delay);
+	return irda_register_dongle(&toim3232);
+}
+
+static void __exit toim3232_sir_cleanup(void)
+{
+	irda_unregister_dongle(&toim3232);
+}
+
+static int toim3232_open(struct sir_dev *dev)
+{
+	struct qos_info *qos =3D &dev->qos;
+
+	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+
+	/* Pull the lines high to start with.=20
+	 *
+	 * For the IR320ST-2, we need to charge the main supply capacitor to
+	 * switch the device on. We keep DTR high throughout to do this.
+	 * When RTS, TD and RD are high, they will also trickle-charge the
+	 * cap. RTS is high for data transmission, and low for baud rate select.
+	 * 	-- DGB
+	 */
+	sirdev_set_dtr_rts(dev, TRUE, TRUE);
+
+	/* The TOI3232 supports many speeds between 1200bps and 115000bps.
+	 * We really only care about those supported by the IRDA spec, but
+	 * 38400 seems to be implemented in many places */
+	qos->baud_rate.bits &=3D IR_2400|IR_9600|IR_19200|IR_38400|IR_57600|IR_=
115200;
+
+	/* From the tekram driver. Not sure what a reasonable value is -- DGB *=
/
+	qos->min_turn_time.bits =3D 0x01; /* Needs at least 10 ms */
+	irda_qos_bits_to_value(qos);
+
+	/* irda thread waits 50 msec for power settling */
+
+	return 0;
+}
+
+static int toim3232_close(struct sir_dev *dev)
+{
+	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+
+	/* Power off dongle */
+	sirdev_set_dtr_rts(dev, FALSE, FALSE);
+
+	return 0;
+}
+
+/*
+ * Function toim3232change_speed (dev, state, speed)
+ *
+ *    Set the speed for the TOIM3232 based dongle. Warning, this=20
+ *    function must be called with a process context!
+ *
+ *    Algorithm
+ *    1. keep DTR high but clear RTS to bring into baud programming mode
+ *    2. wait at least 7us to enter programming mode=20
+ *    3. send control word to set baud rate and timing
+ *    4. wait at least 1us
+ *    5. bring RTS high to enter DATA mode (RS232 is passed through to t=
ransceiver)
+ *    6. should take effect immediately (although probably worth waiting=
)
+ */
+
+#define TOIM3232_STATE_WAIT_SPEED	(SIRDEV_STATE_DONGLE_SPEED + 1)
+
+static int toim3232_change_speed(struct sir_dev *dev, unsigned speed)
+{
+	unsigned state =3D dev->fsm.substate;
+	unsigned delay =3D 0;
+	u8 byte;
+	static int ret =3D 0;
+=09
+	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+
+	switch(state) {
+	case SIRDEV_STATE_DONGLE_SPEED:
+
+		/* Figure out what we are going to send as a control byte */
+		switch (speed) {
+		case 2400:
+			byte =3D TOIM3232_PW|TOIM3232_2400;
+			break;
+		default:
+			speed =3D 9600;
+			ret =3D -EINVAL;
+			/* fall thru */
+		case 9600:
+			byte =3D TOIM3232_PW|TOIM3232_9600;
+			break;
+		case 19200:
+			byte =3D TOIM3232_PW|TOIM3232_19200;
+			break;
+		case 38400:
+			byte =3D TOIM3232_PW|TOIM3232_38400;
+			break;
+		case 57600:
+			byte =3D TOIM3232_PW|TOIM3232_57600;
+			break;
+		case 115200:
+			byte =3D TOIM3232_115200;
+			break;
+		}
+
+		/* Set DTR, Clear RTS: Go into baud programming mode */
+		sirdev_set_dtr_rts(dev, TRUE, FALSE);
+=09
+		/* Wait at least 7us */
+		udelay(14);
+
+		/* Write control byte */
+		sirdev_raw_write(dev, &byte, 1);
+	=09
+		dev->speed =3D speed;
+
+		state =3D TOIM3232_STATE_WAIT_SPEED;
+		delay =3D toim3232delay;
+		break;
+
+	case TOIM3232_STATE_WAIT_SPEED:
+		/* Have transmitted control byte * Wait for 'at least 1us' */
+		udelay(14);
+
+		/* Set DTR, Set RTS: Go into normal data mode */
+		sirdev_set_dtr_rts(dev, TRUE, TRUE);
+
+		/* Wait (TODO: check this is needed) */
+		udelay(50);
+		break;
+
+	default:
+		printk(KERN_ERR "%s - undefined state %d\n", __FUNCTION__, state);
+		ret =3D -EINVAL;
+		break;
+	}
+
+	dev->fsm.substate =3D state;
+	return (delay > 0) ? delay : ret;
+}
+
+/*
+ * Function toim3232reset (driver)
+ *
+ *      This function resets the toim3232 dongle. Warning, this function=
=20
+ *      must be called with a process context!!=20
+ *
+ * What we should do is:
+ * 	0. Pull RESET high=20
+ * 	1. Wait for at least 7us
+ * 	2. Pull RESET low
+ * 	3. Wait for at least 7us
+ * 	4. Pull BR/~D high
+ * 	5. Wait for at least 7us
+ * 	6. Send control byte to set baud rate
+ * 	7. Wait at least 1us after stop bit
+ * 	8. Pull BR/~D low
+ * 	9. Should then be in data mode
+ *
+ * Because the IR320ST-2 doesn't have the RESET line connected for some =
reason,
+ * we'll have to do something else.
+ *
+ * The default speed after a RESET is 9600, so lets try just bringing it=
 up in=20
+ * data mode after switching it off, waiting for the supply capacitor to
+ * discharge, and then switch it back on. This isn't actually pulling RE=
SET
+ * high, but it seems to have the same effect.
+ *
+ * This behaviour will probably work on dongles that have the RESET line=
 connected,
+ * but if not, add a flag for the IR320ST-2, and implment the above-list=
ed proper
+ * behaviour.
+ *
+ * RTS is inverted and then fed to BR/~D, so to put it in programming mo=
de, we
+ * need to have pull RTS low
+ */
+
+static int toim3232_reset(struct sir_dev *dev)
+{
+	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+
+	/* Switch off both DTR and RTS to switch off dongle */
+	sirdev_set_dtr_rts(dev, FALSE, FALSE);=20
+
+	/* Should sleep a while. This might be evil doing it this way.*/
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(msecs_to_jiffies(50));
+
+	/* Set DTR, Set RTS (data mode) */
+	sirdev_set_dtr_rts(dev, TRUE, TRUE);
+=09
+	/* Wait at least 10 ms for power to stabilize again */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(msecs_to_jiffies(10));
+
+	/* Speed should now be 9600 */
+	dev->speed =3D 9600;
+
+	return 0;
+}
+
+MODULE_AUTHOR("David Basden <davidb-linux-Q/PxBS77Xz0@public.gmane.org>");
+MODULE_DESCRIPTION("Vishay/Temic TOIM3232 based dongle driver");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("irda-dongle-12"); /* IRDA_TOIM3232_DONGLE */
+	=09
+module_init(toim3232_sir_init);
+module_exit(toim3232_sir_cleanup);

diff --git a/include/linux/irda.h b/include/linux/irda.h
index 95dee17..09d8f10 100644
--- a/include/linux/irda.h
+++ b/include/linux/irda.h
@@ -74,10 +74,11 @@ typedef enum {
 	IRDA_OLD_BELKIN_DONGLE   =3D 7,
 	IRDA_EP7211_IR           =3D 8,
 	IRDA_MCP2120_DONGLE      =3D 9,
 	IRDA_ACT200L_DONGLE      =3D 10,
 	IRDA_MA600_DONGLE        =3D 11,
+	IRDA_TOIM3232_DONGLE     =3D 12,
 } IRDA_DONGLE;
=20
 /* Protocol types to be used for SOCK_DGRAM */
 enum {
 	IRDAPROTO_UNITDATA =3D 0,


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
