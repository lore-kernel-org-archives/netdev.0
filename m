From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v3 PATCH 3/4] virtio-net: notify guest to annouce itself
Date: Thu, 27 Oct 2011 16:48:55 +0800
Message-ID: <20111027084855.15020.80416.stgit@dhcp-8-146.nay.redhat.com>
References: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: aliguori@us.ibm.com, mst@redhat.com, jan.kiszka@siemens.com,
	rusty@rustcorp.com.au, qemu-devel@nongnu.org, blauwirbel@gmail.com,
	stefanha@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's hard to track all mac address and its usage (vlan, bondings,
ipv6) in qemu to send proper gratituous packet. The better choice is
let guest to do it.

The patch introduces a new rw config status bit of virtio-net,
VIRTIO_NET_S_ANNOUNCE which is used to notify guest to announce
presence of its link through config update interrupt. When gust have
done the annoucement, it should clear that bit.

The feature is negotiated by bit VIRTIO_NET_F_ANNOUNCE.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 hw/virtio-net.c |   18 +++++++++++++++++-
 hw/virtio-net.h |    3 +++
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/hw/virtio-net.c b/hw/virtio-net.c
index 8c2f460..5451eec 100644
--- a/hw/virtio-net.c
+++ b/hw/virtio-net.c
@@ -95,6 +95,8 @@ static void virtio_net_set_config(VirtIODevice *vdev, const uint8_t *config)
         memcpy(n->mac, netcfg.mac, ETH_ALEN);
         qemu_format_nic_info_str(&n->nic->nc, n->mac);
     }
+
+    memcpy(&n->status, &netcfg.status, sizeof(n->status));
 }
 
 static bool virtio_net_started(VirtIONet *n, uint8_t status)
@@ -227,7 +229,7 @@ static uint32_t virtio_net_get_features(VirtIODevice *vdev, uint32_t features)
 {
     VirtIONet *n = to_virtio_net(vdev);
 
-    features |= (1 << VIRTIO_NET_F_MAC);
+    features |= (1 << VIRTIO_NET_F_MAC | 1 << VIRTIO_NET_F_GUEST_ANNOUNCE);
 
     if (peer_has_vnet_hdr(n)) {
         tap_using_vnet_hdr(n->nic->nc.peer, 1);
@@ -983,6 +985,19 @@ static void virtio_net_cleanup(VLANClientState *nc)
     n->nic = NULL;
 }
 
+static int virtio_net_announce(VLANClientState *nc)
+{
+    VirtIONet *n = DO_UPCAST(NICState, nc, nc)->opaque;
+
+    if (n->vdev.guest_features & (0x1 << VIRTIO_NET_F_GUEST_ANNOUNCE)) {
+        n->status |= VIRTIO_NET_S_ANNOUNCE;
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
@@ -990,6 +1005,7 @@ static NetClientInfo net_virtio_info = {
     .receive = virtio_net_receive,
         .cleanup = virtio_net_cleanup,
     .link_status_changed = virtio_net_set_link_status,
+    .announce = virtio_net_announce,
 };
 
 VirtIODevice *virtio_net_init(DeviceState *dev, NICConf *conf,
diff --git a/hw/virtio-net.h b/hw/virtio-net.h
index 4468741..9f8cea7 100644
--- a/hw/virtio-net.h
+++ b/hw/virtio-net.h
@@ -44,8 +44,10 @@
 #define VIRTIO_NET_F_CTRL_RX    18      /* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN  19      /* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20   /* Extra RX mode control support */
+#define VIRTIO_NET_F_GUEST_ANNOUNCE 21  /* Guest can announce itself */
 
 #define VIRTIO_NET_S_LINK_UP    1       /* Link is up */
+#define VIRTIO_NET_S_ANNOUNCE   2       /* Announcement is needed */
 
 #define TX_TIMER_INTERVAL 150000 /* 150 us */
 
@@ -176,6 +178,7 @@ struct virtio_net_ctrl_mac {
         DEFINE_PROP_BIT("guest_tso6", _state, _field, VIRTIO_NET_F_GUEST_TSO6, true), \
         DEFINE_PROP_BIT("guest_ecn", _state, _field, VIRTIO_NET_F_GUEST_ECN, true), \
         DEFINE_PROP_BIT("guest_ufo", _state, _field, VIRTIO_NET_F_GUEST_UFO, true), \
+        DEFINE_PROP_BIT("guest_announce", _state, _field, VIRTIO_NET_F_GUEST_ANNOUNCE, true), \
         DEFINE_PROP_BIT("host_tso4", _state, _field, VIRTIO_NET_F_HOST_TSO4, true), \
         DEFINE_PROP_BIT("host_tso6", _state, _field, VIRTIO_NET_F_HOST_TSO6, true), \
         DEFINE_PROP_BIT("host_ecn", _state, _field, VIRTIO_NET_F_HOST_ECN, true), \

