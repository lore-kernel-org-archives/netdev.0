From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [v3 RFC PATCH 4/4] qemu changes
Date: Wed, 20 Oct 2010 14:25:28 +0530
Message-ID: <20101020085528.15579.81209.sendpatchset@krkumar2.in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, arnd@arndb.de, avi@redhat.com,
	anthony@codemonkey.ws, Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:41335 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab0JTIzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 04:55:36 -0400
In-Reply-To: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in qemu to support mq TX.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---     
 hw/vhost.c      |    7 ++++--
 hw/vhost.h      |    2 -
 hw/vhost_net.c  |   16 +++++++++----
 hw/vhost_net.h  |    2 -
 hw/virtio-net.c |   53 ++++++++++++++++++++++++++++++++--------------
 hw/virtio-net.h |    2 +
 hw/virtio-pci.c |    2 +
 net.c           |   17 ++++++++++++++
 net.h           |    1 
 net/tap.c       |   34 ++++++++++++++++++++++++++---
 10 files changed, 107 insertions(+), 29 deletions(-)

diff -ruNp org3/hw/vhost.c new3/hw/vhost.c
--- org3/hw/vhost.c	2010-10-19 19:38:11.000000000 +0530
+++ new3/hw/vhost.c	2010-10-20 12:44:21.000000000 +0530
@@ -580,7 +580,7 @@ static void vhost_virtqueue_cleanup(stru
                               0, virtio_queue_get_desc_size(vdev, idx));
 }
 
-int vhost_dev_init(struct vhost_dev *hdev, int devfd)
+int vhost_dev_init(struct vhost_dev *hdev, int devfd, int numtxqs)
 {
     uint64_t features;
     int r;
@@ -592,11 +592,14 @@ int vhost_dev_init(struct vhost_dev *hde
             return -errno;
         }
     }
-    r = ioctl(hdev->control, VHOST_SET_OWNER, NULL);
+
+    r = ioctl(hdev->control, VHOST_SET_OWNER, numtxqs);
     if (r < 0) {
         goto fail;
     }
 
+    hdev->nvqs = numtxqs + 1;
+
     r = ioctl(hdev->control, VHOST_GET_FEATURES, &features);
     if (r < 0) {
         goto fail;
diff -ruNp org3/hw/vhost.h new3/hw/vhost.h
--- org3/hw/vhost.h	2010-07-01 11:42:09.000000000 +0530
+++ new3/hw/vhost.h	2010-10-20 12:47:10.000000000 +0530
@@ -40,7 +40,7 @@ struct vhost_dev {
     unsigned long long log_size;
 };
 
-int vhost_dev_init(struct vhost_dev *hdev, int devfd);
+int vhost_dev_init(struct vhost_dev *hdev, int devfd, int numtxqs);
 void vhost_dev_cleanup(struct vhost_dev *hdev);
 int vhost_dev_start(struct vhost_dev *hdev, VirtIODevice *vdev);
 void vhost_dev_stop(struct vhost_dev *hdev, VirtIODevice *vdev);
diff -ruNp org3/hw/vhost_net.c new3/hw/vhost_net.c
--- org3/hw/vhost_net.c	2010-09-28 10:07:31.000000000 +0530
+++ new3/hw/vhost_net.c	2010-10-19 19:46:52.000000000 +0530
@@ -36,7 +36,8 @@
 
 struct vhost_net {
     struct vhost_dev dev;
-    struct vhost_virtqueue vqs[2];
+    struct vhost_virtqueue *vqs;
+    int nvqs;
     int backend;
     VLANClientState *vc;
 };
@@ -81,7 +82,8 @@ static int vhost_net_get_fd(VLANClientSt
     }
 }
 
-struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd)
+struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd,
+				 int numtxqs)
 {
     int r;
     struct vhost_net *net = qemu_malloc(sizeof *net);
@@ -98,10 +100,14 @@ struct vhost_net *vhost_net_init(VLANCli
         (1 << VHOST_NET_F_VIRTIO_NET_HDR);
     net->backend = r;
 
-    r = vhost_dev_init(&net->dev, devfd);
+    r = vhost_dev_init(&net->dev, devfd, numtxqs);
     if (r < 0) {
         goto fail;
     }
+
+    net->nvqs = numtxqs + 1;
+    net->vqs = qemu_malloc(net->nvqs * (sizeof *net->vqs));
+
     if (!tap_has_vnet_hdr_len(backend,
                               sizeof(struct virtio_net_hdr_mrg_rxbuf))) {
         net->dev.features &= ~(1 << VIRTIO_NET_F_MRG_RXBUF);
@@ -131,7 +137,6 @@ int vhost_net_start(struct vhost_net *ne
                              sizeof(struct virtio_net_hdr_mrg_rxbuf));
     }
 
-    net->dev.nvqs = 2;
     net->dev.vqs = net->vqs;
     r = vhost_dev_start(&net->dev, dev);
     if (r < 0) {
@@ -188,7 +193,8 @@ void vhost_net_cleanup(struct vhost_net 
     qemu_free(net);
 }
 #else
-struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd)
+struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd,
+				 int nvqs)
 {
 	return NULL;
 }
diff -ruNp org3/hw/vhost_net.h new3/hw/vhost_net.h
--- org3/hw/vhost_net.h	2010-07-01 11:42:09.000000000 +0530
+++ new3/hw/vhost_net.h	2010-10-19 19:46:52.000000000 +0530
@@ -6,7 +6,7 @@
 struct vhost_net;
 typedef struct vhost_net VHostNetState;
 
-VHostNetState *vhost_net_init(VLANClientState *backend, int devfd);
+VHostNetState *vhost_net_init(VLANClientState *backend, int devfd, int nvqs);
 
 int vhost_net_start(VHostNetState *net, VirtIODevice *dev);
 void vhost_net_stop(VHostNetState *net, VirtIODevice *dev);
diff -ruNp org3/hw/virtio-net.c new3/hw/virtio-net.c
--- org3/hw/virtio-net.c	2010-10-19 19:38:11.000000000 +0530
+++ new3/hw/virtio-net.c	2010-10-19 21:02:33.000000000 +0530
@@ -32,7 +32,7 @@ typedef struct VirtIONet
     uint8_t mac[ETH_ALEN];
     uint16_t status;
     VirtQueue *rx_vq;
-    VirtQueue *tx_vq;
+    VirtQueue **tx_vq;
     VirtQueue *ctrl_vq;
     NICState *nic;
     QEMUTimer *tx_timer;
@@ -65,6 +65,7 @@ typedef struct VirtIONet
     } mac_table;
     uint32_t *vlans;
     DeviceState *qdev;
+    uint16_t numtxqs;
 } VirtIONet;
 
 /* TODO
@@ -82,6 +83,7 @@ static void virtio_net_get_config(VirtIO
     struct virtio_net_config netcfg;
 
     netcfg.status = n->status;
+    netcfg.numtxqs = n->numtxqs;
     memcpy(netcfg.mac, n->mac, ETH_ALEN);
     memcpy(config, &netcfg, sizeof(netcfg));
 }
@@ -196,6 +198,8 @@ static uint32_t virtio_net_get_features(
     VirtIONet *n = to_virtio_net(vdev);
 
     features |= (1 << VIRTIO_NET_F_MAC);
+    if (n->numtxqs > 1)
+        features |= (1 << VIRTIO_NET_F_NUMTXQS);
 
     if (peer_has_vnet_hdr(n)) {
         tap_using_vnet_hdr(n->nic->nc.peer, 1);
@@ -659,13 +663,16 @@ static void virtio_net_tx_complete(VLANC
 {
     VirtIONet *n = DO_UPCAST(NICState, nc, nc)->opaque;
 
-    virtqueue_push(n->tx_vq, &n->async_tx.elem, n->async_tx.len);
-    virtio_notify(&n->vdev, n->tx_vq);
+    /*
+     * If this function executes, we are single TX and hence use only txq[0]
+     */
+    virtqueue_push(n->tx_vq[0], &n->async_tx.elem, n->async_tx.len);
+    virtio_notify(&n->vdev, n->tx_vq[0]);
 
     n->async_tx.elem.out_num = n->async_tx.len = 0;
 
