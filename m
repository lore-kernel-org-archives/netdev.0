From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 2/4 linux-2.6.9-rc3/linux-2.4.28-pre3]
	prism54 Bug in timeout scheduling
Date: Sat, 2 Oct 2004 16:43:40 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200410021643.40328.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_c6rXBEu8/u0bS+K"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_c6rXBEu8/u0bS+K
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-10-02 Margit Schubert-While <margitsw@t-online.de>

* 02_schedbug.patch
*  Bug in loop around schedule_timeout
*  We must rearm the task
*
*  Make timeout message meaningful

Margit

















--Boundary-00=_c6rXBEu8/u0bS+K
Content-Type: text/x-diff;
  charset="us-ascii";
  name="02_schedbug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="02_schedbug.patch"

diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_dev.c	2004-10-02 12:23:39.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_dev.c	2004-10-02 12:26:51.000000000 +0200
@@ -486,6 +486,7 @@
 		/* The software reset acknowledge needs about 220 msec here.
 		 * Be conservative and wait for up to one second. */
 	
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		remaining = schedule_timeout(HZ);
 
 		if(remaining > 0) {
@@ -496,14 +497,14 @@
 		/* If we're here it's because our IRQ hasn't yet gone through. 
 		 * Retry a bit more...
 		 */
-		printk(KERN_ERR "%s: reset problem: no 'reset complete' IRQ seen\n",
+		printk(KERN_ERR "%s: no 'reset complete' IRQ seen - retrying\n",
 			priv->ndev->name);
 	}
 
 	finish_wait(&priv->reset_done, &wait);
 
 	if (result) {
-		printk(KERN_ERR "%s: islpci_reset_if: failure\n", priv->ndev->name);
+		printk(KERN_ERR "%s: interface reset failure\n", priv->ndev->name);
 		return result;
 	}
 
diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_mgt.c linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_mgt.c
--- linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_mgt.c	2004-10-02 12:23:40.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_mgt.c	2004-10-02 12:27:10.000000000 +0200
@@ -473,6 +473,7 @@
 		int timeleft;
 		struct islpci_mgmtframe *frame;
 
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		timeleft = schedule_timeout(wait_cycle_jiffies);
 		frame = xchg(&priv->mgmt_received, NULL);
 		if (frame) {

--Boundary-00=_c6rXBEu8/u0bS+K
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_c6rXBEu8/u0bS+K--
