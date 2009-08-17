From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: AlacrityVM numbers updated for 31-rc4
Date: Mon, 17 Aug 2009 14:06:59 +0300
Message-ID: <20090817110659.GA10128@redhat.com>
References: <4A83296B.3080606@gmail.com> <4A834ABB.4010801@codemonkey.ws> <4A834E75.9060204@gmail.com> <4A85BFF8.4050001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	alacrityvm-devel@lists.sourceforge.net,
	alacrityvm-users@lists.sourceforge.net,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757730AbZHQLIh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A85BFF8.4050001@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 14, 2009 at 03:50:16PM -0400, Gregory Haskins wrote:
> Gregory Haskins wrote:
> > Anthony Liguori wrote:
> >> Gregory Haskins wrote:
> >>> I re-ran the numbers on 10GE against the actual alacrityvm v0.1 release
> >>> available in git on kernel.org.
> >>>
> >>> I tried to include the newly announced "vhost" driver (Michael Tsirkin)
> >>> for virtio acceleration, but ran into issues getting the patches to
> >>> apply.
> >>>
> >>> For now, this includes native, virtio-u (virtio-userspace), and venet
> >>> all running on 31-rc4.  If I can resolve the issue with Michaels
> >>> patches, I will add "virtio-k" (virtio-kernel) to the mix as well.  For
> >>> now, here are the results for 1500mtu:
> >>>
> >>> native:   7388Mb/s,   29.8us rtt (33505 tps udp-rr)
> >>> venet:    3654Mb/s,   56.8us rtt (17600 tps udp-rr)
> >>> virtio-u: 1955Mb/s, 4016.0us rtt (  249 tps udp-rr)
> >>>   
> 
> I re-ran the numbers now that I have the HRT issue straighted out.
> Native and virtio stayed level, venet recovered from the 3.6Gb/s
> quagmire it was in, back up to ~4.5Gb/s.
> 
> native (hw):        7388Mb/s,  29.8us rtt (33500 tps udp-rr)
> venet (alacrityvm): 4560Mb/s,  56.8us rtt (17600 tps udp-rr)
> virtio-u (kvm):	    2670Mb/s, 265.7us rtt ( 3764 tps udp-rr)
> virtio-k (kvm):     d-n-f
> 
> (still having problems getting vhost to run).  Will try again next week.)
> 
> I have updated the graphs on the wiki:
> 
> http://developer.novell.com/wiki/index.php/AlacrityVM
> 
> Have a nice weekend, all.
> 
> -Greg
> 
> 

Hi Greg,
could you check what does disabling tx timer completely do to virtio-u
performance?  Here's a patch from Mark McLoughlin do this this:
it works and seems to improve latency for me.


From: Mark McLoughlin <markmc@redhat.com>
Subject: virtio_net: remove the tx mitigation timer
    
The tx mitigation timer is designed to reduce the rate of guest exits
thereby improving throughput. However, we have identified a number of
cases where mitigation hurts throughput and benchmarking has shown that
it only helps throughput in a very limited number of cases.

This patch firstly removes the timer and replaces it with a bottom half.
When the host is notified of a packet on the tx queue, it schedules a
bottom half in the I/O thread in order to flush the queue.

Next, it disables enabling notifications until it has flushed the queue.
In order to avoid a race condition with this, it flushes the queue a
second time when notifications are re-enabled.

Finally, if it successfully flushed a number of packets in the bottom
half, it disables notifications re-schedules the bottom half to quickly
flush the queue again.

Migration is handled by equating the tx_timer_active savevm field to
tx_bh_scheduled.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>

---

diff --git a/hw/virtio-net.c b/hw/virtio-net.c
index 95d9f93..835f4e1 100644
--- a/hw/virtio-net.c
+++ b/hw/virtio-net.c
@@ -37,8 +37,8 @@ typedef struct VirtIONet
     VirtQueue *tx_vq;
     VirtQueue *ctrl_vq;
     VLANClientState *vc;
-    QEMUTimer *tx_timer;
-    int tx_timer_active;
+    QEMUBH *tx_bh;
+    int tx_bh_scheduled;
     struct {
         VirtQueueElement elem;
         ssize_t len;
@@ -591,7 +591,7 @@ static ssize_t virtio_net_receive2(VLANClientState *vc, const uint8_t *buf, size
     return size;
 }
 
-static void virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq);
+static int virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq, int enable_notify);
 
 static void virtio_net_tx_complete(VLANClientState *vc, ssize_t len)
 {
@@ -603,7 +603,7 @@ static void virtio_net_tx_complete(VLANClientState *vc, ssize_t len)
     n->async_tx.elem.out_num = n->async_tx.len = 0;
 
     virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    virtio_net_flush_tx(n, n->tx_vq, 0);
 }
 
 static ssize_t virtio_net_receive(VLANClientState *vc, const uint8_t *buf, size_t size)
@@ -617,9 +617,10 @@ static ssize_t virtio_net_receive_raw(VLANClientState *vc, const uint8_t *buf, s
 }
 
 /* TX */
