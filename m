From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2] vhost: rcu annotation fixup
Date: Tue, 18 Jan 2011 20:08:13 +0200
Message-ID: <20110118180813.GA18757@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When built with rcu checks enabled, vhost triggers
bogus warnings as vhost features are read without
dev->mutex sometimes, and private pointer is read
with our kind of rcu where work serves as a
read side critical section.

Fixing it properly is not trivial.
Disable the warnings by stubbing out the checks for now.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v1: add TODO, fix more warnings.

 drivers/vhost/net.c   |    9 +++++----
 drivers/vhost/vhost.h |    6 +++---
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9b3ca10..f616cef 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -128,8 +128,7 @@ static void handle_tx(struct vhost_net *net)
 	size_t hdr_size;
 	struct socket *sock;
 
-	/* TODO: check that we are running from vhost_worker?
-	 * Not sure it's worth it, it's straight-forward enough. */
+	/* TODO: check that we are running from vhost_worker? */
 	sock = rcu_dereference_check(vq->private_data, 1);
 	if (!sock)
 		return;
@@ -306,7 +305,8 @@ static void handle_rx_big(struct vhost_net *net)
 	size_t len, total_len = 0;
 	int err;
 	size_t hdr_size;
-	struct socket *sock = rcu_dereference(vq->private_data);
+	/* TODO: check that we are running from vhost_worker? */
+	struct socket *sock = rcu_dereference_check(vq->private_data, 1);
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
@@ -415,7 +415,8 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	int err, headcount;
 	size_t vhost_hlen, sock_hlen;
 	size_t vhost_len, sock_len;
-	struct socket *sock = rcu_dereference(vq->private_data);
+	/* TODO: check that we are running from vhost_worker? */
+	struct socket *sock = rcu_dereference_check(vq->private_data, 1);
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 2af44b7..b3363ae 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -173,9 +173,9 @@ static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
 {
 	unsigned acked_features;
 
-	acked_features =
-		rcu_dereference_index_check(dev->acked_features,
-					    lockdep_is_held(&dev->mutex));
+	/* TODO: check that we are running from vhost_worker or dev mutex is
+	 * held? */
+	acked_features = rcu_dereference_index_check(dev->acked_features, 1);
 	return acked_features & (1 << bit);
 }
 
-- 
1.7.3.2.91.g446ac
