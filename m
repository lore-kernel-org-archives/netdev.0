From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 4/5] tun: vringfd receive support.
Date: Fri, 18 Apr 2008 14:42:16 +1000
Message-ID: <200804181442.17251.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au> <200804181439.49051.rusty@rustcorp.com.au> <200804181441.10499.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45284 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbYDREnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 00:43:13 -0400
In-Reply-To: <200804181441.10499.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies tun to allow a vringfd to specify the receive
buffer.  Because we can't copy to userspace in bh context, we queue
like normal then use the "pull" hook to actually do the copy.

We use struct virtio_net_hdr prepended to packets in the ring to allow
userspace to receive GSO packets in future (at the moment, the tun
driver doesn't tell the stack it can handle them, so these cases are
never taken).  This will need to be something that userspace tells us
it can handle.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/Kconfig    |    2 
 drivers/net/tun.c      |  159 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_tun.h |    1 
 3 files changed, 162 insertions(+)

diff -r 9bafcef88e1b drivers/net/Kconfig
--- a/drivers/net/Kconfig	Fri Apr 18 05:54:45 2008 +1000
+++ b/drivers/net/Kconfig	Fri Apr 18 05:58:40 2008 +1000
@@ -120,6 +120,8 @@ config TUN
 config TUN
 	tristate "Universal TUN/TAP device driver support"
 	select CRC32
+# If no VRING at all, that's fine, but if it's a module, we must be, too.
+	depends on !VRING || VRING
 	---help---
 	  TUN/TAP provides packet reception and transmission for user space
 	  programs.  It can be viewed as a simple Point-to-Point or Ethernet
diff -r 9bafcef88e1b drivers/net/tun.c
--- a/drivers/net/tun.c	Fri Apr 18 05:54:45 2008 +1000
+++ b/drivers/net/tun.c	Fri Apr 18 05:58:40 2008 +1000
@@ -62,6 +62,9 @@
 #include <linux/if_ether.h>
 #include <linux/if_tun.h>
 #include <linux/crc32.h>
+#include <linux/vring.h>
+#include <linux/virtio_net.h>
+#include <linux/file.h>
 #include <net/net_namespace.h>
 
 #include <asm/system.h>
