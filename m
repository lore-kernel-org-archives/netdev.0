From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] net/sb1000: replace nicedelay() with ssleep_interruptible()
Date: Mon, 1 Nov 2004 12:24:45 -0800
Message-ID: <20041101202445.GH1730@us.ibm.com>
References: <E1CO1w1-0002Uj-Hm@sputnik> <4184C6EB.1000700@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4184C6EB.1000700@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 06:05:15AM -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >Any comments would be appreciated.
> >
> >Description: Use msleep_interruptible() instead of nicedelay()
> >to guarantee the task delays as expected. Remove the prototype and
> >definition of nicedelay(). This is a very weird function, because it is
> >called to sleep in terms of usecs, but always sleeps for 1 second,
> >completely ignoring the parameter. I have gone ahead and followed suit,
> >just sleeping for a second in all cases, but maybe someone with the
> >hardware could tell me if perhaps the paramter *should* matter.
> >Also remove a random "^L" character.
> 
> use ssleep() here too

Done, please fine patch below:

Description: Use ssleep_interruptible() instead of nicedelay()
to guarantee the task delays as expected. Remove the prototype and
definition of nicedelay(). This is a very weird function, because it is
called to sleep in terms of usecs, but always sleeps for 1 second,
completely ignoring the parameter. I have gone ahead and followed suit,
just sleeping for a second in all cases, but maybe someone with the
hardware could tell me if perhaps the paramter *should* matter.
escription.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.10-rc1-vanilla/drivers/net/sb1000.c	2004-10-30 15:33:28.000000000 -0700
+++ 2.6.10-rc1/drivers/net/sb1000.c	2004-11-01 12:22:26.000000000 -0800
@@ -90,7 +90,6 @@ static int sb1000_close(struct net_devic
 
 
 /* SB1000 hardware routines to be used during open/configuration phases */
-static inline void nicedelay(unsigned long usecs);
 static inline int card_wait_for_busy_clear(const int ioaddr[],
 	const char* name);
 static inline int card_wait_for_ready(const int ioaddr[], const char* name,
@@ -254,13 +253,6 @@ static struct pnp_driver sb1000_driver =
 
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
@@ -475,7 +467,7 @@ sb1000_reset(const int ioaddr[], const c
 	udelay(1000);
 	outb(0x0, port);
 	inb(port);
-	nicedelay(60000);
+	ssleep_interruptible(1);
 	outb(0x4, port);
 	inb(port);
 	udelay(1000);
@@ -537,7 +529,7 @@ sb1000_activate(const int ioaddr[], cons
 	const unsigned char Command0[6] = {0x80, 0x11, 0x00, 0x00, 0x00, 0x00};
 	const unsigned char Command1[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
 
-	nicedelay(50000);
+	ssleep_interruptible(1);
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
 		return status;
 	if ((status = card_send_command(ioaddr, name, Command1, st)))
@@ -944,7 +936,7 @@ sb1000_open(struct net_device *dev)
 	/* initialize sb1000 */
 	if ((status = sb1000_reset(ioaddr, name)))
 		return status;
-	nicedelay(200000);
+	ssleep_interruptible(1);
 	if ((status = sb1000_check_CRC(ioaddr, name)))
 		return status;
 
