From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 4/4] [RFC rev2] qemu changes
Date: Tue, 05 Apr 2011 20:39:20 +0530
Message-ID: <20110405150920.20501.12605.sendpatchset@krkumar2.in.ibm.com>
References: <20110405150826.20501.39679.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	horms@verge.net.au, avi@redhat.com, anthony@codemonkey.ws,
	kvm@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110405150826.20501.39679.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/hw/vhost.c new/hw/vhost.c
--- org/hw/vhost.c	2011-04-05 14:15:18.000000000 +0530
+++ new/hw/vhost.c	2011-04-05 14:15:18.000000000 +0530
@@ -581,7 +581,7 @@ static void vhost_virtqueue_cleanup(stru
                               0, virtio_queue_get_desc_size(vdev, idx));
 }
 
-int vhost_dev_init(struct vhost_dev *hdev, int devfd, bool force)
+int vhost_dev_init(struct vhost_dev *hdev, int devfd, bool force, int numtxqs)
 {
     uint64_t features;
     int r;
@@ -593,11 +593,13 @@ int vhost_dev_init(struct vhost_dev *hde
             return -errno;
         }
     }
-    r = ioctl(hdev->control, VHOST_SET_OWNER, NULL);
+    r = ioctl(hdev->control, VHOST_SET_OWNER, numtxqs);
     if (r < 0) {
         goto fail;
     }
 
+    hdev->nvqs = numtxqs * 2;
+
     r = ioctl(hdev->control, VHOST_GET_FEATURES, &features);
     if (r < 0) {
         goto fail;
diff -ruNp org/hw/vhost.h new/hw/vhost.h
--- org/hw/vhost.h	2011-04-05 14:15:18.000000000 +0530
+++ new/hw/vhost.h	2011-04-05 14:15:18.000000000 +0530
@@ -41,7 +41,7 @@ struct vhost_dev {
     bool force;
 };
 
-int vhost_dev_init(struct vhost_dev *hdev, int devfd, bool force);
+int vhost_dev_init(struct vhost_dev *hdev, int devfd, bool force, int numtxqs);
 void vhost_dev_cleanup(struct vhost_dev *hdev);
 bool vhost_dev_query(struct vhost_dev *hdev, VirtIODevice *vdev);
 int vhost_dev_start(struct vhost_dev *hdev, VirtIODevice *vdev);
diff -ruNp org/hw/vhost_net.c new/hw/vhost_net.c
--- org/hw/vhost_net.c	2011-04-05 14:15:18.000000000 +0530
+++ new/hw/vhost_net.c	2011-04-05 20:27:01.000000000 +0530
@@ -36,8 +36,9 @@
 
 struct vhost_net {
     struct vhost_dev dev;
-    struct vhost_virtqueue vqs[2];
-    int backend;
+    struct vhost_virtqueue *vqs;
+    int nvqs;
+    int *backend;
     VLANClientState *vc;
 };
 
@@ -70,11 +71,11 @@ void vhost_net_ack_features(struct vhost
     }
 }
 
