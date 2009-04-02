From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 11:09:35 -0500
Message-ID: <49D4E33F.5000303@codemonkey.ws>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060302060900030103090505"
Cc: Gregory Haskins <ghaskins@novell.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:35796 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761714AbZDBQKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 12:10:13 -0400
In-Reply-To: <49D4D075.9010702@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060302060900030103090505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Anthony Liguori wrote:
> Avi Kivity wrote:
>> Avi Kivity wrote:
>>>
>>> The alternative is to get a notification from the stack that the 
>>> packet is done processing.  Either an skb destructor in the kernel, 
>>> or my new API that everyone is not rushing out to implement.
>>
>> btw, my new api is
>>
>>
>>   io_submit(..., nr, ...): submit nr packets
>>   io_getevents(): complete nr packets
>
> I don't think we even need that to end this debate.  I'm convinced we 
> have a bug somewhere.  Even disabling TX mitigation, I see a ping 
> latency of around 300ns whereas it's only 50ns on the host.  This 
> defies logic so I'm now looking to isolate why that is.

I'm down to 90us.  Obviously, s/ns/us/g above.  The exec.c changes were 
the big winner... I hate qemu sometimes.

I'm pretty confident I can get at least to Greg's numbers with some 
poking.  I think I understand why he's doing better after reading his 
patches carefully but I also don't think it'll scale with many guests 
well...  stay tuned.

But most importantly, we are darn near where vbus is with this patch wrt 
added packet latency and this is totally from userspace with no host 
kernel changes.

So no, userspace is not the issue.

Regards,

Anthony Liguori

> Regards,
>
> Anthony Liguori
>


--------------060302060900030103090505
Content-Type: text/x-patch;
 name="first-pass.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="first-pass.patch"

diff --git a/qemu/exec.c b/qemu/exec.c
index 67f3fa3..1331022 100644
--- a/qemu/exec.c
+++ b/qemu/exec.c
@@ -3268,6 +3268,10 @@ uint32_t ldl_phys(target_phys_addr_t addr)
     unsigned long pd;
     PhysPageDesc *p;
 
+#if 1
+    return ldl_p(phys_ram_base + addr);
+#endif
+
     p = phys_page_find(addr >> TARGET_PAGE_BITS);
     if (!p) {
         pd = IO_MEM_UNASSIGNED;
@@ -3300,6 +3304,10 @@ uint64_t ldq_phys(target_phys_addr_t addr)
     unsigned long pd;
     PhysPageDesc *p;
 
+#if 1
+    return ldq_p(phys_ram_base + addr);
+#endif
+
     p = phys_page_find(addr >> TARGET_PAGE_BITS);
     if (!p) {
         pd = IO_MEM_UNASSIGNED;
diff --git a/qemu/hw/virtio-net.c b/qemu/hw/virtio-net.c
index 9bce3a0..ac77b80 100644
--- a/qemu/hw/virtio-net.c
+++ b/qemu/hw/virtio-net.c
@@ -36,6 +36,7 @@ typedef struct VirtIONet
     VirtQueue *ctrl_vq;
     VLANClientState *vc;
     QEMUTimer *tx_timer;
+    QEMUBH *bh;
     int tx_timer_active;
     int mergeable_rx_bufs;
     int promisc;
@@ -504,6 +505,10 @@ static void virtio_net_receive(void *opaque, const uint8_t *buf, int size)
     virtio_notify(&n->vdev, n->rx_vq);
 }
 
+VirtIODevice *global_vdev = NULL;
+
+extern void tap_try_to_recv(VLANClientState *vc);
+
 /* TX */
 static void virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq)
 {
@@ -545,42 +550,35 @@ static void virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq)
             len += hdr_len;
         }
 
+        global_vdev = &n->vdev;
         len += qemu_sendv_packet(n->vc, out_sg, out_num);
+        global_vdev = NULL;
 
         virtqueue_push(vq, &elem, len);
         virtio_notify(&n->vdev, vq);
     }
+
+    tap_try_to_recv(n->vc->vlan->first_client);
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
+#if 0
+    virtio_queue_set_notification(vq, 0);
+    qemu_bh_schedule(n->bh);
+#else
+    virtio_net_flush_tx(n, n->tx_vq);
+#endif
 }
 
-static void virtio_net_tx_timer(void *opaque)
+static void virtio_net_handle_tx_bh(void *opaque)
 {
     VirtIONet *n = opaque;
 
-    n->tx_timer_active = 0;
-
-    /* Just in case the driver is not ready on more */
-    if (!(n->vdev.status & VIRTIO_CONFIG_S_DRIVER_OK))
-        return;
-
-    virtio_queue_set_notification(n->tx_vq, 1);
     virtio_net_flush_tx(n, n->tx_vq);
+    virtio_queue_set_notification(n->tx_vq, 1);
 }
 
 static void virtio_net_save(QEMUFile *f, void *opaque)
