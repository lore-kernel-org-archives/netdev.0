From: Varun Prakash <varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [net-next PATCH 07/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_tid_release()
Date: Tue, 13 Sep 2016 21:24:02 +0530
Message-ID: <fd902f05ba1c5e47480e66924041696df43f5a78.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
        gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, indranil-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1473781521.git.varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <cover.1473781521.git.varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
References: <cover.1473781521.git.varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add cxgb_mk_tid_release() to remove duplicate code
to form CPL_TID_RELEASE hardware command.

Signed-off-by: Varun Prakash <varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 10 ++++------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 13 +++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 11 ++---------
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index b9d77df..b818bd6 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -240,15 +240,13 @@ int c4iw_ofld_send(struct c4iw_rdev *rdev, struct sk_buff *skb)
 
 static void release_tid(struct c4iw_rdev *rdev, u32 hwtid, struct sk_buff *skb)
 {
-	struct cpl_tid_release *req;
+	u32 len = roundup(sizeof(struct cpl_tid_release), 16);
 
-	skb = get_skb(skb, sizeof *req, GFP_KERNEL);
+	skb = get_skb(skb, len, GFP_KERNEL);
 	if (!skb)
 		return;
-	req = (struct cpl_tid_release *) skb_put(skb, sizeof(*req));
-	INIT_TP_WR(req, hwtid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_TID_RELEASE, hwtid));
-	set_wr_txq(skb, CPL_PRIORITY_SETUP, 0);
+
+	cxgb_mk_tid_release(skb, len, hwtid, 0);
 	c4iw_ofld_send(rdev, skb);
 	return;
 }
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index ecf3baa..fbb973e 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -83,4 +83,17 @@ static inline u32 cxgb_compute_wscale(u32 win)
 		wscale++;
 	return wscale;
 }
+
+static inline void
+cxgb_mk_tid_release(struct sk_buff *skb, u32 len, u32 tid, u16 chan)
+{
+	struct cpl_tid_release *req;
+
+	req = (struct cpl_tid_release *)__skb_put(skb, len);
+	memset(req, 0, len);
+
+	INIT_TP_WR(req, tid);
+	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_TID_RELEASE, tid));
+	set_wr_txq(skb, CPL_PRIORITY_SETUP, chan);
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index cd29c91..994058f 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -961,21 +961,14 @@ int cxgbit_ofld_send(struct cxgbit_device *cdev, struct sk_buff *skb)
 
 static void cxgbit_release_tid(struct cxgbit_device *cdev, u32 tid)
 {
-	struct cpl_tid_release *req;
-	unsigned int len = roundup(sizeof(*req), 16);
+	u32 len = roundup(sizeof(struct cpl_tid_release), 16);
 	struct sk_buff *skb;
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (!skb)
 		return;
 
-	req = (struct cpl_tid_release *)__skb_put(skb, len);
-	memset(req, 0, len);
-
-	INIT_TP_WR(req, tid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(
-		   CPL_TID_RELEASE, tid));
-	set_wr_txq(skb, CPL_PRIORITY_SETUP, 0);
+	cxgb_mk_tid_release(skb, len, tid, 0);
 	cxgbit_ofld_send(cdev, skb);
 }
 
-- 
2.0.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