-    virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    virtio_queue_set_notification(n->tx_vq[0], 1);
+    virtio_net_flush_tx(n, n->tx_vq[0]);
 }
 
 /* TX */
@@ -679,7 +686,7 @@ static int32_t virtio_net_flush_tx(VirtI
     }
 
     if (n->async_tx.elem.out_num) {
-        virtio_queue_set_notification(n->tx_vq, 0);
+        virtio_queue_set_notification(n->tx_vq[0], 0);
         return num_packets;
     }
 
@@ -714,7 +721,7 @@ static int32_t virtio_net_flush_tx(VirtI
         ret = qemu_sendv_packet_async(&n->nic->nc, out_sg, out_num,
                                       virtio_net_tx_complete);
         if (ret == 0) {
-            virtio_queue_set_notification(n->tx_vq, 0);
+            virtio_queue_set_notification(n->tx_vq[0], 0);
             n->async_tx.elem = elem;
             n->async_tx.len  = len;
             return -EBUSY;
@@ -771,8 +778,8 @@ static void virtio_net_tx_timer(void *op
     if (!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
         return;
 
-    virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    virtio_queue_set_notification(n->tx_vq[0], 1);
+    virtio_net_flush_tx(n, n->tx_vq[0]);
 }
 
 static void virtio_net_tx_bh(void *opaque)
@@ -786,7 +793,7 @@ static void virtio_net_tx_bh(void *opaqu
     if (unlikely(!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK)))
         return;
 
-    ret = virtio_net_flush_tx(n, n->tx_vq);
+    ret = virtio_net_flush_tx(n, n->tx_vq[0]);
     if (ret == -EBUSY) {
         return; /* Notification re-enable handled by tx_complete */
     }
@@ -802,9 +809,9 @@ static void virtio_net_tx_bh(void *opaqu
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
@@ -820,6 +827,7 @@ static void virtio_net_save(QEMUFile *f,
     virtio_save(&n->vdev, f);
 
     qemu_put_buffer(f, n->mac, ETH_ALEN);
+    qemu_put_be16(f, n->numtxqs);
     qemu_put_be32(f, n->tx_waiting);
     qemu_put_be32(f, n->mergeable_rx_bufs);
     qemu_put_be16(f, n->status);
@@ -849,6 +857,7 @@ static int virtio_net_load(QEMUFile *f, 
     virtio_load(&n->vdev, f);
 
     qemu_get_buffer(f, n->mac, ETH_ALEN);
+    n->numtxqs = qemu_get_be32(f);
     n->tx_waiting = qemu_get_be32(f);
     n->mergeable_rx_bufs = qemu_get_be32(f);
 
@@ -966,11 +975,14 @@ VirtIODevice *virtio_net_init(DeviceStat
                               virtio_net_conf *net)
 {
     VirtIONet *n;
+    int i;
 
     n = (VirtIONet *)virtio_common_init("virtio-net", VIRTIO_ID_NET,
                                         sizeof(struct virtio_net_config),
                                         sizeof(VirtIONet));
 
+    n->numtxqs = conf->peer->numtxqs;
+
     n->vdev.get_config = virtio_net_get_config;
     n->vdev.set_config = virtio_net_set_config;
     n->vdev.get_features = virtio_net_get_features;
@@ -978,8 +990,8 @@ VirtIODevice *virtio_net_init(DeviceStat
     n->vdev.bad_features = virtio_net_bad_features;
     n->vdev.reset = virtio_net_reset;
     n->vdev.set_status = virtio_net_set_status;
-    n->rx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_rx);
 
+    n->rx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_rx);
     if (net->tx && strcmp(net->tx, "timer") && strcmp(net->tx, "bh")) {
         fprintf(stderr, "virtio-net: "
                 "Unknown option tx=%s, valid options: \"timer\" \"bh\"\n",
@@ -987,12 +999,21 @@ VirtIODevice *virtio_net_init(DeviceStat
         fprintf(stderr, "Defaulting to \"bh\"\n");
     }
 
+    /* Allocate per tx vq's */
+    n->tx_vq = qemu_mallocz(n->numtxqs * sizeof(*n->tx_vq));
+    for (i = 0; i < n->numtxqs; i++) {
+        if (net->tx && !strcmp(net->tx, "timer")) {
+            n->tx_vq[i] = virtio_add_queue(&n->vdev, 256,
+                                           virtio_net_handle_tx_timer);
+        } else {
+            n->tx_vq[i] = virtio_add_queue(&n->vdev, 256,
+                                           virtio_net_handle_tx_bh);
+        }
+    }
     if (net->tx && !strcmp(net->tx, "timer")) {
-        n->tx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_tx_timer);
         n->tx_timer = qemu_new_timer(vm_clock, virtio_net_tx_timer, n);
         n->tx_timeout = net->txtimer;
     } else {
-        n->tx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_tx_bh);
         n->tx_bh = qemu_bh_new(virtio_net_tx_bh, n);
     }
     n->ctrl_vq = virtio_add_queue(&n->vdev, 64, virtio_net_handle_ctrl);
diff -ruNp org3/hw/virtio-net.h new3/hw/virtio-net.h
--- org3/hw/virtio-net.h	2010-09-28 10:07:31.000000000 +0530
+++ new3/hw/virtio-net.h	2010-10-19 19:46:52.000000000 +0530
@@ -44,6 +44,7 @@
 #define VIRTIO_NET_F_CTRL_RX    18      /* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN  19      /* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20   /* Extra RX mode control support */
+#define VIRTIO_NET_F_NUMTXQS    21      /* Supports multiple TX queues */
 
 #define VIRTIO_NET_S_LINK_UP    1       /* Link is up */
 
@@ -72,6 +73,7 @@ struct virtio_net_config
     uint8_t mac[ETH_ALEN];
     /* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
     uint16_t status;
+    uint16_t numtxqs;	/* number of transmit queues */
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
diff -ruNp org3/hw/virtio-pci.c new3/hw/virtio-pci.c
--- org3/hw/virtio-pci.c	2010-10-19 19:38:11.000000000 +0530
+++ new3/hw/virtio-pci.c	2010-10-19 19:46:52.000000000 +0530
@@ -99,6 +99,7 @@ typedef struct {
     uint32_t addr;
     uint32_t class_code;
     uint32_t nvectors;
+    uint32_t mq;
     BlockConf block;
     NICConf nic;
     uint32_t host_features;
@@ -788,6 +789,7 @@ static PCIDeviceInfo virtio_info[] = {
         .romfile    = "pxe-virtio.bin",
         .qdev.props = (Property[]) {
             DEFINE_PROP_UINT32("vectors", VirtIOPCIProxy, nvectors, 3),
+	    DEFINE_PROP_UINT32("mq", VirtIOPCIProxy, mq, 1),
             DEFINE_VIRTIO_NET_FEATURES(VirtIOPCIProxy, host_features),
             DEFINE_NIC_PROPERTIES(VirtIOPCIProxy, nic),
             DEFINE_PROP_UINT32("x-txtimer", VirtIOPCIProxy,
diff -ruNp org3/net/tap.c new3/net/tap.c
--- org3/net/tap.c	2010-09-28 10:07:31.000000000 +0530
+++ new3/net/tap.c	2010-10-20 12:39:56.000000000 +0530
@@ -320,13 +320,14 @@ static NetClientInfo net_tap_info = {
 static TAPState *net_tap_fd_init(VLANState *vlan,
                                  const char *model,
                                  const char *name,
-                                 int fd,
+                                 int fd, int numtxqs,
                                  int vnet_hdr)
 {
     VLANClientState *nc;
     TAPState *s;
 
     nc = qemu_new_net_client(&net_tap_info, vlan, NULL, model, name);
+    nc->numtxqs = numtxqs;
 
     s = DO_UPCAST(TAPState, nc, nc);
 
@@ -424,6 +425,27 @@ int net_init_tap(QemuOpts *opts, Monitor
 {
     TAPState *s;
     int fd, vnet_hdr = 0;
+    int vhost;
+    int numtxqs = 1;
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
+#define VIRTIO_MAX_TXQS         32
+            int dflt = MIN(smp_cpus, VIRTIO_MAX_TXQS);
+
+            numtxqs = qemu_opt_get_number(opts, "numtxqs", dflt);
+        }
+    }
 
     if (qemu_opt_get(opts, "fd")) {
         if (qemu_opt_get(opts, "ifname") ||
@@ -457,7 +479,7 @@ int net_init_tap(QemuOpts *opts, Monitor
         }
     }
 
-    s = net_tap_fd_init(vlan, "tap", name, fd, vnet_hdr);
+    s = net_tap_fd_init(vlan, "tap", name, fd, numtxqs, vnet_hdr);
     if (!s) {
         close(fd);
         return -1;
@@ -486,7 +508,7 @@ int net_init_tap(QemuOpts *opts, Monitor
         }
     }
 
-    if (qemu_opt_get_bool(opts, "vhost", !!qemu_opt_get(opts, "vhostfd"))) {
+    if (vhost) {
         int vhostfd, r;
         if (qemu_opt_get(opts, "vhostfd")) {
             r = net_handle_fd_param(mon, qemu_opt_get(opts, "vhostfd"));
@@ -497,9 +519,13 @@ int net_init_tap(QemuOpts *opts, Monitor
         } else {
             vhostfd = -1;
         }
-        s->vhost_net = vhost_net_init(&s->nc, vhostfd);
+        s->vhost_net = vhost_net_init(&s->nc, vhostfd, numtxqs);
         if (!s->vhost_net) {
             error_report("vhost-net requested but could not be initialized");
+            if (numtxqs > 1) {
+                error_report("Need vhost support for numtxqs > 1, exiting...");
+                exit(1);
+            }
             return -1;
         }
     } else if (qemu_opt_get(opts, "vhostfd")) {
diff -ruNp org3/net.c new3/net.c
--- org3/net.c	2010-10-19 19:38:11.000000000 +0530
+++ new3/net.c	2010-10-19 19:46:52.000000000 +0530
@@ -849,6 +849,15 @@ static int net_init_nic(QemuOpts *opts,
         return -1;
     }
 
+    if (nd->netdev->numtxqs > 1 && nd->nvectors == DEV_NVECTORS_UNSPECIFIED) {
+        /*
+         * User specified mq for guest, but no "vectors=", tune
+         * it automatically to 'numtxqs' TX + 1 RX + 1 controlq.
+         */
+        nd->nvectors = nd->netdev->numtxqs + 1 + 1;
+        monitor_printf(mon, "nvectors tuned to %d\n", nd->nvectors);
+    }
+
     nd->used = 1;
     nb_nics++;
 
@@ -992,6 +1001,14 @@ static const struct {
             },
 #ifndef _WIN32
             {
+                .name = "mq",
+                .type = QEMU_OPT_BOOL,
+                .help = "enable multiqueue on network i/f",
+            }, {
+                .name = "numtxqs",
+                .type = QEMU_OPT_NUMBER,
+                .help = "optional number of TX queues, if mq is enabled",
+            }, {
                 .name = "fd",
                 .type = QEMU_OPT_STRING,
                 .help = "file descriptor of an already opened tap",
diff -ruNp org3/net.h new3/net.h
--- org3/net.h	2010-10-19 19:38:11.000000000 +0530
+++ new3/net.h	2010-10-19 19:46:52.000000000 +0530
@@ -62,6 +62,7 @@ struct VLANClientState {
     struct VLANState *vlan;
     VLANClientState *peer;
     NetQueue *send_queue;
+    int numtxqs;
     char *model;
     char *name;
     char info_str[256];
