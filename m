From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH 1/2] net: Add multiqueue support
Date: Wed, 20 Apr 2011 16:33:18 +0800
Message-ID: <20110420083318.32157.63955.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
References: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	qemu-devel@nongnu.org, anthony@codemonkey.ws
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202Ab1DTIcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 04:32:31 -0400
In-Reply-To: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the multiqueues support for emulated nics. Each VLANClientState
pairs are now abstract as a queue instead of a nic, and multiple VLANClientState
pointers were stored in the NICState and treated as the multiple queues of a
single nic. The netdev options of qdev were now expanded to accept more than one
netdev ids. A queue_index were also introduced to let the emulated nics know
which queue the packet were came from or sent out. Virtio-net would be the first
user.

The legacy single queue nics can still run happily without modification as the
the compatibility were kept.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 hw/qdev-properties.c |   37 ++++++++++++++++++++++++++++++-------
 hw/qdev.h            |    3 ++-
 net.c                |   34 ++++++++++++++++++++++++++--------
 net.h                |   15 +++++++++++----
 4 files changed, 69 insertions(+), 20 deletions(-)

diff --git a/hw/qdev-properties.c b/hw/qdev-properties.c
index 1088a26..dd371e1 100644
--- a/hw/qdev-properties.c
+++ b/hw/qdev-properties.c
@@ -384,14 +384,37 @@ PropertyInfo qdev_prop_chr = {
 
 static int parse_netdev(DeviceState *dev, Property *prop, const char *str)
 {
-    VLANClientState **ptr = qdev_get_prop_ptr(dev, prop);
+    VLANClientState ***nc = qdev_get_prop_ptr(dev, prop);
+    const char *ptr = str;
+    int i = 0;
+    size_t len = strlen(str);
+    *nc = qemu_malloc(MAX_QUEUE_NUM * sizeof(VLANClientState *));
+
+    while (i < MAX_QUEUE_NUM && ptr < str + len) {
+        char *name = NULL;
+        char *this = strchr(ptr, '#');
+
+        if (this == NULL) {
+            name = strdup(ptr);
+        } else {
+            name = strndup(ptr, this - ptr);
+        }
 
-    *ptr = qemu_find_netdev(str);
-    if (*ptr == NULL)
-        return -ENOENT;
-    if ((*ptr)->peer) {
-        return -EEXIST;
+        (*nc)[i] = qemu_find_netdev(name);
+        if ((*nc)[i] == NULL) {
+            return -ENOENT;
+        }
+        if (((*nc)[i])->peer) {
+            return -EEXIST;
+        }
+
+        if (this == NULL) {
+            break;
+        }
+        i++;
+        ptr = this + 1;
     }
+
     return 0;
 }
 
@@ -409,7 +432,7 @@ static int print_netdev(DeviceState *dev, Property *prop, char *dest, size_t len
 PropertyInfo qdev_prop_netdev = {
     .name  = "netdev",
     .type  = PROP_TYPE_NETDEV,
-    .size  = sizeof(VLANClientState*),
+    .size  = sizeof(VLANClientState **),
     .parse = parse_netdev,
     .print = print_netdev,
 };
diff --git a/hw/qdev.h b/hw/qdev.h
index 8a13ec9..b438da0 100644
--- a/hw/qdev.h
+++ b/hw/qdev.h
@@ -257,6 +257,7 @@ extern PropertyInfo qdev_prop_pci_devfn;
         .defval    = (bool[]) { (_defval) },                     \
         }
 
+
 #define DEFINE_PROP_UINT8(_n, _s, _f, _d)                       \
     DEFINE_PROP_DEFAULT(_n, _s, _f, _d, qdev_prop_uint8, uint8_t)
 #define DEFINE_PROP_UINT16(_n, _s, _f, _d)                      \
@@ -281,7 +282,7 @@ extern PropertyInfo qdev_prop_pci_devfn;
 #define DEFINE_PROP_STRING(_n, _s, _f)             \
     DEFINE_PROP(_n, _s, _f, qdev_prop_string, char*)
 #define DEFINE_PROP_NETDEV(_n, _s, _f)             \
-    DEFINE_PROP(_n, _s, _f, qdev_prop_netdev, VLANClientState*)
+    DEFINE_PROP(_n, _s, _f, qdev_prop_netdev, VLANClientState**)
 #define DEFINE_PROP_VLAN(_n, _s, _f)             \
     DEFINE_PROP(_n, _s, _f, qdev_prop_vlan, VLANState*)
 #define DEFINE_PROP_DRIVE(_n, _s, _f) \
diff --git a/net.c b/net.c
index 4f777c3..a937e5d 100644
--- a/net.c
+++ b/net.c
@@ -227,16 +227,36 @@ NICState *qemu_new_nic(NetClientInfo *info,
 {
     VLANClientState *nc;
     NICState *nic;
+    int i;
 
     assert(info->type == NET_CLIENT_TYPE_NIC);
     assert(info->size >= sizeof(NICState));
 
-    nc = qemu_new_net_client(info, conf->vlan, conf->peer, model, name);
+    nc = qemu_new_net_client(info, conf->vlan, conf->peers[0], model, name);
 
     nic = DO_UPCAST(NICState, nc, nc);
     nic->conf = conf;
     nic->opaque = opaque;
 
+    /* For compatiablity with single queue nic */
+    nic->ncs[0] = nc;
+    nc->opaque = nic;
+
+    for (i = 1 ; i < conf->queues; i++) {
+        VLANClientState *vc = qemu_mallocz(sizeof(*vc));
+        vc->opaque = nic;
+        nic->ncs[i] = vc;
+        vc->peer = conf->peers[i];
+        vc->info = info;
+        vc->queue_index = i;
+        vc->peer->peer = vc;
+        QTAILQ_INSERT_TAIL(&non_vlan_clients, vc, next);
+
+        vc->send_queue = qemu_new_net_queue(qemu_deliver_packet,
+                                            qemu_deliver_packet_iov,
+                                            vc);
+    }
+
     return nic;
 }
 
@@ -272,11 +292,10 @@ void qemu_del_vlan_client(VLANClientState *vc)
 {
     /* If there is a peer NIC, delete and cleanup client, but do not free. */
     if (!vc->vlan && vc->peer && vc->peer->info->type == NET_CLIENT_TYPE_NIC) {
-        NICState *nic = DO_UPCAST(NICState, nc, vc->peer);
-        if (nic->peer_deleted) {
+        if (vc->peer_deleted) {
             return;
         }
-        nic->peer_deleted = true;
+        vc->peer_deleted = true;
         /* Let NIC know peer is gone. */
         vc->peer->link_down = true;
         if (vc->peer->info->link_status_changed) {
@@ -288,8 +307,7 @@ void qemu_del_vlan_client(VLANClientState *vc)
 
     /* If this is a peer NIC and peer has already been deleted, free it now. */
     if (!vc->vlan && vc->peer && vc->info->type == NET_CLIENT_TYPE_NIC) {
-        NICState *nic = DO_UPCAST(NICState, nc, vc);
-        if (nic->peer_deleted) {
+        if (vc->peer_deleted) {
             qemu_free_vlan_client(vc->peer);
         }
     }
@@ -331,14 +349,14 @@ void qemu_foreach_nic(qemu_nic_foreach func, void *opaque)
 
     QTAILQ_FOREACH(nc, &non_vlan_clients, next) {
         if (nc->info->type == NET_CLIENT_TYPE_NIC) {
-            func(DO_UPCAST(NICState, nc, nc), opaque);
+            func((NICState *)nc->opaque, opaque);
         }
     }
 
     QTAILQ_FOREACH(vlan, &vlans, next) {
         QTAILQ_FOREACH(nc, &vlan->clients, next) {
             if (nc->info->type == NET_CLIENT_TYPE_NIC) {
-                func(DO_UPCAST(NICState, nc, nc), opaque);
+                func((NICState *)nc->opaque, opaque);
             }
         }
     }
diff --git a/net.h b/net.h
index 6ceca50..c2fbd60 100644
--- a/net.h
+++ b/net.h
@@ -11,20 +11,24 @@ struct MACAddr {
     uint8_t a[6];
 };
 
+#define MAX_QUEUE_NUM 32
+
 /* qdev nic properties */
 
 typedef struct NICConf {
     MACAddr macaddr;
     VLANState *vlan;
-    VLANClientState *peer;
+    VLANClientState **peers;
     int32_t bootindex;
+    int32_t queues;
 } NICConf;
 
 #define DEFINE_NIC_PROPERTIES(_state, _conf)                            \
     DEFINE_PROP_MACADDR("mac",   _state, _conf.macaddr),                \
     DEFINE_PROP_VLAN("vlan",     _state, _conf.vlan),                   \
-    DEFINE_PROP_NETDEV("netdev", _state, _conf.peer),                   \
-    DEFINE_PROP_INT32("bootindex", _state, _conf.bootindex, -1)
+    DEFINE_PROP_NETDEV("netdev", _state, _conf.peers),                   \
+    DEFINE_PROP_INT32("bootindex", _state, _conf.bootindex, -1),        \
+    DEFINE_PROP_INT32("queues", _state, _conf.queues, 1)
 
 /* VLANs support */
 
@@ -68,13 +72,16 @@ struct VLANClientState {
     char *name;
     char info_str[256];
     unsigned receive_disabled : 1;
+    unsigned int queue_index;
+    bool peer_deleted;
+    void *opaque;
 };
 
 typedef struct NICState {
     VLANClientState nc;
+    VLANClientState *ncs[MAX_QUEUE_NUM];
     NICConf *conf;
     void *opaque;
-    bool peer_deleted;
 } NICState;
 
 struct VLANState {

