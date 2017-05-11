From: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Subject: Support for VETH_MRU in libnl
Date: Thu, 11 May 2017 15:46:29 +0200
Message-ID: <20170511134629.139528-4-fredrik.markstrom@gmail.com>
References: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	Fredrik Markstrom <fredrik.markstrom@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
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

---
 include/linux/if_link.h           |   1 +
 include/netlink-private/types.h   |   1 +
 include/netlink/route/link/veth.h |   4 ++
 lib/route/link.c                  |   4 ++
 lib/route/link/veth.c             | 141 +++++++++++++++++++++++++++++---------
 5 files changed, 118 insertions(+), 33 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 8b84939..b9859bd 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -316,6 +316,7 @@ struct ifla_vxlan_port_range {
 enum {
 	VETH_INFO_UNSPEC,
 	VETH_INFO_PEER,
+	VETH_MRU,
 
 	__VETH_INFO_MAX
 #define VETH_INFO_MAX   (__VETH_INFO_MAX - 1)
diff --git a/include/netlink-private/types.h b/include/netlink-private/types.h
index 3ff4fe1..c97090b 100644
--- a/include/netlink-private/types.h
+++ b/include/netlink-private/types.h
@@ -165,6 +165,7 @@ struct rtnl_link
 	uint32_t			l_flags;
 	uint32_t			l_change;
 	uint32_t 			l_mtu;
+	uint32_t 			l_mru;
 	uint32_t			l_link;
 	uint32_t			l_txqlen;
 	uint32_t			l_weight;
diff --git a/include/netlink/route/link/veth.h b/include/netlink/route/link/veth.h
index 35c2345..58eeb98 100644
--- a/include/netlink/route/link/veth.h
+++ b/include/netlink/route/link/veth.h
@@ -29,6 +29,10 @@ extern struct rtnl_link *rtnl_link_veth_get_peer(struct rtnl_link *);
 extern int rtnl_link_veth_add(struct nl_sock *sock, const char *name,
 			      const char *peer, pid_t pid);
 
+extern int rtnl_link_veth_set_mru(struct rtnl_link *, uint32_t);
+
+extern uint32_t rtnl_link_veth_get_mru(struct rtnl_link *);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/lib/route/link.c b/lib/route/link.c
index 3d31ffc..3cdacbb 100644
--- a/lib/route/link.c
+++ b/lib/route/link.c
@@ -61,6 +61,7 @@
 #define LINK_ATTR_PHYS_PORT_ID	(1 << 28)
 #define LINK_ATTR_NS_FD		(1 << 29)
 #define LINK_ATTR_NS_PID	(1 << 30)
+#define LINK_ATTR_MRU		(1 << 31)
 
 static struct nl_cache_ops rtnl_link_ops;
 static struct nl_object_ops link_obj_ops;
@@ -1255,6 +1256,9 @@ int rtnl_link_fill_info(struct nl_msg *msg, struct rtnl_link *link)
 	if (link->ce_mask & LINK_ATTR_MTU)
 		NLA_PUT_U32(msg, IFLA_MTU, link->l_mtu);
 
+	if (link->ce_mask & LINK_ATTR_MRU)
+		NLA_PUT_U32(msg, IFLA_MTU, link->l_mru);
+
 	if (link->ce_mask & LINK_ATTR_TXQLEN)
 		NLA_PUT_U32(msg, IFLA_TXQLEN, link->l_txqlen);
 
diff --git a/lib/route/link/veth.c b/lib/route/link/veth.c
index e7e4a26..5dc15af 100644
--- a/lib/route/link/veth.c
+++ b/lib/route/link/veth.c
@@ -33,16 +33,62 @@
 
 #include <linux/if_link.h>
 
+#define VETH_HAS_MRU		(1<<0)
+
+struct veth_info
+{
+	struct rtnl_link *peer;
+	uint32_t		vei_mru;
+	uint32_t		vei_mask;
+};
+
 static struct nla_policy veth_policy[VETH_INFO_MAX+1] = {
 	[VETH_INFO_PEER]	= { .minlen = sizeof(struct ifinfomsg) },
+	[VETH_MRU]		= { .type = NLA_U32 },
 };
 
+static int veth_alloc(struct rtnl_link *link)
+{
+	struct rtnl_link *peer;
+	struct veth_info *vei = link->l_info;
+	int err;
+
+	/* return early if we are in recursion */
+	if (vei && vei->peer)
+		return 0;
+
+	if (!(peer = rtnl_link_alloc()))
+		return -NLE_NOMEM;
+
+	if ((vei = calloc(1, sizeof(*vei))) == NULL)
+	  return -NLE_NOMEM;
+
+	/* We don't need to hold a reference here, as link and
+	 * its peer should always be freed together.
+	 */
+	vei->peer = link;
+
+	peer->l_info = vei;
+	if ((err = rtnl_link_set_type(peer, "veth")) < 0) {
+		rtnl_link_put(peer);
+		return err;
+	}
+
+	if ((vei = calloc(1, sizeof(*vei))) == NULL)
+	  return -NLE_NOMEM;
+
+	vei->peer = peer;
+	link->l_info = vei;
+	return 0;
+}
+
 static int veth_parse(struct rtnl_link *link, struct nlattr *data,
 		      struct nlattr *xstats)
 {
 	struct nlattr *tb[VETH_INFO_MAX+1];
 	struct nlattr *peer_tb[IFLA_MAX + 1];
-	struct rtnl_link *peer = link->l_info;
+	struct veth_info *vei = link->l_info;
+	struct rtnl_link *peer = vei->peer;
 	int err;
 
 	NL_DBG(3, "Parsing veth link info");
@@ -50,6 +96,14 @@ static int veth_parse(struct rtnl_link *link, struct nlattr *data,
 	if ((err = nla_parse_nested(tb, VETH_INFO_MAX, data, veth_policy)) < 0)
 		goto errout;
 
+	if ((err = veth_alloc(link)) < 0)
+		goto errout;
+
+	if (tb[VETH_MRU]) {
+		vei->vei_mru = nla_get_u32(tb[VETH_MRU]);
+		vei->vei_mask |= VETH_HAS_MRU;
+	}
+
 	if (tb[VETH_INFO_PEER]) {
 		struct nlattr *nla_peer;
 		struct ifinfomsg *ifi;
@@ -86,7 +140,8 @@ static void veth_dump_line(struct rtnl_link *link, struct nl_dump_params *p)
 
 static void veth_dump_details(struct rtnl_link *link, struct nl_dump_params *p)
 {
-	struct rtnl_link *peer = link->l_info;
+	struct veth_info *vei = link->l_info;
+	struct rtnl_link *peer = vei->peer;
 	char *name;
 	name = rtnl_link_get_name(peer);
 	nl_dump(p, "      peer ");
@@ -98,7 +153,14 @@ static void veth_dump_details(struct rtnl_link *link, struct nl_dump_params *p)
 
 static int veth_clone(struct rtnl_link *dst, struct rtnl_link *src)
 {
-	struct rtnl_link *dst_peer = NULL, *src_peer = src->l_info;
+	struct veth_info *src_vei = src->l_info;
+	struct veth_info *dst_vei = dst->l_info;
+	struct rtnl_link *dst_peer = NULL, *src_peer = src_vei->peer;
+
+
+	printf("veth_clone not implemented\n");
+
+	// FIXME:
 
 	/* we are calling nl_object_clone() recursively, this should
 	 * happen only once */
@@ -116,7 +178,8 @@ static int veth_clone(struct rtnl_link *dst, struct rtnl_link *src)
 
 static int veth_put_attrs(struct nl_msg *msg, struct rtnl_link *link)
 {
-	struct rtnl_link *peer = link->l_info;
+	struct veth_info *vei = link->l_info;
+	struct rtnl_link *peer = vei->peer;
 	struct ifinfomsg ifi;
 	struct nlattr *data, *info_peer;
 
@@ -135,44 +198,31 @@ static int veth_put_attrs(struct nl_msg *msg, struct rtnl_link *link)
 		return -NLE_MSGSIZE;
 	rtnl_link_fill_info(msg, peer);
 	nla_nest_end(msg, info_peer);
-	nla_nest_end(msg, data);
 
-	return 0;
-}
-
-static int veth_alloc(struct rtnl_link *link)
-{
-	struct rtnl_link *peer;
-	int err;
-
-	/* return early if we are in recursion */
-	if (link->l_info)
-		return 0;
+	if (vei->vei_mask & VETH_HAS_MRU)
+		NLA_PUT_U32(msg, VETH_MRU, vei->vei_mru);
 
-	if (!(peer = rtnl_link_alloc()))
-		return -NLE_NOMEM;
+	nla_nest_end(msg, data);
 
-	/* We don't need to hold a reference here, as link and
-	 * its peer should always be freed together.
-	 */
-	peer->l_info = link;
-	if ((err = rtnl_link_set_type(peer, "veth")) < 0) {
-		rtnl_link_put(peer);
-		return err;
-	}
+nla_put_failure:
 
-	link->l_info = peer;
 	return 0;
 }
 
 static void veth_free(struct rtnl_link *link)
 {
-	struct rtnl_link *peer = link->l_info;
-	if (peer) {
+	struct veth_info *vei = link->l_info;
+	if (vei) {
+		struct rtnl_link *peer = vei->peer;
+		if (peer) {
+			vei->peer = NULL;
+			rtnl_link_put(peer);
+			/* avoid calling this recursively */
+			free(peer->l_info);
+			peer->l_info = NULL;
+		}
+		free(vei);
 		link->l_info = NULL;
-		/* avoid calling this recursively */
-		peer->l_info = NULL;
-		rtnl_link_put(peer);
 	}
 	/* the caller should finally free link */
 }
@@ -195,7 +245,7 @@ static struct rtnl_link_info_ops veth_info_ops = {
 #define IS_VETH_LINK_ASSERT(link) \
 	if ((link)->l_info_ops != &veth_info_ops) { \
 		APPBUG("Link is not a veth link. set type \"veth\" first."); \
-		return NULL; \
+		return -NLE_OPNOTSUPP; \
 	}
 /** @endcond */
 
@@ -293,6 +343,31 @@ int rtnl_link_veth_add(struct nl_sock *sock, const char *name,
 	return err;
 }
 
+int rtnl_link_veth_set_mru(struct rtnl_link *link, uint32_t mru)
+{
+	struct veth_info *vei = link->l_info;
+
+	IS_VETH_LINK_ASSERT(link);
+
+	vei->vei_mru = mru;
+	vei->vei_mask |= VETH_HAS_MRU;
+
+	return 0;
+}
+
+uint32_t rtnl_link_veth_get_mru(struct rtnl_link *link)
+{
+	struct veth_info *vei = link->l_info;
+
+	IS_VETH_LINK_ASSERT(link);
+
+	if (vei->vei_mask & VETH_HAS_MRU)
+		return vei->vei_mru;
+	else
+		return 0;
+}
+
+
 /** @} */
 
 static void __init veth_init(void)
-- 
2.10.1
