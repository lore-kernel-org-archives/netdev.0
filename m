From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/2] use rtnl_lock_interruptible in 8139 to avoid shutdown hang
Date: Sun, 9 Jan 2005 13:16:30 +0100
Message-ID: <20050109121630.GB19599@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The 8139too thread needs to use rtnl_lock_interruptible so it can avoid
doing the actual work once it's been kill_proc()ed on module removal
time.

Based on debugging and an earlier patch that adds a driver-private
semaphore from Herbert Xu.

--- 1.101/drivers/net/8139too.c	2004-10-30 02:00:00 +02:00
+++ edited/drivers/net/8139too.c	2005-01-09 12:55:31 +01:00
@@ -1636,7 +1636,8 @@
 		if (tp->time_to_die)
 			break;
 
-		rtnl_lock ();
+		if (rtnl_lock_interruptible ())
+			break;
 		rtl8139_thread_iter (dev, tp, tp->mmio_addr);
 		rtnl_unlock ();
 	}
