From: Masashi Honma <masashi.honma@gmail.com>
Subject: [RFC 4/7] infiniband: Add allocation flag to ibnl_unicast()
Date: Wed,  6 Jul 2016 09:28:33 +0900
Message-ID: <1467764916-4983-5-git-send-email-masashi.honma@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, paul@paul-moore.com, eparis@redhat.com,
	zbr@ioremap.net, pshelar@nicira.com, ccaulfie@redhat.com,
	teigland@redhat.com, bsingharora@gmail.com,
	Masashi Honma <masashi.honma@gmail.com>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-audit@redhat.com, cluster-devel@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masashi Honma <masashi.honma@gmail.com>
---
 drivers/infiniband/core/iwpm_msg.c  | 6 +++---
 drivers/infiniband/core/iwpm_util.c | 5 +++--
 drivers/infiniband/core/iwpm_util.h | 1 +
 drivers/infiniband/core/netlink.c   | 4 ++--
 include/rdma/rdma_netlink.h         | 3 ++-
 5 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/core/iwpm_msg.c b/drivers/infiniband/core/iwpm_msg.c
index 1c41b95..4307eab 100644
--- a/drivers/infiniband/core/iwpm_msg.c
+++ b/drivers/infiniband/core/iwpm_msg.c
@@ -174,7 +174,7 @@ int iwpm_add_mapping(struct iwpm_sa_data *pm_msg, u8 nl_client)
 		goto add_mapping_error;
 	nlmsg_request->req_buffer = pm_msg;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = ibnl_unicast(skb, nlh, iwpm_user_pid, GFP_ATOMIC);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		iwpm_user_pid = IWPM_PID_UNDEFINED;
@@ -251,7 +251,7 @@ int iwpm_add_and_query_mapping(struct iwpm_sa_data *pm_msg, u8 nl_client)
 		goto query_mapping_error;
 	nlmsg_request->req_buffer = pm_msg;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = ibnl_unicast(skb, nlh, iwpm_user_pid, GFP_ATOMIC);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		err_str = "Unable to send a nlmsg";
@@ -312,7 +312,7 @@ int iwpm_remove_mapping(struct sockaddr_storage *local_addr, u8 nl_client)
 	if (ret)
 		goto remove_mapping_error;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = ibnl_unicast(skb, nlh, iwpm_user_pid, GFP_ATOMIC);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		iwpm_user_pid = IWPM_PID_UNDEFINED;
diff --git a/drivers/infiniband/core/iwpm_util.c b/drivers/infiniband/core/iwpm_util.c
index b65e06c..6dcbb2d 100644
--- a/drivers/infiniband/core/iwpm_util.c
+++ b/drivers/infiniband/core/iwpm_util.c
@@ -609,7 +609,7 @@ static int send_mapinfo_num(u32 mapping_num, u8 nl_client, int iwpm_pid)
 				&mapping_num, IWPM_NLA_MAPINFO_SEND_NUM);
 	if (ret)
 		goto mapinfo_num_error;
-	ret = ibnl_unicast(skb, nlh, iwpm_pid);
+	ret = ibnl_unicast(skb, nlh, iwpm_pid, GFP_ATOMIC);
 	if (ret) {
 		skb = NULL;
 		err_str = "Unable to send a nlmsg";
@@ -638,7 +638,8 @@ static int send_nlmsg_done(struct sk_buff *skb, u8 nl_client, int iwpm_pid)
 		return -ENOMEM;
 	}
 	nlh->nlmsg_type = NLMSG_DONE;
-	ret = ibnl_unicast(skb, (struct nlmsghdr *)skb->data, iwpm_pid);
+	ret = ibnl_unicast(skb, (struct nlmsghdr *)skb->data, iwpm_pid,
+			   GFP_ATOMIC);
 	if (ret)
 		pr_warn("%s Unable to send a nlmsg\n", __func__);
 	return ret;
diff --git a/drivers/infiniband/core/iwpm_util.h b/drivers/infiniband/core/iwpm_util.h
index af1fc14..0ced7f4 100644
--- a/drivers/infiniband/core/iwpm_util.h
+++ b/drivers/infiniband/core/iwpm_util.h
@@ -46,6 +46,7 @@
 #include <linux/jhash.h>
 #include <linux/kref.h>
 #include <net/netlink.h>
+#include <net/sock.h>
 #include <linux/errno.h>
 #include <rdma/iw_portmap.h>
 #include <rdma/rdma_netlink.h>
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 09037a9..1451238 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -227,9 +227,9 @@ static void ibnl_rcv(struct sk_buff *skb)
 }
 
 int ibnl_unicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			__u32 pid)
+			__u32 pid, gfp_t flags)
 {
-	return nlmsg_unicast(nls, skb, pid, gfp_any());
+	return nlmsg_unicast(nls, skb, pid, flags);
 }
 EXPORT_SYMBOL(ibnl_unicast);
 
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 5852661..0bb3010 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -61,10 +61,11 @@ int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
  * @skb: The netlink skb
  * @nlh: Header of the netlink message to send
  * @pid: Userspace netlink process ID
+ * @flags: allocation flags
  * Returns 0 on success or a negative error code.
  */
 int ibnl_unicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			__u32 pid);
+			__u32 pid, gfp_t flags);
 
 /**
  * Send the supplied skb to a netlink group.
-- 
2.7.4

