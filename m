From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 15/19] RDMA/netlink: Implement nldev device dumpit calback
Date: Wed, 21 Jun 2017 09:05:24 +0300
Message-ID: <20170621060528.3752-16-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57988 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751965AbdFUGGV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:06:21 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

This patch adds the ability to return all available devices
together with their properties.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c | 61 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 60 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 1d1e4f214874..219b52166c46 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -30,13 +30,72 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <net/netlink.h>
 #include <rdma/rdma_netlink.h>
 
 #include "core_priv.h"
 
+static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
+	[RDMA_NLDEV_ATTR_DEV_NAME]	= { .type = NLA_NUL_STRING,
+					    .len = IB_DEVICE_NAME_MAX - 1},
+	[RDMA_NLDEV_ATTR_PORT_INDEX]	= { .type = NLA_U32 },
+};
+
+static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
+{
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
2.13.1
