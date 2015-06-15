From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 09/11] IB/cma: validate routing of incoming requests
Date: Mon, 15 Jun 2015 11:47:14 +0300
Message-ID: <1434358036-15526-10-git-send-email-haggaie@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pass incoming request parameters through the relevant IPv4/IPv6 routing
tables and make sure the network stack is configured to handle such
requests.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c | 100 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 97 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index a43bbd57400c..74e562ec5b93 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -46,6 +46,8 @@
 
 #include <net/tcp.h>
 #include <net/ipv6.h>
+#include <net/ip_fib.h>
+#include <net/ip6_route.h>
 
 #include <rdma/rdma_cm.h>
 #include <rdma/rdma_cm_ib.h>
@@ -1062,15 +1064,102 @@ static int cma_save_req_info(const struct ib_cm_event *ib_event,
 	return 0;
 }
 
+static bool validate_ipv4_net_dev(struct net_device *net_dev,
+				  const struct sockaddr_in *dst_addr,
+				  const struct sockaddr_in *src_addr)
+{
+	struct in_device *in_dev = in_dev_get(net_dev);
+	__be32 daddr = dst_addr->sin_addr.s_addr,
+	       saddr = src_addr->sin_addr.s_addr;
+	struct fib_result res;
+	struct flowi4 fl4;
+	int err;
+	bool ret = false;
+
+	if (!in_dev)
+		return false;
+
+	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
+	    ipv4_is_lbcast(daddr) || ipv4_is_zeronet(saddr) ||
+	    ipv4_is_zeronet(daddr) || ipv4_is_loopback(daddr) ||
+	    ipv4_is_loopback(saddr))
+		goto out;
+
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.flowi4_iif = net_dev->ifindex;
+	fl4.daddr = daddr;
+	fl4.saddr = saddr;
+	err = fib_lookup(dev_net(net_dev), &fl4, &res);
+	if (err)
+		goto out;
+
+	if (res.fi->fib_dev != net_dev)
+		goto out;
+
+	ret = true;
+out:
+	in_dev_put(in_dev);
+	return ret;
+}
+
+static bool validate_ipv6_net_dev(struct net_device *net_dev,
+				  const struct sockaddr_in6 *dst_addr,
+				  const struct sockaddr_in6 *src_addr)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	const int strict = ipv6_addr_type(&dst_addr->sin6_addr) &
+			   IPV6_ADDR_LINKLOCAL;
+	struct rt6_info *rt = rt6_lookup(dev_net(net_dev), &dst_addr->sin6_addr,
+					 &src_addr->sin6_addr, net_dev->ifindex,
+					 strict);
+	bool ret;
+
+	if (!rt)
+		return false;
+
+	ret = rt->rt6i_idev->dev == net_dev;
+	ip6_rt_put(rt);
+
+	return ret;
+#else
+	return false;
+#endif
+}
+
+static bool validate_net_dev(struct net_device *net_dev,
+			     const struct sockaddr *daddr,
+			     const struct sockaddr *saddr)
+{
+	const struct sockaddr_in *daddr4 = (const struct sockaddr_in *)daddr;
+	const struct sockaddr_in *saddr4 = (const struct sockaddr_in *)saddr;
+	const struct sockaddr_in6 *daddr6 = (const struct sockaddr_in6 *)daddr;
+	const struct sockaddr_in6 *saddr6 = (const struct sockaddr_in6 *)saddr;
+
+	switch (daddr->sa_family) {
+	case AF_INET:
+		return saddr->sa_family == AF_INET &&
+		       validate_ipv4_net_dev(net_dev, daddr4, saddr4);
+
+	case AF_INET6:
+		return saddr->sa_family == AF_INET6 &&
+		       validate_ipv6_net_dev(net_dev, daddr6, saddr6);
+
+	default:
+		return false;
+	}
+}
+
 static struct net_device *cma_get_net_dev(struct ib_cm_event *ib_event,
 					  const struct cma_req_info *req)
 {
-	struct sockaddr_storage listen_addr_storage;
-	struct sockaddr *listen_addr = (struct sockaddr *)&listen_addr_storage;
+	struct sockaddr_storage listen_addr_storage, src_addr_storage;
+	struct sockaddr *listen_addr = (struct sockaddr *)&listen_addr_storage,
+			*src_addr = (struct sockaddr *)&src_addr_storage;
 	struct net_device *net_dev;
 	int err;
 
-	err = cma_save_ip_info(listen_addr, NULL, ib_event, req->service_id);
+	err = cma_save_ip_info(listen_addr, src_addr, ib_event,
+			       req->service_id);
 	if (err)
 		return ERR_PTR(err);
 
@@ -1079,6 +1168,11 @@ static struct net_device *cma_get_net_dev(struct ib_cm_event *ib_event,
 	if (!net_dev)
 		return ERR_PTR(-ENODEV);
 
+	if (!validate_net_dev(net_dev, listen_addr, src_addr)) {
+		dev_put(net_dev);
+		return ERR_PTR(-EHOSTUNREACH);
+	}
+
 	return net_dev;
 }
 
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
