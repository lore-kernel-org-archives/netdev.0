From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/2) fix sppp device pointer
Date: Fri, 3 Oct 2003 14:46:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003144616.11a6b6c5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My bad, a change I put in while debugging the sealevel driver broke
all the other sync drivers.  The SPPP drivers expect that
netdev->priv points to device local structure whose first element
is a pointer to the ppp device. 

The bug was in sppp_of change that got rid of one level of indirection.

To prevent future stupidity, do some reverse lookup check in
sppp_attach and sppp_of.

diff -Nru a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
--- a/drivers/net/wan/syncppp.c	Fri Oct  3 11:28:23 2003
+++ b/drivers/net/wan/syncppp.c	Fri Oct  3 11:28:23 2003
@@ -1069,6 +1069,9 @@
 	struct sppp *sp = &pd->sppp;
 	unsigned long flags;
 
+	/* Make sure embedding is safe for sppp_of */
+	BUG_ON(sppp_of(dev) != sp);
+
 	spin_lock_irqsave(&spppq_lock, flags);
 	/* Initialize keepalive handler. */
 	if (! spppq)
diff -Nru a/include/net/syncppp.h b/include/net/syncppp.h
--- a/include/net/syncppp.h	Fri Oct  3 11:28:23 2003
+++ b/include/net/syncppp.h	Fri Oct  3 11:28:23 2003
@@ -59,8 +59,9 @@
 
 static inline struct sppp *sppp_of(struct net_device *dev) 
 {
-	struct ppp_device *ppp = dev->priv;
-	return &ppp->sppp;
+	struct ppp_device **ppp = dev->priv;
+	BUG_ON((*ppp)->dev != dev);
+	return &(*ppp)->sppp;
 }
 
 #define PP_KEEPALIVE    0x01    /* use keepalive protocol */
