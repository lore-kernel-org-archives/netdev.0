From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V1 13/19] RDMA/netlink: Add netlink device definitions to UAPI
Date: Thu, 22 Jun 2017 16:24:28 +0300
Message-ID: <20170622132434.1327-14-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.99]:60828 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753078AbdFVNZv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:25:51 -0400
In-Reply-To: <20170622132434.1327-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Introduce new defines to rdma_netlink.h, so the RDMA configuration tool
will be able to communicate with RDMA subsystem by using the shared defines.

The addition of new client (NLDEV) revealed the fact that we exposed by
mistake the RDMA_NL_I40IW define which is not backed by any RDMA netlink
by now and it won't be exposed in the future too. So this patch reuses
the value and deletes the old defines.

The NLDEV operates with objects. The struct ib_device has two straightforward
objects: device itself and ports of that device.

This brings us to propose the following commands to work on those objects:
 * RDMA_NLDEV_CMD_{GET,SET,NEW,DEL} - works on ib_device itself
 * RDMA_NLDEV_CMD_PORT_{GET,SET,NEW,DEL} - works on ports of specific ib_device

Those commands receive/return the device index (RDMA_NLDEV_ATTR_DEV_INDEX)
and port index (RDMA_NLDEV_ATTR_PORT_INDEX). For device object accesses,
the RDMA_NLDEV_ATTR_PORT_INDEX will return the maximum number of ports
for specific ib_device and for port access the actual port index.

The port index starts from 1 to follow RDMA/core internal semantics and
the sysfs exposed knobs.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/netlink.c |  2 +-
 include/uapi/rdma/rdma_netlink.h  | 39 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 58b7ec213c59..9b6b9b84f856 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -60,7 +60,7 @@ static bool is_nl_msg_valid(unsigned int type, unsigned int op)
 				  RDMA_NL_IWPM_NUM_OPS,
 				  0,
 				  RDMA_NL_LS_NUM_OPS,
-				  0 };
+				  RDMA_NLDEV_NUM_OPS };
 
 	/*
 	 * This BUILD_BUG_ON is intended to catch addition of new
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index 02fe8390c18f..1d064fedfa9a 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -8,7 +8,7 @@ enum {
 	RDMA_NL_IWCM,
 	RDMA_NL_RSVD,
 	RDMA_NL_LS,	/* RDMA Local Services */
-	RDMA_NL_I40IW,
+	RDMA_NL_NLDEV,	/* RDMA device interface */
 	RDMA_NL_NUM_CLIENTS
 };
 
@@ -222,4 +222,41 @@ struct rdma_nla_ls_gid {
 	__u8		gid[16];
 };
 
+enum rdma_nldev_command {
+	RDMA_NLDEV_CMD_UNSPEC,
+
+	RDMA_NLDEV_CMD_GET, /* can dump */
+	RDMA_NLDEV_CMD_SET,
+	RDMA_NLDEV_CMD_NEW,
+	RDMA_NLDEV_CMD_DEL,
+
+	RDMA_NLDEV_CMD_PORT_GET, /* can dump */
+	RDMA_NLDEV_CMD_PORT_SET,
+	RDMA_NLDEV_CMD_PORT_NEW,
+	RDMA_NLDEV_CMD_PORT_DEL,
+
+	RDMA_NLDEV_NUM_OPS
+};
+
+enum rdma_nldev_attr {
+	/* don't change the order or add anything between, this is ABI! */
+	RDMA_NLDEV_ATTR_UNSPEC,
+
+	/* Identifier for ib_device */
+	RDMA_NLDEV_ATTR_DEV_INDEX,		/* u32 */
+
+	RDMA_NLDEV_ATTR_DEV_NAME,		/* string */
+	/*
+	 * Device index together with port index are identifiers
+	 * for port/link properties.
+	 *
+	 * For RDMA_NLDEV_CMD_GET comamnd, port index will return number
+	 * of available ports in ib_device, while for port specific operations,
+	 * it will be real port index as it appears in sysfs. Port index follows
+	 * sysfs notation and starts from 1 for the first port.
+	 */
+	RDMA_NLDEV_ATTR_PORT_INDEX,		/* u32 */
+
+	RDMA_NLDEV_ATTR_MAX
+};
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.1
