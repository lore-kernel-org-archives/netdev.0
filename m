From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH RFC 5/5] lguest support
Date: Sat, 5 Apr 2008 22:09:14 +1000
Message-ID: <200804052209.14827.rusty@rustcorp.com.au>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052205.43824.rusty@rustcorp.com.au> <200804052206.33922.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Max Krasnyansky <maxk@qualcomm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52462 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877AbYDEMJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 08:09:37 -0400
In-Reply-To: <200804052206.33922.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is how lguest uses the vringfd tun support.  It needs more cleanup,
but it seems to basically work.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 6979348a6ece Documentation/lguest/lguest.c
--- a/Documentation/lguest/lguest.c	Sat Apr 05 22:02:28 2008 +1100
+++ b/Documentation/lguest/lguest.c	Sat Apr 05 22:12:25 2008 +1100
@@ -43,6 +43,7 @@
 #include "linux/virtio_console.h"
 #include "linux/virtio_rng.h"
 #include "linux/virtio_ring.h"
+#include "linux/vring.h"
 #include "asm-x86/bootparam.h"
 /*L:110 We can ignore the 39 include files we need for this program, but I do
  * want to draw attention to the use of kernel-style types.
@@ -56,6 +57,10 @@ typedef uint16_t u16;
 typedef uint16_t u16;
 typedef uint8_t u8;
 /*:*/
+
+#ifndef __NR_vringfd
+#define __NR_vringfd		327
+#endif
 
 #define PAGE_PRESENT 0x7 	/* Present, RW, Execute */
 #define NET_PEERNUM 1
@@ -101,6 +106,9 @@ struct device_list
 
 	/* The descriptor page for the devices. */
 	u8 *descpage;
+
+	/* Pointer to last used in descpage */
+	u8 *nextdesc;
 
 	/* A single linked list of devices. */
 	struct device *dev;
