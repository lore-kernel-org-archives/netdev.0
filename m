From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 4/20] net/ibmtr: remove
	interruptible_sleep_on_timeout() usage
Date: Wed, 2 Feb 2005 10:18:50 -0800
Message-ID: <20050202181850.GE2546@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2691360889185459=="
Cc: netdev@oss.sgi.com, linux-tr@linuxtr.net, kernel-janitors@lists.osdl.org
To: Peter.Deschrijver@linux.cc.kuleuven.ac.be, mikep@linuxtr.net,
   sullivan@us.ibm.com
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============2691360889185459==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

Please consider applying. This patch supersedes the recent patch "net/ibmtr:
remove sleep_on*() usage"

Description: Replace deprecated sleep_on*() function calls with direct
wait-queue usage. Patch is compile-tested. The patch also fixes a potentially
racy conditional in tok_open(), whereby msleep_interruptible() could receive a
signal within the last jiffy, thus returning 0, but signal_pending(current)
would be true.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.11-rc2-kj-v/drivers/net/tokenring/ibmtr.c	2005-01-26 11:19:04.000000000 -0800
+++ 2.6.11-rc2-kj/drivers/net/tokenring/ibmtr.c	2005-02-02 10:16:56.000000000 -0800
@@ -109,6 +109,7 @@ in the event that chatty debug messages 
 
 #include <linux/module.h>
 #include <linux/delay.h>
+#include <linux/wait.h>
 
 #ifdef PCMCIA		/* required for ibmtr_cs.c to build */
 #undef MODULE		/* yes, really */
@@ -847,6 +848,7 @@ static int __devinit trdev_init(struct n
 
 static int tok_init_card(struct net_device *dev)
 {
+	DEFINE_WAIT(wait);
 	struct tok_info *ti;
 	short PIOaddr;
 	unsigned long i;
@@ -867,13 +869,16 @@ static int tok_init_card(struct net_devi
 		writeb(SRPR_ENABLE_PAGING,ti->mmio+ACA_OFFSET+ACA_RW+SRPR_EVEN);
 #endif
 	writeb(INT_ENABLE, ti->mmio + ACA_OFFSET + ACA_SET + ISRP_EVEN);
-	i = sleep_on_timeout(&ti->wait_for_reset, 4 * HZ);
+	prepare_to_wait(&ti->wait_for_reset, &wait, TASK_UNINTERRUPTIBLE);
+	i = schedule_timeout(4*HZ);
+	finish_wait(&ti->wait_for_reset, &wait);
 	return i? 0 : -EAGAIN;
 }
 
 /*****************************************************************************/
 static int tok_open(struct net_device *dev)
 {
+	DEFINE_WAIT(wait);
 	struct tok_info *ti = (struct tok_info *) dev->priv;
 	int i;
 
@@ -903,7 +908,9 @@ static int tok_open(struct net_device *d
 
 	while (1){
 		tok_open_adapter((unsigned long) dev);
-		i= interruptible_sleep_on_timeout(&ti->wait_for_reset, 25 * HZ);
+		prepare_to_wait(&ti->wait_for_reset, &wait, TASK_INTERRUPTIBLE);
+		i = schedule_timeout(25 * HZ);
+		finish_wait(&ti->wait_for_reset, &wait);
 		/* sig catch: estimate opening adapter takes more than .5 sec*/
 		if (i>(245*HZ)/10) break; /* fancier than if (i==25*HZ) */
 		if (i==0) break;
@@ -912,7 +919,8 @@ static int tok_open(struct net_device *d
 			DPRINTK("Adapter is up and running\n");
 			return 0;
 		}
-		if(msleep_interruptible(jiffies_to_msecs(TR_RETRY_INTERVAL)))
+		msleep_interruptible(jiffies_to_msecs(TR_RETRY_INTERVAL));
+		if (signal_pending(current))
 			break; /*prob. a signal, like the i>24*HZ case above */
 	}
 	outb(0, dev->base_addr + ADAPTRESET);/* kill pending interrupts*/

--===============2691360889185459==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============2691360889185459==--
