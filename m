From: David Stevens <dlstevens@us.ibm.com>
Subject: [RFC][ PATCH 2/3] vhost-net: handle vnet_hdr processing for MRG_RX_BUF
Date: Tue, 2 Mar 2010 17:20:26 -0700
Message-ID: <OF9CBCD776.645508E4-ON882576DB.0000CB6E-882576DB.0001DED1@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0001DECF882576DB_="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: mst@redhat.com, rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 0001DECF882576DB_=
Content-Type: text/plain; charset="US-ASCII"

This patch adds vnet_hdr processing for mergeable buffer
support to vhost-net.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruN net-next-p1/drivers/vhost/net.c net-next-p2/drivers/vhost/net.c
--- net-next-p1/drivers/vhost/net.c     2010-03-01 11:44:22.000000000 
-0800
+++ net-next-p2/drivers/vhost/net.c     2010-03-02 13:01:34.000000000 
-0800
@@ -109,7 +109,6 @@
        };
        size_t len, total_len = 0;
        int err, wmem;
-       size_t hdr_size;
        struct socket *sock = rcu_dereference(vq->private_data);
        if (!sock)
                return;
@@ -124,7 +123,6 @@
 
        if (wmem < sock->sk->sk_sndbuf * 2)
                tx_poll_stop(net);
-       hdr_size = vq->hdr_size;
 
        for (;;) {
                head.iov_base = (void *)vhost_get_vq_desc(&net->dev, vq,
@@ -148,25 +146,45 @@
                               "out %d, int %d\n", out, in);
                        break;
                }
+               if (vq->guest_hlen > vq->sock_hlen) {
+                       if (msg.msg_iov[0].iov_len == vq->guest_hlen)
+                               msg.msg_iov[0].iov_len = vq->sock_hlen;
+                       else if (out == ARRAY_SIZE(vq->iov))
+                               vq_err(vq, "handle_tx iov overflow!");
+                       else {
+                               int i;
+
+                               /* give header its own iov */
+                               for (i=out; i>0; ++i)
+                                       msg.msg_iov[i+1] = msg.msg_iov[i];
+                               msg.msg_iov[0].iov_len = vq->sock_hlen;
+                               msg.msg_iov[1].iov_base += vq->guest_hlen;
+                               msg.msg_iov[1].iov_len -= vq->guest_hlen;
+                               out++;
+                       }
+               }
                /* Skip header. TODO: support TSO. */
-               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
                msg.msg_iovlen = out;
                head.iov_len = len = iov_length(vq->iov, out);
                /* Sanity check */
                if (!len) {
                        vq_err(vq, "Unexpected header len for TX: "
                               "%zd expected %zd\n",
-                              iov_length(vq->hdr, s), hdr_size);
+                              len, vq->guest_hlen);
                        break;
                }
                /* TODO: Check specific error and bomb out unless ENOBUFS? 
*/
                err = sock->ops->sendmsg(NULL, sock, &msg, len);
                if (unlikely(err < 0)) {
-                       vhost_discard(vq, 1);
-                       tx_poll_start(net, sock);
+                       if (err == -EAGAIN) {
+                               tx_poll_start(net, sock);
+                       } else {
+                               vq_err(vq, "sendmsg: errno %d\n", -err);
+                               /* drop packet; do not discard/resend */
+ vhost_add_used_and_signal(&net->dev,vq,&head,1);
+                       }
                        break;
-               }
-               if (err != len)
+               } else if (err != len)
                        pr_err("Truncated TX packet: "
                               " len %d != %zd\n", err, len);
                vhost_add_used_and_signal(&net->dev, vq, &head, 1);
@@ -207,14 +225,8 @@
                .msg_flags = MSG_DONTWAIT,
        };
 
-       struct virtio_net_hdr hdr = {
-               .flags = 0,
-               .gso_type = VIRTIO_NET_HDR_GSO_NONE
-       };
-
        size_t len, total_len = 0;
        int err, headcount, datalen;
-       size_t hdr_size;
        struct socket *sock = rcu_dereference(vq->private_data);
 
        if (!sock || !skb_head_len(&sock->sk->sk_receive_queue))
@@ -223,7 +235,6 @@
        use_mm(net->dev.mm);
        mutex_lock(&vq->mutex);
        vhost_disable_notify(vq);
-       hdr_size = vq->hdr_size;
 
        vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
                vq->log : NULL;
@@ -232,25 +243,18 @@
                headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
&log);
                /* OK, now we need to know about added descriptors. */
                if (!headcount) {
-                       if (unlikely(vhost_enable_notify(vq))) {
-                               /* They have slipped one in as we were
-                                * doing that: check again. */
-                               vhost_disable_notify(vq);
-                               continue;
-                       }
-                       /* Nothing new?  Wait for eventfd to tell us
-                        * they refilled. */
+                       vhost_enable_notify(vq);
                        break;
                }
                /* Skip header. TODO: support TSO/mergeable rx buffers. */
-               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
                msg.msg_iovlen = in;
                len = iov_length(vq->iov, in);
+
                /* Sanity check */
                if (!len) {
                        vq_err(vq, "Unexpected header len for RX: "
                               "%zd expected %zd\n",
-                              iov_length(vq->hdr, s), hdr_size);
+                              len, vq->guest_hlen);
                        break;
                }
                err = sock->ops->recvmsg(NULL, sock, &msg,
@@ -268,13 +272,7 @@
                        continue;
                }
                len = err;
