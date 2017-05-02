From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH] xdp: use common helper for netlink extended ack reporting
Date: Wed,  3 May 2017 00:39:17 +0200
Message-ID: <9dc20d2c3cca095b42e730655c8fd9f5d59a4568.1493763990.git.daniel@iogearbox.net>
Cc: jakub.kicinski@netronome.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43164 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbdEBWji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 18:39:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small follow-up to d74a32acd59a ("xdp: use netlink extended ACK reporting")
in order to let drivers all use the same NL_SET_ERR_MSG_MOD() helper macro
for reporting. This also ensures that we consistently add the driver's
prefix for dumping the report in user space to indicate that the error
message is driver specific and not coming from core code. Furthermore,
NL_SET_ERR_MSG_MOD() now reuses NL_SET_ERR_MSG() and thus makes all macros
check the pointer as suggested.

References: https://www.spinics.net/lists/netdev/msg433267.html
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ( Would still be good to have this so that also virtio_net sets the
   prefix for user error messages. Thanks! )

 drivers/net/ethernet/netronome/nfp/nfp_net_common.c |  4 ++--
 drivers/net/virtio_net.c                            |  8 ++++----
 include/linux/netlink.h                             | 19 ++++++++-----------
 3 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index db20376..82bd6b0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2532,11 +2532,11 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn)
 	if (!dp->xdp_prog)
 		return 0;
 	if (dp->fl_bufsz > PAGE_SIZE) {
-		NL_MOD_TRY_SET_ERR_MSG(extack, "MTU too large w/ XDP enabled");
+		NL_SET_ERR_MSG_MOD(extack, "MTU too large w/ XDP enabled");
 		return -EINVAL;
 	}
 	if (dp->num_tx_rings > nn->max_tx_rings) {
-		NL_MOD_TRY_SET_ERR_MSG(extack, "Insufficient number of TX rings w/ XDP enabled");
+		NL_SET_ERR_MSG_MOD(extack, "Insufficient number of TX rings w/ XDP enabled");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3d0bc48..1c6d392 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1891,17 +1891,17 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO)) {
-		NL_SET_ERR_MSG(extack, "can't set XDP while host is implementing LRO, disable LRO first");
+		NL_SET_ERR_MSG_MOD(extack, "Can't set XDP while host is implementing LRO, disable LRO first");
 		return -EOPNOTSUPP;
 	}
 
 	if (vi->mergeable_rx_bufs && !vi->any_header_sg) {
-		NL_SET_ERR_MSG(extack, "XDP expects header/data in single page, any_header_sg required");
+		NL_SET_ERR_MSG_MOD(extack, "XDP expects header/data in single page, any_header_sg required");
 		return -EINVAL;
 	}
 
 	if (dev->mtu > max_sz) {
-		NL_SET_ERR_MSG(extack, "MTU too large to enable XDP");
+		NL_SET_ERR_MSG_MOD(extack, "MTU too large to enable XDP");
 		netdev_warn(dev, "XDP requires MTU less than %lu\n", max_sz);
 		return -EINVAL;
 	}
@@ -1912,7 +1912,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
 
 	/* XDP requires extra queues for XDP_TX */
 	if (curr_qp + xdp_qp > vi->max_queue_pairs) {
-		NL_SET_ERR_MSG(extack, "Too few free TX rings available");
+		NL_SET_ERR_MSG_MOD(extack, "Too few free TX rings available");
 		netdev_warn(dev, "request %i queues but max is %i\n",
 			    curr_qp + xdp_qp, vi->max_queue_pairs);
 		return -ENOMEM;
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index c20395e..5fff5ba 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -86,19 +86,16 @@ struct netlink_ext_ack {
  * Currently string formatting is not supported (due
  * to the lack of an output buffer.)
  */
-#define NL_SET_ERR_MSG(extack, msg) do {	\
-	static const char _msg[] = (msg);	\
-						\
-	(extack)->_msg = _msg;			\
+#define NL_SET_ERR_MSG(extack, msg) do {		\
+	static const char __msg[] = (msg);		\
+	struct netlink_ext_ack *__extack = (extack);	\
+							\
+	if (__extack)					\
+		__extack->_msg = __msg;			\
 } while (0)
 
-#define NL_MOD_TRY_SET_ERR_MSG(extack, msg) do {		\
-	static const char _msg[] = KBUILD_MODNAME ": " msg;	\
-	struct netlink_ext_ack *_extack = (extack);		\
-								\
-	if (_extack)						\
-		_extack->_msg = _msg;				\
-} while (0)
+#define NL_SET_ERR_MSG_MOD(extack, msg)			\
+	NL_SET_ERR_MSG((extack), KBUILD_MODNAME ": " msg)
 
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
-- 
1.9.3
