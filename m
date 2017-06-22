From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V1 19/19] RDMA/netlink: Expose device and port capability masks
Date: Thu, 22 Jun 2017 16:24:34 +0300
Message-ID: <20170622132434.1327-20-leon@kernel.org>
References: <20170622132434.1327-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60930 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753078AbdFVN0B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:26:01 -0400
In-Reply-To: <20170622132434.1327-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

The port capability mask is exposed to user space via sysfs interface,
while device capabilities are available for verbs only.

This patch provides those capabilities through netlink interface.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/nldev.c  | 19 +++++++++++++++++++
 include/uapi/rdma/rdma_netlink.h |  5 +++++
 2 files changed, 24 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 2489ad9d9211..75416f9f7747 100644
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
2.13.1
