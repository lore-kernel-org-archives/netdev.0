From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC PATCH 4/4] qemu changes
Date: Wed, 08 Sep 2010 12:59:23 +0530
Message-ID: <20100908072923.23769.19707.sendpatchset@krkumar2.in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Cc: anthony@codemonkey.ws, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, kvm@vger.kernel.org,
	mst@redhat.com
To: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:55857 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758025Ab0IHH3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:29:31 -0400
In-Reply-To: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in qemu to support mq TX.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 hw/vhost.c      |    8 ++-
 hw/vhost.h      |    2 
 hw/vhost_net.c  |   16 +++++--
 hw/vhost_net.h  |    2 
 hw/virtio-net.c |   97 ++++++++++++++++++++++++++++++----------------
 hw/virtio-net.h |    5 ++
 hw/virtio-pci.c |    2 
 net.c           |   17 ++++++++
 net.h           |    1 
 net/tap.c       |   61 +++++++++++++++++++++-------
 10 files changed, 155 insertions(+), 56 deletions(-)

diff -ruNp org/hw/vhost.c new/hw/vhost.c
--- org/hw/vhost.c	2010-08-09 09:51:58.000000000 +0530
+++ new/hw/vhost.c	2010-09-08 12:54:50.000000000 +0530
@@ -599,23 +599,27 @@ static void vhost_virtqueue_cleanup(stru
                               0, virtio_queue_get_desc_size(vdev, idx));
 }
 
