From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tun driver not cleaning up on module remove
Date: Thu, 7 Aug 2003 15:45:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807154524.4794ad45.shemminger@osdl.org>
References: <200308051630.28552.bellucda@tiscali.it>
	<20030805090647.691daa7e.shemminger@osdl.org>
	<200308051910.55823.bellucda@tiscali.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bellucda@tiscali.it, "David S. Miller" <davem@redhat.com>
In-Reply-To: <200308051910.55823.bellucda@tiscali.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This should fix module unload issues with tun driver in 2.6-test2.
Driver was not cleaning up it's devices on module exit.

diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	Thu Aug  7 15:41:10 2003
+++ b/drivers/net/tun.c	Thu Aug  7 15:41:10 2003
@@ -605,7 +605,18 @@
 
 void tun_cleanup(void)
 {
+	struct net_device *dev, *nxt;
+
 	misc_deregister(&tun_miscdev);  
+
+	rtnl_lock();
+	for (dev = dev_base; dev; dev = nxt) {
+		nxt = dev->next;
+		if (dev->init == tun_net_init) 
+			unregister_netdevice(dev);
+	}
+	rtnl_unlock();
+	
 }
 
 module_init(tun_init);