-static int vhost_net_get_fd(VLANClientState *backend)
+static int vhost_net_get_fd(VLANClientState *backend, int index)
 {
     switch (backend->info->type) {
     case NET_CLIENT_TYPE_TAP:
-        return tap_get_fd(backend);
+        return tap_get_fd(backend, index);
     default:
         fprintf(stderr, "vhost-net requires tap backend\n");
         return -EBADFD;
@@ -82,27 +83,36 @@ static int vhost_net_get_fd(VLANClientSt
 }
 
 struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd,
-                                 bool force)
+                                 bool force, int numtxqs)
 {
-    int r;
+    int i, r;
     struct vhost_net *net = qemu_malloc(sizeof *net);
     if (!backend) {
         fprintf(stderr, "vhost-net requires backend to be setup\n");
         goto fail;
     }
-    r = vhost_net_get_fd(backend);
-    if (r < 0) {
-        goto fail;
+
+    net->backend = qemu_malloc(numtxqs * (sizeof *net->backend));
+    for (i = 0; i < numtxqs; i++) {
+        r = vhost_net_get_fd(backend, i);
+        if (r < 0) {
+            goto fail;
+        }
+        net->backend[i] = r;
     }
+
     net->vc = backend;
     net->dev.backend_features = tap_has_vnet_hdr(backend) ? 0 :
         (1 << VHOST_NET_F_VIRTIO_NET_HDR);
-    net->backend = r;
 
-    r = vhost_dev_init(&net->dev, devfd, force);
+    r = vhost_dev_init(&net->dev, devfd, force, numtxqs);
     if (r < 0) {
         goto fail;
     }
+
+    net->nvqs = numtxqs * 2;
+    net->vqs = qemu_malloc(net->nvqs * (sizeof *net->vqs));
+
     if (!tap_has_vnet_hdr_len(backend,
                               sizeof(struct virtio_net_hdr_mrg_rxbuf))) {
         net->dev.features &= ~(1 << VIRTIO_NET_F_MRG_RXBUF);
@@ -137,7 +147,6 @@ int vhost_net_start(struct vhost_net *ne
                              sizeof(struct virtio_net_hdr_mrg_rxbuf));
     }
 
-    net->dev.nvqs = 2;
     net->dev.vqs = net->vqs;
     r = vhost_dev_start(&net->dev, dev);
     if (r < 0) {
@@ -145,9 +154,9 @@ int vhost_net_start(struct vhost_net *ne
     }
 
     net->vc->info->poll(net->vc, false);
-    qemu_set_fd_handler(net->backend, NULL, NULL, NULL);
-    file.fd = net->backend;
     for (file.index = 0; file.index < net->dev.nvqs; ++file.index) {
+        qemu_set_fd_handler(net->backend[file.index/2], NULL, NULL, NULL);
+        file.fd = net->backend[(file.index / 2) % (net->dev.nvqs / 2)];
         r = ioctl(net->dev.control, VHOST_NET_SET_BACKEND, &file);
         if (r < 0) {
             r = -errno;
@@ -195,7 +204,7 @@ void vhost_net_cleanup(struct vhost_net 
 }
 #else
 struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd,
-                                 bool force)
+                                 bool force, int numtxqs)
 {
     return NULL;
 }
diff -ruNp org/hw/vhost_net.h new/hw/vhost_net.h
--- org/hw/vhost_net.h	2011-04-05 14:15:18.000000000 +0530
+++ new/hw/vhost_net.h	2011-04-05 14:15:18.000000000 +0530
@@ -6,7 +6,8 @@
 struct vhost_net;
 typedef struct vhost_net VHostNetState;
 
-VHostNetState *vhost_net_init(VLANClientState *backend, int devfd, bool force);
+VHostNetState *vhost_net_init(VLANClientState *backend, int devfd, bool force,
+                              int numtxqs);
 
 bool vhost_net_query(VHostNetState *net, VirtIODevice *dev);
 int vhost_net_start(VHostNetState *net, VirtIODevice *dev);
diff -ruNp org/hw/virtio-net.c new/hw/virtio-net.c
--- org/hw/virtio-net.c	2011-04-05 14:15:18.000000000 +0530
+++ new/hw/virtio-net.c	2011-04-05 14:15:18.000000000 +0530
@@ -31,8 +31,8 @@ typedef struct VirtIONet
     VirtIODevice vdev;
     uint8_t mac[ETH_ALEN];
     uint16_t status;
-    VirtQueue *rx_vq;
-    VirtQueue *tx_vq;
+    VirtQueue **rx_vq;
+    VirtQueue **tx_vq;
     VirtQueue *ctrl_vq;
     NICState *nic;
     QEMUTimer *tx_timer;
@@ -63,6 +63,7 @@ typedef struct VirtIONet
     } mac_table;
     uint32_t *vlans;
     DeviceState *qdev;
+    uint16_t numtxqs;
 } VirtIONet;
 
 /* TODO
@@ -80,6 +81,7 @@ static void virtio_net_get_config(VirtIO
     struct virtio_net_config netcfg;
 
     stw_p(&netcfg.status, n->status);
+    netcfg.num_queue_pairs = n->numtxqs * 2;
     memcpy(netcfg.mac, n->mac, ETH_ALEN);
     memcpy(config, &netcfg, sizeof(netcfg));
 }
@@ -228,6 +230,9 @@ static uint32_t virtio_net_get_features(
     VirtIONet *n = to_virtio_net(vdev);
 
     features |= (1 << VIRTIO_NET_F_MAC);
+    if (n->numtxqs > 1)
+        features |= (1 << VIRTIO_NET_F_MULTIQUEUE);
+
 
     if (peer_has_vnet_hdr(n)) {
         tap_using_vnet_hdr(n->nic->nc.peer, 1);
@@ -460,7 +465,7 @@ static int virtio_net_can_receive(VLANCl
         return 0;
     }
 
-    if (!virtio_queue_ready(n->rx_vq) ||
+    if (!virtio_queue_ready(n->rx_vq[0]) ||
         !(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
         return 0;
 
@@ -469,22 +474,22 @@ static int virtio_net_can_receive(VLANCl
 
 static int virtio_net_has_buffers(VirtIONet *n, int bufsize)
 {
-    if (virtio_queue_empty(n->rx_vq) ||
+    if (virtio_queue_empty(n->rx_vq[0]) ||
         (n->mergeable_rx_bufs &&
-         !virtqueue_avail_bytes(n->rx_vq, bufsize, 0))) {
-        virtio_queue_set_notification(n->rx_vq, 1);
+         !virtqueue_avail_bytes(n->rx_vq[0], bufsize, 0))) {
+        virtio_queue_set_notification(n->rx_vq[0], 1);
 
         /* To avoid a race condition where the guest has made some buffers
          * available after the above check but before notification was
          * enabled, check for available buffers again.
          */
-        if (virtio_queue_empty(n->rx_vq) ||
+        if (virtio_queue_empty(n->rx_vq[0]) ||
             (n->mergeable_rx_bufs &&
-             !virtqueue_avail_bytes(n->rx_vq, bufsize, 0)))
+             !virtqueue_avail_bytes(n->rx_vq[0], bufsize, 0)))
             return 0;
     }
 