-int vhost_dev_init(struct vhost_dev *hdev, int devfd)
+int vhost_dev_init(struct vhost_dev *hdev, int devfd, int numtxqs)
 {
     uint64_t features;
     int r;
     if (devfd >= 0) {
         hdev->control = devfd;
+        hdev->nvqs = 2;
     } else {
         hdev->control = open("/dev/vhost-net", O_RDWR);
         if (hdev->control < 0) {
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
diff -ruNp org/hw/vhost.h new/hw/vhost.h
--- org/hw/vhost.h	2010-07-01 11:42:09.000000000 +0530
+++ new/hw/vhost.h	2010-09-08 12:54:50.000000000 +0530
@@ -40,7 +40,7 @@ struct vhost_dev {
     unsigned long long log_size;
 };
 
-int vhost_dev_init(struct vhost_dev *hdev, int devfd);
+int vhost_dev_init(struct vhost_dev *hdev, int devfd, int nvqs);
 void vhost_dev_cleanup(struct vhost_dev *hdev);
 int vhost_dev_start(struct vhost_dev *hdev, VirtIODevice *vdev);
 void vhost_dev_stop(struct vhost_dev *hdev, VirtIODevice *vdev);
diff -ruNp org/hw/vhost_net.c new/hw/vhost_net.c
--- org/hw/vhost_net.c	2010-08-09 09:51:58.000000000 +0530
+++ new/hw/vhost_net.c	2010-09-08 12:54:50.000000000 +0530
@@ -36,7 +36,8 @@
 
 struct vhost_net {
     struct vhost_dev dev;
-    struct vhost_virtqueue vqs[2];
+    struct vhost_virtqueue *vqs;
+    int nvqs;
     int backend;
     VLANClientState *vc;
 };
@@ -76,7 +77,8 @@ static int vhost_net_get_fd(VLANClientSt
     }
 }
 
-struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd)
+struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd,
+				 int numtxqs)
 {
     int r;
     struct vhost_net *net = qemu_malloc(sizeof *net);
@@ -93,10 +95,14 @@ struct vhost_net *vhost_net_init(VLANCli
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
     if (~net->dev.features & net->dev.backend_features) {
         fprintf(stderr, "vhost lacks feature mask %" PRIu64 " for backend\n",
                 (uint64_t)(~net->dev.features & net->dev.backend_features));
@@ -118,7 +124,6 @@ int vhost_net_start(struct vhost_net *ne
     struct vhost_vring_file file = { };
     int r;
 
-    net->dev.nvqs = 2;
     net->dev.vqs = net->vqs;
     r = vhost_dev_start(&net->dev, dev);
     if (r < 0) {
@@ -166,7 +171,8 @@ void vhost_net_cleanup(struct vhost_net 
     qemu_free(net);
 }
 #else
-struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd)
+struct vhost_net *vhost_net_init(VLANClientState *backend, int devfd,
+				 int nvqs)
 {
 	return NULL;
 }
diff -ruNp org/hw/vhost_net.h new/hw/vhost_net.h
--- org/hw/vhost_net.h	2010-07-01 11:42:09.000000000 +0530
+++ new/hw/vhost_net.h	2010-09-08 12:54:50.000000000 +0530
@@ -6,7 +6,7 @@
 struct vhost_net;
 typedef struct vhost_net VHostNetState;
 
-VHostNetState *vhost_net_init(VLANClientState *backend, int devfd);
+VHostNetState *vhost_net_init(VLANClientState *backend, int devfd, int nvqs);
 
 int vhost_net_start(VHostNetState *net, VirtIODevice *dev);
 void vhost_net_stop(VHostNetState *net, VirtIODevice *dev);
diff -ruNp org/hw/virtio-net.c new/hw/virtio-net.c
--- org/hw/virtio-net.c	2010-07-19 12:41:28.000000000 +0530
+++ new/hw/virtio-net.c	2010-09-08 12:54:50.000000000 +0530
@@ -32,17 +32,17 @@ typedef struct VirtIONet
     uint8_t mac[ETH_ALEN];
     uint16_t status;
     VirtQueue *rx_vq;
-    VirtQueue *tx_vq;
+    VirtQueue **tx_vq;
     VirtQueue *ctrl_vq;
     NICState *nic;
-    QEMUTimer *tx_timer;
-    int tx_timer_active;
+    QEMUTimer **tx_timer;
+    int *tx_timer_active;
     uint32_t has_vnet_hdr;
     uint8_t has_ufo;
     struct {
         VirtQueueElement elem;
         ssize_t len;
-    } async_tx;
+    } *async_tx;
     int mergeable_rx_bufs;
     uint8_t promisc;
     uint8_t allmulti;
@@ -61,6 +61,7 @@ typedef struct VirtIONet
     } mac_table;
     uint32_t *vlans;
     DeviceState *qdev;
+    uint16_t numtxqs;
 } VirtIONet;
 
 /* TODO
@@ -78,6 +79,7 @@ static void virtio_net_get_config(VirtIO
     struct virtio_net_config netcfg;
 
     netcfg.status = n->status;
+    netcfg.numtxqs = n->numtxqs;
     memcpy(netcfg.mac, n->mac, ETH_ALEN);
     memcpy(config, &netcfg, sizeof(netcfg));
 }
@@ -162,6 +164,8 @@ static uint32_t virtio_net_get_features(
     VirtIONet *n = to_virtio_net(vdev);
 
     features |= (1 << VIRTIO_NET_F_MAC);
+    if (n->numtxqs > 1)
+        features |= (1 << VIRTIO_NET_F_NUMTXQS);
 
     if (peer_has_vnet_hdr(n)) {
         tap_using_vnet_hdr(n->nic->nc.peer, 1);
@@ -625,13 +629,16 @@ static void virtio_net_tx_complete(VLANC
 {
     VirtIONet *n = DO_UPCAST(NICState, nc, nc)->opaque;
 
-    virtqueue_push(n->tx_vq, &n->async_tx.elem, n->async_tx.len);
-    virtio_notify(&n->vdev, n->tx_vq);
+    /*
+     * If this function executes, we are single TX and hence use only txq[0]
+     */
+    virtqueue_push(n->tx_vq[0], &n->async_tx[0].elem, n->async_tx[0].len);
+    virtio_notify(&n->vdev, n->tx_vq[0]);
 
-    n->async_tx.elem.out_num = n->async_tx.len = 0;
+    n->async_tx[0].elem.out_num = n->async_tx[0].len = 0;
 
-    virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    virtio_queue_set_notification(n->tx_vq[0], 1);
+    virtio_net_flush_tx(n, n->tx_vq[0]);
 }
 
 /* TX */
