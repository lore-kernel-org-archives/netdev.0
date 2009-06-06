From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH qemu-kvm] Enable UFO on virtio-net/tap devices
Date: Fri, 05 Jun 2009 17:16:48 -0700
Message-ID: <1244247408.1526.174.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: kvm@vger.kernel.org, herbert.xu@redhat.com, rusty@rustcorp.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable UFO on the host tap device if supported and allow setting UFO
on virtio-net in the guest.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>


diff --git a/hw/virtio-net.c b/hw/virtio-net.c
index 3c77b99..8a53e27 100644
--- a/hw/virtio-net.c
+++ b/hw/virtio-net.c
@@ -134,7 +134,8 @@ static uint32_t virtio_net_get_features(VirtIODevice *vdev)
         features |= (1 << VIRTIO_NET_F_HOST_TSO6);
         features |= (1 << VIRTIO_NET_F_HOST_ECN);
         features |= (1 << VIRTIO_NET_F_MRG_RXBUF);
-        /* Kernel can't actually handle UFO in software currently. */
+       // features |= (1 << VIRTIO_NET_F_HOST_UFO);
+        features |= (1 << VIRTIO_NET_F_GUEST_UFO);
     }
 #endif
 
@@ -173,6 +174,7 @@ static void virtio_net_set_features(VirtIODevice *vdev, uint32_t features)
                       (features >> VIRTIO_NET_F_GUEST_CSUM) & 1,
                       (features >> VIRTIO_NET_F_GUEST_TSO4) & 1,
                       (features >> VIRTIO_NET_F_GUEST_TSO6) & 1,
+                      (features >> VIRTIO_NET_F_GUEST_UFO)  & 1,
                       (features >> VIRTIO_NET_F_GUEST_ECN)  & 1);
 #endif
 }
diff --git a/net.c b/net.c
index 01e31db..e7dbcd0 100644
--- a/net.c
+++ b/net.c
@@ -990,8 +990,13 @@ static int tap_probe_vnet_hdr(int fd)
 }
 
 #ifdef TUNSETOFFLOAD
+
+#ifndef TUN_F_UFO
+#define TUN_F_UFO	0x10
+#endif
+
 static void tap_set_offload(VLANClientState *vc, int csum, int tso4, int tso6,
-			    int ecn)
+			    int ecn, int ufo)
 {
     TAPState *s = vc->opaque;
     unsigned int offload = 0;
@@ -1004,11 +1009,18 @@ static void tap_set_offload(VLANClientState *vc, int csum, int tso4, int tso6,
 	    offload |= TUN_F_TSO6;
 	if ((tso4 || tso6) && ecn)
 	    offload |= TUN_F_TSO_ECN;
+	if (ufo)
+	    offload |= TUN_F_UFO;
     }
 
-    if (ioctl(s->fd, TUNSETOFFLOAD, offload) != 0)
-	fprintf(stderr, "TUNSETOFFLOAD ioctl() failed: %s\n",
-		strerror(errno));
+    if (ioctl(s->fd, TUNSETOFFLOAD, offload) != 0) {
+        /* Try without UFO */
+        offload &= ~TUN_F_UFO;
+        if (ioctl(s->fd, TUNSETOFFLOAD, offload) != 0) {
+	    fprintf(stderr, "TUNSETOFFLOAD ioctl() failed: %s\n",
+	   	strerror(errno));
+        }
+    }
 }
 #endif /* TUNSETOFFLOAD */
 
@@ -1043,7 +1055,7 @@ static TAPState *net_tap_fd_init(VLANState *vlan,
     s->vc->fd_read_raw = tap_receive_raw;
 #ifdef TUNSETOFFLOAD
     s->vc->set_offload = tap_set_offload;
-    tap_set_offload(s->vc, 0, 0, 0, 0);
+    tap_set_offload(s->vc, 0, 0, 0, 0, 0);
 #endif
     qemu_set_fd_handler2(s->fd, tap_can_send, tap_send, NULL, s);
     snprintf(s->vc->info_str, sizeof(s->vc->info_str), "fd=%d", fd);
diff --git a/net.h b/net.h
index 3d0b6f2..ecfb1f9 100644
--- a/net.h
+++ b/net.h
@@ -11,7 +11,7 @@ typedef struct VLANClientState VLANClientState;
 
 typedef void (NetCleanup) (VLANClientState *);
 typedef void (LinkStatusChanged)(VLANClientState *);
-typedef void (SetOffload)(VLANClientState *, int, int, int, int);
+typedef void (SetOffload)(VLANClientState *, int, int, int, int, int);
 
 struct VLANClientState {
     IOReadHandler *fd_read;


