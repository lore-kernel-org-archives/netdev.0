From: janitor@sternwelten.at
Subject: [patch 12/18]  net/sb1000: replace 	nicedelay() with msleep_interruptible()
Date: Sun, 31 Oct 2004 00:42:57 +0200
Message-ID: <E1CO1w1-0002Uj-Hm@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of nicedelay()
to guarantee the task delays as expected. Remove the prototype and
definition of nicedelay(). This is a very weird function, because it is
called to sleep in terms of usecs, but always sleeps for 1 second,
completely ignoring the parameter. I have gone ahead and followed suit,
just sleeping for a second in all cases, but maybe someone with the
hardware could tell me if perhaps the paramter *should* matter.
Also remove a random "^L" character.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/sb1000.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff -puN drivers/net/sb1000.c~msleep_interruptible-drivers_net_sb1000 drivers/net/sb1000.c
--- linux-2.6.10-rc1/drivers/net/sb1000.c~msleep_interruptible-drivers_net_sb1000	2004-10-24 17:05:15.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/sb1000.c	2004-10-24 17:05:15.000000000 +0200
@@ -90,7 +90,6 @@ static int sb1000_close(struct net_devic
 
 
 /* SB1000 hardware routines to be used during open/configuration phases */
-static inline void nicedelay(unsigned long usecs);
 static inline int card_wait_for_busy_clear(const int ioaddr[],
 	const char* name);
 static inline int card_wait_for_ready(const int ioaddr[], const char* name,
@@ -247,20 +246,12 @@ static struct pnp_driver sb1000_driver =
 	.remove		= sb1000_remove_one,
 };
 
-
 /*
  * SB1000 hardware routines to be used during open/configuration phases
  */
 
 const int TimeOutJiffies = (875 * HZ) / 100;
 
-static inline void nicedelay(unsigned long usecs)
-{
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(HZ);
-	return;
-}
-
 /* Card Wait For Busy Clear (cannot be used during an interrupt) */
 static inline int
 card_wait_for_busy_clear(const int ioaddr[], const char* name)
@@ -475,7 +466,7 @@ sb1000_reset(const int ioaddr[], const c
 	udelay(1000);
 	outb(0x0, port);
 	inb(port);
-	nicedelay(60000);
+	msleep_interruptible(1000);
 	outb(0x4, port);
 	inb(port);
 	udelay(1000);
@@ -537,7 +528,7 @@ sb1000_activate(const int ioaddr[], cons
 	const unsigned char Command0[6] = {0x80, 0x11, 0x00, 0x00, 0x00, 0x00};
 	const unsigned char Command1[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
 
-	nicedelay(50000);
+	msleep_interruptible(1000);
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
 		return status;
 	if ((status = card_send_command(ioaddr, name, Command1, st)))
@@ -944,7 +935,7 @@ sb1000_open(struct net_device *dev)
 	/* initialize sb1000 */
 	if ((status = sb1000_reset(ioaddr, name)))
 		return status;
-	nicedelay(200000);
+	msleep_interruptible(1000);
 	if ((status = sb1000_check_CRC(ioaddr, name)))
 		return status;
 
_