@@ -853,6 +861,13 @@ static void handle_console_output(int fd
  * and write them (ignoring the first element) to this device's file descriptor
  * (/dev/net/tun).
  */
+struct virtio_net_info
+{
+	struct virtqueue *xmit_vq, *recv_vq;
+	u16 xmit_used, recv_used;
+	int xmitfd;
+};
+
 static void handle_net_output(int fd, struct virtqueue *vq)
 {
 	unsigned int head, out, in;
@@ -870,6 +885,15 @@ static void handle_net_output(int fd, st
 		len = writev(vq->dev->fd, iov+1, out-1);
 		add_used_and_trigger(fd, vq, head, len);
 	}
+}
+
+static void handle_netring_output(int fd, struct virtqueue *vq)
+{
+	struct virtio_net_info *ni = vq->dev->priv;
+
+	/* We have output, kick the kernel. */
+	if (write(ni->xmitfd, "", 0) != 0)
+		err(1, "Writing to xmitfd");
 }
 
 /* This is where we handle a packet coming in from the tun device to our
@@ -1054,18 +1078,13 @@ static struct lguest_device_desc *new_de
 static struct lguest_device_desc *new_dev_desc(u16 type)
 {
 	struct lguest_device_desc d = { .type = type };
-	void *p;
-
-	/* Figure out where the next device config is, based on the last one. */
-	if (devices.lastdev)
-		p = device_config(devices.lastdev)
-			+ devices.lastdev->desc->config_len;
-	else
-		p = devices.descpage;
+	void *p = devices.nextdesc;
 
 	/* We only have one page for all the descriptors. */
 	if (p + sizeof(d) > (void *)devices.descpage + getpagesize())
 		errx(1, "Too many devices");
+
+	devices.nextdesc += sizeof(d);
 
 	/* p might not be aligned, so we memcpy in. */
 	return memcpy(p, &d, sizeof(d));
@@ -1104,6 +1123,7 @@ static void add_virtqueue(struct device 
 	 * yet, otherwise we'd be overwriting them. */
 	assert(dev->desc->config_len == 0 && dev->desc->feature_len == 0);
 	memcpy(device_config(dev), &vq->config, sizeof(vq->config));
+	devices.nextdesc += sizeof(vq->config);
 	dev->desc->num_vq++;
 
 	verbose("Virtqueue page %#lx\n", to_guest_phys(p));
@@ -1133,6 +1153,7 @@ static void add_feature(struct device *d
 	if (dev->desc->feature_len <= bit / CHAR_BIT) {
 		assert(dev->desc->config_len == 0);
 		dev->desc->feature_len = (bit / CHAR_BIT) + 1;
+		devices.nextdesc = features + dev->desc->feature_len * 2;
 	}
 
 	features[bit / CHAR_BIT] |= (1 << (bit % CHAR_BIT));
@@ -1147,8 +1168,10 @@ static void set_config(struct device *de
 	if (device_config(dev) + len > devices.descpage + getpagesize())
 		errx(1, "Too many devices");
 
+	assert(device_config(dev) == devices.nextdesc);
 	/* Copy in the config information, and store the length. */
 	memcpy(device_config(dev), conf, len);
+	devices.nextdesc += len;
 	dev->desc->config_len = len;
 }
 
@@ -1167,7 +1190,8 @@ static struct device *new_device(const c
 	 * to the device_list's fdset and maxfd. */
 	if (handle_input)
 		add_device_fd(dev->fd);
-	dev->desc = new_dev_desc(type);
+	if (type)
+		dev->desc = new_dev_desc(type);
 	dev->handle_input = handle_input;
 	dev->name = name;
 	dev->vq = NULL;
@@ -1295,11 +1319,30 @@ static void configure_device(int fd, con
 	memcpy(hwaddr, ifr.ifr_hwaddr.sa_data, 6);
 }
 
+static bool xmitfd_used(int fd, struct device *dev)
+{
+	struct virtio_net_info *ni = dev->priv;
+
+	ni->xmit_used = ni->xmit_vq->vring.used->idx;
+	trigger_irq(fd, ni->xmit_vq);
+
+	return true;
+}
+
+static bool recvfd_used(int fd, struct device *dev)
+{
+	struct virtio_net_info *ni = dev->priv;
+
+	ni->recv_used = ni->recv_vq->vring.used->idx;
+	trigger_irq(fd, ni->recv_vq);
+	return true;
+}
+
 /*L:195 Our network is a Host<->Guest network.  This can either use bridging or
  * routing, but the principle is the same: it uses the "tun" device to inject
  * packets into the Host as if they came in from a normal network card.  We
  * just shunt packets between the Guest and the tun device. */
-static void setup_tun_net(const char *arg)
+static void setup_tun_net(const char *arg, bool rings)
 {
 	struct device *dev;
 	struct ifreq ifr;
@@ -1307,6 +1350,7 @@ static void setup_tun_net(const char *ar
 	u32 ip;
 	const char *br_name = NULL;
 	struct virtio_net_config conf;
+	struct virtio_net_info *ni;
 
 	/* We open the /dev/net/tun device and tell it we want a tap device.  A
 	 * tap device is like a tun device, only somehow different.  To tell
@@ -1318,17 +1362,63 @@ static void setup_tun_net(const char *ar
 	strcpy(ifr.ifr_name, "tap%d");
 	if (ioctl(netfd, TUNSETIFF, &ifr) != 0)
 		err(1, "configuring /dev/net/tun");
-	/* We don't need checksums calculated for packets coming in this
-	 * device: trust us! */
-	ioctl(netfd, TUNSETNOCSUM, 1);
 
-	/* First we create a new network device. */
-	dev = new_device("net", VIRTIO_ID_NET, netfd, handle_tun_input);
+	if (rings) {
+		/* First we create a new network device. */
+		dev = new_device("net", VIRTIO_ID_NET, netfd, NULL);
+		add_virtqueue(dev, VIRTQUEUE_NUM, NULL);
+		add_virtqueue(dev, VIRTQUEUE_NUM, handle_netring_output);
+	} else {	
+		/* We don't need checksums calculated for packets coming in this
+		 * device: trust us! */
+		ioctl(netfd, TUNSETNOCSUM, 1);
 
-	/* Network devices need a receive and a send queue, just like
-	 * console. */
-	add_virtqueue(dev, VIRTQUEUE_NUM, enable_fd);
-	add_virtqueue(dev, VIRTQUEUE_NUM, handle_net_output);
+		/* First we create a new network device. */
+		dev = new_device("net", VIRTIO_ID_NET, netfd, handle_tun_input);
+		/* When they add more receive buffers, try re-enabling input */
+		add_virtqueue(dev, VIRTQUEUE_NUM, enable_fd);
+		add_virtqueue(dev, VIRTQUEUE_NUM, handle_net_output);
+	}
+
+	dev->priv = ni = malloc(sizeof(*ni));
+
+	ni->recv_vq = dev->vq;
+	ni->xmit_vq = dev->vq->next;
+	ni->recv_used = 0;
+	ni->xmit_used = 0;
+
+	if (rings) {
+		int xmitfd, recvfd;
+
+		/* Now we create the receive and xmit ringfds. */
+		recvfd = syscall(__NR_vringfd, dev->vq->vring.desc,
+				 VIRTQUEUE_NUM, &ni->recv_used);
+		if (recvfd < 0)
+			err(1, "Creating recv vringfd");
+
+		xmitfd = syscall(__NR_vringfd, dev->vq->next->vring.desc,
+				 VIRTQUEUE_NUM, &ni->xmit_used);
+		if (xmitfd < 0)
+			err(1, "Creating xmit vringfd");
+
+		/* Set offset & limit. */
+		if (ioctl(xmitfd, VRINGSETBASE, guest_base) != 0
+		    || ioctl(recvfd, VRINGSETBASE, guest_base) != 0
+		    || ioctl(xmitfd, VRINGSETLIMIT, guest_limit) != 0
+		    || ioctl(recvfd, VRINGSETLIMIT, guest_limit) != 0)
+			err(1, "Setting vring offset and limit");
+
+		/* Tell the tunnet to use them. */
+		if (ioctl(netfd, TUNSETRECVVRING, recvfd) != 0)
+			err(1, "Setting receive ring");
+		if (ioctl(netfd, TUNSETXMITVRING, xmitfd) != 0)
+			err(1, "Setting xmit ring");
+
+		/* Now we need to respond when they become readable. */
+		new_device("net", 0, recvfd, recvfd_used)->priv = ni;
+		new_device("net", 0, xmitfd, xmitfd_used)->priv = ni;
+		ni->xmitfd = xmitfd;
+	}
 
 	/* We need a socket to perform the magic network ioctls to bring up the
 	 * tap interface, connect to the bridge etc.  Any socket will do! */
@@ -1716,6 +1806,7 @@ static struct option opts[] = {
 static struct option opts[] = {
 	{ "verbose", 0, NULL, 'v' },
 	{ "tunnet", 1, NULL, 't' },
+	{ "tunring", 1, NULL, 'R' },
 	{ "block", 1, NULL, 'b' },
 	{ "rng", 0, NULL, 'r' },
 	{ "initrd", 1, NULL, 'i' },
@@ -1775,7 +1866,7 @@ int main(int argc, char *argv[])
 						      + DEVICE_PAGES);
 			guest_limit = mem;
 			guest_max = mem + DEVICE_PAGES*getpagesize();
-			devices.descpage = get_pages(1);
+			devices.descpage = devices.nextdesc = get_pages(1);
 			break;
 		}
 	}
@@ -1787,7 +1878,10 @@ int main(int argc, char *argv[])
 			verbose = true;
 			break;
 		case 't':
-			setup_tun_net(optarg);
+			setup_tun_net(optarg, false);
+			break;
+		case 'R':
+			setup_tun_net(optarg, true);
 			break;
 		case 'b':
 			setup_block_file(optarg);
