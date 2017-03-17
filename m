From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 04/18] net,
	vxlan: convert vxlan_sock.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 13:12:45 +0200
Message-ID: <1489749179-12063-5-git-send-email-elena.reshetova@intel.com>
References: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Cc: peterz@infradead.org, jchapman@katalix.com,
	Elena Reshetova <elena.reshetova@intel.com>,
	johan.hedberg@gmail.com, linux-x25@vger.kernel.org,
	bridge@lists.linux-foundation.org, jmorris@namei.org,
	3chas3@gmail.com, Hans Liljestrand <ishkamiel@gmail.com>,
	keescook@chromium.org, marcel@holtmann.org, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, linux-hams@vger.kernel.org,
	David Windsor <dwindsor@gmail.com>, yoshfuji@linux-ipv6.org,
	linux-decnet-user@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	kaber@trash.net, linux-bluetooth@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/net/vxlan.c | 10 +++++-----
 include/net/vxlan.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b791199..21a9251 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -999,11 +999,11 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 	/* The vxlan_sock is only used by dev, leaving group has
 	 * no effect on other vxlan devices.
 	 */
-	if (family == AF_INET && sock4 && atomic_read(&sock4->refcnt) == 1)
+	if (family == AF_INET && sock4 && refcount_read(&sock4->refcnt) == 1)
 		return false;
 #if IS_ENABLED(CONFIG_IPV6)
 	sock6 = rtnl_dereference(dev->vn6_sock);
-	if (family == AF_INET6 && sock6 && atomic_read(&sock6->refcnt) == 1)
+	if (family == AF_INET6 && sock6 && refcount_read(&sock6->refcnt) == 1)
 		return false;
 #endif
 
@@ -1040,7 +1040,7 @@ static bool __vxlan_sock_release_prep(struct vxlan_sock *vs)
 
 	if (!vs)
 		return false;
-	if (!atomic_dec_and_test(&vs->refcnt))
+	if (!refcount_dec_and_test(&vs->refcnt))
 		return false;
 
 	vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
@@ -2757,7 +2757,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	}
 
 	vs->sock = sock;
-	atomic_set(&vs->refcnt, 1);
+	refcount_set(&vs->refcnt, 1);
 	vs->flags = (flags & VXLAN_F_RCV_FLAGS);
 
 	spin_lock(&vn->sock_lock);
@@ -2791,7 +2791,7 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 		spin_lock(&vn->sock_lock);
 		vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
 				     vxlan->cfg.dst_port, vxlan->flags);
-		if (vs && !atomic_add_unless(&vs->refcnt, 1, 0)) {
+		if (vs && !refcount_inc_not_zero(&vs->refcnt)) {
 			spin_unlock(&vn->sock_lock);
 			return -EBUSY;
 		}
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 49a5920..5c117b4 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -183,7 +183,7 @@ struct vxlan_sock {
 	struct hlist_node hlist;
 	struct socket	 *sock;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
-	atomic_t	  refcnt;
+	refcount_t	  refcnt;
 	u32		  flags;
 };
 
-- 
2.7.4
