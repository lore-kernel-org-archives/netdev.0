From: David Stevens <dlstevens@us.ibm.com>
Subject: [RFC][ PATCH 3/3] vhost-net: Add mergeable RX buffer support to vhost-net
Date: Tue, 2 Mar 2010 17:20:34 -0700
Message-ID: <OFD112C680.DB48ADA2-ON882576DB.0000CE4F-882576DB.0001E192@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0001E192882576DB_="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: mst@redhat.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:41107 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758313Ab0CCAUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 19:20:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 0001E192882576DB_=
Content-Type: text/plain; charset="US-ASCII"

This patch glues them all together and makes sure we
notify whenever we don't have enough buffers to receive
a max-sized packet, and adds the feature bit.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruN net-next-p2/drivers/vhost/net.c net-next-p3/drivers/vhost/net.c
--- net-next-p2/drivers/vhost/net.c     2010-03-02 13:01:34.000000000 
-0800
+++ net-next-p3/drivers/vhost/net.c     2010-03-02 15:25:15.000000000 
-0800
@@ -54,26 +54,6 @@
        enum vhost_net_poll_state tx_poll_state;
 };
 
-/* Pop first len bytes from iovec. Return number of segments used. */
-static int move_iovec_hdr(struct iovec *from, struct iovec *to,
-                         size_t len, int iov_count)
-{
-       int seg = 0;
-       size_t size;
-       while (len && seg < iov_count) {
-               size = min(from->iov_len, len);
-               to->iov_base = from->iov_base;
-               to->iov_len = size;
-               from->iov_len -= size;
-               from->iov_base += size;
-               len -= size;
-               ++from;
-               ++to;
-               ++seg;
-       }
-       return seg;
-}
-
 /* Caller must have TX VQ lock */
 static void tx_poll_stop(struct vhost_net *net)
 {
@@ -97,7 +77,7 @@
 static void handle_tx(struct vhost_net *net)
 {
        struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
-       unsigned out, in, s;
+       unsigned out, in;
        struct iovec head;
        struct msghdr msg = {
                .msg_name = NULL,
@@ -110,6 +90,7 @@
        size_t len, total_len = 0;
        int err, wmem;
        struct socket *sock = rcu_dereference(vq->private_data);
+
        if (!sock)
                return;
 
@@ -166,11 +147,11 @@
                /* Skip header. TODO: support TSO. */
                msg.msg_iovlen = out;
                head.iov_len = len = iov_length(vq->iov, out);
+
                /* Sanity check */
                if (!len) {
                        vq_err(vq, "Unexpected header len for TX: "
-                              "%zd expected %zd\n",
-                              len, vq->guest_hlen);
+                              "%zd expected %zd\n", len, vq->guest_hlen);
                        break;
                }
                /* TODO: Check specific error and bomb out unless ENOBUFS? 
*/
@@ -214,7 +195,7 @@
 static void handle_rx(struct vhost_net *net)
 {
        struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
-       unsigned in, log, s;
+       unsigned in, log;
        struct vhost_log *vq_log;
        struct msghdr msg = {
                .msg_name = NULL,
@@ -245,30 +226,36 @@
                if (!headcount) {
                        vhost_enable_notify(vq);
                        break;
-               }
+               } else if (vq->maxheadcount < headcount)
+                       vq->maxheadcount = headcount;
                /* Skip header. TODO: support TSO/mergeable rx buffers. */
                msg.msg_iovlen = in;
                len = iov_length(vq->iov, in);
-
                /* Sanity check */
                if (!len) {
                        vq_err(vq, "Unexpected header len for RX: "
-                              "%zd expected %zd\n",
-                              len, vq->guest_hlen);
+                              "%zd expected %zd\n", len, vq->guest_hlen);
                        break;
                }
                err = sock->ops->recvmsg(NULL, sock, &msg,
                                         len, MSG_DONTWAIT | MSG_TRUNC);
-               /* TODO: Check specific error and bomb out unless EAGAIN? 
*/
                if (err < 0) {
-                       vhost_discard(vq, 1);
+                       vhost_discard(vq, headcount);
                        break;
                }
                /* TODO: Should check and handle checksum. */
+               if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) 
{
+                       struct virtio_net_hdr_mrg_rxbuf *vhdr =
+                               (struct virtio_net_hdr_mrg_rxbuf *)
+                               vq->iov[0].iov_base;
+                       /* add num_bufs */
+                       vq->iov[0].iov_len = vq->guest_hlen;
+                       vhdr->num_buffers = headcount;
+               }
                if (err > len) {
                        pr_err("Discarded truncated rx packet: "
                               " len %d > %zd\n", err, len);
-                       vhost_discard(vq, 1);
+                       vhost_discard(vq, headcount);
                        continue;
                }
                len = err;
@@ -573,8 +560,6 @@
 
 static int vhost_net_set_features(struct vhost_net *n, u64 features)
 {
-       size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
-               sizeof(struct virtio_net_hdr) : 0;
        int i;
        mutex_lock(&n->dev.mutex);
        if ((features & (1 << VHOST_F_LOG_ALL)) &&
diff -ruN net-next-p2/drivers/vhost/vhost.c 
net-next-p3/drivers/vhost/vhost.c
--- net-next-p2/drivers/vhost/vhost.c   2010-03-02 12:53:02.000000000 
-0800
+++ net-next-p3/drivers/vhost/vhost.c   2010-03-02 15:24:50.000000000 
-0800
@@ -115,6 +115,7 @@
        vq->log_addr = -1ull;
        vq->guest_hlen = 0;
        vq->sock_hlen = 0;
+       vq->maxheadcount = 0;
        vq->private_data = NULL;
        vq->log_base = NULL;
        vq->error_ctx = NULL;
@@ -410,6 +411,7 @@
                vq->last_avail_idx = s.num;
                /* Forget the cached index value. */
                vq->avail_idx = vq->last_avail_idx;
+               vq->maxheadcount = 0;
                break;
        case VHOST_GET_VRING_BASE:
                s.index = idx;
@@ -1114,10 +1116,23 @@
        return 0;
 }
 
+int vhost_available(struct vhost_virtqueue *vq)
+{
+       int avail;
+
+       if (!vq->maxheadcount)  /* haven't got any yet */
+               return 1;
+       avail = vq->avail_idx - vq->last_avail_idx;
+       if (avail < 0)
+               avail += 0x10000; /* wrapped */
+       return avail;
+}
+
 /* This actually signals the guest, using eventfd. */
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
        __u16 flags = 0;
+
        if (get_user(flags, &vq->avail->flags)) {
                vq_err(vq, "Failed to get flags");
                return;
@@ -1125,7 +1140,7 @@
 
        /* If they don't want an interrupt, don't signal, unless empty. */
        if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
-           (vq->avail_idx != vq->last_avail_idx ||
+           (vhost_available(vq) > vq->maxheadcount ||
             !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
                return;
 
diff -ruN net-next-p2/drivers/vhost/vhost.h 
net-next-p3/drivers/vhost/vhost.h
--- net-next-p2/drivers/vhost/vhost.h   2010-03-02 13:02:03.000000000 
-0800
+++ net-next-p3/drivers/vhost/vhost.h   2010-03-02 14:29:44.000000000 
-0800
@@ -85,6 +85,7 @@
        struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr */
        struct iovec heads[VHOST_NET_MAX_SG];
        size_t guest_hlen, sock_hlen;
+       int maxheadcount;
        /* We use a kind of RCU to access private pointer.
         * All readers access it from workqueue, which makes it possible 
to
         * flush the workqueue instead of synchronize_rcu. Therefore 
readers do
@@ -151,7 +152,8 @@
        VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
                         (1 << VIRTIO_RING_F_INDIRECT_DESC) |
                         (1 << VHOST_F_LOG_ALL) |
-                        (1 << VHOST_NET_F_VIRTIO_NET_HDR),
+                        (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
+                        (1 << VIRTIO_NET_F_MRG_RXBUF),
 };
 
 static inline int vhost_has_feature(struct vhost_dev *dev, int bit)


--=_mixed 0001E192882576DB_=
Content-Type: application/octet-stream; name="MRXB3.patch"
Content-Disposition: attachment; filename="MRXB3.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOIG5ldC1uZXh0LXAyL2RyaXZlcnMvdmhvc3QvbmV0LmMgbmV0LW5leHQtcDMvZHJp
dmVycy92aG9zdC9uZXQuYwotLS0gbmV0LW5leHQtcDIvZHJpdmVycy92aG9zdC9uZXQuYwkyMDEw
LTAzLTAyIDEzOjAxOjM0LjAwMDAwMDAwMCAtMDgwMAorKysgbmV0LW5leHQtcDMvZHJpdmVycy92
aG9zdC9uZXQuYwkyMDEwLTAzLTAyIDE1OjI1OjE1LjAwMDAwMDAwMCAtMDgwMApAQCAtNTQsMjYg
KzU0LDYgQEAKIAllbnVtIHZob3N0X25ldF9wb2xsX3N0YXRlIHR4X3BvbGxfc3RhdGU7CiB9Owog
Ci0vKiBQb3AgZmlyc3QgbGVuIGJ5dGVzIGZyb20gaW92ZWMuIFJldHVybiBudW1iZXIgb2Ygc2Vn
bWVudHMgdXNlZC4gKi8KLXN0YXRpYyBpbnQgbW92ZV9pb3ZlY19oZHIoc3RydWN0IGlvdmVjICpm
cm9tLCBzdHJ1Y3QgaW92ZWMgKnRvLAotCQkJICBzaXplX3QgbGVuLCBpbnQgaW92X2NvdW50KQot
ewotCWludCBzZWcgPSAwOwotCXNpemVfdCBzaXplOwotCXdoaWxlIChsZW4gJiYgc2VnIDwgaW92
X2NvdW50KSB7Ci0JCXNpemUgPSBtaW4oZnJvbS0+aW92X2xlbiwgbGVuKTsKLQkJdG8tPmlvdl9i
YXNlID0gZnJvbS0+aW92X2Jhc2U7Ci0JCXRvLT5pb3ZfbGVuID0gc2l6ZTsKLQkJZnJvbS0+aW92
X2xlbiAtPSBzaXplOwotCQlmcm9tLT5pb3ZfYmFzZSArPSBzaXplOwotCQlsZW4gLT0gc2l6ZTsK
LQkJKytmcm9tOwotCQkrK3RvOwotCQkrK3NlZzsKLQl9Ci0JcmV0dXJuIHNlZzsKLX0KLQogLyog
Q2FsbGVyIG11c3QgaGF2ZSBUWCBWUSBsb2NrICovCiBzdGF0aWMgdm9pZCB0eF9wb2xsX3N0b3Ao
c3RydWN0IHZob3N0X25ldCAqbmV0KQogewpAQCAtOTcsNyArNzcsNyBAQAogc3RhdGljIHZvaWQg
aGFuZGxlX3R4KHN0cnVjdCB2aG9zdF9uZXQgKm5ldCkKIHsKIAlzdHJ1Y3Qgdmhvc3RfdmlydHF1
ZXVlICp2cSA9ICZuZXQtPmRldi52cXNbVkhPU1RfTkVUX1ZRX1RYXTsKLQl1bnNpZ25lZCBvdXQs
IGluLCBzOworCXVuc2lnbmVkIG91dCwgaW47CiAJc3RydWN0IGlvdmVjIGhlYWQ7CiAJc3RydWN0
IG1zZ2hkciBtc2cgPSB7CiAJCS5tc2dfbmFtZSA9IE5VTEwsCkBAIC0xMTAsNiArOTAsNyBAQAog
CXNpemVfdCBsZW4sIHRvdGFsX2xlbiA9IDA7CiAJaW50IGVyciwgd21lbTsKIAlzdHJ1Y3Qgc29j
a2V0ICpzb2NrID0gcmN1X2RlcmVmZXJlbmNlKHZxLT5wcml2YXRlX2RhdGEpOworCiAJaWYgKCFz
b2NrKQogCQlyZXR1cm47CiAKQEAgLTE2NiwxMSArMTQ3LDExIEBACiAJCS8qIFNraXAgaGVhZGVy
LiBUT0RPOiBzdXBwb3J0IFRTTy4gKi8KIAkJbXNnLm1zZ19pb3ZsZW4gPSBvdXQ7CiAJCWhlYWQu
aW92X2xlbiA9IGxlbiA9IGlvdl9sZW5ndGgodnEtPmlvdiwgb3V0KTsKKwogCQkvKiBTYW5pdHkg
Y2hlY2sgKi8KIAkJaWYgKCFsZW4pIHsKIAkJCXZxX2Vycih2cSwgIlVuZXhwZWN0ZWQgaGVhZGVy
IGxlbiBmb3IgVFg6ICIKLQkJCSAgICAgICAiJXpkIGV4cGVjdGVkICV6ZFxuIiwKLQkJCSAgICAg
ICBsZW4sIHZxLT5ndWVzdF9obGVuKTsKKwkJCSAgICAgICAiJXpkIGV4cGVjdGVkICV6ZFxuIiwg
bGVuLCB2cS0+Z3Vlc3RfaGxlbik7CiAJCQlicmVhazsKIAkJfQogCQkvKiBUT0RPOiBDaGVjayBz
cGVjaWZpYyBlcnJvciBhbmQgYm9tYiBvdXQgdW5sZXNzIEVOT0JVRlM/ICovCkBAIC0yMTQsNyAr
MTk1LDcgQEAKIHN0YXRpYyB2b2lkIGhhbmRsZV9yeChzdHJ1Y3Qgdmhvc3RfbmV0ICpuZXQpCiB7
CiAJc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqdnEgPSAmbmV0LT5kZXYudnFzW1ZIT1NUX05FVF9W
UV9SWF07Ci0JdW5zaWduZWQgaW4sIGxvZywgczsKKwl1bnNpZ25lZCBpbiwgbG9nOwogCXN0cnVj
dCB2aG9zdF9sb2cgKnZxX2xvZzsKIAlzdHJ1Y3QgbXNnaGRyIG1zZyA9IHsKIAkJLm1zZ19uYW1l
ID0gTlVMTCwKQEAgLTI0NSwzMCArMjI2LDM2IEBACiAJCWlmICghaGVhZGNvdW50KSB7CiAJCQl2
aG9zdF9lbmFibGVfbm90aWZ5KHZxKTsKIAkJCWJyZWFrOwotCQl9CisJCX0gZWxzZSBpZiAodnEt
Pm1heGhlYWRjb3VudCA8IGhlYWRjb3VudCkKKwkJCXZxLT5tYXhoZWFkY291bnQgPSBoZWFkY291
bnQ7CiAJCS8qIFNraXAgaGVhZGVyLiBUT0RPOiBzdXBwb3J0IFRTTy9tZXJnZWFibGUgcnggYnVm
ZmVycy4gKi8KIAkJbXNnLm1zZ19pb3ZsZW4gPSBpbjsKIAkJbGVuID0gaW92X2xlbmd0aCh2cS0+
aW92LCBpbik7Ci0KIAkJLyogU2FuaXR5IGNoZWNrICovCiAJCWlmICghbGVuKSB7CiAJCQl2cV9l
cnIodnEsICJVbmV4cGVjdGVkIGhlYWRlciBsZW4gZm9yIFJYOiAiCi0JCQkgICAgICAgIiV6ZCBl
eHBlY3RlZCAlemRcbiIsCi0JCQkgICAgICAgbGVuLCB2cS0+Z3Vlc3RfaGxlbik7CisJCQkgICAg
ICAgIiV6ZCBleHBlY3RlZCAlemRcbiIsIGxlbiwgdnEtPmd1ZXN0X2hsZW4pOwogCQkJYnJlYWs7
CiAJCX0KIAkJZXJyID0gc29jay0+b3BzLT5yZWN2bXNnKE5VTEwsIHNvY2ssICZtc2csCiAJCQkJ
CSBsZW4sIE1TR19ET05UV0FJVCB8IE1TR19UUlVOQyk7Ci0JCS8qIFRPRE86IENoZWNrIHNwZWNp
ZmljIGVycm9yIGFuZCBib21iIG91dCB1bmxlc3MgRUFHQUlOPyAqLwogCQlpZiAoZXJyIDwgMCkg
ewotCQkJdmhvc3RfZGlzY2FyZCh2cSwgMSk7CisJCQl2aG9zdF9kaXNjYXJkKHZxLCBoZWFkY291
bnQpOwogCQkJYnJlYWs7CiAJCX0KIAkJLyogVE9ETzogU2hvdWxkIGNoZWNrIGFuZCBoYW5kbGUg
Y2hlY2tzdW0uICovCisJCWlmICh2aG9zdF9oYXNfZmVhdHVyZSgmbmV0LT5kZXYsIFZJUlRJT19O
RVRfRl9NUkdfUlhCVUYpKSB7CisJCQlzdHJ1Y3QgdmlydGlvX25ldF9oZHJfbXJnX3J4YnVmICp2
aGRyID0KKwkJCQkoc3RydWN0IHZpcnRpb19uZXRfaGRyX21yZ19yeGJ1ZiAqKQorCQkJCXZxLT5p
b3ZbMF0uaW92X2Jhc2U7CisJCQkvKiBhZGQgbnVtX2J1ZnMgKi8KKwkJCXZxLT5pb3ZbMF0uaW92
X2xlbiA9IHZxLT5ndWVzdF9obGVuOworCQkJdmhkci0+bnVtX2J1ZmZlcnMgPSBoZWFkY291bnQ7
CisJCX0KIAkJaWYgKGVyciA+IGxlbikgewogCQkJcHJfZXJyKCJEaXNjYXJkZWQgdHJ1bmNhdGVk
IHJ4IHBhY2tldDogIgogCQkJICAgICAgICIgbGVuICVkID4gJXpkXG4iLCBlcnIsIGxlbik7Ci0J
CQl2aG9zdF9kaXNjYXJkKHZxLCAxKTsKKwkJCXZob3N0X2Rpc2NhcmQodnEsIGhlYWRjb3VudCk7
CiAJCQljb250aW51ZTsKIAkJfQogCQlsZW4gPSBlcnI7CkBAIC01NzMsOCArNTYwLDYgQEAKIAog
c3RhdGljIGludCB2aG9zdF9uZXRfc2V0X2ZlYXR1cmVzKHN0cnVjdCB2aG9zdF9uZXQgKm4sIHU2
NCBmZWF0dXJlcykKIHsKLQlzaXplX3QgaGRyX3NpemUgPSBmZWF0dXJlcyAmICgxIDw8IFZIT1NU
X05FVF9GX1ZJUlRJT19ORVRfSERSKSA/Ci0JCXNpemVvZihzdHJ1Y3QgdmlydGlvX25ldF9oZHIp
IDogMDsKIAlpbnQgaTsKIAltdXRleF9sb2NrKCZuLT5kZXYubXV0ZXgpOwogCWlmICgoZmVhdHVy
ZXMgJiAoMSA8PCBWSE9TVF9GX0xPR19BTEwpKSAmJgpkaWZmIC1ydU4gbmV0LW5leHQtcDIvZHJp
dmVycy92aG9zdC92aG9zdC5jIG5ldC1uZXh0LXAzL2RyaXZlcnMvdmhvc3Qvdmhvc3QuYwotLS0g
bmV0LW5leHQtcDIvZHJpdmVycy92aG9zdC92aG9zdC5jCTIwMTAtMDMtMDIgMTI6NTM6MDIuMDAw
MDAwMDAwIC0wODAwCisrKyBuZXQtbmV4dC1wMy9kcml2ZXJzL3Zob3N0L3Zob3N0LmMJMjAxMC0w
My0wMiAxNToyNDo1MC4wMDAwMDAwMDAgLTA4MDAKQEAgLTExNSw2ICsxMTUsNyBAQAogCXZxLT5s
b2dfYWRkciA9IC0xdWxsOwogCXZxLT5ndWVzdF9obGVuID0gMDsKIAl2cS0+c29ja19obGVuID0g
MDsKKwl2cS0+bWF4aGVhZGNvdW50ID0gMDsKIAl2cS0+cHJpdmF0ZV9kYXRhID0gTlVMTDsKIAl2
cS0+bG9nX2Jhc2UgPSBOVUxMOwogCXZxLT5lcnJvcl9jdHggPSBOVUxMOwpAQCAtNDEwLDYgKzQx
MSw3IEBACiAJCXZxLT5sYXN0X2F2YWlsX2lkeCA9IHMubnVtOwogCQkvKiBGb3JnZXQgdGhlIGNh
Y2hlZCBpbmRleCB2YWx1ZS4gKi8KIAkJdnEtPmF2YWlsX2lkeCA9IHZxLT5sYXN0X2F2YWlsX2lk
eDsKKwkJdnEtPm1heGhlYWRjb3VudCA9IDA7CiAJCWJyZWFrOwogCWNhc2UgVkhPU1RfR0VUX1ZS
SU5HX0JBU0U6CiAJCXMuaW5kZXggPSBpZHg7CkBAIC0xMTE0LDEwICsxMTE2LDIzIEBACiAJcmV0
dXJuIDA7CiB9CiAKK2ludCB2aG9zdF9hdmFpbGFibGUoc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAq
dnEpCit7CisJaW50IGF2YWlsOworCisJaWYgKCF2cS0+bWF4aGVhZGNvdW50KQkvKiBoYXZlbid0
IGdvdCBhbnkgeWV0ICovCisJCXJldHVybiAxOworCWF2YWlsID0gdnEtPmF2YWlsX2lkeCAtIHZx
LT5sYXN0X2F2YWlsX2lkeDsKKwlpZiAoYXZhaWwgPCAwKQorCQlhdmFpbCArPSAweDEwMDAwOyAv
KiB3cmFwcGVkICovCisJcmV0dXJuIGF2YWlsOworfQorCiAvKiBUaGlzIGFjdHVhbGx5IHNpZ25h
bHMgdGhlIGd1ZXN0LCB1c2luZyBldmVudGZkLiAqLwogdm9pZCB2aG9zdF9zaWduYWwoc3RydWN0
IHZob3N0X2RldiAqZGV2LCBzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSkKIHsKIAlfX3UxNiBm
bGFncyA9IDA7CisKIAlpZiAoZ2V0X3VzZXIoZmxhZ3MsICZ2cS0+YXZhaWwtPmZsYWdzKSkgewog
CQl2cV9lcnIodnEsICJGYWlsZWQgdG8gZ2V0IGZsYWdzIik7CiAJCXJldHVybjsKQEAgLTExMjUs
NyArMTE0MCw3IEBACiAKIAkvKiBJZiB0aGV5IGRvbid0IHdhbnQgYW4gaW50ZXJydXB0LCBkb24n
dCBzaWduYWwsIHVubGVzcyBlbXB0eS4gKi8KIAlpZiAoKGZsYWdzICYgVlJJTkdfQVZBSUxfRl9O
T19JTlRFUlJVUFQpICYmCi0JICAgICh2cS0+YXZhaWxfaWR4ICE9IHZxLT5sYXN0X2F2YWlsX2lk
eCB8fAorCSAgICAodmhvc3RfYXZhaWxhYmxlKHZxKSA+IHZxLT5tYXhoZWFkY291bnQgfHwKIAkg
ICAgICF2aG9zdF9oYXNfZmVhdHVyZShkZXYsIFZJUlRJT19GX05PVElGWV9PTl9FTVBUWSkpKQog
CQlyZXR1cm47CiAKZGlmZiAtcnVOIG5ldC1uZXh0LXAyL2RyaXZlcnMvdmhvc3Qvdmhvc3QuaCBu
ZXQtbmV4dC1wMy9kcml2ZXJzL3Zob3N0L3Zob3N0LmgKLS0tIG5ldC1uZXh0LXAyL2RyaXZlcnMv
dmhvc3Qvdmhvc3QuaAkyMDEwLTAzLTAyIDEzOjAyOjAzLjAwMDAwMDAwMCAtMDgwMAorKysgbmV0
LW5leHQtcDMvZHJpdmVycy92aG9zdC92aG9zdC5oCTIwMTAtMDMtMDIgMTQ6Mjk6NDQuMDAwMDAw
MDAwIC0wODAwCkBAIC04NSw2ICs4NSw3IEBACiAJc3RydWN0IGlvdmVjIGlvdltWSE9TVF9ORVRf
TUFYX1NHKzFdOyAvKiBhbiBleHRyYSBmb3Igdm5ldCBoZHIgKi8KIAlzdHJ1Y3QgaW92ZWMgaGVh
ZHNbVkhPU1RfTkVUX01BWF9TR107CiAJc2l6ZV90IGd1ZXN0X2hsZW4sIHNvY2tfaGxlbjsKKwlp
bnQgbWF4aGVhZGNvdW50OwogCS8qIFdlIHVzZSBhIGtpbmQgb2YgUkNVIHRvIGFjY2VzcyBwcml2
YXRlIHBvaW50ZXIuCiAJICogQWxsIHJlYWRlcnMgYWNjZXNzIGl0IGZyb20gd29ya3F1ZXVlLCB3
aGljaCBtYWtlcyBpdCBwb3NzaWJsZSB0bwogCSAqIGZsdXNoIHRoZSB3b3JrcXVldWUgaW5zdGVh
ZCBvZiBzeW5jaHJvbml6ZV9yY3UuIFRoZXJlZm9yZSByZWFkZXJzIGRvCkBAIC0xNTEsNyArMTUy
LDggQEAKIAlWSE9TVF9GRUFUVVJFUyA9ICgxIDw8IFZJUlRJT19GX05PVElGWV9PTl9FTVBUWSkg
fAogCQkJICgxIDw8IFZJUlRJT19SSU5HX0ZfSU5ESVJFQ1RfREVTQykgfAogCQkJICgxIDw8IFZI
T1NUX0ZfTE9HX0FMTCkgfAotCQkJICgxIDw8IFZIT1NUX05FVF9GX1ZJUlRJT19ORVRfSERSKSwK
KwkJCSAoMSA8PCBWSE9TVF9ORVRfRl9WSVJUSU9fTkVUX0hEUikgfAorCQkJICgxIDw8IFZJUlRJ
T19ORVRfRl9NUkdfUlhCVUYpLAogfTsKIAogc3RhdGljIGlubGluZSBpbnQgdmhvc3RfaGFzX2Zl
YXR1cmUoc3RydWN0IHZob3N0X2RldiAqZGV2LCBpbnQgYml0KQo=

--=_mixed 0001E192882576DB_=--
