From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6.5] Bad scheduling while atomic
Date: Fri, 16 Apr 2004 13:16:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416131633.1bfbfa4c@dell_ss3.pdx.osdl.net>
References: <200404161551.i3GFpD124970@tag.witbe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul Rolland" <rol@witbe.net>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200404161551.i3GFpD124970@tag.witbe.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bring up/down network devices with lapbether causes scheduling while
atomic (if preempt enabled).

The calls to rcu_read_lock are unnecessary since lapb_device_event 
is called from notifier with the rtnetlink semaphore held, it is
already protected from the labp_devices list changing.

Patch against 2.6.6-rc1

diff -Nru a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
--- a/drivers/net/wan/lapbether.c	Fri Apr 16 11:00:35 2004
+++ b/drivers/net/wan/lapbether.c	Fri Apr 16 11:00:35 2004
@@ -392,6 +392,8 @@
 
 /*
  *	Handle device status changes.
+ *
+ * Called from notifier with RTNL held.
  */
 static int lapbeth_device_event(struct notifier_block *this,
 				unsigned long event, void *ptr)
@@ -402,7 +404,6 @@
 	if (!dev_is_ethdev(dev))
 		return NOTIFY_DONE;
 
-	rcu_read_lock();
 	switch (event) {
 	case NETDEV_UP:
 		/* New ethernet device -> new LAPB interface	 */
@@ -422,7 +423,6 @@
 			lapbeth_free_device(lapbeth);
 		break;
 	}
-	rcu_read_unlock();
 
 	return NOTIFY_DONE;
 }
