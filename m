From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6] e100: 2/2 fix sender hang after tx timeout
Date: Tue, 08 Jun 2004 14:27:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406082127.i58LRVZm006023@death.nxdomain.ibm.com>
Cc: "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Simple patch, long description.  When e100 experiences a
transmit timeout, it calls e100_up() to reset the device.  Among other
things, e100_up() calls netif_start_queue() to release any flow block.
If a socket (in my test case, a packet socket sending minimum size
packets in a loop) is blocked in sendto() due to flow blockage, it will
never wake up, because nothing will run the queue (netif_start_queue()
just clears flow block, it does not schedule).  After a tx timeout, the
tx ring is empty, so no transmit interrupts will arrive, and no new
packets will be sent down because the device queue is full.

	A fix is to call netif_schedule() after e100_up() is complete.
Calling netif_start_queue() won't work, because it only schedules if
called with the device flow blocked (which we've already cleared in
e100_up()).  There might be a better way to do this, but this confines
the change to e100_tx_timeout().

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com



diff -urN linux-2.6.6-semi-virgin/drivers/net/e100.c linux-2.6.6/drivers/net/e100.c
--- linux-2.6.6-semi-virgin/drivers/net/e100.c	2004-06-08 13:54:37.000000000 -0700
+++ linux-2.6.6/drivers/net/e100.c	2004-06-08 13:54:58.000000000 -0700
@@ -1697,6 +1697,7 @@
 		readb(&nic->csr->scb.status));
 	e100_down(netdev->priv);
 	e100_up(netdev->priv);
+	netif_schedule(netdev);
 }
 
 static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)
