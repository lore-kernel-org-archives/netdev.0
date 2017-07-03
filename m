From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 24/27] RDMA/netink: Export lids and sm_lids
Date: Mon,  3 Jul 2017 09:28:27 +0300
Message-ID: <20170703062830.30361-25-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59704 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752564AbdGCG34 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:56 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

According to the IB specification, the LID and SM_LID
are 16-bit wide, but to support OmniPath users, export
it as 32-bit value from the beginning.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c  | 9 ++++++++-
 include/uapi/rdma/rdma_netlink.h | 8 ++++++++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index c4884841e2fe..ce733bf33ed9 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -45,6 +45,8 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_NODE_GUID]	= { .type = NLA_U64 },
 	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = { .type = NLA_U64 },
 	[RDMA_NLDEV_ATTR_SUBNET_PREFIX]	= { .type = NLA_U64 },
+	[RDMA_NLDEV_ATTR_LID]		= { .type = NLA_U32 },
+	[RDMA_NLDEV_ATTR_SM_LID]	= { .type = NLA_U32 },
 };
 
 static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
@@ -102,7 +104,12 @@ static int fill_port_info(struct sk_buff *msg,
 	    nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_SUBNET_PREFIX,
 			      attr.subnet_prefix, 0))
 		return -EMSGSIZE;
-
+	if (rdma_protocol_ib(device, port)) {
+		if (nla_put_u32(msg, RDMA_NLDEV_ATTR_LID, attr.lid))
+			return -EMSGSIZE;
+		if (nla_put_u32(msg, RDMA_NLDEV_ATTR_SM_LID, attr.sm_lid))
+			return -EMSGSIZE;
+	}
 	return 0;
 }
 
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index 24712d810dca..82e0d64346e1 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -284,6 +284,14 @@ enum rdma_nldev_attr {
 	 */
 	RDMA_NLDEV_ATTR_SUBNET_PREFIX,		/* u64 */
 
+	/*
+	 * Local Identifier (LID),
+	 * According to IB specification, It is 16-bit address assigned
+	 * by the Subnet Manager. Extended to be 32-bit for OmniPath users.
+	 */
+	RDMA_NLDEV_ATTR_LID,			/* u32 */
+	RDMA_NLDEV_ATTR_SM_LID,			/* u32 */
+
 	RDMA_NLDEV_ATTR_MAX
 };
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.2
