From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ax25 - make sure and hold ref to dev
Date: Fri, 22 Aug 2003 13:13:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030822131328.1696430e.shemminger@osdl.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
	<20030812153901.6e700dcb.shemminger@osdl.org>
	<20030813010301.K28977@jeroen.pe1rxq.ampr.org>
	<20030812172151.7de0c950.shemminger@osdl.org>
	<20030813031159.6c6c9629.davem@redhat.com>
	<20030813173446.A2604@jeroen.pe1rxq.ampr.org>
	<20030813084252.7b667fb8.davem@redhat.com>
	<20030820204518.C5568@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@redhat.com>, linux-hams@vger.kernel.org,
   ralf@linux-mips.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030820204518.C5568@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The lower layers of ax25 hold a reference to the underlying device
but don't increment the ref count. This is safe because it does the
right thing when UNREGISTER notification comes in, but it is better
to do the right thing.

I tested this by messing with bpqether and ax25 to make sure
both can be unloaded correctly.

diff -Nru a/net/ax25/ax25_dev.c b/net/ax25/ax25_dev.c
--- a/net/ax25/ax25_dev.c	Fri Aug 22 08:20:46 2003
+++ b/net/ax25/ax25_dev.c	Fri Aug 22 08:20:46 2003
@@ -67,6 +67,7 @@
 
 	dev->ax25_ptr     = ax25_dev;
 	ax25_dev->dev     = dev;
+	dev_hold(dev);
 	ax25_dev->forward = NULL;
 
 	ax25_dev->values[AX25_VALUES_IPDEFMODE] = AX25_DEF_IPDEFMODE;
@@ -121,6 +122,7 @@
 	if ((s = ax25_dev_list) == ax25_dev) {
 		ax25_dev_list = s->next;
 		spin_unlock_bh(&ax25_dev_lock);
+		dev_put(dev);
 		kfree(ax25_dev);
 		ax25_register_sysctl();
 		return;
@@ -130,6 +132,7 @@
 		if (s->next == ax25_dev) {
 			s->next = ax25_dev->next;
 			spin_unlock_bh(&ax25_dev_lock);
+			dev_put(dev);
 			kfree(ax25_dev);
 			ax25_register_sysctl();
 			return;
@@ -196,8 +199,8 @@
 	ax25_dev = ax25_dev_list;
 	while (ax25_dev != NULL) {
 		s        = ax25_dev;
+		dev_put(ax25_dev->dev);
 		ax25_dev = ax25_dev->next;
-
 		kfree(s);
 	}
 	ax25_dev_list = NULL;
