From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 17/19] RDMA/netlink: Add nldev port dumpit implementation
Date: Wed, 21 Jun 2017 09:05:26 +0300
Message-ID: <20170621060528.3752-18-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.99]:58108 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751120AbdFUGGj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:06:39 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

This patch implements the query interface to get all
ports data for the specific device.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c | 60 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 60 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 8d3fd9b58cc1..ded06fa69ccb 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -50,6 +50,16 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 	return 0;
 }
 
+static int fill_port_info(struct sk_buff *msg,
+			  struct ib_device *device, u32 port)
+{
+	if (nla_put_string(msg, RDMA_NLDEV_ATTR_DEV_NAME, device->name))
+		return -EMSGSIZE;
+	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_PORT_INDEX, port))
+		return -EMSGSIZE;
+	return 0;
+}
+
 static int nldev_get_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
 			  struct netlink_ext_ack *extack)
 {
@@ -126,11 +136,61 @@ static int nldev_get_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 	return ib_enum_all_devs(_nldev_get_dumpit, skb, cb);
 }
 
+static int nldev_port_get_dumpit(struct sk_buff *skb,
+				 struct netlink_callback *cb)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX];
+	char name[IB_DEVICE_NAME_MAX];
+	struct ib_device *device;
+	int start = cb->args[0];
+	struct nlmsghdr *nlh;
+	u32 idx = 0;
+	int err;
+	u32 p;
+
+	err = nlmsg_parse(cb->nlh, 0, tb, RDMA_NLDEV_ATTR_MAX,
+			  nldev_policy, NULL);
+	if (err || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
+		return -EINVAL;
+
+	nla_strlcpy(name, tb[RDMA_NLDEV_ATTR_DEV_NAME], IB_DEVICE_NAME_MAX);
+
+	device = __ib_device_get_by_name(name);
+	if (!device)
+		return -EINVAL;
+
+	for (p = rdma_start_port(device); p <= rdma_end_port(device); ++p) {
+		if (idx < start) {
+			idx++;
+			continue;
+		}
+
+		nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
+				cb->nlh->nlmsg_seq,
+				RDMA_NL_GET_TYPE(RDMA_NL_NLDEV,
+						 RDMA_NLDEV_CMD_PORT_GET),
+				0, NLM_F_MULTI);
+
+		if (fill_port_info(skb, device, p)) {
+			nlmsg_cancel(skb, nlh);
+			goto out;
+		}
+		idx++;
+		nlmsg_end(skb, nlh);
+	}
+
+out:	cb->args[0] = idx;
+	return skb->len;
+}
+
 static const struct rdma_nl_cbs nldev_cb_table[] = {
 	[RDMA_NLDEV_CMD_GET] = {
 		.doit = nldev_get_doit,
 		.dump = nldev_get_dumpit,
 	},
+	[RDMA_NLDEV_CMD_PORT_GET] = {
+		.dump = nldev_port_get_dumpit,
+	},
 };
 
 void __init nldev_init(void)
-- 
2.13.1
