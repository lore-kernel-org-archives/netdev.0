From: Jon Mason <jdmason@us.ibm.com>
Subject: Interdomain/interpartition communication without a checksum
Date: Wed, 11 May 2005 13:35:54 -0500
Message-ID: <20050511183554.GA28298@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nivedita Singhvi <niv@us.ibm.com>, Andrew Theurer <habanero@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have been working on a Xen project to remove unnecessary TCP/UDP
checksums for local (interdomain) communication, while still having the
checksum for all external network communication.  

background:
Xen uses a controlling partition (domain 0 in Xen terms) to connect all
guest partitions to physical devices (disk, ethernet, etc).  For network
traffic, the guest partitions connect to the controlling partition via
virtual ethernet devices.  These virtual ethernet devices are either
bridged or routed to the physical ethernet to connect to the external
network.  

In its current implimentation, Xen guest partitions checksum packets
regardless of their intended destination (local or remote) and
regardless of adapter hardware checksum offload capabilities for the
physical adapter.  I have a working prototype which corrects both of
these issues in Xen, but it requires minor changes to two files
(net/core/dev.c and include/linux/netdevice.h).  

I have not submitted this patch to the Xen mailing list, as I wanted all
of you to comment on it first.  The changes are abstract enough to where
they can be used by anyone wanting interdomain/interpartition
communication without a checksum (e.g., not Xen specific).  

I have only included the Linux files, but if anyone is interested I can
also include the modified Xen files.

Thanks,
Jon


--- ../xen-unstable-pristine/linux-2.6.11-xen0/net/core/dev.c	2005-03-02 01:38:09.000000000 -0600
+++ linux-2.6.11-xen0/net/core/dev.c	2005-05-11 08:00:28.234919880 -0500
@@ -98,6 +98,7 @@
 #include <linux/stat.h>
 #include <linux/if_bridge.h>
 #include <linux/divert.h>
+#include <net/ip.h> 
 #include <net/dst.h>
 #include <net/pkt_sched.h>
 #include <net/checksum.h>
@@ -1236,6 +1237,15 @@ int dev_queue_xmit(struct sk_buff *skb)
 	    __skb_linearize(skb, GFP_ATOMIC))
 		goto out_kfree_skb;
 
+	/* If packet is forwarded to a device that needs a checksum and not 
+	 * checksummed, correct the pointers and enable checksumming in the 
+	 * next function.
+	 */
+	if (!(dev->features & NETIF_F_FWD_NO_CSUM) && skb->csum) {
+		skb->ip_summed = CHECKSUM_HW;
+		skb->h.raw = (void *)skb->nh.iph + (skb->nh.iph->ihl * 4);
+	}
+
 	/* If packet is not checksummed and device does not support
 	 * checksumming for this protocol, complete checksumming here.
 	 */
--- ../xen-unstable-pristine/linux-2.6.11-xen0/include/linux/netdevice.h	2005-03-02 01:38:26.000000000 -0600
+++ linux-2.6.11-xen0/include/linux/netdevice.h	2005-05-10 11:03:25.000000000 -0500
@@ -416,6 +416,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_FWD_NO_CSUM	8192	/* Forwards unchecksumed packets */
 
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