-               err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, 
hdr_size);
-               if (err) {
-                       vq_err(vq, "Unable to write vnet_hdr at addr %p: 
%d\n",
-                              vq->iov->iov_base, err);
-                       break;
-               }
-               len += hdr_size;
+               len += vq->guest_hlen - vq->sock_hlen;
                vhost_add_used_and_signal(&net->dev, vq, vq->heads, 
headcount);
                if (unlikely(vq_log))
                        vhost_log_write(vq, vq_log, log, len);
@@ -483,6 +481,13 @@
        return ERR_PTR(-ENOTSOCK);
 }
 
+static int vhost_sock_is_raw(struct socket *sock)
+{
+       if (!sock || !sock->sk)
+               return 0;
+       return sock->sk->sk_type == SOCK_RAW;
+}
+
 static long vhost_net_set_backend(struct vhost_net *n, unsigned index, 
int fd)
 {
        struct socket *sock, *oldsock;
@@ -519,6 +524,20 @@
 
        vhost_net_disable_vq(n, vq);
        rcu_assign_pointer(vq->private_data, sock);
+
+       if (sock && sock->sk) {
+               if (!vhost_sock_is_raw(sock) ||
+                   vhost_has_feature(&n->dev, 
VHOST_NET_F_VIRTIO_NET_HDR)) {
+                       vq->sock_hlen = sizeof(struct virtio_net_hdr);
+                       if (vhost_has_feature(&n->dev, 
VIRTIO_NET_F_MRG_RXBUF))
+                               vq->guest_hlen =
+                                       sizeof(struct 
virtio_net_hdr_mrg_rxbuf);
+                       else
+                               vq->guest_hlen = sizeof(struct 
virtio_net_hdr);
+               } else
+                       vq->guest_hlen = vq->sock_hlen = 0;
+       } else
+               vq_err(vq, "vhost_net_set_backend: sock->sk is NULL");
        vhost_net_enable_vq(n, vq);
        mutex_unlock(&vq->mutex);
 done:
@@ -566,8 +585,17 @@
        n->dev.acked_features = features;
        smp_wmb();
        for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
-               mutex_lock(&n->vqs[i].mutex);
-               n->vqs[i].hdr_size = hdr_size;
+               struct vhost_virtqueue *vq = n->vqs + i;
+               struct socket *sock = vq->private_data;
+
+               mutex_lock(&vq->mutex);
+               if (features & (1 << VIRTIO_NET_F_MRG_RXBUF))
+                       vq->sock_hlen = sizeof(struct 
virtio_net_hdr_mrg_rxbuf);
+               else if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ||
+                        !vhost_sock_is_raw(sock))
+                       vq->sock_hlen = sizeof(struct virtio_net_hdr);
+               else
+                       vq->sock_hlen = 0;
                mutex_unlock(&n->vqs[i].mutex);
        }
        vhost_net_flush(n);
diff -ruN net-next-p1/drivers/vhost/vhost.c 
net-next-p2/drivers/vhost/vhost.c
--- net-next-p1/drivers/vhost/vhost.c   2010-03-01 11:44:06.000000000 
-0800
+++ net-next-p2/drivers/vhost/vhost.c   2010-03-02 12:53:02.000000000 
-0800
@@ -113,7 +113,8 @@
        vq->used_flags = 0;
        vq->log_used = false;
        vq->log_addr = -1ull;
-       vq->hdr_size = 0;
+       vq->guest_hlen = 0;
+       vq->sock_hlen = 0;
        vq->private_data = NULL;
        vq->log_base = NULL;
        vq->error_ctx = NULL;
@@ -848,20 +849,85 @@
        return 0;
 }
 
+static int
+vhost_get_hdr(struct vhost_virtqueue *vq, int *in, struct vhost_log *log,
+       int *log_num)
+{
+       struct iovec *heads = vq->heads;
+       struct iovec *iov = vq->iov;
+       int out;
+
+       *in = 0;
+       iov[0].iov_len = 0;
+
+       /* get buffer, starting from iov[1] */
+       heads[0].iov_base = (void *)vhost_get_vq_desc(vq->dev, vq,
+               vq->iov+1, ARRAY_SIZE(vq->iov)-1, &out, in, log, log_num);
+       if (out || *in <= 0) {
+               vq_err(vq, "unexpected descriptor format for RX: out %d, "
+                       "in %d\n", out, *in);
+               return 0;
+       }
+       if (heads[0].iov_base == (void *)vq->num)
+               return 0;
+
+       /* make iov[0] the header */
+       if (!vq->guest_hlen) {
+               if (vq->sock_hlen) {
+                       static struct virtio_net_hdr junk; /* bit bucket 
*/
+
+                       iov[0].iov_base = &junk;
+                       iov[0].iov_len = sizeof(junk);
+               } else
+                       iov[0].iov_len = 0;
+       }
+       if (vq->sock_hlen < vq->guest_hlen) {
+               iov[0].iov_base = iov[1].iov_base;
+               iov[0].iov_len = vq->sock_hlen;
+
+               if (iov[1].iov_len < vq->sock_hlen) {
+                       vq_err(vq, "can't fit header in one buffer!");
+                       vhost_discard(vq, 1);
+                       return 0;
+               }
+               if (!vq->sock_hlen) {
+                       static const struct virtio_net_hdr_mrg_rxbuf hdr = 
{
+                               .hdr.flags = 0,
+                               .hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
+                       };
+                       memcpy(iov[0].iov_base, &hdr, vq->guest_hlen);
+               }
+               iov[1].iov_base += vq->guest_hlen;
+               iov[1].iov_len -= vq->guest_hlen;
+       }
+       return 1;
+}
+
 unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 
