From: Steven Galgano <sgalgano@adjacentlink.com>
Subject: [PATCH v2] tuntap: add flow control to support back pressure
Date: Sun, 13 Apr 2014 21:30:27 -0400
Message-ID: <534B3A33.9090401@adjacentlink.com>
References: <5345FFBC.7020502@adjacentlink.com> <20140410102931.GA12077@redhat.com> <5347487B.4040608@adjacentlink.com> <20140413141745.GB17839@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jasowang@redhat.com, xemul@parallels.com,
	wuzhy@linux.vnet.ibm.com, therbert@google.com, yamato@redhat.com,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Brian Adamson <Brian.Adamson@nrl.navy.mil>,
	Joseph Giovatto <jgiovatto@adjacentlink.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:35984 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbaDNBa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 21:30:29 -0400
Received: by mail-qg0-f54.google.com with SMTP id a108so7749302qge.27
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2014 18:30:29 -0700 (PDT)
In-Reply-To: <20140413141745.GB17839@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added optional per queue flow control support using IFF_FLOW_CONTROL. When the IFF_FLOW_CONTROL TUNSETIFF flag is specified it will set a per queue flag to indicate that the queue should be stopped using netif_tx_stop_queue(), rather than discarding frames once full. After reading a frame from the respective stopped queue, a netif_tx_wake_queue() is issued to signal resource availability.

The per queue TUN_FLOW_CONTROL flag is stored in struct tun_file. This provides the flexibility to enable flow control on all, none or some queues when using IFF_MULTI_QUEUE. When not using IFF_MULTI_QUEUE, IFF_FLOW_CONTROL will apply to the single queue. No changes were made to the default drop frame policy.

This change adds support for back pressure use cases.

Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
Tested-by: Joseph Giovatto <jgiovatto@djacentlink.com>
Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>
---
Previous version of patch did not respect individual queues when applying flow control using netif_tx_stop_all_queues()/netif_tx_wake_all_queues().

 drivers/net/tun.c           | 32 ++++++++++++++++++++++++++++----
 include/uapi/linux/if_tun.h |  2 ++
 2 files changed, 30 insertions(+), 4 deletions(-)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ee328ba..3d09f5a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -137,7 +137,7 @@ struct tun_file {
 	struct tun_struct __rcu *tun;
 	struct net *net;
 	struct fasync_struct *fasync;
-	/* only used for fasnyc */
+	/* used for fasnyc and flow control */
 	unsigned int flags;
 	union {
 		u16 queue_index;
@@ -783,8 +783,19 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * number of queues.
 	 */
 	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
-			  >= dev->tx_queue_len)
-		goto drop;
+			>= dev->tx_queue_len) {
+		if (tfile->flags & TUN_FLOW_CONTROL) {
+			/* Resources unavailable stop queue */
+			netif_tx_stop_queue(netdev_get_tx_queue(dev, txq));
+
+			/* We won't see all dropped packets individually, so
+			 * over run error is more appropriate.
+			 */
+			dev->stats.tx_fifo_errors++;
+		} else {
+			goto drop;
+		}
+	}
 
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		goto drop;
@@ -1333,6 +1344,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
 	ssize_t ret = 0;
+	struct netdev_queue *ntxq;
 
 	tun_debug(KERN_INFO, tun, "tun_do_read\n");
 
@@ -1362,6 +1374,12 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 			continue;
 		}
 
+		ntxq = netdev_get_tx_queue(tun->dev, tfile->queue_index);
+
+		if (tfile->flags & TUN_FLOW_CONTROL &&
+		    netif_tx_queue_stopped(ntxq))
+			netif_tx_wake_queue(ntxq);
+
 		ret = tun_put_user(tun, tfile, skb, iv, len);
 		kfree_skb(skb);
 		break;
@@ -1732,6 +1750,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	else
 		tun->flags &= ~TUN_TAP_MQ;
 
+	if (ifr->ifr_flags & IFF_FLOW_CONTROL)
+		tfile->flags |= TUN_FLOW_CONTROL;
+	else
+		tfile->flags &= ~TUN_FLOW_CONTROL;
+
 	/* Make sure persistent devices do not get stuck in
 	 * xoff state.
 	 */
@@ -1900,7 +1923,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR | IFF_MULTI_QUEUE,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE |
+				IFF_FLOW_CONTROL,
 				(unsigned int __user*)argp);
 	} else if (cmd == TUNSETQUEUE)
 		return tun_set_queue(file, &ifr);
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index e9502dd..bcf2790 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -36,6 +36,7 @@
 #define TUN_PERSIST 	0x0100	
 #define TUN_VNET_HDR 	0x0200
 #define TUN_TAP_MQ      0x0400
+#define TUN_FLOW_CONTROL 0x0800
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -70,6 +71,7 @@
 #define IFF_MULTI_QUEUE 0x0100
 #define IFF_ATTACH_QUEUE 0x0200
 #define IFF_DETACH_QUEUE 0x0400
+#define IFF_FLOW_CONTROL 0x0010
 /* read-only flag */
 #define IFF_PERSIST	0x0800
 #define IFF_NOFILTER	0x1000