@@ -675,8 +673,8 @@ PCIDevice *virtio_net_init(PCIBus *bus, NICInfo *nd, int devfn)
     n->vdev.get_features = virtio_net_get_features;
     n->vdev.set_features = virtio_net_set_features;
     n->vdev.reset = virtio_net_reset;
-    n->rx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_rx);
-    n->tx_vq = virtio_add_queue(&n->vdev, 256, virtio_net_handle_tx);
+    n->rx_vq = virtio_add_queue(&n->vdev, 512, virtio_net_handle_rx);
+    n->tx_vq = virtio_add_queue(&n->vdev, 512, virtio_net_handle_tx);
     n->ctrl_vq = virtio_add_queue(&n->vdev, 16, virtio_net_handle_ctrl);
     memcpy(n->mac, nd->macaddr, ETH_ALEN);
     n->status = VIRTIO_NET_S_LINK_UP;
@@ -684,10 +682,10 @@ PCIDevice *virtio_net_init(PCIBus *bus, NICInfo *nd, int devfn)
                                  virtio_net_receive, virtio_net_can_receive, n);
     n->vc->link_status_changed = virtio_net_set_link_status;
 
+    n->bh = qemu_bh_new(virtio_net_handle_tx_bh, n);
+
     qemu_format_nic_info_str(n->vc, n->mac);
 
-    n->tx_timer = qemu_new_timer(vm_clock, virtio_net_tx_timer, n);
-    n->tx_timer_active = 0;
     n->mergeable_rx_bufs = 0;
     n->promisc = 1; /* for compatibility */
 
diff --git a/qemu/hw/virtio.c b/qemu/hw/virtio.c
index 577eb5a..1365d11 100644
--- a/qemu/hw/virtio.c
+++ b/qemu/hw/virtio.c
@@ -507,6 +507,39 @@ static void virtio_reset(void *opaque)
     }
 }
 
+void virtio_sample_start(VirtIODevice *vdev)
+{
+    vdev->n_samples = 0;
+    virtio_sample(vdev);
+}
+
+void virtio_sample(VirtIODevice *vdev)
+{
+    gettimeofday(&vdev->samples[vdev->n_samples], NULL);
+    vdev->n_samples++;
+}
+
+static unsigned long usec_delta(struct timeval *before, struct timeval *after)
+{
+    return (after->tv_sec - before->tv_sec) * 1000000UL + (after->tv_usec - before->tv_usec);
+}
+
+void virtio_sample_end(VirtIODevice *vdev)
+{
+    int last, i;
+
+    virtio_sample(vdev);
+
+    last = vdev->n_samples - 1;
+
+    printf("Total time = %ldus\n", usec_delta(&vdev->samples[0], &vdev->samples[last]));
+
+    for (i = 1; i < vdev->n_samples; i++)
+        printf("sample[%d .. %d] = %ldus\n", i - 1, i, usec_delta(&vdev->samples[i - 1], &vdev->samples[i]));
+
+    vdev->n_samples = 0;
+}
+
 static void virtio_ioport_write(void *opaque, uint32_t addr, uint32_t val)
 {
     VirtIODevice *vdev = to_virtio_device(opaque);
diff --git a/qemu/hw/virtio.h b/qemu/hw/virtio.h
index 18c7a1a..a039310 100644
--- a/qemu/hw/virtio.h
+++ b/qemu/hw/virtio.h
@@ -17,6 +17,8 @@
 #include "hw.h"
 #include "pci.h"
 
+#include <sys/time.h>
+
 /* from Linux's linux/virtio_config.h */
 
 /* Status byte for guest to report progress, and synchronize features. */
@@ -87,6 +89,8 @@ struct VirtIODevice
     void (*set_config)(VirtIODevice *vdev, const uint8_t *config);
     void (*reset)(VirtIODevice *vdev);
     VirtQueue *vq;
+    int n_samples;
+    struct timeval samples[100];
 };
 
 VirtIODevice *virtio_init_pci(PCIBus *bus, const char *name,
@@ -122,4 +126,10 @@ int virtio_queue_ready(VirtQueue *vq);
 
 int virtio_queue_empty(VirtQueue *vq);
 
+void virtio_sample_start(VirtIODevice *vdev);
+
+void virtio_sample(VirtIODevice *vdev);
+
+void virtio_sample_end(VirtIODevice *vdev);
+
 #endif
diff --git a/qemu/net.c b/qemu/net.c
index efb64d3..dc872e5 100644
--- a/qemu/net.c
+++ b/qemu/net.c
@@ -733,6 +733,7 @@ typedef struct TAPState {
 } TAPState;
 
 #ifdef HAVE_IOVEC
+
 static ssize_t tap_receive_iov(void *opaque, const struct iovec *iov,
                                int iovcnt)
 {
@@ -853,6 +854,12 @@ static void tap_send(void *opaque)
     } while (s->size > 0);
 }
 
+void tap_try_to_recv(VLANClientState *vc)
+{
+    TAPState *s = vc->opaque;
+    tap_send(s);
+}
+
 int tap_has_vnet_hdr(void *opaque)
 {
     VLANClientState *vc = opaque;

--------------060302060900030103090505--
