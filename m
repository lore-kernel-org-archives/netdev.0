From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] net/ibmtr: replace schedule_timeout() with msleep()/msleep_interruptible()
Date: Mon, 1 Nov 2004 11:27:38 -0800
Message-ID: <20041101192738.GE1730@us.ibm.com>
References: <E1CO1wB-0002eM-If@sputnik> <4184C66B.8040501@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4184C66B.8040501@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 06:03:07AM -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >Any comments would be appreciated.
> >
> >Description: Use msleep() / msleep_interruptible() [as appropriate]
> >instead of schedule_timeout() to guarantee the task delays as expected.
> >
> >Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> >Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> >
> >---
> >
> > linux-2.6.10-rc1-max/drivers/net/tokenring/ibmtr.c |   11 +++++------
> > 1 files changed, 5 insertions(+), 6 deletions(-)
> >
> >-		schedule_timeout(TR_RST_TIME); /* wait 50ms */
> >+		msleep(jiffies_to_msecs(TR_RST_TIME)); /* wait 50ms */

<snip>

> >-	current->state=TASK_UNINTERRUPTIBLE;
> >-	schedule_timeout(TR_RST_TIME); /* wait 50ms */
> >+	msleep(jiffies_to_msecs(TR_RST_TIME));		/* wait 50ms */

<snip>

> >-		current->state=TASK_INTERRUPTIBLE;
> >-		i=schedule_timeout(TR_RETRY_INTERVAL); /* wait 30 seconds */
> >-		if(i!=0) break; /*prob. a signal, like the i>24*HZ case 
> >above */
> >+		if(msleep_interruptible(jiffies_to_msecs(TR_RETRY_INTERVAL)))
> >+			break; /*prob. a signal, like the i>24*HZ case above 

<snip>

> It makes more sense to convert the constants to msecs in the source 
> code, instead of converting them at runtime.

Here is the patch to ibmtr.c which completes these changes...

Description: Uses msleep()/msleep_interruptible() [as appropriate] to
guarantee the task delays as expected. This patch depends on the
corresponding addition of the millisecond-unit constants to ibmtr.h.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-rc1-vanilla/drivers/net/tokenring/ibmtr.c	2004-10-30 15:33:28.000000000 -0700
+++ 2.6.10-rc1/drivers/net/tokenring/ibmtr.c	2004-11-01 11:18:10.000000000 -0800
@@ -130,6 +130,7 @@ in the event that chatty debug messages 
 #include <linux/ip.h>
 #include <linux/trdevice.h>
 #include <linux/ibmtr.h>
+#include <linux/delay.h>
 
 #include <net/checksum.h>
 
@@ -317,7 +318,7 @@ static void ibmtr_cleanup_card(struct ne
 	if (dev->base_addr) {
 		outb(0,dev->base_addr+ADAPTRESET);
 		
-		schedule_timeout(TR_RST_TIME); /* wait 50ms */
+		msleep(TR_RST_TIME_MS);
 
 		outb(0,dev->base_addr+ADAPTRESETREL);
 	}
@@ -858,8 +859,7 @@ static int tok_init_card(struct net_devi
 	writeb(~INT_ENABLE, ti->mmio + ACA_OFFSET + ACA_RESET + ISRP_EVEN);
 	outb(0, PIOaddr + ADAPTRESET);
 
-	current->state=TASK_UNINTERRUPTIBLE;
-	schedule_timeout(TR_RST_TIME); /* wait 50ms */
+	msleep(TR_RST_TIME_MS);
 
 	outb(0, PIOaddr + ADAPTRESETREL);
 #ifdef ENABLE_PAGING
@@ -912,9 +912,8 @@ static int tok_open(struct net_device *d
 			DPRINTK("Adapter is up and running\n");
 			return 0;
 		}
-		current->state=TASK_INTERRUPTIBLE;
-		i=schedule_timeout(TR_RETRY_INTERVAL); /* wait 30 seconds */
-		if(i!=0) break; /*prob. a signal, like the i>24*HZ case above */
+		if(msleep_interruptible(TR_RETRY_INTERVAL_MS)) break;
+				/*prob. a signal, like the i>24*HZ case above */
 	}
 	outb(0, dev->base_addr + ADAPTRESET);/* kill pending interrupts*/
 	DPRINTK("TERMINATED via signal\n");	/*BMS useful */
