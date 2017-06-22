From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V1 16/19] RDMA/netlink: Add nldev device doit implementation
Date: Thu, 22 Jun 2017 16:24:31 +0300
Message-ID: <20170622132434.1327-17-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.99]:60600 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752124AbdFVNZK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:25:10 -0400
In-Reply-To: <20170622132434.1327-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Provide ability to query specific device.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/nldev.c | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 4b8b0f5d5344..666940f2b49a 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -53,6 +53,45 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 	return 0;
 }
 
+static int nldev_get_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX];
+	struct ib_device *device;
+	struct sk_buff *msg;
+	u32 index;
+	int err;
+
+	err = nlmsg_parse(nlh, 0, tb, RDMA_NLDEV_ATTR_MAX - 1,
+			  nldev_policy, extack);
+	if (err || !tb[RDMA_NLDEV_ATTR_DEV_INDEX])
+		return -EINVAL;
+
+	index = nla_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
+
+	device = __ib_device_get_by_index(index);
+	if (!device)
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
+	err = fill_dev_info(msg, device);
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
 static int _nldev_get_dumpit(struct ib_device *device,
 			     struct sk_buff *skb,
 			     struct netlink_callback *cb,
@@ -92,6 +131,7 @@ static int nldev_get_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 
 static const struct rdma_nl_cbs nldev_cb_table[] = {
 	[RDMA_NLDEV_CMD_GET] = {
+		.doit = nldev_get_doit,
 		.dump = nldev_get_dumpit,
 	},
 };
-- 
2.13.1
