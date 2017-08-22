From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 2/5] xdp: make generic xdp redirect use tracepoint
 trace_xdp_redirect
Date: Tue, 22 Aug 2017 22:47:24 +0200
Message-ID: <150343484470.31091.11187498529801746935.stgit@firesoul>
References: <150343479290.31091.8019008896152616977.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40252 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752477AbdHVUr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 16:47:26 -0400
In-Reply-To: <150343479290.31091.8019008896152616977.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the xdp_do_generic_redirect() call fails, it trigger the
trace_xdp_exception tracepoint.  It seems better to use the same
tracepoint trace_xdp_redirect, as the native xdp_do_redirect{,_map} does.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/filter.h |    3 ++-
 net/core/dev.c         |    4 ++--
 net/core/filter.c      |   36 ++++++++++++++++++++++--------------
 3 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7015116331af..d29e58fde364 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -718,7 +718,8 @@ struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
  * because we only track one map and force a flush when the map changes.
  * This does not appear to be a real limitation for existing software.
  */
-int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb);
+int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
+			    struct bpf_prog *prog);
 int xdp_do_redirect(struct net_device *dev,
 		    struct xdp_buff *xdp,
 		    struct bpf_prog *prog);
diff --git a/net/core/dev.c b/net/core/dev.c
index 40b28e417072..270b54754821 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3953,7 +3953,8 @@ int do_xdp_generic(struct bpf_prog *xdp_prog, struct sk_buff *skb)
 		if (act != XDP_PASS) {
 			switch (act) {
 			case XDP_REDIRECT:
-				err = xdp_do_generic_redirect(skb->dev, skb);
+				err = xdp_do_generic_redirect(skb->dev, skb,
+							      xdp_prog);
 				if (err)
 					goto out_redir;
 			/* fallthru to submit skb */
@@ -3966,7 +3967,6 @@ int do_xdp_generic(struct bpf_prog *xdp_prog, struct sk_buff *skb)
 	}
 	return XDP_PASS;
 out_redir:
-	trace_xdp_exception(skb->dev, xdp_prog, XDP_REDIRECT);
 	kfree_skb(skb);
 	return XDP_DROP;
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index 31c579749679..2d7cdb2c5c66 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2582,29 +2582,37 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
 
-int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
+int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
+			    struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
-	unsigned int len;
 	u32 index = ri->ifindex;
+	struct net_device *fwd;
+	unsigned int len;
+	int err = 0;
 
-	dev = dev_get_by_index_rcu(dev_net(dev), index);
+	fwd = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
-	if (unlikely(!dev)) {
-		goto err;
+	if (unlikely(!fwd)) {
+		err = -EINVAL;
+		goto out;
 	}
 
-	if (unlikely(!(dev->flags & IFF_UP)))
-		goto err;
+	if (unlikely(!(fwd->flags & IFF_UP))) {
+		err = -ENOLINK;
+		goto out;
+	}
 
-	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
-	if (skb->len > len)
-		goto err;
+	len = fwd->mtu + fwd->hard_header_len + VLAN_HLEN;
+	if (skb->len > len) {
+		err = -EMSGSIZE;
+		goto out;
+	}
 
-	skb->dev = dev;
-	return 0;
-err:
-	return -EINVAL;
+	skb->dev = fwd;
+out:
+	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
+	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
 
