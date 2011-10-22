From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v2 PATCH 4/4] virtio-net: notify guest to annouce itself
Date: Sat, 22 Oct 2011 13:39:07 +0800
Message-ID: <20111022053907.21526.81697.stgit@dhcp-8-146.nay.redhat.com>
References: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: aliguori@us.ibm.com, quintela@redhat.com, jan.kiszka@siemens.com,
	mst@redhat.com, qemu-devel@nongnu.org, blauwirbel@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's hard to track all mac address and its usage (vlan, bondings,
ipv6) in qemu to send gratituous packet in qemu side, so the better
choice is let guest do it.

The patch introduces a new rw config status bit of virtio-net,
VIRTIO_NET_S_ANNOUNCE which is used to notify guest to announce itself
( such as sending gratituous packets ) through config update
interrupt. When gust have done the annoucement, it should clear that
bit.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 hw/virtio-net.c |   20 +++++++++++++++++++-
 hw/virtio-net.h |    2 ++
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/hw/virtio-net.c b/hw/virtio-net.c
index 8c2f460..7f844e7 100644
--- a/hw/virtio-net.c
+++ b/hw/virtio-net.c
@@ -95,6 +95,10 @@ static void virtio_net_set_config(VirtIODevice *vdev, const uint8_t *config)
         memcpy(n->mac, netcfg.mac, ETH_ALEN);
         qemu_format_nic_info_str(&n->nic->nc, n->mac);
     }
+
+    if (memcmp(&netcfg.status, &n->status, sizeof(n->status))) {
+        memcpy(&n->status, &netcfg.status, sizeof(n->status));
+    }
 }
 
 static bool virtio_net_started(VirtIONet *n, uint8_t status)
@@ -227,7 +231,7 @@ static uint32_t virtio_net_get_features(VirtIODevice *vdev, uint32_t features)
 {
     VirtIONet *n = to_virtio_net(vdev);
 
-    features |= (1 << VIRTIO_NET_F_MAC);
+    features |= (1 << VIRTIO_NET_F_MAC | 1 << VIRTIO_NET_F_GUEST_ANNOUNCE);
 
     if (peer_has_vnet_hdr(n)) {
         tap_using_vnet_hdr(n->nic->nc.peer, 1);
@@ -983,6 +987,19 @@ static void virtio_net_cleanup(VLANClientState *nc)
     n->nic = NULL;
 }
 
+static int virtio_net_announce(VLANClientState *nc)
+{
+    VirtIONet *n = DO_UPCAST(NICState, nc, nc)->opaque;
+
+    if (n->vdev.guest_features & (0x1 << VIRTIO_NET_F_GUEST_ANNOUNCE)) {
+        n->status |= VIRITO_NET_S_ANNOUNCE;
+        virtio_notify_config(&n->vdev);
+        return 0;
+    }
+
+    return 1;
+}
+
 static NetClientInfo net_virtio_info = {
     .type = NET_CLIENT_TYPE_NIC,
     .size = sizeof(NICState),
@@ -990,6 +1007,7 @@ static NetClientInfo net_virtio_info = {
     .receive = virtio_net_receive,
         .cleanup = virtio_net_cleanup,
     .link_status_changed = virtio_net_set_link_status,
+    .announce = virtio_net_announce,
 };
 
 VirtIODevice *virtio_net_init(DeviceState *dev, NICConf *conf,
diff --git a/hw/virtio-net.h b/hw/virtio-net.h
index 4468741..c47bd52 100644
--- a/hw/virtio-net.h
+++ b/hw/virtio-net.h
@@ -44,8 +44,10 @@
 #define VIRTIO_NET_F_CTRL_RX    18      /* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN  19      /* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20   /* Extra RX mode control support */
+#define VIRTIO_NET_F_GUEST_ANNOUNCE 21  /* Guest can announce itself */
 
 #define VIRTIO_NET_S_LINK_UP    1       /* Link is up */
+#define VIRITO_NET_S_ANNOUNCE   2       /* Announcement is needed */
 
 #define TX_TIMER_INTERVAL 150000 /* 150 us */
 

