From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH RFC 3/5] tun: vringfd receive support.
Date: Sat, 5 Apr 2008 22:05:43 +1000
Message-ID: <200804052205.43824.rusty@rustcorp.com.au>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052204.28518.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Max Krasnyansky <maxk@qualcomm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49023 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbYDEMGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 08:06:09 -0400
In-Reply-To: <200804052204.28518.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies tun to allow a vringfd to specify the receive
buffer.  Because we can't copy to userspace in bh context, we queue
like normal then use the "pull" hook to actually do the copy.

More thought needs to be put into the possible races with ring
registration and a simultaneous close, for example (see FIXME).

We use struct virtio_net_hdr prepended to packets in the ring to allow
userspace to receive GSO packets in future (at the moment, the tun
driver doesn't tell the stack it can handle them, so these cases are
never taken).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 285c3112b26c Documentation/test_vring.c
--- a/Documentation/test_vring.c	Sat Apr 05 22:00:10 2008 +1100
+++ b/Documentation/test_vring.c	Sat Apr 05 22:15:56 2008 +1100
@@ -1,21 +1,62 @@
 #include <unistd.h>
 #include <linux/virtio_ring.h>
+#include <linux/ioctl.h>
+#include <linux/if_tun.h>
 #include <stdio.h>
 #include <stdint.h>
+#include <string.h>
 #include <err.h>
 #include <poll.h>
+#include <net/if.h>
+#include <netinet/in.h>
+#include <linux/sockios.h>
+#include <stdlib.h>
+#include <fcntl.h>
+#include <sys/types.h>
 
 #ifndef __NR_vringfd
 #define __NR_vringfd		327
 #endif
 
+/* This sets up the Host end of the network device with an IP address, brings
+ * it up so packets will flow, the copies the MAC address into the hwaddr
+ * pointer. */
+static void configure_device(int fd, const char *devname, uint32_t ipaddr,
+			     unsigned char hwaddr[6])
+{
+	struct ifreq ifr;
+	struct sockaddr_in *sin = (struct sockaddr_in *)&ifr.ifr_addr;
+
+	/* Don't read these incantations.  Just cut & paste them like I did! */
+	memset(&ifr, 0, sizeof(ifr));
+	strcpy(ifr.ifr_name, devname);
+	sin->sin_family = AF_INET;
+	sin->sin_addr.s_addr = htonl(ipaddr);
+	if (ioctl(fd, SIOCSIFADDR, &ifr) != 0)
+		err(1, "Setting %s interface address", devname);
+	ifr.ifr_flags = IFF_UP;
+	if (ioctl(fd, SIOCSIFFLAGS, &ifr) != 0)
+		err(1, "Bringing interface %s up", devname);
+
+	/* SIOC stands for Socket I/O Control.  G means Get (vs S for Set
+	 * above).  IF means Interface, and HWADDR is hardware address.
+	 * Simple! */
+	if (ioctl(fd, SIOCGIFHWADDR, &ifr) != 0)
+		err(1, "getting hw address for %s", devname);
+	memcpy(hwaddr, ifr.ifr_hwaddr.sa_data, 6);
+}
+
+
+
 int main()
 {
-	int fd, r;
+	int fd, tunfd, r;
 	struct vring vr;
 	uint16_t used = 0;
 	struct pollfd pfd;
+	struct ifreq ifr;
 	void *buf = calloc(vring_size(256, getpagesize()), 0);
+	char pkt[65535];
 
 	vring_init(&vr, 256, buf, getpagesize());
 
@@ -23,25 +64,57 @@ int main()
 	if (fd < 0)
 		err(1, "vringfd gave %i", fd);
 
+	tunfd = open("/dev/net/tun", O_RDWR);
+	if (tunfd < 0)
+		err(1, "Opening /dev/net/tun");
+	memset(&ifr, 0, sizeof(ifr));
+	ifr.ifr_flags = IFF_TAP | IFF_NO_PI;
+	strcpy(ifr.ifr_name, "tap%d");
+	if (ioctl(tunfd, TUNSETIFF, &ifr) != 0)
+		err(1, "configuring /dev/net/tun");
+
+	printf("Interface is %s\n", ifr.ifr_name);
+
+	if (ioctl(tunfd, TUNSETRECVVRING, fd) != 0)
+		err(1, "Setting receive ring");
+
+	/* Add a buffer.  Split it nicely between protocol parts. */
+	vr.desc[0].addr = (unsigned long)pkt;
+	vr.desc[0].len = 14;
+	vr.desc[0].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
+	vr.desc[0].next = 1;
+	vr.desc[1].addr = (unsigned long)pkt + 14;
+	vr.desc[1].len = 20;
+	vr.desc[1].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
+	vr.desc[1].next = 2;
+	vr.desc[2].addr = (unsigned long)pkt + 34;
+	vr.desc[2].len = 8;
+	vr.desc[2].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
+	vr.desc[2].next = 3;
+	vr.desc[3].addr = (unsigned long)pkt + 42;
+	vr.desc[3].len = 100;
+	vr.desc[3].flags = VRING_DESC_F_WRITE;
+
+	/* Here's our buffer. */
+	vr.avail->ring[0] = 0;
+	vr.avail->idx++;
+
+	printf("Waiting for packet...\n");
+	
 	pfd.fd = fd;
 	pfd.events = POLLIN;
-	r = poll(&pfd, 1, 0);
+	r = poll(&pfd, 1, -1);
 	
-	if (r != 0)
+	if (r != 1)
 		err(1, "poll gave %i", r);
 
-	vr.used->idx++;
-	r = poll(&pfd, 1, 0);
-	
-	if (r != 1)
-		err(1, "poll after buf used gave %i", r);
+	/* OK, should have used a buffer. */
+	if (vr.used->idx != 1)
+		errx(1, "vr.used->idx = %u", vr.used->idx);
 
-	used++;
-	r = poll(&pfd, 1, 0);
-	
-	if (r != 0)
-		err(1, "poll after used incremented gave %i", r);
+	if (vr.used->ring[0].id != 0)
+		errx(1, "vr.used->ring[0] = %u", vr.used->ring[0].id);
 
-	close(fd);
+	printf("Total length used = %u\n", vr.used->ring[0].len);
 	return 0;
 }
