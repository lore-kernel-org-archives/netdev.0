From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V1 18/19] RDMA/netlink: Implement nldev port doit callback
Date: Thu, 22 Jun 2017 16:24:33 +0300
Message-ID: <20170622132434.1327-19-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.99]:60966 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753078AbdFVNZy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:25:54 -0400
In-Reply-To: <20170622132434.1327-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Provide ability to get specific to device and port information.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/nldev.c | 44 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 4413eda8c435..2489ad9d9211 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -141,6 +141,49 @@ static int nldev_get_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 	return ib_enum_all_devs(_nldev_get_dumpit, skb, cb);
 }
 
+static int nldev_port_get_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       struct netlink_ext_ack *extack)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX];
+	struct ib_device *device;
+	struct sk_buff *msg;
+	u32 index;
+	u32 port;
+	int err;
+
+	err = nlmsg_parse(nlh, 0, tb, RDMA_NLDEV_ATTR_MAX - 1,
+			  nldev_policy, extack);
+	if (err || !tb[RDMA_NLDEV_ATTR_PORT_INDEX])
+		return -EINVAL;
+
+	index = nla_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
+	device = __ib_device_get_by_index(index);
+	if (!device)
+		return -EINVAL;
+
+	port = nla_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
+	if (rdma_is_port_valid(device, port))
+		return -EINVAL;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	nlh = nlmsg_put(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq,
+			RDMA_NL_GET_TYPE(RDMA_NL_NLDEV, RDMA_NLDEV_CMD_GET),
+			0, 0);
+
+	err = fill_port_info(msg, device, port);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	nlmsg_end(msg, nlh);
+
+	return rdma_nl_unicast(msg, NETLINK_CB(skb).portid);
+}
+
 static int nldev_port_get_dumpit(struct sk_buff *skb,
 				 struct netlink_callback *cb)
 {
@@ -193,6 +236,7 @@ static const struct rdma_nl_cbs nldev_cb_table[] = {
 		.dump = nldev_get_dumpit,
 	},
 	[RDMA_NLDEV_CMD_PORT_GET] = {
+		.doit = nldev_port_get_doit,
 		.dump = nldev_port_get_dumpit,
 	},
 };
-- 
2.13.1
