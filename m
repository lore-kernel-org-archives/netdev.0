From: David Stevens <dlstevens@us.ibm.com>
Subject: [RFC][ PATCH 1/3] vhost-net: support multiple buffer heads in receiver
Date: Tue, 2 Mar 2010 17:20:15 -0700
Message-ID: <OF201C1B9E.C89ADF9F-ON882576DB.00006AD7-882576DB.0001DA4E@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0001DA48882576DB_="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: mst@redhat.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:49493 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164Ab0CCAU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 19:20:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 0001DA48882576DB_=
Content-Type: text/plain; charset="US-ASCII"

This patch generalizes buffer handling functions to
support multiple buffer heads.

In-line for viewing, attached for applying.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruN net-next-p0/drivers/vhost/net.c net-next-p1/drivers/vhost/net.c
--- net-next-p0/drivers/vhost/net.c     2010-02-24 12:59:24.000000000 
-0800
+++ net-next-p1/drivers/vhost/net.c     2010-03-01 11:44:22.000000000 
-0800
@@ -97,7 +97,8 @@
 static void handle_tx(struct vhost_net *net)
 {
        struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
-       unsigned head, out, in, s;
+       unsigned out, in, s;
+       struct iovec head;
        struct msghdr msg = {
                .msg_name = NULL,
                .msg_namelen = 0,
@@ -126,12 +127,10 @@
        hdr_size = vq->hdr_size;
 
        for (;;) {
-               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
-                                        ARRAY_SIZE(vq->iov),
-                                        &out, &in,
-                                        NULL, NULL);
+               head.iov_base = (void *)vhost_get_vq_desc(&net->dev, vq,
+                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, NULL, 
NULL);
                /* Nothing new?  Wait for eventfd to tell us they 
refilled. */
-               if (head == vq->num) {
+               if (head.iov_base == (void *)vq->num) {
                        wmem = atomic_read(&sock->sk->sk_wmem_alloc);
                        if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
                                tx_poll_start(net, sock);
@@ -152,7 +151,7 @@
                /* Skip header. TODO: support TSO. */
                s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
                msg.msg_iovlen = out;
-               len = iov_length(vq->iov, out);
+               head.iov_len = len = iov_length(vq->iov, out);
                /* Sanity check */
                if (!len) {
                        vq_err(vq, "Unexpected header len for TX: "
@@ -163,14 +162,14 @@
                /* TODO: Check specific error and bomb out unless ENOBUFS? 
*/
                err = sock->ops->sendmsg(NULL, sock, &msg, len);
                if (unlikely(err < 0)) {
-                       vhost_discard_vq_desc(vq);
+                       vhost_discard(vq, 1);
                        tx_poll_start(net, sock);
                        break;
                }
                if (err != len)
                        pr_err("Truncated TX packet: "
                               " len %d != %zd\n", err, len);
-               vhost_add_used_and_signal(&net->dev, vq, head, 0);
+               vhost_add_used_and_signal(&net->dev, vq, &head, 1);
                total_len += len;
                if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
                        vhost_poll_queue(&vq->poll);
@@ -182,12 +181,22 @@
        unuse_mm(net->dev.mm);
 }
 
+static int skb_head_len(struct sk_buff_head *skq)
+{
+       struct sk_buff *head;
+
+       head = skb_peek(skq);
+       if (head)
+               return head->len;
+       return 0;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_rx(struct vhost_net *net)
 {
        struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
-       unsigned head, out, in, log, s;
+       unsigned in, log, s;
        struct vhost_log *vq_log;
        struct msghdr msg = {
                .msg_name = NULL,
@@ -204,10 +213,11 @@
        };
 
        size_t len, total_len = 0;
-       int err;
+       int err, headcount, datalen;
        size_t hdr_size;
        struct socket *sock = rcu_dereference(vq->private_data);
-       if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
+
+       if (!sock || !skb_head_len(&sock->sk->sk_receive_queue))
                return;
 
        use_mm(net->dev.mm);
@@ -218,13 +228,10 @@
        vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
                vq->log : NULL;
 
-       for (;;) {
-               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
-                                        ARRAY_SIZE(vq->iov),
-                                        &out, &in,
-                                        vq_log, &log);
+       while ((datalen = skb_head_len(&sock->sk->sk_receive_queue))) {
+               headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
&log);
                /* OK, now we need to know about added descriptors. */
-               if (head == vq->num) {
+               if (!headcount) {
                        if (unlikely(vhost_enable_notify(vq))) {
                                /* They have slipped one in as we were
                                 * doing that: check again. */
@@ -235,13 +242,6 @@
                         * they refilled. */
                        break;
                }
-               /* We don't need to be notified again. */
-               if (out) {
-                       vq_err(vq, "Unexpected descriptor format for RX: "
-                              "out %d, int %d\n",
-                              out, in);
-                       break;
-               }
                /* Skip header. TODO: support TSO/mergeable rx buffers. */
                s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
                msg.msg_iovlen = in;
@@ -257,14 +257,14 @@
                                         len, MSG_DONTWAIT | MSG_TRUNC);
                /* TODO: Check specific error and bomb out unless EAGAIN? 
*/
                if (err < 0) {
-                       vhost_discard_vq_desc(vq);
+                       vhost_discard(vq, 1);
                        break;
                }
                /* TODO: Should check and handle checksum. */
                if (err > len) {
                        pr_err("Discarded truncated rx packet: "
                               " len %d > %zd\n", err, len);
-                       vhost_discard_vq_desc(vq);
+                       vhost_discard(vq, 1);
                        continue;
                }
                len = err;
@@ -275,7 +275,7 @@
                        break;
                }
                len += hdr_size;
-               vhost_add_used_and_signal(&net->dev, vq, head, len);
+               vhost_add_used_and_signal(&net->dev, vq, vq->heads, 
headcount);
                if (unlikely(vq_log))
                        vhost_log_write(vq, vq_log, log, len);
                total_len += len;
diff -ruN net-next-p0/drivers/vhost/vhost.c 
net-next-p1/drivers/vhost/vhost.c
--- net-next-p0/drivers/vhost/vhost.c   2010-02-15 20:08:35.000000000 
-0800
+++ net-next-p1/drivers/vhost/vhost.c   2010-03-01 11:44:06.000000000 
-0800
@@ -848,6 +848,38 @@
        return 0;
 }
 
+unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 
*iovcount,
+       struct vhost_log *log, unsigned int *log_num)
+{
+       struct iovec *heads = vq->heads;
+       int out, in;
+       int hc = 0;
+
+       while (datalen > 0) {
+               if (hc >= VHOST_NET_MAX_SG) {
+                       vhost_discard(vq, hc);
+                       return 0;
+               }
+               heads[hc].iov_base = (void *)vhost_get_vq_desc(vq->dev, 
vq,
+                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, log, 
log_num);
+               if (heads[hc].iov_base == (void *)vq->num) {
+                       vhost_discard(vq, hc);
+                       return 0;
+               }
+               if (out || in <= 0) {
+                       vq_err(vq, "unexpected descriptor format for RX: "
+                               "out %d, in %d\n", out, in);
+                       vhost_discard(vq, hc);
+                       return 0;
+               }
+               heads[hc].iov_len = iov_length(vq->iov, in);
+               hc++;
+               datalen -= heads[hc].iov_len;
+       }
+       *iovcount = in;
+       return hc;
+}
+
 /* This looks in the virtqueue and for the first available buffer, and 
converts
  * it to an iovec for convenient access.  Since descriptors consist of 
some
  * number of output then some number of input descriptors, it's actually 
two
@@ -973,31 +1005,32 @@
 }
 
 /* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
-void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
+void vhost_discard(struct vhost_virtqueue *vq, int n)
 {
-       vq->last_avail_idx--;
+       vq->last_avail_idx -= n;
 }
 
 /* After we've used one of their buffers, we tell them about it.  We'll 
then
  * want to notify the guest, using eventfd. */
-int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int 
len)
+int vhost_add_used(struct vhost_virtqueue *vq, struct iovec *heads, int 
count)
 {
        struct vring_used_elem *used;
+       int i;
 
-       /* The virtqueue contains a ring of used buffers.  Get a pointer 
to the
-        * next entry in that used ring. */
-       used = &vq->used->ring[vq->last_used_idx % vq->num];
-       if (put_user(head, &used->id)) {
-               vq_err(vq, "Failed to write used id");
-               return -EFAULT;
-       }
-       if (put_user(len, &used->len)) {
-               vq_err(vq, "Failed to write used len");
-               return -EFAULT;
+       for (i=0; i<count; i++, vq->last_used_idx++) {
+               used = &vq->used->ring[vq->last_used_idx % vq->num];
+               if (put_user((unsigned)heads[i].iov_base, &used->id)) {
+                       vq_err(vq, "Failed to write used id");
+                       return -EFAULT;
+               }
+               if (put_user(heads[i].iov_len, &used->len)) {
+                       vq_err(vq, "Failed to write used len");
+                       return -EFAULT;
+               }
        }
        /* Make sure buffer is written before we update index. */
        smp_wmb();
-       if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
+       if (put_user(vq->last_used_idx, &vq->used->idx)) {
                vq_err(vq, "Failed to increment used idx");
                return -EFAULT;
        }
@@ -1011,7 +1044,6 @@
                if (vq->log_ctx)
                        eventfd_signal(vq->log_ctx, 1);
        }
-       vq->last_used_idx++;
        return 0;
 }
 
@@ -1038,9 +1070,9 @@
 /* And here's the combo meal deal.  Supersize me! */
 void vhost_add_used_and_signal(struct vhost_dev *dev,
                               struct vhost_virtqueue *vq,
-                              unsigned int head, int len)
+                              struct iovec *heads, int count)
 {
-       vhost_add_used(vq, head, len);
+       vhost_add_used(vq, heads, count);
        vhost_signal(dev, vq);
 }
 
diff -ruN net-next-p0/drivers/vhost/vhost.h 
net-next-p1/drivers/vhost/vhost.h
--- net-next-p0/drivers/vhost/vhost.h   2010-02-15 20:08:35.000000000 
-0800
+++ net-next-p1/drivers/vhost/vhost.h   2010-03-01 11:42:18.000000000 
-0800
@@ -84,6 +84,7 @@
        struct iovec indirect[VHOST_NET_MAX_SG];
        struct iovec iov[VHOST_NET_MAX_SG];
        struct iovec hdr[VHOST_NET_MAX_SG];
+       struct iovec heads[VHOST_NET_MAX_SG];
        size_t hdr_size;
        /* We use a kind of RCU to access private pointer.
         * All readers access it from workqueue, which makes it possible 
to
@@ -120,16 +121,18 @@
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
 
+unsigned vhost_get_heads(struct vhost_virtqueue *, int datalen, int 
*iovcount,
+                       struct vhost_log *log, unsigned int *log_num);
 unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
                           struct iovec iov[], unsigned int iov_count,
                           unsigned int *out_num, unsigned int *in_num,
                           struct vhost_log *log, unsigned int *log_num);
-void vhost_discard_vq_desc(struct vhost_virtqueue *);
+void vhost_discard(struct vhost_virtqueue *, int);
 
-int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
-void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
+int vhost_add_used(struct vhost_virtqueue *, struct iovec *heads, int 
count);
 void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue 
*,
-                              unsigned int head, int len);
+                              struct iovec *heads, int count);
+void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
 void vhost_disable_notify(struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_virtqueue *);
 

--=_mixed 0001DA48882576DB_=
Content-Type: application/octet-stream; name="MRXB1.patch"
Content-Disposition: attachment; filename="MRXB1.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOIG5ldC1uZXh0LXAwL2RyaXZlcnMvdmhvc3QvbmV0LmMgbmV0LW5leHQtcDEvZHJp
dmVycy92aG9zdC9uZXQuYwotLS0gbmV0LW5leHQtcDAvZHJpdmVycy92aG9zdC9uZXQuYwkyMDEw
LTAyLTI0IDEyOjU5OjI0LjAwMDAwMDAwMCAtMDgwMAorKysgbmV0LW5leHQtcDEvZHJpdmVycy92
aG9zdC9uZXQuYwkyMDEwLTAzLTAxIDExOjQ0OjIyLjAwMDAwMDAwMCAtMDgwMApAQCAtOTcsNyAr
OTcsOCBAQAogc3RhdGljIHZvaWQgaGFuZGxlX3R4KHN0cnVjdCB2aG9zdF9uZXQgKm5ldCkKIHsK
IAlzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSA9ICZuZXQtPmRldi52cXNbVkhPU1RfTkVUX1ZR
X1RYXTsKLQl1bnNpZ25lZCBoZWFkLCBvdXQsIGluLCBzOworCXVuc2lnbmVkIG91dCwgaW4sIHM7
CisJc3RydWN0IGlvdmVjIGhlYWQ7CiAJc3RydWN0IG1zZ2hkciBtc2cgPSB7CiAJCS5tc2dfbmFt
ZSA9IE5VTEwsCiAJCS5tc2dfbmFtZWxlbiA9IDAsCkBAIC0xMjYsMTIgKzEyNywxMCBAQAogCWhk
cl9zaXplID0gdnEtPmhkcl9zaXplOwogCiAJZm9yICg7OykgewotCQloZWFkID0gdmhvc3RfZ2V0
X3ZxX2Rlc2MoJm5ldC0+ZGV2LCB2cSwgdnEtPmlvdiwKLQkJCQkJIEFSUkFZX1NJWkUodnEtPmlv
diksCi0JCQkJCSAmb3V0LCAmaW4sCi0JCQkJCSBOVUxMLCBOVUxMKTsKKwkJaGVhZC5pb3ZfYmFz
ZSA9ICh2b2lkICopdmhvc3RfZ2V0X3ZxX2Rlc2MoJm5ldC0+ZGV2LCB2cSwKKwkJCXZxLT5pb3Ys
IEFSUkFZX1NJWkUodnEtPmlvdiksICZvdXQsICZpbiwgTlVMTCwgTlVMTCk7CiAJCS8qIE5vdGhp
bmcgbmV3PyAgV2FpdCBmb3IgZXZlbnRmZCB0byB0ZWxsIHVzIHRoZXkgcmVmaWxsZWQuICovCi0J
CWlmIChoZWFkID09IHZxLT5udW0pIHsKKwkJaWYgKGhlYWQuaW92X2Jhc2UgPT0gKHZvaWQgKil2
cS0+bnVtKSB7CiAJCQl3bWVtID0gYXRvbWljX3JlYWQoJnNvY2stPnNrLT5za193bWVtX2FsbG9j
KTsKIAkJCWlmICh3bWVtID49IHNvY2stPnNrLT5za19zbmRidWYgKiAzIC8gNCkgewogCQkJCXR4
X3BvbGxfc3RhcnQobmV0LCBzb2NrKTsKQEAgLTE1Miw3ICsxNTEsNyBAQAogCQkvKiBTa2lwIGhl
YWRlci4gVE9ETzogc3VwcG9ydCBUU08uICovCiAJCXMgPSBtb3ZlX2lvdmVjX2hkcih2cS0+aW92
LCB2cS0+aGRyLCBoZHJfc2l6ZSwgb3V0KTsKIAkJbXNnLm1zZ19pb3ZsZW4gPSBvdXQ7Ci0JCWxl
biA9IGlvdl9sZW5ndGgodnEtPmlvdiwgb3V0KTsKKwkJaGVhZC5pb3ZfbGVuID0gbGVuID0gaW92
X2xlbmd0aCh2cS0+aW92LCBvdXQpOwogCQkvKiBTYW5pdHkgY2hlY2sgKi8KIAkJaWYgKCFsZW4p
IHsKIAkJCXZxX2Vycih2cSwgIlVuZXhwZWN0ZWQgaGVhZGVyIGxlbiBmb3IgVFg6ICIKQEAgLTE2
MywxNCArMTYyLDE0IEBACiAJCS8qIFRPRE86IENoZWNrIHNwZWNpZmljIGVycm9yIGFuZCBib21i
IG91dCB1bmxlc3MgRU5PQlVGUz8gKi8KIAkJZXJyID0gc29jay0+b3BzLT5zZW5kbXNnKE5VTEws
IHNvY2ssICZtc2csIGxlbik7CiAJCWlmICh1bmxpa2VseShlcnIgPCAwKSkgewotCQkJdmhvc3Rf
ZGlzY2FyZF92cV9kZXNjKHZxKTsKKwkJCXZob3N0X2Rpc2NhcmQodnEsIDEpOwogCQkJdHhfcG9s
bF9zdGFydChuZXQsIHNvY2spOwogCQkJYnJlYWs7CiAJCX0KIAkJaWYgKGVyciAhPSBsZW4pCiAJ
CQlwcl9lcnIoIlRydW5jYXRlZCBUWCBwYWNrZXQ6ICIKIAkJCSAgICAgICAiIGxlbiAlZCAhPSAl
emRcbiIsIGVyciwgbGVuKTsKLQkJdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbCgmbmV0LT5kZXYs
IHZxLCBoZWFkLCAwKTsKKwkJdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbCgmbmV0LT5kZXYsIHZx
LCAmaGVhZCwgMSk7CiAJCXRvdGFsX2xlbiArPSBsZW47CiAJCWlmICh1bmxpa2VseSh0b3RhbF9s
ZW4gPj0gVkhPU1RfTkVUX1dFSUdIVCkpIHsKIAkJCXZob3N0X3BvbGxfcXVldWUoJnZxLT5wb2xs
KTsKQEAgLTE4MiwxMiArMTgxLDIyIEBACiAJdW51c2VfbW0obmV0LT5kZXYubW0pOwogfQogCitz
dGF0aWMgaW50IHNrYl9oZWFkX2xlbihzdHJ1Y3Qgc2tfYnVmZl9oZWFkICpza3EpCit7CisJc3Ry
dWN0IHNrX2J1ZmYgKmhlYWQ7CisKKwloZWFkID0gc2tiX3BlZWsoc2txKTsKKwlpZiAoaGVhZCkK
KwkJcmV0dXJuIGhlYWQtPmxlbjsKKwlyZXR1cm4gMDsKK30KKwogLyogRXhwZWN0cyB0byBiZSBh
bHdheXMgcnVuIGZyb20gd29ya3F1ZXVlIC0gd2hpY2ggYWN0cyBhcwogICogcmVhZC1zaXplIGNy
aXRpY2FsIHNlY3Rpb24gZm9yIG91ciBraW5kIG9mIFJDVS4gKi8KIHN0YXRpYyB2b2lkIGhhbmRs
ZV9yeChzdHJ1Y3Qgdmhvc3RfbmV0ICpuZXQpCiB7CiAJc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAq
dnEgPSAmbmV0LT5kZXYudnFzW1ZIT1NUX05FVF9WUV9SWF07Ci0JdW5zaWduZWQgaGVhZCwgb3V0
LCBpbiwgbG9nLCBzOworCXVuc2lnbmVkIGluLCBsb2csIHM7CiAJc3RydWN0IHZob3N0X2xvZyAq
dnFfbG9nOwogCXN0cnVjdCBtc2doZHIgbXNnID0gewogCQkubXNnX25hbWUgPSBOVUxMLApAQCAt
MjA0LDEwICsyMTMsMTEgQEAKIAl9OwogCiAJc2l6ZV90IGxlbiwgdG90YWxfbGVuID0gMDsKLQlp
bnQgZXJyOworCWludCBlcnIsIGhlYWRjb3VudCwgZGF0YWxlbjsKIAlzaXplX3QgaGRyX3NpemU7
CiAJc3RydWN0IHNvY2tldCAqc29jayA9IHJjdV9kZXJlZmVyZW5jZSh2cS0+cHJpdmF0ZV9kYXRh
KTsKLQlpZiAoIXNvY2sgfHwgc2tiX3F1ZXVlX2VtcHR5KCZzb2NrLT5zay0+c2tfcmVjZWl2ZV9x
dWV1ZSkpCisKKwlpZiAoIXNvY2sgfHwgIXNrYl9oZWFkX2xlbigmc29jay0+c2stPnNrX3JlY2Vp
dmVfcXVldWUpKQogCQlyZXR1cm47CiAKIAl1c2VfbW0obmV0LT5kZXYubW0pOwpAQCAtMjE4LDEz
ICsyMjgsMTAgQEAKIAl2cV9sb2cgPSB1bmxpa2VseSh2aG9zdF9oYXNfZmVhdHVyZSgmbmV0LT5k
ZXYsIFZIT1NUX0ZfTE9HX0FMTCkpID8KIAkJdnEtPmxvZyA6IE5VTEw7CiAKLQlmb3IgKDs7KSB7
Ci0JCWhlYWQgPSB2aG9zdF9nZXRfdnFfZGVzYygmbmV0LT5kZXYsIHZxLCB2cS0+aW92LAotCQkJ
CQkgQVJSQVlfU0laRSh2cS0+aW92KSwKLQkJCQkJICZvdXQsICZpbiwKLQkJCQkJIHZxX2xvZywg
JmxvZyk7CisJd2hpbGUgKChkYXRhbGVuID0gc2tiX2hlYWRfbGVuKCZzb2NrLT5zay0+c2tfcmVj
ZWl2ZV9xdWV1ZSkpKSB7CisJCWhlYWRjb3VudCA9IHZob3N0X2dldF9oZWFkcyh2cSwgZGF0YWxl
biwgJmluLCB2cV9sb2csICZsb2cpOwogCQkvKiBPSywgbm93IHdlIG5lZWQgdG8ga25vdyBhYm91
dCBhZGRlZCBkZXNjcmlwdG9ycy4gKi8KLQkJaWYgKGhlYWQgPT0gdnEtPm51bSkgeworCQlpZiAo
IWhlYWRjb3VudCkgewogCQkJaWYgKHVubGlrZWx5KHZob3N0X2VuYWJsZV9ub3RpZnkodnEpKSkg
ewogCQkJCS8qIFRoZXkgaGF2ZSBzbGlwcGVkIG9uZSBpbiBhcyB3ZSB3ZXJlCiAJCQkJICogZG9p
bmcgdGhhdDogY2hlY2sgYWdhaW4uICovCkBAIC0yMzUsMTMgKzI0Miw2IEBACiAJCQkgKiB0aGV5
IHJlZmlsbGVkLiAqLwogCQkJYnJlYWs7CiAJCX0KLQkJLyogV2UgZG9uJ3QgbmVlZCB0byBiZSBu
b3RpZmllZCBhZ2Fpbi4gKi8KLQkJaWYgKG91dCkgewotCQkJdnFfZXJyKHZxLCAiVW5leHBlY3Rl
ZCBkZXNjcmlwdG9yIGZvcm1hdCBmb3IgUlg6ICIKLQkJCSAgICAgICAib3V0ICVkLCBpbnQgJWRc
biIsCi0JCQkgICAgICAgb3V0LCBpbik7Ci0JCQlicmVhazsKLQkJfQogCQkvKiBTa2lwIGhlYWRl
ci4gVE9ETzogc3VwcG9ydCBUU08vbWVyZ2VhYmxlIHJ4IGJ1ZmZlcnMuICovCiAJCXMgPSBtb3Zl
X2lvdmVjX2hkcih2cS0+aW92LCB2cS0+aGRyLCBoZHJfc2l6ZSwgaW4pOwogCQltc2cubXNnX2lv
dmxlbiA9IGluOwpAQCAtMjU3LDE0ICsyNTcsMTQgQEAKIAkJCQkJIGxlbiwgTVNHX0RPTlRXQUlU
IHwgTVNHX1RSVU5DKTsKIAkJLyogVE9ETzogQ2hlY2sgc3BlY2lmaWMgZXJyb3IgYW5kIGJvbWIg
b3V0IHVubGVzcyBFQUdBSU4/ICovCiAJCWlmIChlcnIgPCAwKSB7Ci0JCQl2aG9zdF9kaXNjYXJk
X3ZxX2Rlc2ModnEpOworCQkJdmhvc3RfZGlzY2FyZCh2cSwgMSk7CiAJCQlicmVhazsKIAkJfQog
CQkvKiBUT0RPOiBTaG91bGQgY2hlY2sgYW5kIGhhbmRsZSBjaGVja3N1bS4gKi8KIAkJaWYgKGVy
ciA+IGxlbikgewogCQkJcHJfZXJyKCJEaXNjYXJkZWQgdHJ1bmNhdGVkIHJ4IHBhY2tldDogIgog
CQkJICAgICAgICIgbGVuICVkID4gJXpkXG4iLCBlcnIsIGxlbik7Ci0JCQl2aG9zdF9kaXNjYXJk
X3ZxX2Rlc2ModnEpOworCQkJdmhvc3RfZGlzY2FyZCh2cSwgMSk7CiAJCQljb250aW51ZTsKIAkJ
fQogCQlsZW4gPSBlcnI7CkBAIC0yNzUsNyArMjc1LDcgQEAKIAkJCWJyZWFrOwogCQl9CiAJCWxl
biArPSBoZHJfc2l6ZTsKLQkJdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbCgmbmV0LT5kZXYsIHZx
LCBoZWFkLCBsZW4pOworCQl2aG9zdF9hZGRfdXNlZF9hbmRfc2lnbmFsKCZuZXQtPmRldiwgdnEs
IHZxLT5oZWFkcywgaGVhZGNvdW50KTsKIAkJaWYgKHVubGlrZWx5KHZxX2xvZykpCiAJCQl2aG9z
dF9sb2dfd3JpdGUodnEsIHZxX2xvZywgbG9nLCBsZW4pOwogCQl0b3RhbF9sZW4gKz0gbGVuOwpk
aWZmIC1ydU4gbmV0LW5leHQtcDAvZHJpdmVycy92aG9zdC92aG9zdC5jIG5ldC1uZXh0LXAxL2Ry
aXZlcnMvdmhvc3Qvdmhvc3QuYwotLS0gbmV0LW5leHQtcDAvZHJpdmVycy92aG9zdC92aG9zdC5j
CTIwMTAtMDItMTUgMjA6MDg6MzUuMDAwMDAwMDAwIC0wODAwCisrKyBuZXQtbmV4dC1wMS9kcml2
ZXJzL3Zob3N0L3Zob3N0LmMJMjAxMC0wMy0wMSAxMTo0NDowNi4wMDAwMDAwMDAgLTA4MDAKQEAg
LTg0OCw2ICs4NDgsMzggQEAKIAlyZXR1cm4gMDsKIH0KIAordW5zaWduZWQgdmhvc3RfZ2V0X2hl
YWRzKHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKnZxLCBpbnQgZGF0YWxlbiwgaW50ICppb3Zjb3Vu
dCwKKwlzdHJ1Y3Qgdmhvc3RfbG9nICpsb2csIHVuc2lnbmVkIGludCAqbG9nX251bSkKK3sKKwlz
dHJ1Y3QgaW92ZWMgKmhlYWRzID0gdnEtPmhlYWRzOworCWludCBvdXQsIGluOworCWludCBoYyA9
IDA7CisKKwl3aGlsZSAoZGF0YWxlbiA+IDApIHsKKwkJaWYgKGhjID49IFZIT1NUX05FVF9NQVhf
U0cpIHsKKwkJCXZob3N0X2Rpc2NhcmQodnEsIGhjKTsKKwkJCXJldHVybiAwOworCQl9CisJCWhl
YWRzW2hjXS5pb3ZfYmFzZSA9ICh2b2lkICopdmhvc3RfZ2V0X3ZxX2Rlc2ModnEtPmRldiwgdnEs
CisJCQl2cS0+aW92LCBBUlJBWV9TSVpFKHZxLT5pb3YpLCAmb3V0LCAmaW4sIGxvZywgbG9nX251
bSk7CisJCWlmIChoZWFkc1toY10uaW92X2Jhc2UgPT0gKHZvaWQgKil2cS0+bnVtKSB7CisJCQl2
aG9zdF9kaXNjYXJkKHZxLCBoYyk7CisJCQlyZXR1cm4gMDsKKwkJfQorCQlpZiAob3V0IHx8IGlu
IDw9IDApIHsKKwkJCXZxX2Vycih2cSwgInVuZXhwZWN0ZWQgZGVzY3JpcHRvciBmb3JtYXQgZm9y
IFJYOiAiCisJCQkJIm91dCAlZCwgaW4gJWRcbiIsIG91dCwgaW4pOworCQkJdmhvc3RfZGlzY2Fy
ZCh2cSwgaGMpOworCQkJcmV0dXJuIDA7CisJCX0KKwkJaGVhZHNbaGNdLmlvdl9sZW4gPSBpb3Zf
bGVuZ3RoKHZxLT5pb3YsIGluKTsKKwkJaGMrKzsKKwkJZGF0YWxlbiAtPSBoZWFkc1toY10uaW92
X2xlbjsKKwl9CisJKmlvdmNvdW50ID0gaW47CisJcmV0dXJuIGhjOworfQorCiAvKiBUaGlzIGxv
b2tzIGluIHRoZSB2aXJ0cXVldWUgYW5kIGZvciB0aGUgZmlyc3QgYXZhaWxhYmxlIGJ1ZmZlciwg
YW5kIGNvbnZlcnRzCiAgKiBpdCB0byBhbiBpb3ZlYyBmb3IgY29udmVuaWVudCBhY2Nlc3MuICBT
aW5jZSBkZXNjcmlwdG9ycyBjb25zaXN0IG9mIHNvbWUKICAqIG51bWJlciBvZiBvdXRwdXQgdGhl
biBzb21lIG51bWJlciBvZiBpbnB1dCBkZXNjcmlwdG9ycywgaXQncyBhY3R1YWxseSB0d28KQEAg
LTk3MywzMSArMTAwNSwzMiBAQAogfQogCiAvKiBSZXZlcnNlIHRoZSBlZmZlY3Qgb2Ygdmhvc3Rf
Z2V0X3ZxX2Rlc2MuIFVzZWZ1bCBmb3IgZXJyb3IgaGFuZGxpbmcuICovCi12b2lkIHZob3N0X2Rp
c2NhcmRfdnFfZGVzYyhzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSkKK3ZvaWQgdmhvc3RfZGlz
Y2FyZChzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSwgaW50IG4pCiB7Ci0JdnEtPmxhc3RfYXZh
aWxfaWR4LS07CisJdnEtPmxhc3RfYXZhaWxfaWR4IC09IG47CiB9CiAKIC8qIEFmdGVyIHdlJ3Zl
IHVzZWQgb25lIG9mIHRoZWlyIGJ1ZmZlcnMsIHdlIHRlbGwgdGhlbSBhYm91dCBpdC4gIFdlJ2xs
IHRoZW4KICAqIHdhbnQgdG8gbm90aWZ5IHRoZSBndWVzdCwgdXNpbmcgZXZlbnRmZC4gKi8KLWlu
dCB2aG9zdF9hZGRfdXNlZChzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSwgdW5zaWduZWQgaW50
IGhlYWQsIGludCBsZW4pCitpbnQgdmhvc3RfYWRkX3VzZWQoc3RydWN0IHZob3N0X3ZpcnRxdWV1
ZSAqdnEsIHN0cnVjdCBpb3ZlYyAqaGVhZHMsIGludCBjb3VudCkKIHsKIAlzdHJ1Y3QgdnJpbmdf
dXNlZF9lbGVtICp1c2VkOworCWludCBpOwogCi0JLyogVGhlIHZpcnRxdWV1ZSBjb250YWlucyBh
IHJpbmcgb2YgdXNlZCBidWZmZXJzLiAgR2V0IGEgcG9pbnRlciB0byB0aGUKLQkgKiBuZXh0IGVu
dHJ5IGluIHRoYXQgdXNlZCByaW5nLiAqLwotCXVzZWQgPSAmdnEtPnVzZWQtPnJpbmdbdnEtPmxh
c3RfdXNlZF9pZHggJSB2cS0+bnVtXTsKLQlpZiAocHV0X3VzZXIoaGVhZCwgJnVzZWQtPmlkKSkg
ewotCQl2cV9lcnIodnEsICJGYWlsZWQgdG8gd3JpdGUgdXNlZCBpZCIpOwotCQlyZXR1cm4gLUVG
QVVMVDsKLQl9Ci0JaWYgKHB1dF91c2VyKGxlbiwgJnVzZWQtPmxlbikpIHsKLQkJdnFfZXJyKHZx
LCAiRmFpbGVkIHRvIHdyaXRlIHVzZWQgbGVuIik7Ci0JCXJldHVybiAtRUZBVUxUOworCWZvciAo
aT0wOyBpPGNvdW50OyBpKyssIHZxLT5sYXN0X3VzZWRfaWR4KyspIHsKKwkJdXNlZCA9ICZ2cS0+
dXNlZC0+cmluZ1t2cS0+bGFzdF91c2VkX2lkeCAlIHZxLT5udW1dOworCQlpZiAocHV0X3VzZXIo
KHVuc2lnbmVkKWhlYWRzW2ldLmlvdl9iYXNlLCAmdXNlZC0+aWQpKSB7CisJCQl2cV9lcnIodnEs
ICJGYWlsZWQgdG8gd3JpdGUgdXNlZCBpZCIpOworCQkJcmV0dXJuIC1FRkFVTFQ7CisJCX0KKwkJ
aWYgKHB1dF91c2VyKGhlYWRzW2ldLmlvdl9sZW4sICZ1c2VkLT5sZW4pKSB7CisJCQl2cV9lcnIo
dnEsICJGYWlsZWQgdG8gd3JpdGUgdXNlZCBsZW4iKTsKKwkJCXJldHVybiAtRUZBVUxUOworCQl9
CiAJfQogCS8qIE1ha2Ugc3VyZSBidWZmZXIgaXMgd3JpdHRlbiBiZWZvcmUgd2UgdXBkYXRlIGlu
ZGV4LiAqLwogCXNtcF93bWIoKTsKLQlpZiAocHV0X3VzZXIodnEtPmxhc3RfdXNlZF9pZHggKyAx
LCAmdnEtPnVzZWQtPmlkeCkpIHsKKwlpZiAocHV0X3VzZXIodnEtPmxhc3RfdXNlZF9pZHgsICZ2
cS0+dXNlZC0+aWR4KSkgewogCQl2cV9lcnIodnEsICJGYWlsZWQgdG8gaW5jcmVtZW50IHVzZWQg
aWR4Iik7CiAJCXJldHVybiAtRUZBVUxUOwogCX0KQEAgLTEwMTEsNyArMTA0NCw2IEBACiAJCWlm
ICh2cS0+bG9nX2N0eCkKIAkJCWV2ZW50ZmRfc2lnbmFsKHZxLT5sb2dfY3R4LCAxKTsKIAl9Ci0J
dnEtPmxhc3RfdXNlZF9pZHgrKzsKIAlyZXR1cm4gMDsKIH0KIApAQCAtMTAzOCw5ICsxMDcwLDkg
QEAKIC8qIEFuZCBoZXJlJ3MgdGhlIGNvbWJvIG1lYWwgZGVhbC4gIFN1cGVyc2l6ZSBtZSEgKi8K
IHZvaWQgdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbChzdHJ1Y3Qgdmhvc3RfZGV2ICpkZXYsCiAJ
CQkgICAgICAgc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqdnEsCi0JCQkgICAgICAgdW5zaWduZWQg
aW50IGhlYWQsIGludCBsZW4pCisJCQkgICAgICAgc3RydWN0IGlvdmVjICpoZWFkcywgaW50IGNv
dW50KQogewotCXZob3N0X2FkZF91c2VkKHZxLCBoZWFkLCBsZW4pOworCXZob3N0X2FkZF91c2Vk
KHZxLCBoZWFkcywgY291bnQpOwogCXZob3N0X3NpZ25hbChkZXYsIHZxKTsKIH0KIApkaWZmIC1y
dU4gbmV0LW5leHQtcDAvZHJpdmVycy92aG9zdC92aG9zdC5oIG5ldC1uZXh0LXAxL2RyaXZlcnMv
dmhvc3Qvdmhvc3QuaAotLS0gbmV0LW5leHQtcDAvZHJpdmVycy92aG9zdC92aG9zdC5oCTIwMTAt
MDItMTUgMjA6MDg6MzUuMDAwMDAwMDAwIC0wODAwCisrKyBuZXQtbmV4dC1wMS9kcml2ZXJzL3Zo
b3N0L3Zob3N0LmgJMjAxMC0wMy0wMSAxMTo0MjoxOC4wMDAwMDAwMDAgLTA4MDAKQEAgLTg0LDYg
Kzg0LDcgQEAKIAlzdHJ1Y3QgaW92ZWMgaW5kaXJlY3RbVkhPU1RfTkVUX01BWF9TR107CiAJc3Ry
dWN0IGlvdmVjIGlvdltWSE9TVF9ORVRfTUFYX1NHXTsKIAlzdHJ1Y3QgaW92ZWMgaGRyW1ZIT1NU
X05FVF9NQVhfU0ddOworCXN0cnVjdCBpb3ZlYyBoZWFkc1tWSE9TVF9ORVRfTUFYX1NHXTsKIAlz
aXplX3QgaGRyX3NpemU7CiAJLyogV2UgdXNlIGEga2luZCBvZiBSQ1UgdG8gYWNjZXNzIHByaXZh
dGUgcG9pbnRlci4KIAkgKiBBbGwgcmVhZGVycyBhY2Nlc3MgaXQgZnJvbSB3b3JrcXVldWUsIHdo
aWNoIG1ha2VzIGl0IHBvc3NpYmxlIHRvCkBAIC0xMjAsMTYgKzEyMSwxOCBAQAogaW50IHZob3N0
X3ZxX2FjY2Vzc19vayhzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSk7CiBpbnQgdmhvc3RfbG9n
X2FjY2Vzc19vayhzdHJ1Y3Qgdmhvc3RfZGV2ICopOwogCit1bnNpZ25lZCB2aG9zdF9nZXRfaGVh
ZHMoc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqLCBpbnQgZGF0YWxlbiwgaW50ICppb3Zjb3VudCwK
KwkJCXN0cnVjdCB2aG9zdF9sb2cgKmxvZywgdW5zaWduZWQgaW50ICpsb2dfbnVtKTsKIHVuc2ln
bmVkIHZob3N0X2dldF92cV9kZXNjKHN0cnVjdCB2aG9zdF9kZXYgKiwgc3RydWN0IHZob3N0X3Zp
cnRxdWV1ZSAqLAogCQkJICAgc3RydWN0IGlvdmVjIGlvdltdLCB1bnNpZ25lZCBpbnQgaW92X2Nv
dW50LAogCQkJICAgdW5zaWduZWQgaW50ICpvdXRfbnVtLCB1bnNpZ25lZCBpbnQgKmluX251bSwK
IAkJCSAgIHN0cnVjdCB2aG9zdF9sb2cgKmxvZywgdW5zaWduZWQgaW50ICpsb2dfbnVtKTsKLXZv
aWQgdmhvc3RfZGlzY2FyZF92cV9kZXNjKHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKik7Cit2b2lk
IHZob3N0X2Rpc2NhcmQoc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqLCBpbnQpOwogCi1pbnQgdmhv
c3RfYWRkX3VzZWQoc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqLCB1bnNpZ25lZCBpbnQgaGVhZCwg
aW50IGxlbik7Ci12b2lkIHZob3N0X3NpZ25hbChzdHJ1Y3Qgdmhvc3RfZGV2ICosIHN0cnVjdCB2
aG9zdF92aXJ0cXVldWUgKik7CitpbnQgdmhvc3RfYWRkX3VzZWQoc3RydWN0IHZob3N0X3ZpcnRx
dWV1ZSAqLCBzdHJ1Y3QgaW92ZWMgKmhlYWRzLCBpbnQgY291bnQpOwogdm9pZCB2aG9zdF9hZGRf
dXNlZF9hbmRfc2lnbmFsKHN0cnVjdCB2aG9zdF9kZXYgKiwgc3RydWN0IHZob3N0X3ZpcnRxdWV1
ZSAqLAotCQkJICAgICAgIHVuc2lnbmVkIGludCBoZWFkLCBpbnQgbGVuKTsKKwkJCSAgICAgICBz
dHJ1Y3QgaW92ZWMgKmhlYWRzLCBpbnQgY291bnQpOwordm9pZCB2aG9zdF9zaWduYWwoc3RydWN0
IHZob3N0X2RldiAqLCBzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICopOwogdm9pZCB2aG9zdF9kaXNh
YmxlX25vdGlmeShzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICopOwogYm9vbCB2aG9zdF9lbmFibGVf
bm90aWZ5KHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKik7CiAK

--=_mixed 0001DA48882576DB_=--