@@ -642,8 +649,8 @@ static void virtio_net_flush_tx(VirtIONe
     if (!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
         return;
 
-    if (n->async_tx.elem.out_num) {
-        virtio_queue_set_notification(n->tx_vq, 0);
+    if (n->async_tx[0].elem.out_num) {
+        virtio_queue_set_notification(n->tx_vq[0], 0);
         return;
     }
 
@@ -678,9 +685,9 @@ static void virtio_net_flush_tx(VirtIONe
         ret = qemu_sendv_packet_async(&n->nic->nc, out_sg, out_num,
                                       virtio_net_tx_complete);
         if (ret == 0) {
-            virtio_queue_set_notification(n->tx_vq, 0);
-            n->async_tx.elem = elem;
-            n->async_tx.len  = len;
+            virtio_queue_set_notification(n->tx_vq[0], 0);
+            n->async_tx[0].elem = elem;
+            n->async_tx[0].len  = len;
             return;
         }
 
@@ -695,15 +702,15 @@ static void virtio_net_handle_tx(VirtIOD
 {
     VirtIONet *n = to_virtio_net(vdev);
 
-    if (n->tx_timer_active) {
+    if (n->tx_timer_active[0]) {
         virtio_queue_set_notification(vq, 1);
-        qemu_del_timer(n->tx_timer);
-        n->tx_timer_active = 0;
+        qemu_del_timer(n->tx_timer[0]);
+        n->tx_timer_active[0] = 0;
         virtio_net_flush_tx(n, vq);
     } else {
-        qemu_mod_timer(n->tx_timer,
+        qemu_mod_timer(n->tx_timer[0],
                        qemu_get_clock(vm_clock) + TX_TIMER_INTERVAL);
-        n->tx_timer_active = 1;
+        n->tx_timer_active[0] = 1;
         virtio_queue_set_notification(vq, 0);
     }
 }
@@ -712,18 +719,19 @@ static void virtio_net_tx_timer(void *op
 {
     VirtIONet *n = opaque;
 
-    n->tx_timer_active = 0;
+    n->tx_timer_active[0] = 0;
 
     /* Just in case the driver is not ready on more */
     if (!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
         return;
 
-    virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    virtio_queue_set_notification(n->tx_vq[0], 1);
+    virtio_net_flush_tx(n, n->tx_vq[0]);
 }
 
 static void virtio_net_save(QEMUFile *f, void *opaque)
 {
+    int i;
     VirtIONet *n = opaque;
 
     if (n->vhost_started) {
@@ -735,7 +743,9 @@ static void virtio_net_save(QEMUFile *f,
     virtio_save(&n->vdev, f);
 
     qemu_put_buffer(f, n->mac, ETH_ALEN);
-    qemu_put_be32(f, n->tx_timer_active);
+    qemu_put_be16(f, n->numtxqs);
+    for (i = 0; i < n->numtxqs; i++)
+        qemu_put_be32(f, n->tx_timer_active[i]);
     qemu_put_be32(f, n->mergeable_rx_bufs);
     qemu_put_be16(f, n->status);
     qemu_put_byte(f, n->promisc);
@@ -764,7 +774,9 @@ static int virtio_net_load(QEMUFile *f, 
     virtio_load(&n->vdev, f);
 
     qemu_get_buffer(f, n->mac, ETH_ALEN);
-    n->tx_timer_active = qemu_get_be32(f);
+    n->numtxqs = qemu_get_be16(f);
+    for (i = 0; i < n->numtxqs; i++)
+        n->tx_timer_active[i] = qemu_get_be32(f);
     n->mergeable_rx_bufs = qemu_get_be32(f);
 
     if (version_id >= 3)
@@ -840,9 +852,10 @@ static int virtio_net_load(QEMUFile *f, 
     }
     n->mac_table.first_multi = i;
 
-    if (n->tx_timer_active) {
-        qemu_mod_timer(n->tx_timer,
-                       qemu_get_clock(vm_clock) + TX_TIMER_INTERVAL);
+    for (i = 0; i < n->numtxqs; i++) {
+        if (n->tx_timer_active[i])
+            qemu_mod_timer(n->tx_timer[i],
+                           qemu_get_clock(vm_clock) + TX_TIMER_INTERVAL);
     }
     return 0;
 }
@@ -905,12 +918,15 @@ static void virtio_net_vmstate_change(vo
 
 VirtIODevice *virtio_net_init(DeviceState *dev, NICConf *conf)
 {
+    int i;
     VirtIONet *n;
 
     n = (VirtIONet *)virtio_common_init("virtio-net", VIRTIO_ID_NET,
                                         sizeof(struct virtio_net_config),
                                         sizeof(VirtIONet));
 
+    n->numtxqs = conf->peer->numtxqs;
+
     n->vdev.get_config = virtio_net_get_config;
     n->vdev.set_config = virtio_net_set_config;
     n->vdev.get_features = virtio_net_get_features;
@@ -918,8 +934,24 @@ VirtIODevice *virtio_net_init(DeviceStat
     n->vdev.bad_features = virtio_net_bad_features;
     n->vdev.reset = virtio_net_reset;
     n->vdev.set_status = virtio_net_set_status;
+
     n->rx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_rx);
-    n->tx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_tx);
+
+    n->tx_vq = qemu_mallocz(n->numtxqs * sizeof(*n->tx_vq));
+    n->tx_timer = qemu_mallocz(n->numtxqs * sizeof(*n->tx_timer));
+    n->tx_timer_active = qemu_mallocz(n->numtxqs * sizeof(*n->tx_timer_active));
+    n->async_tx = qemu_mallocz(n->numtxqs * sizeof(*n->async_tx));
+
+    /* Allocate per tx vq's */
+    for (i = 0; i < n->numtxqs; i++) {
+        n->tx_vq[i] = virtio_add_queue(&n->vdev, 256, virtio_net_handle_tx);
+
+        /* setup timer per tx vq */
+        n->tx_timer[i] = qemu_new_timer(vm_clock, virtio_net_tx_timer, n);
+        n->tx_timer_active[i] = 0;
+    }
+
+    /* Allocate control vq */
     n->ctrl_vq = virtio_add_queue(&n->vdev, 64, virtio_net_handle_ctrl);
     qemu_macaddr_default_if_unset(&conf->macaddr);
     memcpy(&n->mac[0], &conf->macaddr, sizeof(n->mac));
@@ -929,8 +961,6 @@ VirtIODevice *virtio_net_init(DeviceStat
 
     qemu_format_nic_info_str(&n->nic->nc, conf->macaddr.a);
 
-    n->tx_timer = qemu_new_timer(vm_clock, virtio_net_tx_timer, n);
-    n->tx_timer_active = 0;
     n->mergeable_rx_bufs = 0;
     n->promisc = 1; /* for compatibility */
 
@@ -948,6 +978,7 @@ VirtIODevice *virtio_net_init(DeviceStat
 
 void virtio_net_exit(VirtIODevice *vdev)
 {
+    int i;
     VirtIONet *n = DO_UPCAST(VirtIONet, vdev, vdev);
     qemu_del_vm_change_state_handler(n->vmstate);
 
@@ -962,8 +993,10 @@ void virtio_net_exit(VirtIODevice *vdev)
     qemu_free(n->mac_table.macs);
     qemu_free(n->vlans);
 
-    qemu_del_timer(n->tx_timer);
-    qemu_free_timer(n->tx_timer);
+    for (i = 0; i < n->numtxqs; i++) {
+        qemu_del_timer(n->tx_timer[i]);
+        qemu_free_timer(n->tx_timer[i]);
+    }
 
     virtio_cleanup(&n->vdev);
     qemu_del_vlan_client(&n->nic->nc);
diff -ruNp org/hw/virtio-net.h new/hw/virtio-net.h
--- org/hw/virtio-net.h	2010-07-01 11:42:09.000000000 +0530
+++ new/hw/virtio-net.h	2010-09-08 12:54:50.000000000 +0530
@@ -22,6 +22,9 @@
 
 /* from Linux's virtio_net.h */
 
+/* The maximum of transmit (& separate receive) queues supported */
+#define VIRTIO_MAX_TXQS		16
+
 /* The ID for virtio_net */
 #define VIRTIO_ID_NET   1
 
@@ -44,6 +47,7 @@
 #define VIRTIO_NET_F_CTRL_RX    18      /* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN  19      /* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20   /* Extra RX mode control support */
+#define VIRTIO_NET_F_NUMTXQS    21      /* Supports multiple TX queues */
 
 #define VIRTIO_NET_S_LINK_UP    1       /* Link is up */
 
@@ -58,6 +62,7 @@ struct virtio_net_config
     uint8_t mac[ETH_ALEN];
     /* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
     uint16_t status;
+    uint16_t numtxqs;	/* number of transmit queues */
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
diff -ruNp org/hw/virtio-pci.c new/hw/virtio-pci.c
--- org/hw/virtio-pci.c	2010-09-08 12:46:36.000000000 +0530
+++ new/hw/virtio-pci.c	2010-09-08 12:54:50.000000000 +0530
@@ -99,6 +99,7 @@ typedef struct {
     uint32_t addr;
     uint32_t class_code;
     uint32_t nvectors;
+    uint32_t mq;
     BlockConf block;
     NICConf nic;
     uint32_t host_features;
@@ -722,6 +723,7 @@ static PCIDeviceInfo virtio_info[] = {
         .romfile    = "pxe-virtio.bin",
         .qdev.props = (Property[]) {
             DEFINE_PROP_UINT32("vectors", VirtIOPCIProxy, nvectors, 3),
+	    DEFINE_PROP_UINT32("mq", VirtIOPCIProxy, mq, 1),
             DEFINE_VIRTIO_NET_FEATURES(VirtIOPCIProxy, host_features),
             DEFINE_NIC_PROPERTIES(VirtIOPCIProxy, nic),
             DEFINE_PROP_END_OF_LIST(),
diff -ruNp org/net/tap.c new/net/tap.c
--- org/net/tap.c	2010-07-01 11:42:09.000000000 +0530
+++ new/net/tap.c	2010-09-08 12:54:50.000000000 +0530
@@ -249,7 +249,7 @@ void tap_set_offload(VLANClientState *nc
 {
     TAPState *s = DO_UPCAST(TAPState, nc, nc);
 
-    return tap_fd_set_offload(s->fd, csum, tso4, tso6, ecn, ufo);
+    tap_fd_set_offload(s->fd, csum, tso4, tso6, ecn, ufo);
 }
 
 static void tap_cleanup(VLANClientState *nc)
@@ -262,8 +262,9 @@ static void tap_cleanup(VLANClientState 
 
     qemu_purge_queued_packets(nc);
 
-    if (s->down_script[0])
+    if (s->down_script[0]) {
         launch_script(s->down_script, s->down_script_arg, s->fd);
+    }
 
     tap_read_poll(s, 0);
     tap_write_poll(s, 0);
@@ -299,13 +300,14 @@ static NetClientInfo net_tap_info = {
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
 
@@ -368,6 +370,7 @@ static int net_tap_init(QemuOpts *opts, 
     int fd, vnet_hdr_required;
     char ifname[128] = {0,};
     const char *setup_script;
+    int launch = 0;
 
     if (qemu_opt_get(opts, "ifname")) {
         pstrcpy(ifname, sizeof(ifname), qemu_opt_get(opts, "ifname"));
@@ -380,29 +383,57 @@ static int net_tap_init(QemuOpts *opts, 
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
+        strcmp(setup_script, "no") != 0) {
+         launch = 1;
+    }
+
+    TFR(fd = tap_open(ifname, sizeof(ifname), vnet_hdr,
+                          vnet_hdr_required));
+    if (fd < 0) {
         return -1;
     }
 
+    if (launch && launch_script(setup_script, ifname, fd))
+        goto err;
+
     qemu_opt_set(opts, "ifname", ifname);
 
     return fd;
+
+err:
+    close(fd);
+
+    return -1;
 }
 
 int net_init_tap(QemuOpts *opts, Monitor *mon, const char *name, VLANState *vlan)
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
+#define VIRTIO_MAX_TXQS		16
+            int dflt = MIN(smp_cpus, VIRTIO_MAX_TXQS);
+
+            numtxqs = qemu_opt_get_number(opts, "numtxqs", dflt);
+        }
+    }
 
     if (qemu_opt_get(opts, "fd")) {
         if (qemu_opt_get(opts, "ifname") ||
@@ -436,14 +467,14 @@ int net_init_tap(QemuOpts *opts, Monitor
         }
     }
 
-    s = net_tap_fd_init(vlan, "tap", name, fd, vnet_hdr);
+    s = net_tap_fd_init(vlan, "tap", name, fd, numtxqs, vnet_hdr);
     if (!s) {
         close(fd);
         return -1;
     }
 
     if (tap_set_sndbuf(s->fd, opts) < 0) {
-        return -1;
+            return -1;
     }
 
     if (qemu_opt_get(opts, "fd")) {
@@ -465,7 +496,7 @@ int net_init_tap(QemuOpts *opts, Monitor
         }
     }
 
-    if (qemu_opt_get_bool(opts, "vhost", !!qemu_opt_get(opts, "vhostfd"))) {
+    if (vhost) {
         int vhostfd, r;
         if (qemu_opt_get(opts, "vhostfd")) {
             r = net_handle_fd_param(mon, qemu_opt_get(opts, "vhostfd"));
@@ -476,7 +507,7 @@ int net_init_tap(QemuOpts *opts, Monitor
         } else {
             vhostfd = -1;
         }
-        s->vhost_net = vhost_net_init(&s->nc, vhostfd);
+        s->vhost_net = vhost_net_init(&s->nc, vhostfd, numtxqs);
         if (!s->vhost_net) {
             error_report("vhost-net requested but could not be initialized");
             return -1;
diff -ruNp org/net.c new/net.c
--- org/net.c	2010-09-08 12:46:36.000000000 +0530
+++ new/net.c	2010-09-08 12:54:50.000000000 +0530
@@ -814,6 +814,15 @@ static int net_init_nic(QemuOpts *opts,
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
 
@@ -957,6 +966,14 @@ static const struct {
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
diff -ruNp org/net.h new/net.h
--- org/net.h	2010-07-01 11:42:09.000000000 +0530
+++ new/net.h	2010-09-08 12:54:50.000000000 +0530
@@ -62,6 +62,7 @@ struct VLANClientState {
     struct VLANState *vlan;
     VLANClientState *peer;
     NetQueue *send_queue;
+    int numtxqs;
     char *model;
     char *name;
     char info_str[256];
