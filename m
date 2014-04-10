From: Steven Galgano <sgalgano@adjacentlink.com>
Subject: [PATCH] tuntap: add flow control to support back pressure
Date: Wed, 09 Apr 2014 22:19:40 -0400
Message-ID: <5345FFBC.7020502@adjacentlink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, xemul@parallels.com,
	wuzhy@linux.vnet.ibm.com, therbert@google.com, yamato@redhat.com,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Brian Adamson <Brian.Adamson@nrl.navy.mil>,
	Joseph Giovatto <jgiovatto@adjacentlink.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:61777 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933251AbaDJCTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 22:19:42 -0400
Received: by mail-qa0-f54.google.com with SMTP id w8so3317182qac.13
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 19:19:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tuntap flow control support for use by back pressure routing protocols. Setting the new TUNSETIFF flag IFF_FLOW_CONTROL, will signal resources as unavailable when the tx queue limit is reached by issuing a netif_tx_stop_all_queues() rather than discarding frames. A netif_tx_wake_all_queues() is issued after reading a frame from the queue to signal resource availability.

Back pressure capability was previously supported by the legacy tun default mode. This change restores that functionality, which was last present in v3.7.

Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
Tested-by: Joseph Giovatto <jgiovatto@adjacentlink.com>
Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>
---
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ee328ba..268130c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -783,8 +783,19 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * number of queues.
 	 */
 	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
-			  >= dev->tx_queue_len)
-		goto drop;
+			>= dev->tx_queue_len) {
+		if (tun->flags & TUN_FLOW_CONTROL) {
+			/* Resources unavailable stop transmissions */
+			netif_tx_stop_all_queues(dev);
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
@@ -1362,6 +1373,9 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 			continue;
 		}
 
+		/* Wake in case resources previously signaled unavailable */
+		netif_tx_wake_all_queues(tun->dev);
+
 		ret = tun_put_user(tun, tfile, skb, iv, len);
 		kfree_skb(skb);
 		break;
@@ -1550,6 +1564,9 @@ static int tun_flags(struct tun_struct *tun)
 	if (tun->flags & TUN_PERSIST)
 		flags |= IFF_PERSIST;
 
+	if (tun->flags & TUN_FLOW_CONTROL)
+		flags |= IFF_FLOW_CONTROL;
+
 	return flags;
 }
 
@@ -1732,6 +1749,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	else
 		tun->flags &= ~TUN_TAP_MQ;
 
+	if (ifr->ifr_flags & IFF_FLOW_CONTROL)
+		tun->flags |= TUN_FLOW_CONTROL;
+	else
+		tun->flags &= ~TUN_FLOW_CONTROL;
+
 	/* Make sure persistent devices do not get stuck in
 	 * xoff state.
 	 */
@@ -1900,7 +1922,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
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
