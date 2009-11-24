From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
	and big packets in virtio_net
Date: Tue, 24 Nov 2009 13:37:54 +0200
Message-ID: <20091124113754.GB2405@redhat.com>
References: <1258697745.7416.20.camel@localhost.localdomain> <200911231138.30755.rusty@rustcorp.com.au> <1258992421.5022.19.camel@localhost.localdomain> <200911240854.24054.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hollis Blanchard <hollisb@us.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932572AbZKXLko@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200911240854.24054.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2009 at 08:54:23AM +1030, Rusty Russell wrote:
> On Tue, 24 Nov 2009 02:37:01 am Shirley Ma wrote:
> > > > +             skb = (struct sk_buff *)buf;
> > > This cast is unnecessary, but a comment would be nice:
> > 
> > Without this cast there is a compile warning. 
> 
> Hi Shirley,
> 
>    Looks like buf is a void *, so no cast should be necessary.  But I could
> be reading the patch wrong.
> 
> > > However, I question whether making it 16 byte is the right thing: the
> > > ethernet header is 14 bytes long, so don't we want 8 bytes of padding?
> > 
> > Because in QEMU it requires 10 bytes header in a separately, so one page
> > is used to share between virtio_net_hdr header which is 10 bytes head
> > and rest of data. So I put 6 bytes offset here between two buffers. I
> > didn't look at the reason why a seperate buf is used for virtio_net_hdr
> > in QEMU.
> 
> It's a qemu bug.  It insists the header be an element in the scatterlist by
> itself.  Unfortunately we have to accommodate it.

We do?  Let's just fix this?
All we have to do is replace memcpy with proper iovec walk, correct?
Something like the followng (untested) patch?  It's probably not too
late to put this in the next qemu release...

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>


diff --git a/hw/virtio-net.c b/hw/virtio-net.c
index 2f147e5..06c5148 100644
--- a/hw/virtio-net.c
+++ b/hw/virtio-net.c
@@ -434,26 +434,59 @@ static int iov_fill(struct iovec *iov, int iovcnt, const void *buf, int count)
     return offset;
 }
 
+static int iov_skip(struct iovec *iov, int iovcnt, int count)
+{
+    int offset, i;
+
+    offset = i = 0;
+    while (offset < count && i < iovcnt) {
+        int len = MIN(iov[i].iov_len, count - offset);
+	iov[i].iov_base += len;
+	iov[i].iov_len -= len;
+        offset += len;
+        i++;
+    }
+
+    return offset;
+}
+
+static int iov_copy(struct iovec *to, struct iovec *from, int iovcnt, int count)
+{
+    int offset, i;
+
+    offset = i = 0;
+    while (offset < count && i < iovcnt) {
+        int len = MIN(from[i].iov_len, count - offset);
+	to[i].iov_base = from[i].iov_base;
+	to[i].iov_len = from[i].iov_len;
+        offset += len;
+        i++;
+    }
+
+    return i;
+}
+
 static int receive_header(VirtIONet *n, struct iovec *iov, int iovcnt,
                           const void *buf, size_t size, size_t hdr_len)
 {
-    struct virtio_net_hdr *hdr = (struct virtio_net_hdr *)iov[0].iov_base;
+    struct virtio_net_hdr hdr = {};
     int offset = 0;
 
-    hdr->flags = 0;
-    hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
+    hdr.flags = 0;
+    hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
 
     if (n->has_vnet_hdr) {
-        memcpy(hdr, buf, sizeof(*hdr));
-        offset = sizeof(*hdr);
-        work_around_broken_dhclient(hdr, buf + offset, size - offset);
+        memcpy(&hdr, buf, sizeof hdr);
+        offset = sizeof hdr;
+        work_around_broken_dhclient(&hdr, buf + offset, size - offset);
     }
 
+    iov_fill(iov, iovcnt, &hdr, sizeof hdr);
+
     /* We only ever receive a struct virtio_net_hdr from the tapfd,
      * but we may be passing along a larger header to the guest.
      */
-    iov[0].iov_base += hdr_len;
-    iov[0].iov_len  -= hdr_len;
+    iov_skip(iov, iovcnt, hdr_len);
 
     return offset;
 }
@@ -514,7 +547,8 @@ static int receive_filter(VirtIONet *n, const uint8_t *buf, int size)
 static ssize_t virtio_net_receive(VLANClientState *vc, const uint8_t *buf, size_t size)
 {
     VirtIONet *n = vc->opaque;
-    struct virtio_net_hdr_mrg_rxbuf *mhdr = NULL;
+    struct iovec mhdr[VIRTQUEUE_MAX_SIZE];
+    int mhdrcnt = 0;
     size_t hdr_len, offset, i;
 
     if (!virtio_net_can_receive(n->vc))
@@ -552,16 +586,13 @@ static ssize_t virtio_net_receive(VLANClientState *vc, const uint8_t *buf, size_
             exit(1);
         }
 
-        if (!n->mergeable_rx_bufs && elem.in_sg[0].iov_len != hdr_len) {
-            fprintf(stderr, "virtio-net header not in first element\n");
-            exit(1);
-        }
-
         memcpy(&sg, &elem.in_sg[0], sizeof(sg[0]) * elem.in_num);
 
         if (i == 0) {
-            if (n->mergeable_rx_bufs)
-                mhdr = (struct virtio_net_hdr_mrg_rxbuf *)sg[0].iov_base;
+            if (n->mergeable_rx_bufs) {
+                mhdrcnt = iov_copy(mhdr, sg, elem.in_num,
+                                   sizeof(struct virtio_net_hdr_mrg_rxbuf));
+            }
 
             offset += receive_header(n, sg, elem.in_num,
                                      buf + offset, size - offset, hdr_len);
@@ -579,8 +610,12 @@ static ssize_t virtio_net_receive(VLANClientState *vc, const uint8_t *buf, size_
         offset += len;
     }
 
-    if (mhdr)
-        mhdr->num_buffers = i;
+    if (mhdrcnt) {
+        uint16_t num = i;
+        iov_skip(mhdr, mhdrcnt,
+                 offsetof(struct virtio_net_hdr_mrg_rxbuf, num_buffers));
+        iov_fill(mhdr, mhdrcnt, &num, sizeof num);
+    }
 
     virtqueue_flush(n->rx_vq, i);
     virtio_notify(&n->vdev, n->rx_vq);
@@ -627,20 +662,19 @@ static void virtio_net_flush_tx(VirtIONet *n, VirtQueue *vq)
             sizeof(struct virtio_net_hdr_mrg_rxbuf) :
             sizeof(struct virtio_net_hdr);
 
-        if (out_num < 1 || out_sg->iov_len != hdr_len) {
-            fprintf(stderr, "virtio-net header not in first element\n");
+        if (out_num < 1) {
+            fprintf(stderr, "virtio-net: no output element\n");
             exit(1);
         }
 
         /* ignore the header if GSO is not supported */
         if (!n->has_vnet_hdr) {
-            out_num--;
-            out_sg++;
+            iov_skip(out_sg, out_num, hdr_len);
             len += hdr_len;
         } else if (n->mergeable_rx_bufs) {
             /* tapfd expects a struct virtio_net_hdr */
             hdr_len -= sizeof(struct virtio_net_hdr);
-            out_sg->iov_len -= hdr_len;
+            iov_skip(out_sg, out_num, hdr_len);
             len += hdr_len;
         }
 