-static void virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq)
+static int virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq, int enable_notify)
 {
     VirtQueueElement elem;
+    int num_packets = 0;
 #ifdef TAP_VNET_HDR
     int has_vnet_hdr = tap_has_vnet_hdr(n->vc->vlan->first_client);
 #else
@@ -629,11 +630,11 @@ static void virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq)
 	    return;
 
     if (!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
-        return;
+        return num_packets;
 
     if (n->async_tx.elem.out_num) {
         virtio_queue_set_notification(n->tx_vq, 0);
-        return;
+        return num_packets;
     }
 
     while (virtqueue_pop(vq, &elem)) {
@@ -670,45 +671,48 @@ static void virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq)
             virtio_queue_set_notification(n->tx_vq, 0);
             n->async_tx.elem = elem;
             n->async_tx.len  = len;
-            return;
+            return num_packets;
         }
 
         len += ret;
 
         virtqueue_push(vq, &elem, len);
         virtio_notify(&n->vdev, vq);
+
+        num_packets++;
+    }
+
+    if (enable_notify) {
+        virtio_queue_set_notification(vq, 1);
+        num_packets += virtio_net_flush_tx(n, vq, 0);
     }
+
+    return num_packets;
 }
 
 static void virtio_net_handle_tx(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIONet *n = to_virtio_net(vdev);
 
-    if (n->tx_timer_active) {
-        virtio_queue_set_notification(vq, 1);
-        qemu_del_timer(n->tx_timer);
-        n->tx_timer_active = 0;
-        virtio_net_flush_tx(n, vq);
-    } else {
-        qemu_mod_timer(n->tx_timer,
-                       qemu_get_clock(vm_clock) + TX_TIMER_INTERVAL);
-        n->tx_timer_active = 1;
-        virtio_queue_set_notification(vq, 0);
-    }
+    if (n->tx_bh_scheduled)
+        return;
+
+    virtio_queue_set_notification(n->tx_vq, 0);
+    qemu_bh_schedule(n->tx_bh);
+    n->tx_bh_scheduled = 1;
 }
 
-static void virtio_net_tx_timer(void *opaque)
+static void virtio_net_tx_bh(void *opaque)
 {
     VirtIONet *n = opaque;
 
-    n->tx_timer_active = 0;
-
-    /* Just in case the driver is not ready on more */
-    if (!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
-        return;
+    n->tx_bh_scheduled = 0;
 
-    virtio_queue_set_notification(n->tx_vq, 1);
-    virtio_net_flush_tx(n, n->tx_vq);
+    if (virtio_net_flush_tx(n, n->tx_vq, 1)) {
+        virtio_queue_set_notification(n->tx_vq, 0);
+        qemu_bh_schedule(n->tx_bh);
+        n->tx_bh_scheduled = 1;
+    }
 }
 
 static void virtio_net_save(QEMUFile *f, void *opaque)
@@ -718,7 +722,7 @@ static void virtio_net_save(QEMUFile *f, void *opaque)
     virtio_save(&n->vdev, f);
 
     qemu_put_buffer(f, n->mac, ETH_ALEN);
-    qemu_put_be32(f, n->tx_timer_active);
+    qemu_put_be32(f, n->tx_bh_scheduled);
     qemu_put_be32(f, n->mergeable_rx_bufs);
     qemu_put_be16(f, n->status);
     qemu_put_byte(f, n->promisc);
@@ -752,7 +756,7 @@ static int virtio_net_load(QEMUFile *f, void *opaque, int version_id)
     virtio_load(&n->vdev, f);
 
     qemu_get_buffer(f, n->mac, ETH_ALEN);
-    n->tx_timer_active = qemu_get_be32(f);
+    n->tx_bh_scheduled = qemu_get_be32(f);
     n->mergeable_rx_bufs = qemu_get_be32(f);
 
     if (version_id >= 3)
@@ -814,9 +818,8 @@ static int virtio_net_load(QEMUFile *f, void *opaque, int version_id)
     }
     n->mac_table.first_multi = i;
 
-    if (n->tx_timer_active) {
-        qemu_mod_timer(n->tx_timer,
-                       qemu_get_clock(vm_clock) + TX_TIMER_INTERVAL);
+    if (n->tx_bh_scheduled) {
+        qemu_bh_schedule(n->tx_bh);
     }
 
     return 0;
@@ -833,9 +836,6 @@ static void virtio_net_cleanup(VLANClientState *vc)
     qemu_free(n->mac_table.macs);
     qemu_free(n->vlans);
 
-    qemu_del_timer(n->tx_timer);
-    qemu_free_timer(n->tx_timer);
-
     virtio_cleanup(&n->vdev);
 }
 
@@ -881,8 +881,8 @@ VirtIODevice *virtio_net_init(DeviceState *dev)
 
     qemu_format_nic_info_str(n->vc, n->mac);
 
-    n->tx_timer = qemu_new_timer(vm_clock, virtio_net_tx_timer, n);
-    n->tx_timer_active = 0;
+    n->tx_bh = qemu_bh_new(virtio_net_tx_bh, n);
+    n->tx_bh_scheduled = 0;
     n->mergeable_rx_bufs = 0;
     n->promisc = 1; /* for compatibility */
 
diff --git a/hw/virtio-net.h b/hw/virtio-net.h
index 2085181..add7815 100644
--- a/hw/virtio-net.h
+++ b/hw/virtio-net.h
@@ -47,8 +47,6 @@
 
 #define VIRTIO_NET_S_LINK_UP    1       /* Link is up */
 
-#define TX_TIMER_INTERVAL 150000 /* 150 us */
-
 /* Maximum packet size we can receive from tap device: header + 64k */
 #define VIRTIO_NET_MAX_BUFSIZE (sizeof(struct virtio_net_hdr) + (64 << 10))
 