@@ -98,6 +101,9 @@ struct tun_struct {
 	u8 dev_addr[ETH_ALEN];
 	u32 chr_filter[2];
 	u32 net_filter[2];
+
+	struct vring_info	*inring;
+	struct file		*infile;
 
 #ifdef TUN_DEBUG
 	int debug;
@@ -158,6 +164,10 @@ static int tun_net_xmit(struct sk_buff *
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
+
+	if (tun->inring)
+		vring_wake(tun->inring);
+
 	wake_up_interruptible(&tun->read_wait);
 	return 0;
 
@@ -249,6 +259,149 @@ static void tun_net_init(struct net_devi
 		break;
 	}
 }
+
+#if defined(CONFIG_VRING) || defined(CONFIG_VRING_MODULE)
+/* Returns whether there are queued buffers */
+static bool pending_recv_skbs(void *_tun)
+{
+	struct tun_struct *tun = _tun;
+
+	return !skb_queue_empty(&tun->readq);
+}
+
+/* Returns 0, or negative errno. */
+static int pull_recv_skbs(void *_tun)
+{
+	struct tun_struct *tun = _tun;
+	int err = 0, num_copied = 0;
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(&tun->readq)) != NULL) {
+		struct iovec iov[1+MAX_SKB_FRAGS];
+		struct virtio_net_hdr gso = { 0 }; /* no info leak */
+		unsigned int iovnum = ARRAY_SIZE(iov);
+		unsigned long len;
+		int id;
+
+		id = vring_get_buffer(tun->inring, iov, &iovnum, &len,
+				      NULL, NULL, NULL);
+		if (id <= 0) {
+			err = id;
+			break;
+		}
+
+		/* FIXME: we could stash this descriptor and go looking for a
+		 * better-sized one.  That would allow them to mix different
+		 * buffer sizes for efficiency. */
+		if (unlikely(len < sizeof(gso) + skb->len)) {
+			tun->dev->stats.tx_aborted_errors++;
+			err = -ENOBUFS; /* PS. You suck! */
+			break;
+		}
+
+		if (skb_is_gso(skb)) {
+			struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+			/* This is a hint as to how much should be linear. */
+			gso.hdr_len = skb_headlen(skb);
+			gso.gso_size = sinfo->gso_size;
+			if (sinfo->gso_type & SKB_GSO_TCPV4)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+			else if (sinfo->gso_type & SKB_GSO_TCPV6)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
+			else
+				BUG();
+			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+				gso.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+		} else
+			gso.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			gso.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			gso.csum_start = skb->csum_start - skb_headroom(skb);
+			gso.csum_offset = skb->csum_offset;
+		} /* else everything is zero */
+
+		err = memcpy_toiovec(iov, (void *)&gso, sizeof(gso));
+		if (unlikely(err)) {
+			tun->dev->stats.tx_fifo_errors++;
+			break;
+		}
+
+		err = skb_copy_datagram_iovec(skb, 0, iov, skb->len);
+		if (unlikely(err)) {
+			tun->dev->stats.tx_fifo_errors++;
+			break;
+		}
+
+		vring_used_buffer(tun->inring, id, sizeof(gso) + skb->len);
+		num_copied++;
+	}
+
+	/* We took an skb, but ring isn't ready for it.  Put it back */
+	if (skb)
+		skb_queue_head(&tun->readq, skb);
+
+	if (num_copied)
+		netif_wake_queue(tun->dev);
+
+	return err;
+}
+
+static struct vring_ops recvops = {
+	.needs_pull = pending_recv_skbs,
+	.pull = pull_recv_skbs,
+};
+
+static int set_recv_vring(struct tun_struct *tun, int fd)
+{
+	int err;
+
+	if (tun->inring)
+		return -EBUSY;
+
+	tun->infile = fget(fd);
+	if (!tun->infile)
+		return -EBADF;
+
+	tun->inring = vring_get(tun->infile);
+	if (!tun->inring) {
+		err = -EBADF;
+		goto put;
+	}
+
+	err = vring_set_ops(tun->inring, &recvops, tun);
+	if (err) {
+		tun->inring = NULL;
+		goto put;
+	}
+	return 0;
+
+put:
+	fput(tun->infile);
+	tun->infile = NULL;
+	return err;
+}
+
+static void unset_vrings(struct tun_struct *tun)
+{
+	if (tun->inring) {
+		vring_unset_ops(tun->inring);
+		fput(tun->infile);
+	}
+}
+#else /* ... !CONFIG_VRING */
+static int set_recv_vring(struct tun_struct *tun, int fd)
+{
+	return -ENOTTY;
+}
+
+static void unset_vrings(struct tun_struct *tun)
+{
+}
+#endif
 
 /* Character device part */
 
@@ -465,6 +618,7 @@ static void tun_setup(struct net_device 
 
 	tun->owner = -1;
 	tun->group = -1;
+	tun->inring = NULL;
 
 	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
@@ -674,6 +828,9 @@ static int tun_chr_ioctl(struct inode *i
 		break;
 #endif
 
+	case TUNSETRECVVRING:
+		return set_recv_vring(tun, arg);
+
 	case SIOCGIFFLAGS:
 		ifr.ifr_flags = tun->if_flags;
 		if (copy_to_user( argp, &ifr, sizeof ifr))
@@ -784,6 +941,8 @@ static int tun_chr_close(struct inode *i
 	DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
 
 	tun_chr_fasync(-1, file, 0);
+
+	unset_vrings(tun);
 
 	rtnl_lock();
 
diff -r 9bafcef88e1b include/linux/if_tun.h
--- a/include/linux/if_tun.h	Fri Apr 18 05:54:45 2008 +1000
+++ b/include/linux/if_tun.h	Fri Apr 18 05:58:40 2008 +1000
@@ -42,6 +42,7 @@
 #define TUNSETOWNER   _IOW('T', 204, int)
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
+#define TUNSETRECVVRING _IOW('T', 207, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