*iovcount,
        struct vhost_log *log, unsigned int *log_num)
 {
        struct iovec *heads = vq->heads;
-       int out, in;
+       int out, in = 0;
+       int seg = 0;
        int hc = 0;
 
+       if (vq->guest_hlen != vq->sock_hlen) {
+               seg = vhost_get_hdr(vq, &in, log, log_num);
+               if (!seg)
+                       return 0;
+               hc++;
+               datalen -= iov_length(vq->iov+seg, in);
+               seg += in;
+       }
+
        while (datalen > 0) {
                if (hc >= VHOST_NET_MAX_SG) {
                        vhost_discard(vq, hc);
                        return 0;
                }
                heads[hc].iov_base = (void *)vhost_get_vq_desc(vq->dev, 
vq,
-                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, log, 
log_num);
+                       vq->iov+seg, ARRAY_SIZE(vq->iov)-seg, &out, &in,
+                       log, log_num);
                if (heads[hc].iov_base == (void *)vq->num) {
                        vhost_discard(vq, hc);
                        return 0;
@@ -872,11 +938,12 @@
                        vhost_discard(vq, hc);
                        return 0;
                }
-               heads[hc].iov_len = iov_length(vq->iov, in);
-               hc++;
+               heads[hc].iov_len = iov_length(vq->iov+seg, in);
                datalen -= heads[hc].iov_len;
+               hc++;
+               seg += in;
        }
-       *iovcount = in;
+       *iovcount = seg;
        return hc;
 }
 
diff -ruN net-next-p1/drivers/vhost/vhost.h 
net-next-p2/drivers/vhost/vhost.h
--- net-next-p1/drivers/vhost/vhost.h   2010-03-01 11:42:18.000000000 
-0800
+++ net-next-p2/drivers/vhost/vhost.h   2010-03-02 13:02:03.000000000 
-0800
@@ -82,10 +82,9 @@
        u64 log_addr;
 
        struct iovec indirect[VHOST_NET_MAX_SG];
-       struct iovec iov[VHOST_NET_MAX_SG];
-       struct iovec hdr[VHOST_NET_MAX_SG];
+       struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr */
        struct iovec heads[VHOST_NET_MAX_SG];
