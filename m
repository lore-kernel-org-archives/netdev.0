From: domen@coderock.org
Subject: [patch 1/3] net/ibmtr: replace schedule_timeout() with msleep()/msleep_interruptible()
Date: Fri, 21 Jan 2005 22:03:35 +0100
Message-ID: <20050121210337.47D191F2D2@trashy.coderock.org>
Cc: domen@coderock.org, nacc@us.ibm.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() / msleep_interruptible() [as appropriate]
instead of schedule_timeout() to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/tokenring/ibmtr.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff -puN drivers/net/tokenring/ibmtr.c~msleep+msleep_interruptible-drivers_net_tokenring_ibmtr drivers/net/tokenring/ibmtr.c
--- kj/drivers/net/tokenring/ibmtr.c~msleep+msleep_interruptible-drivers_net_tokenring_ibmtr	2005-01-10 18:00:13.000000000 +0100
+++ kj-domen/drivers/net/tokenring/ibmtr.c	2005-01-10 18:00:13.000000000 +0100
@@ -108,6 +108,7 @@ in the event that chatty debug messages 
 #define IBMTR_DEBUG_MESSAGES 0
 
 #include <linux/module.h>
+#include <linux/delay.h>
 
 #ifdef PCMCIA		/* required for ibmtr_cs.c to build */
 #undef MODULE		/* yes, really */
@@ -317,7 +318,7 @@ static void ibmtr_cleanup_card(struct ne
 	if (dev->base_addr) {
 		outb(0,dev->base_addr+ADAPTRESET);
 		
-		schedule_timeout(TR_RST_TIME); /* wait 50ms */
+		msleep(jiffies_to_msecs(TR_RST_TIME)); /* wait 50ms */
 
 		outb(0,dev->base_addr+ADAPTRESETREL);
 	}
@@ -858,8 +859,7 @@ static int tok_init_card(struct net_devi
 	writeb(~INT_ENABLE, ti->mmio + ACA_OFFSET + ACA_RESET + ISRP_EVEN);
 	outb(0, PIOaddr + ADAPTRESET);
 
-	current->state=TASK_UNINTERRUPTIBLE;
-	schedule_timeout(TR_RST_TIME); /* wait 50ms */
+	msleep(jiffies_to_msecs(TR_RST_TIME));		/* wait 50ms */
 
 	outb(0, PIOaddr + ADAPTRESETREL);
 #ifdef ENABLE_PAGING
@@ -912,9 +912,8 @@ static int tok_open(struct net_device *d
 			DPRINTK("Adapter is up and running\n");
 			return 0;
 		}
-		current->state=TASK_INTERRUPTIBLE;
-		i=schedule_timeout(TR_RETRY_INTERVAL); /* wait 30 seconds */
-		if(i!=0) break; /*prob. a signal, like the i>24*HZ case above */
+		if(msleep_interruptible(jiffies_to_msecs(TR_RETRY_INTERVAL)))
+			break; /*prob. a signal, like the i>24*HZ case above */
 	}
 	outb(0, dev->base_addr + ADAPTRESET);/* kill pending interrupts*/
 	DPRINTK("TERMINATED via signal\n");	/*BMS useful */
_
