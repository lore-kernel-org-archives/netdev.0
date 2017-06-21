From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 03/19] RDMA/netlink: Rename and remove redundant parameter from ibnl_unicast
Date: Wed, 21 Jun 2017 09:05:12 +0300
Message-ID: <20170621060528.3752-4-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.99]:57652 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbdFUGGA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:06:00 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Netlink message header is not needed for unicast reply, hence remove it.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/iwpm_msg.c  | 6 +++---
 drivers/infiniband/core/iwpm_util.c | 4 ++--
 drivers/infiniband/core/netlink.c   | 5 ++---
 include/rdma/rdma_netlink.h         | 4 +---
 4 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/core/iwpm_msg.c b/drivers/infiniband/core/iwpm_msg.c
index 1fab707b1f68..8f84557d04e3 100644
--- a/drivers/infiniband/core/iwpm_msg.c
+++ b/drivers/infiniband/core/iwpm_msg.c
@@ -172,7 +172,7 @@ int iwpm_add_mapping(struct iwpm_sa_data *pm_msg, u8 nl_client)
 		goto add_mapping_error;
 	nlmsg_request->req_buffer = pm_msg;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = rdma_nl_unicast(skb, iwpm_user_pid);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		iwpm_user_pid = IWPM_PID_UNDEFINED;
@@ -248,7 +248,7 @@ int iwpm_add_and_query_mapping(struct iwpm_sa_data *pm_msg, u8 nl_client)
 		goto query_mapping_error;
 	nlmsg_request->req_buffer = pm_msg;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = rdma_nl_unicast(skb, iwpm_user_pid);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		err_str = "Unable to send a nlmsg";
@@ -308,7 +308,7 @@ int iwpm_remove_mapping(struct sockaddr_storage *local_addr, u8 nl_client)
 	if (ret)
 		goto remove_mapping_error;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = rdma_nl_unicast(skb, iwpm_user_pid);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		iwpm_user_pid = IWPM_PID_UNDEFINED;
diff --git a/drivers/infiniband/core/iwpm_util.c b/drivers/infiniband/core/iwpm_util.c
index c46442ac71a2..c81c55942626 100644
--- a/drivers/infiniband/core/iwpm_util.c
+++ b/drivers/infiniband/core/iwpm_util.c
@@ -597,7 +597,7 @@ static int send_mapinfo_num(u32 mapping_num, u8 nl_client, int iwpm_pid)
 				&mapping_num, IWPM_NLA_MAPINFO_SEND_NUM);
 	if (ret)
 		goto mapinfo_num_error;
-	ret = ibnl_unicast(skb, nlh, iwpm_pid);
+	ret = rdma_nl_unicast(skb, iwpm_pid);
 	if (ret) {
 		skb = NULL;
 		err_str = "Unable to send a nlmsg";
@@ -626,7 +626,7 @@ static int send_nlmsg_done(struct sk_buff *skb, u8 nl_client, int iwpm_pid)
 		return -ENOMEM;
 	}
 	nlh->nlmsg_type = NLMSG_DONE;
-	ret = ibnl_unicast(skb, (struct nlmsghdr *)skb->data, iwpm_pid);
+	ret = rdma_nl_unicast(skb, iwpm_pid);
 	if (ret)
 		pr_warn("%s Unable to send a nlmsg\n", __func__);
 	return ret;
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 96057e722123..cd29311078b5 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -241,12 +241,11 @@ static void rdma_nl_rcv(struct sk_buff *skb)
 	mutex_unlock(&rdma_nl_mutex);
 }
 
-int ibnl_unicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			__u32 pid)
+int rdma_nl_unicast(struct sk_buff *skb, u32 pid)
 {
 	return nlmsg_unicast(nls, skb, pid);
 }
-EXPORT_SYMBOL(ibnl_unicast);
+EXPORT_SYMBOL(rdma_nl_unicast);
 
 int ibnl_multicast(struct sk_buff *skb, struct nlmsghdr *nlh,
 			unsigned int group, gfp_t flags)
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 6932b7acd3a6..9779cd5520d7 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -59,12 +59,10 @@ int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
 /**
  * Send the supplied skb to a specific userspace PID.
  * @skb: The netlink skb
- * @nlh: Header of the netlink message to send
  * @pid: Userspace netlink process ID
  * Returns 0 on success or a negative error code.
  */
-int ibnl_unicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			__u32 pid);
+int rdma_nl_unicast(struct sk_buff *skb, u32 pid);
 
 /**
  * Send the supplied skb to a netlink group.
-- 
2.13.1
