From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/26 v3] rdma/cm: Include AF_IB in loopback and any address
 checks
Date: Mon, 24 Sep 2012 23:55:27 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0A2@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Enhance checks for loopback and any address to support AF_IB
in addition to AF_INET and AF_INET6.  This will allow future
patches to use AF_IB when binding and resolving addresses.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |   40 ++++++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 2e826f9..e3d2837 100644
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
@@ -674,26 +675,30 @@ EXPORT_SYMBOL(rdma_init_qp_attr);
 
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
@@ -710,9 +715,12 @@ static int cma_addr_cmp(struct sockaddr *src, struct sockaddr *dst)
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
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
