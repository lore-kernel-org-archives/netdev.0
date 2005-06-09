From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH] iseries_veth: Supress spurious WARN_ON() at module unload
Date: Thu, 9 Jun 2005 16:11:59 +1000
Message-ID: <200506091611.59648.michael@ellerman.id.au>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Andrew, Jeff,

My patch from a few weeks back (now in mainline), called
"Cleanup skbs to prevent unregister_netdevice() hanging", can cause
our TX timeout code to fire on machines with lots of VLANs (because
it takes > 2 seconds between when we stop the queues and when we're
finished stopping the connections).

When that happens the TX timeout code freaks out and does a WARN_ON()
because as far as it's concerned there shouldn't be a TX timeout
happening, which is fair enough.

I have a "proper" fix for this, which is to a) do refcounting on
connections and b) implement a proper ack timer so we don't keep unacked
skbs lying around for ever. But for 2.6.12 I propose just supressing
the WARN_ON(). Users will still see the "NETDEV WATCHDOG" warning,
but that's not nearly as bad as a WARN_ON() which users interpret
as an Oops.

cheers

--

Supress a spurious WARN_ON() in the iseries_veth driver which can
occur at module unload on machines with many VLANs.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>


--- a/drivers/net/iseries_veth.c 
+++ b/drivers/net/iseries_veth.c 
@@ -802,12 +802,13 @@
 
 	spin_lock_irqsave(&port->pending_gate, flags);
 
+	if (! port->pending_lpmask) {
+		spin_unlock_irqrestore(&port->pending_gate, flags);
+		return;
+	}
+
 	printk(KERN_WARNING "%s: Tx timeout!  Resetting lp connections: %08x\n",
 	       dev->name, port->pending_lpmask);
-
-	/* If we've timed out the queue must be stopped, which should
-	 * only ever happen when there is a pending packet. */
-	WARN_ON(! port->pending_lpmask);
 
 	for (i = 0; i < HVMAXARCHITECTEDLPS; i++) {
 		struct veth_lpar_connection *cnx = veth_cnx[i];
