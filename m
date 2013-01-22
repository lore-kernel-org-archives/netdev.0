From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v4 2/9] rdma/cm: Include AF_IB in loopback and any address checks
Date: Tue, 22 Jan 2013 13:56:30 -0800
Message-ID: <1358891797-14625-3-git-send-email-sean.hefty@intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358891797-14625-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Enhance checks for loopback and any address to support AF_IB
in addition to AF_INET and AF_INT6.  This will allow future
patches to use AF_IB when binding and resolving addresses.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   40 ++++++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d789eea..9e3dc7f 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -50,6 +50,7 @@
 #include <rdma/rdma_cm.h>
 #include <rdma/rdma_cm_ib.h>
 #include <rdma/rdma_netlink.h>
+#include <rdma/ib.h>
 #include <rdma/ib_cache.h>
 #include <rdma/ib_cm.h>
 #include <rdma/ib_sa.h>
@@ -679,26 +680,30 @@ EXPORT_SYMBOL(rdma_init_qp_attr);
 
 static inline int cma_zero_addr(struct sockaddr *addr)
 {
-	struct in6_addr *ip6;
-
-	if (addr->sa_family == AF_INET)
-		return ipv4_is_zeronet(
-			((struct sockaddr_in *)addr)->sin_addr.s_addr);
-	else {
-		ip6 = &((struct sockaddr_in6 *) addr)->sin6_addr;
-		return (ip6->s6_addr32[0] | ip6->s6_addr32[1] |
-			ip6->s6_addr32[2] | ip6->s6_addr32[3]) == 0;
+	switch (addr->sa_family) {
+	case AF_INET:
+		return ipv4_is_zeronet(((struct sockaddr_in *)addr)->sin_addr.s_addr);
+	case AF_INET6:
+		return ipv6_addr_any(&((struct sockaddr_in6 *) addr)->sin6_addr);
+	case AF_IB:
+		return ib_addr_any(&((struct sockaddr_ib *) addr)->sib_addr);
+	default:
+		return 0;
 	}
 }
 
 static inline int cma_loopback_addr(struct sockaddr *addr)
 {
-	if (addr->sa_family == AF_INET)
-		return ipv4_is_loopback(
-			((struct sockaddr_in *) addr)->sin_addr.s_addr);
-	else
-		return ipv6_addr_loopback(
-			&((struct sockaddr_in6 *) addr)->sin6_addr);
+	switch (addr->sa_family) {
+	case AF_INET:
+		return ipv4_is_loopback(((struct sockaddr_in *) addr)->sin_addr.s_addr);
+	case AF_INET6:
+		return ipv6_addr_loopback(&((struct sockaddr_in6 *) addr)->sin6_addr);
+	case AF_IB:
+		return ib_addr_loopback(&((struct sockaddr_ib *) addr)->sib_addr);
+	default:
+		return 0;
+	}
 }
 
 static inline int cma_any_addr(struct sockaddr *addr)
@@ -715,9 +720,12 @@ static int cma_addr_cmp(struct sockaddr *src, struct sockaddr *dst)
 	case AF_INET:
 		return ((struct sockaddr_in *) src)->sin_addr.s_addr !=
 		       ((struct sockaddr_in *) dst)->sin_addr.s_addr;
-	default:
+	case AF_INET6:
 		return ipv6_addr_cmp(&((struct sockaddr_in6 *) src)->sin6_addr,
 				     &((struct sockaddr_in6 *) dst)->sin6_addr);
+	default:
+		return ib_addr_cmp(&((struct sockaddr_ib *) src)->sib_addr,
+				   &((struct sockaddr_ib *) dst)->sib_addr);
 	}
 }
 
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
