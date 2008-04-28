From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/4] virtio: finer-grained features for virtio_net
Date: Tue, 29 Apr 2008 01:17:44 +1000
Message-ID: <200804290117.45010.rusty@rustcorp.com.au>
References: <200804290116.05951.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34648 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933866AbYD1PTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 11:19:25 -0400
In-Reply-To: <200804290116.05951.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, we previously had a 'VIRTIO_NET_F_GSO' bit which meant that 'the
host can handle csum offload, and any TSO (v4&v6 incl ECN) or UFO
packets you might want to send.  I thought this was good enough for
Linux, but it actually isn't, since we don't do UFO in software.

So, add separate feature bits for what the host can handle.  Add
equivalent ones for the guest to say what it can handle, because LRO
is coming too (thanks Herbert!).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c   |    9 +++++++++
 include/linux/virtio_net.h |   13 +++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff -r effa8facedf1 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Tue Apr 22 07:59:24 2008 +1000
+++ b/drivers/net/virtio_net.c	Tue Apr 22 10:31:05 2008 +1000
@@ -381,6 +381,15 @@ static int virtnet_probe(struct virtio_d
 			dev->features |= NETIF_F_TSO | NETIF_F_UFO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
 		}
+		/* Individual feature bits: what can host handle? */
+		if (gso && vdev->config->feature(vdev, VIRTIO_NET_F_HOST_TSO4))
+			dev->features |= NETIF_F_TSO;
+		if (gso && vdev->config->feature(vdev, VIRTIO_NET_F_HOST_TSO6))
+			dev->features |= NETIF_F_TSO6;
+		if (gso && vdev->config->feature(vdev, VIRTIO_NET_F_HOST_ECN))
+			dev->features |= NETIF_F_TSO_ECN;
+		if (gso && vdev->config->feature(vdev, VIRTIO_NET_F_HOST_UFO))
+			dev->features |= NETIF_F_UFO;
 	}
 
 	/* Configuration may specify what MAC to use.  Otherwise random. */
diff -r effa8facedf1 include/linux/virtio_net.h
--- a/include/linux/virtio_net.h	Tue Apr 22 07:59:24 2008 +1000
+++ b/include/linux/virtio_net.h	Tue Apr 22 10:31:05 2008 +1000
@@ -6,9 +6,18 @@
 #define VIRTIO_ID_NET	1
 
 /* The feature bitmap for virtio net */
-#define VIRTIO_NET_F_CSUM	0	/* Can handle pkts w/ partial csum */
+#define VIRTIO_NET_F_CSUM	0	/* Host handles pkts w/ partial csum */
+#define VIRTIO_NET_F_GUEST_CSUM	1	/* Guest handles pkts w/ partial csum */
 #define VIRTIO_NET_F_MAC	5	/* Host has given MAC address. */
-#define VIRTIO_NET_F_GSO	6	/* Can handle pkts w/ any GSO type */
+#define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
+#define VIRTIO_NET_F_GUEST_TSO4	7	/* Guest can handle TSOv4 in. */
+#define VIRTIO_NET_F_GUEST_TSO6	8	/* Guest can handle TSOv6 in. */
+#define VIRTIO_NET_F_GUEST_ECN	9	/* Guest can handle TSO[6] w/ ECN in. */
+#define VIRTIO_NET_F_GUEST_UFO	10	/* Guest can handle UFO in. */
+#define VIRTIO_NET_F_HOST_TSO4	11	/* Host can handle TSOv4 in. */
+#define VIRTIO_NET_F_HOST_TSO6	12	/* Host can handle TSOv6 in. */
+#define VIRTIO_NET_F_HOST_ECN	13	/* Host can handle TSO[6] w/ ECN in. */
+#define VIRTIO_NET_F_HOST_UFO	14	/* Host can handle UFO in. */
 
 struct virtio_net_config
 {
