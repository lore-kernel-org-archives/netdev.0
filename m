From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/2) syncppp wan device regression
Date: Mon, 13 Oct 2003 11:09:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013110955.688c1c5c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In 2.6.0-test6, I put in a patch which fixed sealevel driver, but broke
all the other wan devices because it got rid of one level of indirection.

This puts back the indirection, and hopefully prevents others from
misreading it the same way. The SPPP drivers expect that
netdev->priv points to device local structure whose first element
is a pointer to the ppp device. 

This is a resend of an earlier patch which seems not to have been included.

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
