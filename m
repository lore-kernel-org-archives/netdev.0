From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Deadlock in af_packet/packet_rcv
Date: Thu, 25 Nov 2004 21:55:03 +0100
Message-ID: <20041125205503.GA18083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Before introduction of lock-less loopback, all of netdev_xmit_nit was
running with bottom halves disabled, and some code seems to rely on
this. One of them is af_packet's packet_rcv handler, which is called
from the receive path via netdev_xmit_nit.  It takes a spin lock,
and if an interrupt occurs and calls netdev_xmit during this time,
the CPU deadlocks.

The patch below disables BHs while in the TX path for loopback and
similar devices.

An alternative, less conservative fix would be to just use spin_lock_bh
in af_packet.c.

Signed-off-by: Olaf Kirch <okir@suse.de>


Index: linux-2.6.9/net/core/dev.c
===================================================================
--- linux-2.6.9.orig/net/core/dev.c
+++ linux-2.6.9/net/core/dev.c
@@ -1222,6 +1222,7 @@ int __skb_linearize(struct sk_buff *skb,
 }
 
 #define HARD_TX_LOCK(dev, cpu) {			\
+	local_disable_bh();				\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		spin_lock(&dev->xmit_lock);		\
 		dev->xmit_lock_owner = cpu;		\
@@ -1233,6 +1234,7 @@ int __skb_linearize(struct sk_buff *skb,
 		dev->xmit_lock_owner = -1;		\
 		spin_unlock(&dev->xmit_lock);		\
 	}						\
+	local_enable_bh();				\
 }
 
 static inline void qdisc_run(struct net_device *dev)

-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"
