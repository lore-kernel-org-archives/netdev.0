From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 4/4] lguest: Use GSO/IFF_VNET_HDR extensions on tun/tap
Date: Thu, 26 Jun 2008 00:32:12 +1000
Message-ID: <200806260032.12359.rusty@rustcorp.com.au>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260029.40267.rusty@rustcorp.com.au> <200806260030.38293.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, markmc@redhat.com
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37403 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623AbYFYOcV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 10:32:21 -0400
In-Reply-To: <200806260030.38293.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Might not apply cleanly to current Linus, there are other lguest things
 going on, but this gives you the idea at least).

Guest -> Host 1GB TCP:
Before: Seconds 16.6282 xmit 250498 recv 3 timeout 248355
After: Seconds 9.86102 xmit 241989 recv 192014 timeout 231224

Host -> Guest 1GB TCP:
Before: Seconds 11.0831 xmit 324742 recv 1910 timeout 323429
After: Seconds 10.6626 xmit 342489 recv 24 timeout 341173

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 Documentation/lguest/lguest.c |   34 ++++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff -r 7358caf10bd8 Documentation/lguest/lguest.c
--- a/Documentation/lguest/lguest.c	Tue Jun 24 16:15:36 2008 +1000
+++ b/Documentation/lguest/lguest.c	Wed Jun 25 00:29:31 2008 +1000
@@ -928,11 +928,9 @@ static void handle_net_output(int fd, st
 	while ((head = get_vq_desc(vq, iov, &out, &in)) != vq->vring.num) {
 		if (in)
 			errx(1, "Input buffers in output queue?");
-		/* Check header, but otherwise ignore it (we told the Guest we
-		 * supported no features, so it shouldn't have anything
-		 * interesting). */
-		(void)convert(&iov[0], struct virtio_net_hdr);
-		len = writev(vq->dev->fd, iov+1, out-1);
+		len = writev(vq->dev->fd, iov, out);
+		if (len < 0)
+			err(1, "Writing network packet to tun");
 		add_used_and_trigger(fd, vq, head, len);
 		num++;
 	}
@@ -949,7 +947,6 @@ static bool handle_tun_input(int fd, str
 	unsigned int head, in_num, out_num;
 	int len;
 	struct iovec iov[dev->vq->vring.num];
-	struct virtio_net_hdr *hdr;
 
 	/* First we need a network buffer from the Guests's recv virtqueue. */
 	head = get_vq_desc(dev->vq, iov, &out_num, &in_num);
@@ -970,18 +969,13 @@ static bool handle_tun_input(int fd, str
 	} else if (out_num)
 		errx(1, "Output buffers in network recv queue?");
 
-	/* First element is the header: we set it to 0 (no features). */
-	hdr = convert(&iov[0], struct virtio_net_hdr);
-	hdr->flags = 0;
-	hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
-
 	/* Read the packet from the device directly into the Guest's buffer. */
-	len = readv(dev->fd, iov+1, in_num-1);
+	len = readv(dev->fd, iov, in_num);
 	if (len <= 0)
 		err(1, "reading network");
 
 	/* Tell the Guest about the new packet. */
-	add_used_and_trigger(fd, dev->vq, head, sizeof(*hdr) + len);
+	add_used_and_trigger(fd, dev->vq, head, len);
 
 	verbose("tun input packet len %i [%02x %02x] (%s)\n", len,
 		((u8 *)iov[1].iov_base)[0], ((u8 *)iov[1].iov_base)[1],
@@ -1492,10 +1486,14 @@ static int get_tun_device(char tapif[IFN
 	 * the truth, I completely blundered my way through this code, but it
 	 * works now! */
 	netfd = open_or_die("/dev/net/tun", O_RDWR);
-	ifr.ifr_flags = IFF_TAP | IFF_NO_PI;
+	ifr.ifr_flags = IFF_TAP | IFF_NO_PI | IFF_VNET_HDR;
 	strcpy(ifr.ifr_name, "tap%d");
 	if (ioctl(netfd, TUNSETIFF, &ifr) != 0)
 		err(1, "configuring /dev/net/tun");
+
+	if (ioctl(netfd, TUNSETFEATURES,
+		  TUN_F_CSUM|TUN_F_TSO4|TUN_F_TSO6|TUN_F_TSO_ECN) != 0)
+		err(1, "Could not set features for tun device");
 
 	/* We don't need checksums calculated for packets coming in this
 	 * device: trust us! */
@@ -1563,6 +1561,16 @@ static void setup_tun_net(char *arg)
 	/* Tell Guest what MAC address to use. */
 	add_feature(dev, VIRTIO_NET_F_MAC);
 	add_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY);
+	/* Expect Guest to handle everything except UFO */
+	add_feature(dev, VIRTIO_NET_F_CSUM);
+	add_feature(dev, VIRTIO_NET_F_GUEST_CSUM);
+	add_feature(dev, VIRTIO_NET_F_MAC);
+	add_feature(dev, VIRTIO_NET_F_GUEST_TSO4);
+	add_feature(dev, VIRTIO_NET_F_GUEST_TSO6);
+	add_feature(dev, VIRTIO_NET_F_GUEST_ECN);
+	add_feature(dev, VIRTIO_NET_F_HOST_TSO4);
+	add_feature(dev, VIRTIO_NET_F_HOST_TSO6);
+	add_feature(dev, VIRTIO_NET_F_HOST_ECN);
 	set_config(dev, sizeof(conf), &conf);
 
 	/* We don't need the socket any more; setup is done. */