diff -r 285c3112b26c drivers/net/tun.c
--- a/drivers/net/tun.c	Sat Apr 05 22:00:10 2008 +1100
+++ b/drivers/net/tun.c	Sat Apr 05 22:15:56 2008 +1100
@@ -62,6 +62,8 @@
 #include <linux/if_ether.h>
 #include <linux/if_tun.h>
 #include <linux/crc32.h>
+#include <linux/vring.h>
+#include <linux/virtio_net.h>
 #include <net/net_namespace.h>
 
 #include <asm/system.h>
@@ -98,6 +100,8 @@ struct tun_struct {
 	u8 dev_addr[ETH_ALEN];
 	u32 chr_filter[2];
 	u32 net_filter[2];
+
+	struct vring_info	*inring;
 
 #ifdef TUN_DEBUG	
 	int debug;
@@ -158,6 +162,10 @@ static int tun_net_xmit(struct sk_buff *
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
+
+	if (tun->inring)
+		vring_wake(tun->inring);
+
 	wake_up_interruptible(&tun->read_wait);
 	return 0;
 
@@ -249,6 +257,117 @@ static void tun_net_init(struct net_devi
 		break;
 	}
 }
+
+#ifdef CONFIG_VRINGFD
+static void unset_recv(void *_tun)
+{
+	struct tun_struct *tun = _tun;
+
+	tun->inring = NULL;
+}
+
+/* Returns number of used buffers, or negative errno. */
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
+	if (skb)
+		skb_queue_head(&tun->readq, skb);
+
+	if (num_copied)
+		netif_wake_queue(tun->dev);
+
+	return err ?: num_copied;
+}
+
+static struct vring_ops recvops = {
+	.destroy = unset_recv,
+	.pull = pull_recv_skbs,
+};
+
+static int set_recv_vring(struct tun_struct *tun, int fd)
+{
+	struct vring_info *vi;
+
+	/* FIXME: Racy vs unset_recv or even pull_recv_skbs. */
+	vi = vring_attach(fd, &recvops, tun, false);
+	if (IS_ERR(vi))
+		return PTR_ERR(vi);
+	tun->inring = vi;
+	return 0;
+}
+#else /* ... !CONFIG_VRINGFD */
+static int set_recv_vring(struct tun_struct *tun, int fd)
+{
+	return -ENOTTY;
+}
+#endif
 
 /* Character device part */
 
@@ -462,6 +581,7 @@ static void tun_setup(struct net_device 
 
 	tun->owner = -1;
 	tun->group = -1;
+	tun->inring = NULL;
 
 	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
@@ -670,6 +790,9 @@ static int tun_chr_ioctl(struct inode *i
 		tun->debug = arg;
 		break;
 #endif
+
+	case TUNSETRECVVRING:
+		return set_recv_vring(tun, arg);		
 
 	case SIOCGIFFLAGS:
 		ifr.ifr_flags = tun->if_flags;
diff -r 285c3112b26c include/linux/if_tun.h
--- a/include/linux/if_tun.h	Sat Apr 05 22:00:10 2008 +1100
+++ b/include/linux/if_tun.h	Sat Apr 05 22:15:56 2008 +1100
@@ -42,6 +42,7 @@
 #define TUNSETOWNER   _IOW('T', 204, int)
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
+#define TUNSETRECVVRING _IOW('T', 207, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
