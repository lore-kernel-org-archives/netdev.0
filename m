From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 22/27] RDMA/netlink: Export node_guid and sys_image_guid
Date: Mon,  3 Jul 2017 09:28:25 +0300
Message-ID: <20170703062830.30361-23-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59672 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752597AbdGCG3u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:50 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Add Node GUID and system image GUID to the device properties
exported by RDMA netlink, to be used by RDMAtool.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c  |  8 ++++++++
 include/uapi/rdma/rdma_netlink.h | 13 +++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 40d5f0eb16f5..fde0138fff5f 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -42,6 +42,8 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_PORT_INDEX]	= { .type = NLA_U32 },
 	[RDMA_NLDEV_ATTR_FW_VERSION]	= { .type = NLA_NUL_STRING,
 					    .len = IB_FW_VERSION_NAME_MAX - 1},
+	[RDMA_NLDEV_ATTR_NODE_GUID]	= { .type = NLA_U64 },
+	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = { .type = NLA_U64 },
 };
 
 static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
@@ -65,6 +67,12 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 	if (strlen(fw) && nla_put_string(msg, RDMA_NLDEV_ATTR_FW_VERSION, fw))
 		return -EMSGSIZE;
 
+	if (nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_NODE_GUID,
+			      be64_to_cpu(device->node_guid), 0))
+		return -EMSGSIZE;
+	if (nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_SYS_IMAGE_GUID,
+			      be64_to_cpu(device->attrs.sys_image_guid), 0))
+		return -EMSGSIZE;
 	return 0;
 }
 
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index fec735f73eee..b34f7745daf0 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -266,6 +266,19 @@ enum rdma_nldev_attr {
 	 * FW version
 	 */
 	RDMA_NLDEV_ATTR_FW_VERSION,		/* string */
+
+	/*
+	 * Node GUID (in host byte order) associated with the RDMA device.
+	 */
+	RDMA_NLDEV_ATTR_NODE_GUID,			/* u64 */
+
+	/*
+	 * System image GUID (in host byte order) associated with
+	 * this RDMA device and other devices which are part of a
+	 * single system.
+	 */
+	RDMA_NLDEV_ATTR_SYS_IMAGE_GUID,		/* u64 */
+
 	RDMA_NLDEV_ATTR_MAX
 };
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.2
