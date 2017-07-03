From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V2 19/27] RDMA/netlink: Expose device and port capability masks
Date: Mon,  3 Jul 2017 09:28:22 +0300
Message-ID: <20170703062830.30361-20-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170703062830.30361-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

The port capability mask is exposed to user space via sysfs interface,
while device capabilities are available for verbs only.

This patch provides those capabilities through netlink interface.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/core/nldev.c  | 19 +++++++++++++++++++
 include/uapi/rdma/rdma_netlink.h |  5 +++++
 2 files changed, 24 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 533ac72a05b8..21e75928400c 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -50,18 +50,37 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 		return -EMSGSIZE;
 	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_PORT_INDEX, rdma_end_port(device)))
 		return -EMSGSIZE;
+
+	BUILD_BUG_ON(sizeof(device->attrs.device_cap_flags) != sizeof(u64));
+	if (nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_CAP_FLAGS,
+			      device->attrs.device_cap_flags, 0))
+		return -EMSGSIZE;
+
 	return 0;
 }
 
 static int fill_port_info(struct sk_buff *msg,
 			  struct ib_device *device, u32 port)
 {
+	struct ib_port_attr attr;
+	int ret;
+
 	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_DEV_INDEX, device->index))
 		return -EMSGSIZE;
 	if (nla_put_string(msg, RDMA_NLDEV_ATTR_DEV_NAME, device->name))
 		return -EMSGSIZE;
 	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_PORT_INDEX, port))
 		return -EMSGSIZE;
+
+	ret = ib_query_port(device, port, &attr);
+	if (ret)
+		return ret;
+
+	BUILD_BUG_ON(sizeof(attr.port_cap_flags) > sizeof(u64));
+	if (nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_CAP_FLAGS,
+			      (u64)attr.port_cap_flags, 0))
+		return -EMSGSIZE;
+
 	return 0;
 }
 
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index 1d064fedfa9a..8fc5278d07d6 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -257,6 +257,11 @@ enum rdma_nldev_attr {
 	 */
 	RDMA_NLDEV_ATTR_PORT_INDEX,		/* u32 */
 
+	/*
+	 * Device and port capabilities
+	 */
+	RDMA_NLDEV_ATTR_CAP_FLAGS,		/* u64 */
+
 	RDMA_NLDEV_ATTR_MAX
 };
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