-       size_t hdr_size;
+       size_t guest_hlen, sock_hlen;
        /* We use a kind of RCU to access private pointer.
         * All readers access it from workqueue, which makes it possible 
to
         * flush the workqueue instead of synchronize_rcu. Therefore 
readers do


--=_mixed 0001DECF882576DB_=
Content-Type: application/octet-stream; name="MRXB2.patch"
Content-Disposition: attachment; filename="MRXB2.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOIG5ldC1uZXh0LXAxL2RyaXZlcnMvdmhvc3QvbmV0LmMgbmV0LW5leHQtcDIvZHJp
dmVycy92aG9zdC9uZXQuYwotLS0gbmV0LW5leHQtcDEvZHJpdmVycy92aG9zdC9uZXQuYwkyMDEw
LTAzLTAxIDExOjQ0OjIyLjAwMDAwMDAwMCAtMDgwMAorKysgbmV0LW5leHQtcDIvZHJpdmVycy92
aG9zdC9uZXQuYwkyMDEwLTAzLTAyIDEzOjAxOjM0LjAwMDAwMDAwMCAtMDgwMApAQCAtMTA5LDcg
KzEwOSw2IEBACiAJfTsKIAlzaXplX3QgbGVuLCB0b3RhbF9sZW4gPSAwOwogCWludCBlcnIsIHdt
ZW07Ci0Jc2l6ZV90IGhkcl9zaXplOwogCXN0cnVjdCBzb2NrZXQgKnNvY2sgPSByY3VfZGVyZWZl
cmVuY2UodnEtPnByaXZhdGVfZGF0YSk7CiAJaWYgKCFzb2NrKQogCQlyZXR1cm47CkBAIC0xMjQs
NyArMTIzLDYgQEAKIAogCWlmICh3bWVtIDwgc29jay0+c2stPnNrX3NuZGJ1ZiAqIDIpCiAJCXR4
X3BvbGxfc3RvcChuZXQpOwotCWhkcl9zaXplID0gdnEtPmhkcl9zaXplOwogCiAJZm9yICg7Oykg
ewogCQloZWFkLmlvdl9iYXNlID0gKHZvaWQgKil2aG9zdF9nZXRfdnFfZGVzYygmbmV0LT5kZXYs
IHZxLApAQCAtMTQ4LDI1ICsxNDYsNDUgQEAKIAkJCSAgICAgICAib3V0ICVkLCBpbnQgJWRcbiIs
IG91dCwgaW4pOwogCQkJYnJlYWs7CiAJCX0KKwkJaWYgKHZxLT5ndWVzdF9obGVuID4gdnEtPnNv
Y2tfaGxlbikgeworCQkJaWYgKG1zZy5tc2dfaW92WzBdLmlvdl9sZW4gPT0gdnEtPmd1ZXN0X2hs
ZW4pCisJCQkJbXNnLm1zZ19pb3ZbMF0uaW92X2xlbiA9IHZxLT5zb2NrX2hsZW47CisJCQllbHNl
IGlmIChvdXQgPT0gQVJSQVlfU0laRSh2cS0+aW92KSkKKwkJCQl2cV9lcnIodnEsICJoYW5kbGVf
dHggaW92IG92ZXJmbG93ISIpOworCQkJZWxzZSB7CisJCQkJaW50IGk7CisKKwkJCQkvKiBnaXZl
IGhlYWRlciBpdHMgb3duIGlvdiAqLworCQkJCWZvciAoaT1vdXQ7IGk+MDsgKytpKQorCQkJCQlt
c2cubXNnX2lvdltpKzFdID0gbXNnLm1zZ19pb3ZbaV07CisJCQkJbXNnLm1zZ19pb3ZbMF0uaW92
X2xlbiA9IHZxLT5zb2NrX2hsZW47CisJCQkJbXNnLm1zZ19pb3ZbMV0uaW92X2Jhc2UgKz0gdnEt
Pmd1ZXN0X2hsZW47CisJCQkJbXNnLm1zZ19pb3ZbMV0uaW92X2xlbiAtPSB2cS0+Z3Vlc3RfaGxl
bjsKKwkJCQlvdXQrKzsKKwkJCX0KKwkJfQogCQkvKiBTa2lwIGhlYWRlci4gVE9ETzogc3VwcG9y
dCBUU08uICovCi0JCXMgPSBtb3ZlX2lvdmVjX2hkcih2cS0+aW92LCB2cS0+aGRyLCBoZHJfc2l6
ZSwgb3V0KTsKIAkJbXNnLm1zZ19pb3ZsZW4gPSBvdXQ7CiAJCWhlYWQuaW92X2xlbiA9IGxlbiA9
IGlvdl9sZW5ndGgodnEtPmlvdiwgb3V0KTsKIAkJLyogU2FuaXR5IGNoZWNrICovCiAJCWlmICgh
bGVuKSB7CiAJCQl2cV9lcnIodnEsICJVbmV4cGVjdGVkIGhlYWRlciBsZW4gZm9yIFRYOiAiCiAJ
CQkgICAgICAgIiV6ZCBleHBlY3RlZCAlemRcbiIsCi0JCQkgICAgICAgaW92X2xlbmd0aCh2cS0+
aGRyLCBzKSwgaGRyX3NpemUpOworCQkJICAgICAgIGxlbiwgdnEtPmd1ZXN0X2hsZW4pOwogCQkJ
YnJlYWs7CiAJCX0KIAkJLyogVE9ETzogQ2hlY2sgc3BlY2lmaWMgZXJyb3IgYW5kIGJvbWIgb3V0
IHVubGVzcyBFTk9CVUZTPyAqLwogCQllcnIgPSBzb2NrLT5vcHMtPnNlbmRtc2coTlVMTCwgc29j
aywgJm1zZywgbGVuKTsKIAkJaWYgKHVubGlrZWx5KGVyciA8IDApKSB7Ci0JCQl2aG9zdF9kaXNj
YXJkKHZxLCAxKTsKLQkJCXR4X3BvbGxfc3RhcnQobmV0LCBzb2NrKTsKKwkJCWlmIChlcnIgPT0g
LUVBR0FJTikgeworCQkJCXR4X3BvbGxfc3RhcnQobmV0LCBzb2NrKTsKKwkJCX0gZWxzZSB7CisJ
CQkJdnFfZXJyKHZxLCAic2VuZG1zZzogZXJybm8gJWRcbiIsIC1lcnIpOworCQkJCS8qIGRyb3Ag
cGFja2V0OyBkbyBub3QgZGlzY2FyZC9yZXNlbmQgKi8KKwkJCQl2aG9zdF9hZGRfdXNlZF9hbmRf
c2lnbmFsKCZuZXQtPmRldix2cSwmaGVhZCwxKTsKKwkJCX0KIAkJCWJyZWFrOwotCQl9Ci0JCWlm
IChlcnIgIT0gbGVuKQorCQl9IGVsc2UgaWYgKGVyciAhPSBsZW4pCiAJCQlwcl9lcnIoIlRydW5j
YXRlZCBUWCBwYWNrZXQ6ICIKIAkJCSAgICAgICAiIGxlbiAlZCAhPSAlemRcbiIsIGVyciwgbGVu
KTsKIAkJdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbCgmbmV0LT5kZXYsIHZxLCAmaGVhZCwgMSk7
CkBAIC0yMDcsMTQgKzIyNSw4IEBACiAJCS5tc2dfZmxhZ3MgPSBNU0dfRE9OVFdBSVQsCiAJfTsK
IAotCXN0cnVjdCB2aXJ0aW9fbmV0X2hkciBoZHIgPSB7Ci0JCS5mbGFncyA9IDAsCi0JCS5nc29f
dHlwZSA9IFZJUlRJT19ORVRfSERSX0dTT19OT05FCi0JfTsKLQogCXNpemVfdCBsZW4sIHRvdGFs
X2xlbiA9IDA7CiAJaW50IGVyciwgaGVhZGNvdW50LCBkYXRhbGVuOwotCXNpemVfdCBoZHJfc2l6
ZTsKIAlzdHJ1Y3Qgc29ja2V0ICpzb2NrID0gcmN1X2RlcmVmZXJlbmNlKHZxLT5wcml2YXRlX2Rh
dGEpOwogCiAJaWYgKCFzb2NrIHx8ICFza2JfaGVhZF9sZW4oJnNvY2stPnNrLT5za19yZWNlaXZl
X3F1ZXVlKSkKQEAgLTIyMyw3ICsyMzUsNiBAQAogCXVzZV9tbShuZXQtPmRldi5tbSk7CiAJbXV0
ZXhfbG9jaygmdnEtPm11dGV4KTsKIAl2aG9zdF9kaXNhYmxlX25vdGlmeSh2cSk7Ci0JaGRyX3Np
emUgPSB2cS0+aGRyX3NpemU7CiAKIAl2cV9sb2cgPSB1bmxpa2VseSh2aG9zdF9oYXNfZmVhdHVy
ZSgmbmV0LT5kZXYsIFZIT1NUX0ZfTE9HX0FMTCkpID8KIAkJdnEtPmxvZyA6IE5VTEw7CkBAIC0y
MzIsMjUgKzI0MywxOCBAQAogCQloZWFkY291bnQgPSB2aG9zdF9nZXRfaGVhZHModnEsIGRhdGFs
ZW4sICZpbiwgdnFfbG9nLCAmbG9nKTsKIAkJLyogT0ssIG5vdyB3ZSBuZWVkIHRvIGtub3cgYWJv
dXQgYWRkZWQgZGVzY3JpcHRvcnMuICovCiAJCWlmICghaGVhZGNvdW50KSB7Ci0JCQlpZiAodW5s
aWtlbHkodmhvc3RfZW5hYmxlX25vdGlmeSh2cSkpKSB7Ci0JCQkJLyogVGhleSBoYXZlIHNsaXBw
ZWQgb25lIGluIGFzIHdlIHdlcmUKLQkJCQkgKiBkb2luZyB0aGF0OiBjaGVjayBhZ2Fpbi4gKi8K
LQkJCQl2aG9zdF9kaXNhYmxlX25vdGlmeSh2cSk7Ci0JCQkJY29udGludWU7Ci0JCQl9Ci0JCQkv
KiBOb3RoaW5nIG5ldz8gIFdhaXQgZm9yIGV2ZW50ZmQgdG8gdGVsbCB1cwotCQkJICogdGhleSBy
ZWZpbGxlZC4gKi8KKwkJCXZob3N0X2VuYWJsZV9ub3RpZnkodnEpOwogCQkJYnJlYWs7CiAJCX0K
IAkJLyogU2tpcCBoZWFkZXIuIFRPRE86IHN1cHBvcnQgVFNPL21lcmdlYWJsZSByeCBidWZmZXJz
LiAqLwotCQlzID0gbW92ZV9pb3ZlY19oZHIodnEtPmlvdiwgdnEtPmhkciwgaGRyX3NpemUsIGlu
KTsKIAkJbXNnLm1zZ19pb3ZsZW4gPSBpbjsKIAkJbGVuID0gaW92X2xlbmd0aCh2cS0+aW92LCBp
bik7CisKIAkJLyogU2FuaXR5IGNoZWNrICovCiAJCWlmICghbGVuKSB7CiAJCQl2cV9lcnIodnEs
ICJVbmV4cGVjdGVkIGhlYWRlciBsZW4gZm9yIFJYOiAiCiAJCQkgICAgICAgIiV6ZCBleHBlY3Rl
ZCAlemRcbiIsCi0JCQkgICAgICAgaW92X2xlbmd0aCh2cS0+aGRyLCBzKSwgaGRyX3NpemUpOwor
CQkJICAgICAgIGxlbiwgdnEtPmd1ZXN0X2hsZW4pOwogCQkJYnJlYWs7CiAJCX0KIAkJZXJyID0g
c29jay0+b3BzLT5yZWN2bXNnKE5VTEwsIHNvY2ssICZtc2csCkBAIC0yNjgsMTMgKzI3Miw3IEBA
CiAJCQljb250aW51ZTsKIAkJfQogCQlsZW4gPSBlcnI7Ci0JCWVyciA9IG1lbWNweV90b2lvdmVj
KHZxLT5oZHIsICh1bnNpZ25lZCBjaGFyICopJmhkciwgaGRyX3NpemUpOwotCQlpZiAoZXJyKSB7
Ci0JCQl2cV9lcnIodnEsICJVbmFibGUgdG8gd3JpdGUgdm5ldF9oZHIgYXQgYWRkciAlcDogJWRc
biIsCi0JCQkgICAgICAgdnEtPmlvdi0+aW92X2Jhc2UsIGVycik7Ci0JCQlicmVhazsKLQkJfQot
CQlsZW4gKz0gaGRyX3NpemU7CisJCWxlbiArPSB2cS0+Z3Vlc3RfaGxlbiAtIHZxLT5zb2NrX2hs
ZW47CiAJCXZob3N0X2FkZF91c2VkX2FuZF9zaWduYWwoJm5ldC0+ZGV2LCB2cSwgdnEtPmhlYWRz
LCBoZWFkY291bnQpOwogCQlpZiAodW5saWtlbHkodnFfbG9nKSkKIAkJCXZob3N0X2xvZ193cml0
ZSh2cSwgdnFfbG9nLCBsb2csIGxlbik7CkBAIC00ODMsNiArNDgxLDEzIEBACiAJcmV0dXJuIEVS
Ul9QVFIoLUVOT1RTT0NLKTsKIH0KIAorc3RhdGljIGludCB2aG9zdF9zb2NrX2lzX3JhdyhzdHJ1
Y3Qgc29ja2V0ICpzb2NrKQoreworCWlmICghc29jayB8fCAhc29jay0+c2spCisJCXJldHVybiAw
OworCXJldHVybiBzb2NrLT5zay0+c2tfdHlwZSA9PSBTT0NLX1JBVzsKK30KKwogc3RhdGljIGxv
bmcgdmhvc3RfbmV0X3NldF9iYWNrZW5kKHN0cnVjdCB2aG9zdF9uZXQgKm4sIHVuc2lnbmVkIGlu
ZGV4LCBpbnQgZmQpCiB7CiAJc3RydWN0IHNvY2tldCAqc29jaywgKm9sZHNvY2s7CkBAIC01MTks
NiArNTI0LDIwIEBACiAKIAl2aG9zdF9uZXRfZGlzYWJsZV92cShuLCB2cSk7CiAJcmN1X2Fzc2ln
bl9wb2ludGVyKHZxLT5wcml2YXRlX2RhdGEsIHNvY2spOworCisJaWYgKHNvY2sgJiYgc29jay0+
c2spIHsKKwkJaWYgKCF2aG9zdF9zb2NrX2lzX3Jhdyhzb2NrKSB8fAorCQkgICAgdmhvc3RfaGFz
X2ZlYXR1cmUoJm4tPmRldiwgVkhPU1RfTkVUX0ZfVklSVElPX05FVF9IRFIpKSB7CisJCQl2cS0+
c29ja19obGVuID0gc2l6ZW9mKHN0cnVjdCB2aXJ0aW9fbmV0X2hkcik7CisJCQlpZiAodmhvc3Rf
aGFzX2ZlYXR1cmUoJm4tPmRldiwgVklSVElPX05FVF9GX01SR19SWEJVRikpCisJCQkJdnEtPmd1
ZXN0X2hsZW4gPQorCQkJCQlzaXplb2Yoc3RydWN0IHZpcnRpb19uZXRfaGRyX21yZ19yeGJ1Zik7
CisJCQllbHNlCisJCQkJdnEtPmd1ZXN0X2hsZW4gPSBzaXplb2Yoc3RydWN0IHZpcnRpb19uZXRf
aGRyKTsKKwkJfSBlbHNlCisJCQl2cS0+Z3Vlc3RfaGxlbiA9IHZxLT5zb2NrX2hsZW4gPSAwOwor
CX0gZWxzZQorCQl2cV9lcnIodnEsICJ2aG9zdF9uZXRfc2V0X2JhY2tlbmQ6IHNvY2stPnNrIGlz
IE5VTEwiKTsKIAl2aG9zdF9uZXRfZW5hYmxlX3ZxKG4sIHZxKTsKIAltdXRleF91bmxvY2soJnZx
LT5tdXRleCk7CiBkb25lOgpAQCAtNTY2LDggKzU4NSwxNyBAQAogCW4tPmRldi5hY2tlZF9mZWF0
dXJlcyA9IGZlYXR1cmVzOwogCXNtcF93bWIoKTsKIAlmb3IgKGkgPSAwOyBpIDwgVkhPU1RfTkVU
X1ZRX01BWDsgKytpKSB7Ci0JCW11dGV4X2xvY2soJm4tPnZxc1tpXS5tdXRleCk7Ci0JCW4tPnZx
c1tpXS5oZHJfc2l6ZSA9IGhkcl9zaXplOworCQlzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSA9
IG4tPnZxcyArIGk7CisJCXN0cnVjdCBzb2NrZXQgKnNvY2sgPSB2cS0+cHJpdmF0ZV9kYXRhOwor
CisJCW11dGV4X2xvY2soJnZxLT5tdXRleCk7CisJCWlmIChmZWF0dXJlcyAmICgxIDw8IFZJUlRJ
T19ORVRfRl9NUkdfUlhCVUYpKQorCQkJdnEtPnNvY2tfaGxlbiA9IHNpemVvZihzdHJ1Y3Qgdmly
dGlvX25ldF9oZHJfbXJnX3J4YnVmKTsKKwkJZWxzZSBpZiAoZmVhdHVyZXMgJiAoMSA8PCBWSE9T
VF9ORVRfRl9WSVJUSU9fTkVUX0hEUikgfHwKKwkJCSAhdmhvc3Rfc29ja19pc19yYXcoc29jaykp
CisJCQl2cS0+c29ja19obGVuID0gc2l6ZW9mKHN0cnVjdCB2aXJ0aW9fbmV0X2hkcik7CisJCWVs
c2UKKwkJCXZxLT5zb2NrX2hsZW4gPSAwOwogCQltdXRleF91bmxvY2soJm4tPnZxc1tpXS5tdXRl
eCk7CiAJfQogCXZob3N0X25ldF9mbHVzaChuKTsKZGlmZiAtcnVOIG5ldC1uZXh0LXAxL2RyaXZl
cnMvdmhvc3Qvdmhvc3QuYyBuZXQtbmV4dC1wMi9kcml2ZXJzL3Zob3N0L3Zob3N0LmMKLS0tIG5l
dC1uZXh0LXAxL2RyaXZlcnMvdmhvc3Qvdmhvc3QuYwkyMDEwLTAzLTAxIDExOjQ0OjA2LjAwMDAw
MDAwMCAtMDgwMAorKysgbmV0LW5leHQtcDIvZHJpdmVycy92aG9zdC92aG9zdC5jCTIwMTAtMDMt
MDIgMTI6NTM6MDIuMDAwMDAwMDAwIC0wODAwCkBAIC0xMTMsNyArMTEzLDggQEAKIAl2cS0+dXNl
ZF9mbGFncyA9IDA7CiAJdnEtPmxvZ191c2VkID0gZmFsc2U7CiAJdnEtPmxvZ19hZGRyID0gLTF1
bGw7Ci0JdnEtPmhkcl9zaXplID0gMDsKKwl2cS0+Z3Vlc3RfaGxlbiA9IDA7CisJdnEtPnNvY2tf
aGxlbiA9IDA7CiAJdnEtPnByaXZhdGVfZGF0YSA9IE5VTEw7CiAJdnEtPmxvZ19iYXNlID0gTlVM
TDsKIAl2cS0+ZXJyb3JfY3R4ID0gTlVMTDsKQEAgLTg0OCwyMCArODQ5LDg1IEBACiAJcmV0dXJu
IDA7CiB9CiAKK3N0YXRpYyBpbnQKK3Zob3N0X2dldF9oZHIoc3RydWN0IHZob3N0X3ZpcnRxdWV1
ZSAqdnEsIGludCAqaW4sIHN0cnVjdCB2aG9zdF9sb2cgKmxvZywKKwlpbnQgKmxvZ19udW0pCit7
CisJc3RydWN0IGlvdmVjICpoZWFkcyA9IHZxLT5oZWFkczsKKwlzdHJ1Y3QgaW92ZWMgKmlvdiA9
IHZxLT5pb3Y7CisJaW50IG91dDsKKworCSppbiA9IDA7CisJaW92WzBdLmlvdl9sZW4gPSAwOwor
CisJLyogZ2V0IGJ1ZmZlciwgc3RhcnRpbmcgZnJvbSBpb3ZbMV0gKi8KKwloZWFkc1swXS5pb3Zf
YmFzZSA9ICh2b2lkICopdmhvc3RfZ2V0X3ZxX2Rlc2ModnEtPmRldiwgdnEsCisJCXZxLT5pb3Yr
MSwgQVJSQVlfU0laRSh2cS0+aW92KS0xLCAmb3V0LCBpbiwgbG9nLCBsb2dfbnVtKTsKKwlpZiAo
b3V0IHx8ICppbiA8PSAwKSB7CisJCXZxX2Vycih2cSwgInVuZXhwZWN0ZWQgZGVzY3JpcHRvciBm
b3JtYXQgZm9yIFJYOiBvdXQgJWQsICIKKwkJCSJpbiAlZFxuIiwgb3V0LCAqaW4pOworCQlyZXR1
cm4gMDsKKwl9CisJaWYgKGhlYWRzWzBdLmlvdl9iYXNlID09ICh2b2lkICopdnEtPm51bSkKKwkJ
cmV0dXJuIDA7CisKKwkvKiBtYWtlIGlvdlswXSB0aGUgaGVhZGVyICovCisJaWYgKCF2cS0+Z3Vl
c3RfaGxlbikgeworCQlpZiAodnEtPnNvY2tfaGxlbikgeworCQkJc3RhdGljIHN0cnVjdCB2aXJ0
aW9fbmV0X2hkciBqdW5rOyAvKiBiaXQgYnVja2V0ICovCisKKwkJCWlvdlswXS5pb3ZfYmFzZSA9
ICZqdW5rOworCQkJaW92WzBdLmlvdl9sZW4gPSBzaXplb2YoanVuayk7CisJCX0gZWxzZQorCQkJ
aW92WzBdLmlvdl9sZW4gPSAwOworCX0KKwlpZiAodnEtPnNvY2tfaGxlbiA8IHZxLT5ndWVzdF9o
bGVuKSB7CisJCWlvdlswXS5pb3ZfYmFzZSA9IGlvdlsxXS5pb3ZfYmFzZTsKKwkJaW92WzBdLmlv
dl9sZW4gPSB2cS0+c29ja19obGVuOworCisJCWlmIChpb3ZbMV0uaW92X2xlbiA8IHZxLT5zb2Nr
X2hsZW4pIHsKKwkJCXZxX2Vycih2cSwgImNhbid0IGZpdCBoZWFkZXIgaW4gb25lIGJ1ZmZlciEi
KTsKKwkJCXZob3N0X2Rpc2NhcmQodnEsIDEpOworCQkJcmV0dXJuIDA7CisJCX0KKwkJaWYgKCF2
cS0+c29ja19obGVuKSB7CisJCQlzdGF0aWMgY29uc3Qgc3RydWN0IHZpcnRpb19uZXRfaGRyX21y
Z19yeGJ1ZiBoZHIgPSB7CisJCQkJLmhkci5mbGFncyA9IDAsCisJCQkJLmhkci5nc29fdHlwZSA9
IFZJUlRJT19ORVRfSERSX0dTT19OT05FCisJCQl9OworCQkJbWVtY3B5KGlvdlswXS5pb3ZfYmFz
ZSwgJmhkciwgdnEtPmd1ZXN0X2hsZW4pOworCQl9CisJCWlvdlsxXS5pb3ZfYmFzZSArPSB2cS0+
Z3Vlc3RfaGxlbjsKKwkJaW92WzFdLmlvdl9sZW4gLT0gdnEtPmd1ZXN0X2hsZW47CisJfQorCXJl
dHVybiAxOworfQorCiB1bnNpZ25lZCB2aG9zdF9nZXRfaGVhZHMoc3RydWN0IHZob3N0X3ZpcnRx
dWV1ZSAqdnEsIGludCBkYXRhbGVuLCBpbnQgKmlvdmNvdW50LAogCXN0cnVjdCB2aG9zdF9sb2cg
KmxvZywgdW5zaWduZWQgaW50ICpsb2dfbnVtKQogewogCXN0cnVjdCBpb3ZlYyAqaGVhZHMgPSB2
cS0+aGVhZHM7Ci0JaW50IG91dCwgaW47CisJaW50IG91dCwgaW4gPSAwOworCWludCBzZWcgPSAw
OwogCWludCBoYyA9IDA7CiAKKwlpZiAodnEtPmd1ZXN0X2hsZW4gIT0gdnEtPnNvY2tfaGxlbikg
eworCQlzZWcgPSB2aG9zdF9nZXRfaGRyKHZxLCAmaW4sIGxvZywgbG9nX251bSk7CisJCWlmICgh
c2VnKQorCQkJcmV0dXJuIDA7CisJCWhjKys7CisJCWRhdGFsZW4gLT0gaW92X2xlbmd0aCh2cS0+
aW92K3NlZywgaW4pOworCQlzZWcgKz0gaW47CisJfQorCiAJd2hpbGUgKGRhdGFsZW4gPiAwKSB7
CiAJCWlmIChoYyA+PSBWSE9TVF9ORVRfTUFYX1NHKSB7CiAJCQl2aG9zdF9kaXNjYXJkKHZxLCBo
Yyk7CiAJCQlyZXR1cm4gMDsKIAkJfQogCQloZWFkc1toY10uaW92X2Jhc2UgPSAodm9pZCAqKXZo
b3N0X2dldF92cV9kZXNjKHZxLT5kZXYsIHZxLAotCQkJdnEtPmlvdiwgQVJSQVlfU0laRSh2cS0+
aW92KSwgJm91dCwgJmluLCBsb2csIGxvZ19udW0pOworCQkJdnEtPmlvditzZWcsIEFSUkFZX1NJ
WkUodnEtPmlvdiktc2VnLCAmb3V0LCAmaW4sCisJCQlsb2csIGxvZ19udW0pOwogCQlpZiAoaGVh
ZHNbaGNdLmlvdl9iYXNlID09ICh2b2lkICopdnEtPm51bSkgewogCQkJdmhvc3RfZGlzY2FyZCh2
cSwgaGMpOwogCQkJcmV0dXJuIDA7CkBAIC04NzIsMTEgKzkzOCwxMiBAQAogCQkJdmhvc3RfZGlz
Y2FyZCh2cSwgaGMpOwogCQkJcmV0dXJuIDA7CiAJCX0KLQkJaGVhZHNbaGNdLmlvdl9sZW4gPSBp
b3ZfbGVuZ3RoKHZxLT5pb3YsIGluKTsKLQkJaGMrKzsKKwkJaGVhZHNbaGNdLmlvdl9sZW4gPSBp
b3ZfbGVuZ3RoKHZxLT5pb3Yrc2VnLCBpbik7CiAJCWRhdGFsZW4gLT0gaGVhZHNbaGNdLmlvdl9s
ZW47CisJCWhjKys7CisJCXNlZyArPSBpbjsKIAl9Ci0JKmlvdmNvdW50ID0gaW47CisJKmlvdmNv
dW50ID0gc2VnOwogCXJldHVybiBoYzsKIH0KIApkaWZmIC1ydU4gbmV0LW5leHQtcDEvZHJpdmVy
cy92aG9zdC92aG9zdC5oIG5ldC1uZXh0LXAyL2RyaXZlcnMvdmhvc3Qvdmhvc3QuaAotLS0gbmV0
LW5leHQtcDEvZHJpdmVycy92aG9zdC92aG9zdC5oCTIwMTAtMDMtMDEgMTE6NDI6MTguMDAwMDAw
MDAwIC0wODAwCisrKyBuZXQtbmV4dC1wMi9kcml2ZXJzL3Zob3N0L3Zob3N0LmgJMjAxMC0wMy0w
MiAxMzowMjowMy4wMDAwMDAwMDAgLTA4MDAKQEAgLTgyLDEwICs4Miw5IEBACiAJdTY0IGxvZ19h
ZGRyOwogCiAJc3RydWN0IGlvdmVjIGluZGlyZWN0W1ZIT1NUX05FVF9NQVhfU0ddOwotCXN0cnVj
dCBpb3ZlYyBpb3ZbVkhPU1RfTkVUX01BWF9TR107Ci0Jc3RydWN0IGlvdmVjIGhkcltWSE9TVF9O
RVRfTUFYX1NHXTsKKwlzdHJ1Y3QgaW92ZWMgaW92W1ZIT1NUX05FVF9NQVhfU0crMV07IC8qIGFu
IGV4dHJhIGZvciB2bmV0IGhkciAqLwogCXN0cnVjdCBpb3ZlYyBoZWFkc1tWSE9TVF9ORVRfTUFY
X1NHXTsKLQlzaXplX3QgaGRyX3NpemU7CisJc2l6ZV90IGd1ZXN0X2hsZW4sIHNvY2tfaGxlbjsK
IAkvKiBXZSB1c2UgYSBraW5kIG9mIFJDVSB0byBhY2Nlc3MgcHJpdmF0ZSBwb2ludGVyLgogCSAq
IEFsbCByZWFkZXJzIGFjY2VzcyBpdCBmcm9tIHdvcmtxdWV1ZSwgd2hpY2ggbWFrZXMgaXQgcG9z
c2libGUgdG8KIAkgKiBmbHVzaCB0aGUgd29ya3F1ZXVlIGluc3RlYWQgb2Ygc3luY2hyb25pemVf
cmN1LiBUaGVyZWZvcmUgcmVhZGVycyBkbwo=

--=_mixed 0001DECF882576DB_=--
