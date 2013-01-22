From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v4 4/9] rdma/cm: Update port reservation to support AF_IB
Date: Tue, 22 Jan 2013 13:56:32 -0800
Message-ID: <1358891797-14625-5-git-send-email-sean.hefty@intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358891797-14625-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

The AF_IB uses a 64-bit service id (SID), which the
user can control through the use of a mask.  The rdma_cm
will assign values to the unmasked portions of the SID
based on the selected port space and port number.

Because the IB spec divides the SID range into several regions,
a SID/mask combination may fall into one of the existing
port space ranges as defined by the RDMA CM IP Annex.  Map
the AF_IB SID to the correct RDMA port space.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |  107 +++++++++++++++++++++++++++++++++--------
 include/rdma/rdma_cm.h        |    5 ++
 2 files changed, 91 insertions(+), 21 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index e08f830..7eed4ee 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -729,12 +729,22 @@ static int cma_addr_cmp(struct sockaddr *src, struct sockaddr *dst)
 	}
 }
 
-static inline __be16 cma_port(struct sockaddr *addr)
+static __be16 cma_port(struct sockaddr *addr)
 {
-	if (addr->sa_family == AF_INET)
+	struct sockaddr_ib *sib;
+
+	switch (addr->sa_family) {
+	case AF_INET:
 		return ((struct sockaddr_in *) addr)->sin_port;
-	else
+	case AF_INET6:
 		return ((struct sockaddr_in6 *) addr)->sin6_port;
+	case AF_IB:
+		sib = (struct sockaddr_ib *) addr;
+		return htons((u16) (be64_to_cpu(sib->sib_sid) &
+				    be64_to_cpu(sib->sib_sid_mask)));
+	default:
+		return 0;
+	}
 }
 
 static inline int cma_any_port(struct sockaddr *addr)
@@ -2139,10 +2149,29 @@ EXPORT_SYMBOL(rdma_set_afonly);
 static void cma_bind_port(struct rdma_bind_list *bind_list,
 			  struct rdma_id_private *id_priv)
 {
-	struct sockaddr_in *sin;
+	struct sockaddr *addr;
+	struct sockaddr_ib *sib;
+	u64 sid, mask;
+	__be16 port;
 
-	sin = (struct sockaddr_in *) &id_priv->id.route.addr.src_addr;
-	sin->sin_port = htons(bind_list->port);
+	addr = (struct sockaddr *) &id_priv->id.route.addr.src_addr;
+	port = htons(bind_list->port);
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *) addr)->sin_port = port;
+		break;
+	case AF_INET6:
+		((struct sockaddr_in6 *) addr)->sin6_port = port;
+		break;
+	case AF_IB:
+		sib = (struct sockaddr_ib *) addr;
+		sid = be64_to_cpu(sib->sib_sid);
+		mask = be64_to_cpu(sib->sib_sid_mask);
+		sib->sib_sid = cpu_to_be64((sid & mask) | (u64) ntohs(port));
+		sib->sib_sid_mask = cpu_to_be64(~0ULL);
+		break;
+	}
 	id_priv->bind_list = bind_list;
 	hlist_add_head(&id_priv->node, &bind_list->owners);
 }
@@ -2280,31 +2309,67 @@ static int cma_bind_listen(struct rdma_id_private *id_priv)
 	return ret;
 }
 
-static int cma_get_port(struct rdma_id_private *id_priv)
+static struct idr *cma_select_inet_ps(struct rdma_id_private *id_priv)
 {
-	struct idr *ps;
-	int ret;
-
 	switch (id_priv->id.ps) {
 	case RDMA_PS_SDP:
-		ps = &sdp_ps;
-		break;
+		return &sdp_ps;
 	case RDMA_PS_TCP:
-		ps = &tcp_ps;
-		break;
+		return &tcp_ps;
 	case RDMA_PS_UDP:
-		ps = &udp_ps;
-		break;
+		return &udp_ps;
 	case RDMA_PS_IPOIB:
-		ps = &ipoib_ps;
-		break;
+		return &ipoib_ps;
 	case RDMA_PS_IB:
-		ps = &ib_ps;
-		break;
+		return &ib_ps;
 	default:
-		return -EPROTONOSUPPORT;
+		return NULL;
+	}
+}
+
+static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
+{
+	struct idr *ps = NULL;
+	struct sockaddr_ib *sib;
+	u64 sid_ps, mask, sid;
+
+	sib = (struct sockaddr_ib *) &id_priv->id.route.addr.src_addr;
+	mask = be64_to_cpu(sib->sib_sid_mask) & RDMA_IB_IP_PS_MASK;
+	sid = be64_to_cpu(sib->sib_sid) & mask;
+
+	if ((id_priv->id.ps == RDMA_PS_IB) && (sid == (RDMA_IB_IP_PS_IB & mask))) {
+		sid_ps = RDMA_IB_IP_PS_IB;
+		ps = &ib_ps;
+	} else if (((id_priv->id.ps == RDMA_PS_IB) || (id_priv->id.ps == RDMA_PS_TCP)) &&
+		   (sid == (RDMA_IB_IP_PS_TCP & mask))) {
+		sid_ps = RDMA_IB_IP_PS_TCP;
+		ps = &tcp_ps;
+	} else if (((id_priv->id.ps == RDMA_PS_IB) || (id_priv->id.ps == RDMA_PS_UDP)) &&
+		   (sid == (RDMA_IB_IP_PS_UDP & mask))) {
+		sid_ps = RDMA_IB_IP_PS_UDP;
+		ps = &udp_ps;
 	}
 
+	if (ps) {
+		sib->sib_sid = cpu_to_be64(sid_ps | ntohs(cma_port((struct sockaddr *) sib)));
+		sib->sib_sid_mask = cpu_to_be64(RDMA_IB_IP_PS_MASK |
+						be64_to_cpu(sib->sib_sid_mask));
+	}
+	return ps;
+}
+
+static int cma_get_port(struct rdma_id_private *id_priv)
+{
+	struct idr *ps;
+	int ret;
+
+	if (id_priv->id.route.addr.src_addr.ss_family != AF_IB)
+		ps = cma_select_inet_ps(id_priv);
+	else
+		ps = cma_select_ib_ps(id_priv);
+	if (!ps)
+		return -EPROTONOSUPPORT;
+
 	mutex_lock(&lock);
 	if (cma_any_port((struct sockaddr *) &id_priv->id.route.addr.src_addr))
 		ret = cma_alloc_any_port(ps, id_priv);
diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
index ad3a314..1e6c3c7 100644
--- a/include/rdma/rdma_cm.h
+++ b/include/rdma/rdma_cm.h
@@ -70,6 +70,11 @@ enum rdma_port_space {
 	RDMA_PS_UDP   = 0x0111,
 };
 
+#define RDMA_IB_IP_PS_MASK   0xFFFFFFFFFFFF0000ULL
+#define RDMA_IB_IP_PS_TCP    0x0000000001060000ULL
+#define RDMA_IB_IP_PS_UDP    0x0000000001110000ULL
+#define RDMA_IB_IP_PS_IB     0x00000000013F0000ULL
+
 struct rdma_addr {
 	struct sockaddr_storage src_addr;
 	struct sockaddr_storage dst_addr;
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
