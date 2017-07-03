From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V2 15/27] RDMA/netlink: Implement nldev device dumpit calback
Date: Mon,  3 Jul 2017 09:28:18 +0300
Message-ID: <20170703062830.30361-16-leon@kernel.org>
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

This patch adds the ability to return all available devices
together with their properties.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/core/nldev.c | 64 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 63 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 1d1e4f214874..4b8b0f5d5344 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -30,13 +30,75 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <net/netlink.h>
 #include <rdma/rdma_netlink.h>
 
 #include "core_priv.h"
 
+static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
+	[RDMA_NLDEV_ATTR_DEV_INDEX]     = { .type = NLA_U32 },
+	[RDMA_NLDEV_ATTR_DEV_NAME]	= { .type = NLA_NUL_STRING,
+					    .len = IB_DEVICE_NAME_MAX - 1},
+	[RDMA_NLDEV_ATTR_PORT_INDEX]	= { .type = NLA_U32 },
+};
+
+static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
+{
+	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_DEV_INDEX, device->index))
+		return -EMSGSIZE;
+	if (nla_put_string(msg, RDMA_NLDEV_ATTR_DEV_NAME, device->name))
+		return -EMSGSIZE;
+	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_PORT_INDEX, rdma_end_port(device)))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static int _nldev_get_dumpit(struct ib_device *device,
+			     struct sk_buff *skb,
+			     struct netlink_callback *cb,
+			     unsigned int idx)
+{
+	int start = cb->args[0];
+	struct nlmsghdr *nlh;
+
+	if (idx < start)
+		return 0;
+
+	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
+			RDMA_NL_GET_TYPE(RDMA_NL_NLDEV, RDMA_NLDEV_CMD_GET),
+			0, NLM_F_MULTI);
+
+	if (fill_dev_info(skb, device)) {
+		nlmsg_cancel(skb, nlh);
+		goto out;
+	}
+
+	nlmsg_end(skb, nlh);
+
+	idx++;
+
+out:	cb->args[0] = idx;
+	return skb->len;
+}
+
+static int nldev_get_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	/*
+	 * There is no need to take lock, because
+	 * we are relying on ib_core's lists_rwsem
+	 */
+	return ib_enum_all_devs(_nldev_get_dumpit, skb, cb);
+}
+
+static const struct rdma_nl_cbs nldev_cb_table[] = {
+	[RDMA_NLDEV_CMD_GET] = {
+		.dump = nldev_get_dumpit,
+	},
+};
+
 void __init nldev_init(void)
 {
-	rdma_nl_register(RDMA_NL_NLDEV, NULL);
+	rdma_nl_register(RDMA_NL_NLDEV, nldev_cb_table);
 }
 
 void __exit nldev_exit(void)
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
