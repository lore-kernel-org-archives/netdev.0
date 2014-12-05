From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next] tun: support retrieving multiple packets in a single read with IFF_MULTI_READ
Date: Thu, 4 Dec 2014 20:00:00 -0800
Message-ID: <1417752000-27171-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <mst@redhat.com>,
	<herbert@gondor.apena.org.au>, <kernel-team@fb.com>,
	Alex Gartrell <agartrell@fb.com>
To: <jasonwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the IFF_MULTI_READ flag.  This has the following behavior.

1) If a read is too short for a packet, a single stripped packet will be read

2) If a read is long enough for multiple packets, as many *full* packets
will be read as possible.  We will not return a stripped packet, so even if
there are many, many packets, we may get a short read.

In casual performance testing with a simple test program that simply reads
and counts packets, IFF_MULTI_READ conservatively yielded a 30% CPU win, as
measured by top.  Load was being driven by a bunch of hpings running on a
server on the same L2 network (single hop through a top-of-rack switch).

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 drivers/net/tun.c           | 66 ++++++++++++++++++++++++++++++++++++++-------
 include/uapi/linux/if_tun.h |  3 +++
 2 files changed, 60 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6d44da1..f57d618 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1228,6 +1228,26 @@ static ssize_t tun_chr_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	return result;
 }
 
+static inline size_t tun_calc_max_put_len(const struct tun_struct *tun)
+{
+	size_t len = 0;
+
+	/* It's a pain to peek the skb, so let's assume the worst:
+	 * 1) That skb->len = mtu
+	 * 2) That there is a vlan_tx_tag present
+	 */
+
+	len += tun->dev->mtu + VLAN_HLEN;
+
+	if (tun->flags & TUN_VNET_HDR)
+		len += tun->vnet_hdr_sz;
+
+	if (!(tun->flags & TUN_NO_PI))
+		len += sizeof(struct tun_pi);
+
+	return len;
+}
+
 /* Put packet to the user space buffer */
 static ssize_t tun_put_user(struct tun_struct *tun,
 			    struct tun_file *tfile,
@@ -1343,8 +1363,10 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 			   struct iov_iter *to,
 			   int noblock)
 {
+	const size_t max_put_len = tun_calc_max_put_len(tun);
 	struct sk_buff *skb;
-	ssize_t ret;
+	ssize_t ret = 0;
+	ssize_t put_ret = 0;
 	int peeked, err, off = 0;
 
 	tun_debug(KERN_INFO, tun, "tun_do_read\n");
@@ -1355,14 +1377,31 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	if (tun->dev->reg_state != NETREG_REGISTERED)
 		return -EIO;
 
-	/* Read frames from queue */
-	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
-				  &peeked, &off, &err);
-	if (!skb)
-		return 0;
+	while (!ret || ((tun->flags & TUN_MULTI_READ) &&
+			iov_iter_count(to) >= max_put_len)) {
+		/* Read frames from queue */
+		skb = __skb_recv_datagram(tfile->socket.sk,
+					  noblock ? MSG_DONTWAIT : 0,
+					  &peeked, &off, &err);
+		if (skb) {
+			put_ret = tun_put_user(tun, tfile, skb, to);
+			kfree_skb(skb);
+			if (put_ret < 0) {
+				ret = put_ret;
+				break;
+			}
+			ret += put_ret;
+		} else {
+			if (!ret)
+				ret = err;
+			break;
+		}
 
-	ret = tun_put_user(tun, tfile, skb, to);
-	kfree_skb(skb);
+		/* Now that we've received a datagram, noblock for the
+		 * rest
+		 */
+		noblock = 1;
+	}
 
 	return ret;
 }
@@ -1537,6 +1576,9 @@ static int tun_flags(struct tun_struct *tun)
 	if (tun->flags & TUN_PERSIST)
 		flags |= IFF_PERSIST;
 
+	if (tun->flags & TUN_MULTI_READ)
+		flags |= IFF_MULTI_READ;
+
 	return flags;
 }
 
@@ -1720,6 +1762,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	else
 		tun->flags &= ~TUN_TAP_MQ;
 
+	if (ifr->ifr_flags & IFF_MULTI_READ)
+		tun->flags |= TUN_MULTI_READ;
+	else
+		tun->flags &= ~TUN_MULTI_READ;
+
 	/* Make sure persistent devices do not get stuck in
 	 * xoff state.
 	 */
@@ -1883,7 +1930,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR | IFF_MULTI_QUEUE,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE |
+				IFF_MULTI_READ,
 				(unsigned int __user*)argp);
 	} else if (cmd == TUNSETQUEUE)
 		return tun_set_queue(file, &ifr);
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index e9502dd..aaf9ddc 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -36,6 +36,7 @@
 #define TUN_PERSIST 	0x0100	
 #define TUN_VNET_HDR 	0x0200
 #define TUN_TAP_MQ      0x0400
+#define TUN_MULTI_READ	0x0800
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -74,6 +75,8 @@
 #define IFF_PERSIST	0x0800
 #define IFF_NOFILTER	0x1000
 
+#define IFF_MULTI_READ	0x2000
+
 /* Socket options */
 #define TUN_TX_TIMESTAMP 1
 
-- 
Alex Gartrell <agartrell@fb.com>
