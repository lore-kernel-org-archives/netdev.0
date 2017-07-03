From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 21/27] RDMA/netlink: Export FW version
Date: Mon,  3 Jul 2017 09:28:24 +0300
Message-ID: <20170703062830.30361-22-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59642 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752728AbdGCG3q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:46 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Add FW version to the device properties exported
by RDMA netlink, to be used by RDMAtool.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c  | 9 +++++++++
 include/uapi/rdma/rdma_netlink.h | 4 ++++
 2 files changed, 13 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 21e75928400c..40d5f0eb16f5 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -40,10 +40,14 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_DEV_NAME]	= { .type = NLA_NUL_STRING,
 					    .len = IB_DEVICE_NAME_MAX - 1},
 	[RDMA_NLDEV_ATTR_PORT_INDEX]	= { .type = NLA_U32 },
+	[RDMA_NLDEV_ATTR_FW_VERSION]	= { .type = NLA_NUL_STRING,
+					    .len = IB_FW_VERSION_NAME_MAX - 1},
 };
 
 static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 {
+	char fw[IB_FW_VERSION_NAME_MAX];
+
 	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_DEV_INDEX, device->index))
 		return -EMSGSIZE;
 	if (nla_put_string(msg, RDMA_NLDEV_ATTR_DEV_NAME, device->name))
@@ -56,6 +60,11 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 			      device->attrs.device_cap_flags, 0))
 		return -EMSGSIZE;
 
+	ib_get_device_fw_str(device, fw);
+	/* Device without FW has strlen(fw) */
+	if (strlen(fw) && nla_put_string(msg, RDMA_NLDEV_ATTR_FW_VERSION, fw))
+		return -EMSGSIZE;
+
 	return 0;
 }
 
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index 8fc5278d07d6..fec735f73eee 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -262,6 +262,10 @@ enum rdma_nldev_attr {
 	 */
 	RDMA_NLDEV_ATTR_CAP_FLAGS,		/* u64 */
 
+	/*
+	 * FW version
+	 */
+	RDMA_NLDEV_ATTR_FW_VERSION,		/* string */
 	RDMA_NLDEV_ATTR_MAX
 };
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.2
