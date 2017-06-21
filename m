From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next 13/19] RDMA/netlink: Add netlink device definitions to UAPI
Date: Wed, 21 Jun 2017 09:05:22 +0300
Message-ID: <20170621060528.3752-14-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621060528.3752-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Introduce new defines to rdma_netlink.h, so the RDMA configuration tool
will be able to communicate with RDMA subsystem by using the shared defines.

The addition of new client (NLDEV) revealed the fact that we exposed by
mistake the RDMA_NL_I40IW define which is not backed by any RDMA netlink
by now and it won't be exposed in the future too. So this patch reuses
the value and leaves the comment together with old definition to whose
who are using RDMA_NL_I40IW as a replacement for digit "5".

The NLDEV operates with objects. The struct ib_device has two straightforward
objects: device itself and ports of that device.

This brings us to propose the following commands to work on those objects:
 * RDMA_NLDEV_CMD_{GET,SET,NEW,DEL} - works on ib_device itself
 * RDMA_NLDEV_CMD_PORT_{GET,SET,NEW,DEL} - works on ports of specific ib_device

Those commands receive/return the device name (RDMA_NLDEV_ATTR_DEV_NAME)
and port index (RDMA_NLDEV_ATTR_PORT_INDEX). For device object accesses,
the RDMA_NLDEV_ATTR_PORT_INDEX will return the maximum number of ports
for specific ib_device and for port access the actual port index.

The port index starts from 1 to follow RDMA/core internal semantics and
the sysfs exposed knobs..

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/netlink.c |  2 +-
 include/uapi/rdma/rdma_netlink.h  | 42 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 9731c313e9b9..cce9b7af4a3b 100644
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
index 02fe8390c18f..bfafd5996d52 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -8,7 +8,14 @@ enum {
 	RDMA_NL_IWCM,
 	RDMA_NL_RSVD,
 	RDMA_NL_LS,	/* RDMA Local Services */
+	/*
+	 * RDMA_NL_I40IW not in use and it was added here by mistake,
+	 * but we need to keep it anyway, because it is UAPI and for
+	 * unknown reasons, someone in the field decided to replace "5"
+	 * with this define.
+	 */
 	RDMA_NL_I40IW,
+	RDMA_NL_NLDEV = RDMA_NL_I40IW, /* RDMA device interface */
 	RDMA_NL_NUM_CLIENTS
 };
 
@@ -222,4 +229,39 @@ struct rdma_nla_ls_gid {
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
+	RDMA_NLDEV_ATTR_DEV_NAME,		/* string */
+	/*
+	 * Device name together with port index are identifiers
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
