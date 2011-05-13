From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Fri, 13 May 2011 09:18:44 -0700
Message-ID: <1305303525-11113-3-git-send-email-roland@kernel.org>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1305303525-11113-1-git-send-email-roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Nir Muchtar <nirm-smomgflXvOZWk0Htik3J/w@public.gmane.org>

[Dave please do not apply even if this ends up in netdev patchwork!]

Add callbacks and data types for statistics export of all current
devices/ids.  The schema for RDMA CM is a series of netlink messages.
Each one contains an rdma_cm_stat struct.  Additionally, two netlink
attributes are created for the addresses for each message (if
applicable).

Their types used are:
RDMA_NL_RDMA_CM_ATTR_SRC_ADDR (The source address for this ID)
RDMA_NL_RDMA_CM_ATTR_DST_ADDR (The destination address for this ID)
sockaddr_* structs are encapsulated within these attributes.

In other words, every transaction contains a series of messages like:

-------message 1-------
struct rdma_cm_id_stats {
       __u32 qp_num;
       __u32 bound_dev_if;
       __u32 port_space;
       __s32 pid;
       __u8 cm_state;
       __u8 node_type;
       __u8 port_num;
       __u8 reserved;
}
RDMA_NL_RDMA_CM_ATTR_SRC_ADDR attribute - contains the source address
RDMA_NL_RDMA_CM_ATTR_DST_ADDR attribute - contains the destination address
-------end 1-------
-------message 2-------
struct rdma_cm_id_stats
RDMA_NL_RDMA_CM_ATTR_SRC_ADDR attribute
RDMA_NL_RDMA_CM_ATTR_DST_ADDR attribute
-------end 2-------

NOT-Signed-off-by: Nir Muchtar <nirm-smomgflXvOZWk0Htik3J/w@public.gmane.org>
NOT-Signed-off-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   98 +++++++++++++++++++++++++++++++++++++++++
 include/rdma/rdma_netlink.h   |   28 ++++++++++++
 2 files changed, 126 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 05b55e4..d4701a8 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -47,6 +47,7 @@
 
 #include <rdma/rdma_cm.h>
 #include <rdma/rdma_cm_ib.h>
+#include <rdma/rdma_netlink.h>
 #include <rdma/ib_cache.h>
 #include <rdma/ib_cm.h>
 #include <rdma/ib_sa.h>
@@ -3247,6 +3248,98 @@ static void cma_remove_one(struct ib_device *device)
 	kfree(cma_dev);
 }
 
