From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V2 05/27] RDMA/netlink: Simplify and rename ibnl_chk_listeners
Date: Mon,  3 Jul 2017 09:28:08 +0300
Message-ID: <20170703062830.30361-6-leon@kernel.org>
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

Make ibnl_chk_listeners function to be one line by removing
unneeded comparison.

Rename that function to be complaint to other functions in RDMA netlink.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/core/addr.c     | 2 +-
 drivers/infiniband/core/netlink.c  | 7 +++----
 drivers/infiniband/core/sa_query.c | 2 +-
 include/rdma/rdma_netlink.h        | 6 ++++++
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index ebd0242bab3d..2cc23a26ce4f 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -324,7 +324,7 @@ static void queue_req(struct addr_req *req)
 static int ib_nl_fetch_ha(struct dst_entry *dst, struct rdma_dev_addr *dev_addr,
 			  const void *daddr, u32 seq, u16 family)
 {
-	if (ibnl_chk_listeners(RDMA_NL_GROUP_LS))
+	if (rdma_nl_chk_listeners(RDMA_NL_GROUP_LS))
 		return -EADDRNOTAVAIL;
 
 	/* We fill in what we can, the response will fill the rest */
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 83e62ecddde1..d1d187f27297 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -47,12 +47,11 @@ static struct {
 	const struct ibnl_client_cbs   *cb_table;
 } rdma_nl_types[RDMA_NL_NUM_CLIENTS];
 
-int ibnl_chk_listeners(unsigned int group)
+int rdma_nl_chk_listeners(unsigned int group)
 {
-	if (netlink_has_listeners(nls, group) == 0)
-		return -1;
-	return 0;
+	return (netlink_has_listeners(nls, group)) ? 0 : -1;
 }
+EXPORT_SYMBOL(rdma_nl_chk_listeners);
 
 static bool is_nl_msg_valid(unsigned int type, unsigned int op)
 {
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 00d824795285..27535970a2b7 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -1419,7 +1419,7 @@ static int send_mad(struct ib_sa_query *query, int timeout_ms, gfp_t gfp_mask)
 
 	if ((query->flags & IB_SA_ENABLE_LOCAL_SERVICE) &&
 	    (!(query->flags & IB_SA_QUERY_OPA))) {
-		if (!ibnl_chk_listeners(RDMA_NL_GROUP_LS)) {
+		if (!rdma_nl_chk_listeners(RDMA_NL_GROUP_LS)) {
 			if (!ib_nl_make_request(query, gfp_mask))
 				return id;
 		}
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index f10607ce1cf0..afc364c3220c 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -70,4 +70,10 @@ int rdma_nl_unicast(struct sk_buff *skb, u32 pid);
  */
 int rdma_nl_multicast(struct sk_buff *skb, unsigned int group, gfp_t flags);
 
+/**
+ * Check if there are any listeners to the netlink group
+ * @group: the netlink group ID
+ * Returns 0 on success or a negative for no listeners.
+ */
+int rdma_nl_chk_listeners(unsigned int group);
 #endif /* _RDMA_NETLINK_H */
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