-    virtio_queue_set_notification(n->rx_vq, 0);
+    virtio_queue_set_notification(n->rx_vq[0], 0);
     return 1;
 }
 
@@ -623,7 +628,7 @@ static ssize_t virtio_net_receive(VLANCl
 
         total = 0;
 
-        if (virtqueue_pop(n->rx_vq, &elem) == 0) {
+        if (virtqueue_pop(n->rx_vq[0], &elem) == 0) {
             if (i == 0)
                 return -1;
             error_report("virtio-net unexpected empty queue: "
@@ -675,15 +680,15 @@ static ssize_t virtio_net_receive(VLANCl
         }
 
         /* signal other side */
-        virtqueue_fill(n->rx_vq, &elem, total, i++);
+        virtqueue_fill(n->rx_vq[0], &elem, total, i++);
     }
 
     if (mhdr) {
         stw_p(&mhdr->num_buffers, i);
     }
 
-    virtqueue_flush(n->rx_vq, i);
-    virtio_notify(&n->vdev, n->rx_vq);
+    virtqueue_flush(n->rx_vq[0], i);
+    virtio_notify(&n->vdev, n->rx_vq[0]);
 
     return size;
 }
@@ -694,13 +699,13 @@ static void virtio_net_tx_complete(VLANC
 {
     VirtIONet *n = DO_UPCAST(NICState, nc, nc)->opaque;
 
-    virtqueue_push(n->tx_vq, &n->async_tx.elem, n->async_tx.len);
-    virtio_notify(&n->vdev, n->tx_vq);
+    virtqueue_push(n->tx_vq[0], &n->async_tx.elem, n->async_tx.len);
+    virtio_notify(&n->vdev, n->tx_vq[0]);
 
     n->async_tx.elem.out_num = n->async_tx.len = 0;
 
-    virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    virtio_queue_set_notification(n->tx_vq[0], 1);
+    virtio_net_flush_tx(n, n->tx_vq[0]);
 }
 
 /* TX */
@@ -715,7 +720,7 @@ static int32_t virtio_net_flush_tx(VirtI
     assert(n->vdev.vm_running);
 
     if (n->async_tx.elem.out_num) {
-        virtio_queue_set_notification(n->tx_vq, 0);
+        virtio_queue_set_notification(n->tx_vq[0], 0);
         return num_packets;
     }
 
@@ -750,7 +755,7 @@ static int32_t virtio_net_flush_tx(VirtI
         ret = qemu_sendv_packet_async(&n->nic->nc, out_sg, out_num,
                                       virtio_net_tx_complete);
         if (ret == 0) {
-            virtio_queue_set_notification(n->tx_vq, 0);
+            virtio_queue_set_notification(n->tx_vq[0], 0);
             n->async_tx.elem = elem;
             n->async_tx.len  = len;
             return -EBUSY;
@@ -818,8 +823,8 @@ static void virtio_net_tx_timer(void *op
     if (!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
         return;
 
-    virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    virtio_queue_set_notification(n->tx_vq[0], 1);
+    virtio_net_flush_tx(n, n->tx_vq[0]);
 }
 
 static void virtio_net_tx_bh(void *opaque)
@@ -835,7 +840,7 @@ static void virtio_net_tx_bh(void *opaqu
     if (unlikely(!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK)))
         return;
 
-    ret = virtio_net_flush_tx(n, n->tx_vq);
+    ret = virtio_net_flush_tx(n, n->tx_vq[0]);
     if (ret == -EBUSY) {
         return; /* Notification re-enable handled by tx_complete */
     }
@@ -851,9 +856,9 @@ static void virtio_net_tx_bh(void *opaqu
     /* If less than a full burst, re-enable notification and flush
      * anything that may have come in while we weren't looking.  If
      * we find something, assume the guest is still active and reschedule */
-    virtio_queue_set_notification(n->tx_vq, 1);
-    if (virtio_net_flush_tx(n, n->tx_vq) > 0) {
-        virtio_queue_set_notification(n->tx_vq, 0);
+    virtio_queue_set_notification(n->tx_vq[0], 1);
+    if (virtio_net_flush_tx(n, n->tx_vq[0]) > 0) {
+        virtio_queue_set_notification(n->tx_vq[0], 0);
         qemu_bh_schedule(n->tx_bh);
         n->tx_waiting = 1;
     }
@@ -869,6 +874,7 @@ static void virtio_net_save(QEMUFile *f,
     virtio_save(&n->vdev, f);
 
     qemu_put_buffer(f, n->mac, ETH_ALEN);
+    qemu_put_be16(f, n->numtxqs);
     qemu_put_be32(f, n->tx_waiting);
     qemu_put_be32(f, n->mergeable_rx_bufs);
     qemu_put_be16(f, n->status);
@@ -898,6 +904,7 @@ static int virtio_net_load(QEMUFile *f, 
     virtio_load(&n->vdev, f);
 
     qemu_get_buffer(f, n->mac, ETH_ALEN);
+    n->numtxqs = qemu_get_be32(f);
     n->tx_waiting = qemu_get_be32(f);
     n->mergeable_rx_bufs = qemu_get_be32(f);
 
@@ -996,11 +1003,13 @@ VirtIODevice *virtio_net_init(DeviceStat
                               virtio_net_conf *net)
 {
     VirtIONet *n;
+    int i;
 
     n = (VirtIONet *)virtio_common_init("virtio-net", VIRTIO_ID_NET,
                                         sizeof(struct virtio_net_config),
                                         sizeof(VirtIONet));
 
+    n->numtxqs = conf->peer->numtxqs;
     n->vdev.get_config = virtio_net_get_config;
     n->vdev.set_config = virtio_net_set_config;
     n->vdev.get_features = virtio_net_get_features;
@@ -1008,7 +1017,6 @@ VirtIODevice *virtio_net_init(DeviceStat
     n->vdev.bad_features = virtio_net_bad_features;
     n->vdev.reset = virtio_net_reset;
     n->vdev.set_status = virtio_net_set_status;
-    n->rx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_rx);
 
     if (net->tx && strcmp(net->tx, "timer") && strcmp(net->tx, "bh")) {
         error_report("virtio-net: "
@@ -1017,12 +1025,25 @@ VirtIODevice *virtio_net_init(DeviceStat
         error_report("Defaulting to \"bh\"");
     }
 
+    /* Allocate per rx/tx vq's */
+    n->rx_vq = qemu_mallocz(n->numtxqs * sizeof(*n->rx_vq));
+    n->tx_vq = qemu_mallocz(n->numtxqs * sizeof(*n->tx_vq));
+
+    for (i = 0; i < n->numtxqs; i++) {
+        n->rx_vq[i] = virtio_add_queue(&n->vdev, 256, virtio_net_handle_rx);
+        if (net->tx && !strcmp(net->tx, "timer")) {
+            n->tx_vq[i] = virtio_add_queue(&n->vdev, 256,
+                                           virtio_net_handle_tx_timer);
+        } else {
+            n->tx_vq[i] = virtio_add_queue(&n->vdev, 256,
+                                           virtio_net_handle_tx_bh);
+        }
+    }
+
     if (net->tx && !strcmp(net->tx, "timer")) {
-        n->tx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_tx_timer);
         n->tx_timer = qemu_new_timer(vm_clock, virtio_net_tx_timer, n);
         n->tx_timeout = net->txtimer;
     } else {
-        n->tx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_tx_bh);
         n->tx_bh = qemu_bh_new(virtio_net_tx_bh, n);
     }
     n->ctrl_vq = virtio_add_queue(&n->vdev, 64, virtio_net_handle_ctrl);
diff -ruNp org/hw/virtio-net.h new/hw/virtio-net.h
--- org/hw/virtio-net.h	2011-04-05 14:15:18.000000000 +0530
+++ new/hw/virtio-net.h	2011-04-05 14:15:18.000000000 +0530
@@ -44,6 +44,7 @@
 #define VIRTIO_NET_F_CTRL_RX    18      /* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN  19      /* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20   /* Extra RX mode control support */
+#define VIRTIO_NET_F_MULTIQUEUE	21	/* Supports multiple RX/TX queues */
 
 #define VIRTIO_NET_S_LINK_UP    1       /* Link is up */
 
@@ -72,6 +73,7 @@ struct virtio_net_config
     uint8_t mac[ETH_ALEN];
     /* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
     uint16_t status;
+    uint16_t num_queue_pairs;  /* number of rx+tx queues */
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
diff -ruNp org/hw/virtio-pci.c new/hw/virtio-pci.c
--- org/hw/virtio-pci.c	2011-04-05 14:15:18.000000000 +0530
+++ new/hw/virtio-pci.c	2011-04-05 14:15:18.000000000 +0530
@@ -103,6 +103,7 @@ typedef struct {
     uint32_t addr;
     uint32_t class_code;
     uint32_t nvectors;
+    uint32_t mq;
     BlockConf block;
     NICConf nic;
     uint32_t host_features;
@@ -965,6 +966,7 @@ static PCIDeviceInfo virtio_info[] = {
             DEFINE_PROP_BIT("ioeventfd", VirtIOPCIProxy, flags,
                             VIRTIO_PCI_FLAG_USE_IOEVENTFD_BIT, false),
             DEFINE_PROP_UINT32("vectors", VirtIOPCIProxy, nvectors, 3),
+	    DEFINE_PROP_UINT32("mq", VirtIOPCIProxy, mq, 1),
             DEFINE_VIRTIO_NET_FEATURES(VirtIOPCIProxy, host_features),
             DEFINE_NIC_PROPERTIES(VirtIOPCIProxy, nic),
             DEFINE_PROP_UINT32("x-txtimer", VirtIOPCIProxy,
diff -ruNp org/net/tap.c new/net/tap.c
--- org/net/tap.c	2011-04-05 14:15:18.000000000 +0530
+++ new/net/tap.c	2011-04-05 14:15:18.000000000 +0530
@@ -49,16 +49,20 @@
  */
 #define TAP_BUFSIZE (4096 + 65536)
 
+#define VIRTIO_MAX_TXQS 8
+
 typedef struct TAPState {
     VLANClientState nc;
-    int fd;
+    int *fds;
+    int numfds;
     char down_script[1024];
-    char down_script_arg[128];
+    char down_script_arg[VIRTIO_MAX_TXQS][128];
     uint8_t buf[TAP_BUFSIZE];
     unsigned int read_poll : 1;
     unsigned int write_poll : 1;
     unsigned int using_vnet_hdr : 1;
     unsigned int has_ufo: 1;
+    unsigned int do_script: 1;
     VHostNetState *vhost_net;
     unsigned host_vnet_hdr_len;
 } TAPState;
@@ -71,11 +75,16 @@ static void tap_writable(void *opaque);
 
 static void tap_update_fd_handler(TAPState *s)
 {
-    qemu_set_fd_handler2(s->fd,
-                         s->read_poll  ? tap_can_send : NULL,
-                         s->read_poll  ? tap_send     : NULL,
-                         s->write_poll ? tap_writable : NULL,
-                         s);
+    int i;
+
+    for (i = 0; i < s->numfds; i++) {
+        qemu_set_fd_handler2(s->fds[i],
+                             s->read_poll  ? tap_can_send : NULL,
+                                 s->read_poll  ? tap_send     : NULL,
+                                 s->write_poll ? tap_writable : NULL,
+                                 s);
+        }
+    }
 }
 
 static void tap_read_poll(TAPState *s, int enable)
@@ -104,7 +113,7 @@ static ssize_t tap_write_packet(TAPState
     ssize_t len;
 
     do {
-        len = writev(s->fd, iov, iovcnt);
+        len = writev(s->fds[0], iov, iovcnt);
     } while (len == -1 && errno == EINTR);
 
     if (len == -1 && errno == EAGAIN) {
@@ -197,7 +206,7 @@ static void tap_send(void *opaque)
     do {
         uint8_t *buf = s->buf;
 
-        size = tap_read_packet(s->fd, s->buf, sizeof(s->buf));
+        size = tap_read_packet(s->fds[0], s->buf, sizeof(s->buf));
         if (size <= 0) {
             break;
         }
@@ -238,18 +247,20 @@ int tap_has_vnet_hdr_len(VLANClientState
 
     assert(nc->info->type == NET_CLIENT_TYPE_TAP);
 
-    return tap_probe_vnet_hdr_len(s->fd, len);
+    return tap_probe_vnet_hdr_len(s->fds[0], len);
 }
 
 void tap_set_vnet_hdr_len(VLANClientState *nc, int len)
 {
     TAPState *s = DO_UPCAST(TAPState, nc, nc);
+    int i;
 
     assert(nc->info->type == NET_CLIENT_TYPE_TAP);
     assert(len == sizeof(struct virtio_net_hdr_mrg_rxbuf) ||
            len == sizeof(struct virtio_net_hdr));
 
-    tap_fd_set_vnet_hdr_len(s->fd, len);
+    for (i = 0; i < s->numfds; i++)
+        tap_fd_set_vnet_hdr_len(s->fds[i], len);
     s->host_vnet_hdr_len = len;
 }
 
@@ -269,16 +280,27 @@ void tap_set_offload(VLANClientState *nc
                      int tso6, int ecn, int ufo)
 {
     TAPState *s = DO_UPCAST(TAPState, nc, nc);
-    if (s->fd < 0) {
-        return;
+    int i;
+
+    for (i = 0; i < s->numfds; i++) {
+        if (s->fds[i] >= 0)
+            tap_fd_set_offload(s->fds[i], csum, tso4, tso6, ecn, ufo);
     }
+}
 
-    tap_fd_set_offload(s->fd, csum, tso4, tso6, ecn, ufo);
+static void close_tap_fds(int *fds, int numtxqs)
+{
+    int i;
+
+    for (i = 0; i < numtxqs; i++) {
+        close(fds[i]);
+    }
 }
 
 static void tap_cleanup(VLANClientState *nc)
 {
     TAPState *s = DO_UPCAST(TAPState, nc, nc);
+    int i;
 
     if (s->vhost_net) {
         vhost_net_cleanup(s->vhost_net);
@@ -287,13 +309,15 @@ static void tap_cleanup(VLANClientState 
 
     qemu_purge_queued_packets(nc);
 
-    if (s->down_script[0])
-        launch_script(s->down_script, s->down_script_arg, s->fd);
+    for (i = 0; i < s->numfds; i++) {
+        if (s->down_script[0])
+            launch_script(s->down_script, s->down_script_arg[i], s->fds[i]);
+    }
 
     tap_read_poll(s, 0);
     tap_write_poll(s, 0);
-    close(s->fd);
-    s->fd = -1;
+
+    close_tap_fds(s->fds, s->numfds);
 }
 
 static void tap_poll(VLANClientState *nc, bool enable)
@@ -303,11 +327,12 @@ static void tap_poll(VLANClientState *nc
     tap_write_poll(s, enable);
 }
 
-int tap_get_fd(VLANClientState *nc)
+int tap_get_fd(VLANClientState *nc, int index)
 {
     TAPState *s = DO_UPCAST(TAPState, nc, nc);
     assert(nc->info->type == NET_CLIENT_TYPE_TAP);
-    return s->fd;
+    assert(index < s->numfds);
+    return s->fds[index];
 }
 
 /* fd support */
@@ -325,20 +350,25 @@ static NetClientInfo net_tap_info = {
 static TAPState *net_tap_fd_init(VLANState *vlan,
                                  const char *model,
                                  const char *name,
-                                 int fd,
+                                 int *fds, int numtxqs,
                                  int vnet_hdr)
 {
     VLANClientState *nc;
     TAPState *s;
+    int i;
 
     nc = qemu_new_net_client(&net_tap_info, vlan, NULL, model, name);
+    nc->numtxqs = numtxqs;
 
     s = DO_UPCAST(TAPState, nc, nc);
 
-    s->fd = fd;
+    s->fds = fds;
+    s->numfds = numtxqs;
     s->host_vnet_hdr_len = vnet_hdr ? sizeof(struct virtio_net_hdr) : 0;
     s->using_vnet_hdr = 0;
-    s->has_ufo = tap_probe_has_ufo(s->fd);
+    for (i = 0; i < s->numfds; i++) {
+        s->has_ufo = tap_probe_has_ufo(s->fds[i]);
+    }
     tap_set_offload(&s->nc, 0, 0, 0, 0, 0);
     tap_read_poll(s, 1);
     s->vhost_net = NULL;
@@ -389,11 +419,28 @@ static int launch_script(const char *set
     return -1;
 }
 
-static int net_tap_init(QemuOpts *opts, int *vnet_hdr)
+static int net_tap_init(QemuOpts *opts, int *vnet_hdr, int *fds, int numtxqs,
+                        int *script)
 {
-    int fd, vnet_hdr_required;
+    int i, vnet_hdr_required;
     char ifname[128] = {0,};
     const char *setup_script;
+    int launch = 0;
+    const char *dev;
+
+    if (qemu_opt_get(opts, "vtap")) {
+        *vnet_hdr = 1;
+        *script = 0;    /* we don't need start/stop script */
+        dev = qemu_opt_get(opts, "vtap");
+        for (i = 0; i < numtxqs; i++) {
+            TFR(fds[i] = vtap_open(dev, vnet_hdr, 1));
+            if (fds[i] < 0)
+                goto err;
+            fcntl(fds[i], F_SETFL, O_NONBLOCK);
+        }
+        *vnet_hdr = !!tap_probe_vnet_hdr(fds[0]);
+        return 0;
+    }
 
     if (qemu_opt_get(opts, "ifname")) {
         pstrcpy(ifname, sizeof(ifname), qemu_opt_get(opts, "ifname"));
@@ -406,29 +453,76 @@ static int net_tap_init(QemuOpts *opts, 
         vnet_hdr_required = 0;
     }
 
-    TFR(fd = tap_open(ifname, sizeof(ifname), vnet_hdr, vnet_hdr_required));
-    if (fd < 0) {
-        return -1;
-    }
-
     setup_script = qemu_opt_get(opts, "script");
     if (setup_script &&
         setup_script[0] != '\0' &&
-        strcmp(setup_script, "no") != 0 &&
-        launch_script(setup_script, ifname, fd)) {
-        close(fd);
-        return -1;
+        strcmp(setup_script, "no") != 0) {
+            launch = 1;
+            *script = 1;
+    }
+
+    if (numtxqs == 1) {
+        fprintf(stderr, "Device: %s\n", ifname);
+        TFR(fds[0] = tap_open(ifname, sizeof(ifname), vnet_hdr,
+                              vnet_hdr_required));
+        if (fds[0] < 0) {
+            goto err;
+        }
+
+        if (launch && launch_script(setup_script, ifname, fds[0]))
+            goto err;
+    } else {
+        char alt_name[128];
+
+        for (i = 0; i < numtxqs; i++) {
+            sprintf(alt_name, "%s.%d", ifname, i);
+            fprintf(stderr, "Device: %s\n", alt_name);
+            TFR(fds[i] = tap_open(alt_name, sizeof(alt_name), vnet_hdr,
+                                  vnet_hdr_required));
+            if (fds[i] < 0) {
+                goto err;
+            }
+
+            if (launch && launch_script(setup_script, alt_name, fds[i]))
+                goto err;
+         }
     }
 
     qemu_opt_set(opts, "ifname", ifname);
 
-    return fd;
+    return 0;
+
+err:
+    close_tap_fds(fds, numtxqs);
+    return -1;
 }
 
 int net_init_tap(QemuOpts *opts, Monitor *mon, const char *name, VLANState *vlan)
 {
     TAPState *s;
-    int fd, vnet_hdr = 0;
+    int *fds, vnet_hdr = 0;
+    int i, vhost;
+    int script = 0, numtxqs = 1;
+
+    vhost = qemu_opt_get_bool(opts, "vhost", 0);
+
+    /*
+     * We support multiple tx queues if:
+     *      1. smp > 1
+     *      2. vhost=on
+     *      3. mq=on
+     * In this case, #txqueues = #cpus. This value can be changed by
+     * using the "numtxqs" option.
+     */
+    if (vhost && smp_cpus > 1) {
+        if (qemu_opt_get_bool(opts, "mq", 0)) {
+            int dflt = MIN(smp_cpus, VIRTIO_MAX_TXQS);
+
+            numtxqs = qemu_opt_get_number(opts, "numtxqs", dflt);
+        }
+    }
+
+    fds = qemu_mallocz(numtxqs * sizeof(*fds));
 
     if (qemu_opt_get(opts, "fd")) {
         if (qemu_opt_get(opts, "ifname") ||
@@ -439,14 +533,14 @@ int net_init_tap(QemuOpts *opts, Monitor
             return -1;
         }
 
-        fd = net_handle_fd_param(mon, qemu_opt_get(opts, "fd"));
-        if (fd == -1) {
+        fds[0] = net_handle_fd_param(mon, qemu_opt_get(opts, "fd"));
+        if (fds[0] == -1) {
             return -1;
         }
 
-        fcntl(fd, F_SETFL, O_NONBLOCK);
+        fcntl(fds[0], F_SETFL, O_NONBLOCK);
 
-        vnet_hdr = tap_probe_vnet_hdr(fd);
+        vnet_hdr = tap_probe_vnet_hdr(fds[0]);
     } else {
         if (!qemu_opt_get(opts, "script")) {
             qemu_opt_set(opts, "script", DEFAULT_NETWORK_SCRIPT);
@@ -456,24 +550,28 @@ int net_init_tap(QemuOpts *opts, Monitor
             qemu_opt_set(opts, "downscript", DEFAULT_NETWORK_DOWN_SCRIPT);
         }
 
-        fd = net_tap_init(opts, &vnet_hdr);
-        if (fd == -1) {
+        if (net_tap_init(opts, &vnet_hdr, fds, numtxqs, &script) == -1) {
             return -1;
         }
     }
 
-    s = net_tap_fd_init(vlan, "tap", name, fd, vnet_hdr);
+    s = net_tap_fd_init(vlan, "tap", name, fds, numtxqs, vnet_hdr);
     if (!s) {
-        close(fd);
+        close_tap_fds(fds, numtxqs);
         return -1;
     }
 
-    if (tap_set_sndbuf(s->fd, opts) < 0) {
-        return -1;
+    s->do_script = script;
+
+    for (i = 0; i < s->numfds; i++) {
+        if (tap_set_sndbuf(s->fds[i], opts) < 0) {
+            close_tap_fds(fds, numtxqs);
+            return -1;
+        }
     }
 
     if (qemu_opt_get(opts, "fd")) {
-        snprintf(s->nc.info_str, sizeof(s->nc.info_str), "fd=%d", fd);
+        snprintf(s->nc.info_str, sizeof(s->nc.info_str), "fd=%d", fds[0]);
     } else {
         const char *ifname, *script, *downscript;
 
@@ -487,12 +585,20 @@ int net_init_tap(QemuOpts *opts, Monitor
 
         if (strcmp(downscript, "no") != 0) {
             snprintf(s->down_script, sizeof(s->down_script), "%s", downscript);
-            snprintf(s->down_script_arg, sizeof(s->down_script_arg), "%s", ifname);
+            for (i = 0; i < s->numfds; i++) {
+                char alt_name[128];
+
+                if (s->numfds == 1) {
+                    pstrcpy(alt_name, sizeof(ifname), ifname);
+                } else {
+                    sprintf(alt_name, "%s.%d", ifname, i);
+                }
+                snprintf(s->down_script_arg[i], sizeof(s->down_script_arg[i]), "%s", alt_name);
+            }
         }
     }
 
-    if (qemu_opt_get_bool(opts, "vhost", !!qemu_opt_get(opts, "vhostfd") ||
-                          qemu_opt_get_bool(opts, "vhostforce", false))) {
+    if (vhost) {
         int vhostfd, r;
         bool force = qemu_opt_get_bool(opts, "vhostforce", false);
         if (qemu_opt_get(opts, "vhostfd")) {
@@ -504,9 +610,13 @@ int net_init_tap(QemuOpts *opts, Monitor
         } else {
             vhostfd = -1;
         }
-        s->vhost_net = vhost_net_init(&s->nc, vhostfd, force);
+        s->vhost_net = vhost_net_init(&s->nc, vhostfd, force, numtxqs);
         if (!s->vhost_net) {
             error_report("vhost-net requested but could not be initialized");
+            if (numtxqs > 1) {
+                error_report("Need vhost support for numtxqs > 1, exiting...");
+                exit(1);
+            }
             return -1;
         }
     } else if (qemu_opt_get(opts, "vhostfd")) {
diff -ruNp org/net/tap.h new/net/tap.h
--- org/net/tap.h	2011-04-05 14:15:18.000000000 +0530
+++ new/net/tap.h	2011-04-05 14:15:18.000000000 +0530
@@ -35,6 +35,7 @@
 int net_init_tap(QemuOpts *opts, Monitor *mon, const char *name, VLANState *vlan);
 
 int tap_open(char *ifname, int ifname_size, int *vnet_hdr, int vnet_hdr_required);
+int vtap_open(const char *devname, int *vnet_hdr, int vnet_hdr_required);
 
 ssize_t tap_read_packet(int tapfd, uint8_t *buf, int maxlen);
 
@@ -52,7 +53,7 @@ int tap_probe_has_ufo(int fd);
 void tap_fd_set_offload(int fd, int csum, int tso4, int tso6, int ecn, int ufo);
 void tap_fd_set_vnet_hdr_len(int fd, int len);
 
-int tap_get_fd(VLANClientState *vc);
+int tap_get_fd(VLANClientState *vc, int index);
 
 struct vhost_net;
 struct vhost_net *tap_get_vhost_net(VLANClientState *vc);
diff -ruNp org/net/tap-linux.c new/net/tap-linux.c
--- org/net/tap-linux.c	2011-04-05 14:15:18.000000000 +0530
+++ new/net/tap-linux.c	2011-04-05 14:15:18.000000000 +0530
@@ -82,6 +82,48 @@ int tap_open(char *ifname, int ifname_si
     return fd;
 }
 
+int vtap_open(const char *devname, int *vnet_hdr, int vnet_hdr_required)
+{
+    struct ifreq ifr;
+    int fd, ret;
+
+    TFR(fd = open(devname, O_RDWR));
+    if (fd < 0) {
+        fprintf(stderr, "warning: could not open %s: no virtual network emulation\n", devname);
+        return -1;
+    }
+    memset(&ifr, 0, sizeof(ifr));
+    ifr.ifr_flags = IFF_TAP | IFF_NO_PI;
+
+    if (*vnet_hdr) {
+        unsigned int features;
+
+        if (ioctl(fd, TUNGETFEATURES, &features) == 0 &&
+            features & IFF_VNET_HDR) {
+            *vnet_hdr = 1;
+            ifr.ifr_flags |= IFF_VNET_HDR;
+        } else {
+            *vnet_hdr = 0;
+        }
+
+        if (vnet_hdr_required && !*vnet_hdr) {
+            error_report("vnet_hdr=1 requested, but no kernel "
+                         "support for IFF_VNET_HDR available");
+            close(fd);
+            return -1;
+        }
+    }
+
+    ret = ioctl(fd, TUNSETIFF, (void *) &ifr);
+    if (ret != 0) {
+        fprintf(stderr, "warning: could not configure %s: no virtual network emulation\n", devname);
+        close(fd);
+        return -1;
+    }
+    fcntl(fd, F_SETFL, O_NONBLOCK);
+    return fd;
+}
+
 /* sndbuf implements a kind of flow control for tap.
  * Unfortunately when it's enabled, and packets are sent
  * to other guests on the same host, the receiver
diff -ruNp org/net.c new/net.c
--- org/net.c	2011-04-05 14:15:18.000000000 +0530
+++ new/net.c	2011-04-05 14:15:18.000000000 +0530
@@ -798,6 +798,16 @@ static int net_init_nic(QemuOpts *opts,
         return -1;
     }
 
+    if (nd->netdev->numtxqs > 1 && nd->nvectors == DEV_NVECTORS_UNSPECIFIED) {
+        /*
+         * User specified mq for guest, but no "vectors=", tune
+         * it automatically to 'numtxqs' TX + 'numtxqs' RX + 1 controlq.
+         */
+        nd->nvectors = nd->netdev->numtxqs * 2 + 1;
+        monitor_printf(mon, "nvectors tuned to %d\n", nd->nvectors);
+    }
+
+
     nd->used = 1;
     nb_nics++;
 
@@ -941,6 +951,18 @@ static const struct {
             },
 #ifndef _WIN32
             {
+                .name = "vtap",
+                .type = QEMU_OPT_STRING,
+                .help = "name of macvtap device to use",
+            }, {
+                .name = "mq",
+                .type = QEMU_OPT_BOOL,
+                .help = "enable multiqueue on network i/f",
+            }, {
+                .name = "numtxqs",
+                .type = QEMU_OPT_NUMBER,
+                .help = "optional number of RX/TX queues, if mq is enabled",
+            }, {
                 .name = "fd",
                 .type = QEMU_OPT_STRING,
                 .help = "file descriptor of an already opened tap",
diff -ruNp org/net.h new/net.h
--- org/net.h	2011-04-05 14:15:18.000000000 +0530
+++ new/net.h	2011-04-05 14:15:18.000000000 +0530
@@ -64,6 +64,7 @@ struct VLANClientState {
     struct VLANState *vlan;
     VLANClientState *peer;
     NetQueue *send_queue;
+    int numtxqs;
     char *model;
     char *name;
     char info_str[256];
