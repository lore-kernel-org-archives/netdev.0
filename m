From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Patch for oops in ctc
Date: Sun, 24 Aug 2003 17:58:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824175816.A872@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Pete Zaitcev <zaitcev@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux390@de.ibm.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin & others:

the following bug is still with us. What's the deal?
The matter is clear, calling dst_link_failure from an
interrupt is illegal (and pointless).

I have a separate patch which adds carrier control to ctc
according to DaveM's suggestions, but let's at least fix
the bug first.

-- Pete

diff -ur -X dontdiff linux-2.6.0-test4/drivers/s390/net/ctcmain.c linux-2.6.0-test4-s390/drivers/s390/net/ctcmain.c
--- linux-2.6.0-test4/drivers/s390/net/ctcmain.c	2003-08-24 14:24:50.000000000 -0700
+++ linux-2.6.0-test4-s390/drivers/s390/net/ctcmain.c	2003-08-24 14:53:25.000000000 -0700
@@ -2441,14 +2441,12 @@
 
 	/**
 	 * If channels are not running, try to restart them
-	 * notify anybody about a link failure and throw
-	 * away packet. 
+	 * and throw away packet. 
 	 */
 	if (fsm_getstate(privptr->fsm) != DEV_STATE_RUNNING) {
 		fsm_event(privptr->fsm, DEV_EVENT_START, dev);
 		if (privptr->protocol == CTC_PROTO_LINUX_TTY)
 			return -EBUSY;
-		dst_link_failure(skb);
 		dev_kfree_skb(skb);
 		privptr->stats.tx_dropped++;
 		privptr->stats.tx_errors++;
diff -ur -X dontdiff linux-2.6.0-test4/drivers/s390/net/netiucv.c linux-2.6.0-test4-s390/drivers/s390/net/netiucv.c
--- linux-2.6.0-test4/drivers/s390/net/netiucv.c	2003-08-24 14:24:50.000000000 -0700
+++ linux-2.6.0-test4-s390/drivers/s390/net/netiucv.c	2003-08-24 14:51:10.000000000 -0700
@@ -1195,12 +1195,10 @@
 
 	/**
 	 * If connection is not running, try to restart it
-	 * notify anybody about a link failure and throw
-	 * away packet. 
+	 * and throw away packet. 
 	 */
 	if (fsm_getstate(privptr->fsm) != DEV_STATE_RUNNING) {
 		fsm_event(privptr->fsm, DEV_EVENT_START, dev);
-		dst_link_failure(skb);
 		dev_kfree_skb(skb);
 		privptr->stats.tx_dropped++;
 		privptr->stats.tx_errors++;