+static int cma_get_id_stats(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct nlmsghdr *nlh;
+	struct rdma_cm_id_stats *id_stats;
+	struct rdma_id_private *id_priv;
+	struct rdma_cm_id *id = NULL;
+	struct cma_device *cma_dev;
+	int i_dev = 0, i_id = 0;
+
+	/*
+	 * We export all of the IDs as a sequence of messages.  Each
+	 * ID gets its own netlink message.
+	 */
+	mutex_lock(&lock);
+
+	list_for_each_entry(cma_dev, &dev_list, list) {
+		if (i_dev < cb->args[0]) {
+			i_dev++;
+			continue;
+		}
+
+		i_id = 0;
+		list_for_each_entry(id_priv, &cma_dev->id_list, list) {
+			if (i_id < cb->args[1]) {
+				i_id++;
+				continue;
+			}
+
+			id_stats = ibnl_put_msg(skb, &nlh, cb->nlh->nlmsg_seq,
+						sizeof *id_stats, RDMA_NL_RDMA_CM,
+						RDMA_NL_RDMA_CM_ID_STATS);
+			if (!id_stats)
+				goto out;
+
+			memset(id_stats, 0, sizeof *id_stats);
+			id = &id_priv->id;
+			id_stats->node_type = id->route.addr.dev_addr.dev_type;
+			id_stats->port_num = id->port_num;
+			id_stats->bound_dev_if =
+				id->route.addr.dev_addr.bound_dev_if;
+
+			if (id->route.addr.src_addr.ss_family == AF_INET) {
+				if (ibnl_put_attr(skb, nlh,
+						  sizeof(struct sockaddr_in),
+						  &id->route.addr.src_addr,
+						  RDMA_NL_RDMA_CM_ATTR_SRC_ADDR)) {
+					goto out;
+				}
+				if (ibnl_put_attr(skb, nlh,
+						  sizeof(struct sockaddr_in),
+						  &id->route.addr.dst_addr,
+						  RDMA_NL_RDMA_CM_ATTR_DST_ADDR)) {
+					goto out;
+				}
+			} else if (id->route.addr.src_addr.ss_family == AF_INET6) {
+				if (ibnl_put_attr(skb, nlh,
+						  sizeof(struct sockaddr_in6),
+						  &id->route.addr.src_addr,
+						  RDMA_NL_RDMA_CM_ATTR_SRC_ADDR)) {
+					goto out;
+				}
+				if (ibnl_put_attr(skb, nlh,
+						  sizeof(struct sockaddr_in6),
+						  &id->route.addr.dst_addr,
+						  RDMA_NL_RDMA_CM_ATTR_DST_ADDR)) {
+					goto out;
+				}
+			}
+
+			id_stats->port_space = id->ps;
+			id_stats->cm_state = id_priv->state;
+			id_stats->qp_num = id_priv->qp_num;
+
+			i_id++;
+		}
+
+		cb->args[1] = 0;
+		i_dev++;
+	}
+
+out:
+	mutex_unlock(&lock);
+	cb->args[0] = i_dev;
+	cb->args[1] = i_id;
+
+	return skb->len;
+}
+
+static const struct ibnl_client_cbs cma_cb_table[] = {
+	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats },
+};
+
 static int __init cma_init(void)
 {
 	int ret;
@@ -3262,6 +3355,10 @@ static int __init cma_init(void)
 	ret = ib_register_client(&cma_client);
 	if (ret)
 		goto err;
+
+	if (ibnl_add_client(RDMA_NL_RDMA_CM, RDMA_NL_RDMA_CM_NUM_OPS, cma_cb_table))
+		printk(KERN_WARNING "RDMA CMA: failed to add netlink callback\n");
+
 	return 0;
 
 err:
@@ -3274,6 +3371,7 @@ err:
 
 static void __exit cma_cleanup(void)
 {
+	ibnl_remove_client(RDMA_NL_RDMA_CM);
 	ib_unregister_client(&cma_client);
 	unregister_netdevice_notifier(&cma_nb);
 	rdma_addr_unregister_client(&addr_client);
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index c983a19..fa318af 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -1,10 +1,38 @@
 #ifndef _RDMA_NETLINK_H
 #define _RDMA_NETLINK_H
 
+#include <linux/types.h>
+
+enum {
+	RDMA_NL_RDMA_CM = 1
+};
+
 #define RDMA_NL_GET_CLIENT(type) ((type & (((1 << 6) - 1) << 10)) >> 10)
 #define RDMA_NL_GET_OP(type) (type & ((1 << 10) - 1))
 #define RDMA_NL_GET_TYPE(client, op) ((client << 10) + op)
 
+enum {
+	RDMA_NL_RDMA_CM_ID_STATS = 0,
+	RDMA_NL_RDMA_CM_NUM_OPS
+};
+
+enum {
+	RDMA_NL_RDMA_CM_ATTR_SRC_ADDR = 1,
+	RDMA_NL_RDMA_CM_ATTR_DST_ADDR,
+	RDMA_NL_RDMA_CM_NUM_ATTR,
+};
+
+struct rdma_cm_id_stats {
+	__u32	qp_num;
+	__u32	bound_dev_if;
+	__u32	port_space;
+	__s32	pid;
+	__u8	cm_state;
+	__u8	node_type;
+	__u8	port_num;
+	__u8	reserved;
+};
+
 #ifdef __KERNEL__
 
 #include <linux/netlink.h>
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
