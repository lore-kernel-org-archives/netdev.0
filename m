From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] cxgb4i : Don't block unload/cxgb4 unload when remote closes TCP connection
Date: Tue, 18 Nov 2014 19:09:51 -0800
Message-ID: <1416366591-9699-1-git-send-email-anish@chelsio.com>
Cc: linux-scsi@vger.kernel.org, davem@davemloft.net, hch@infradead.org,
	jbottomley@parallels.com, kxie@chelsio.com,
	manojmalviya@chelsio.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cxgb4i was returning wrong error and not releasing module reference if remote
end abruptly closed TCP connection. This prevents the cxgb4 network module from
being unloaded, further affecting other network drivers dependent on cxgb4

Sending to net as this affects all cxgb4 based network drivers.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 2 ++
 drivers/scsi/cxgbi/libcxgbi.c      | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 3e0a0d3..f48f40ce 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -828,6 +828,8 @@ static void do_act_open_rpl(struct cxgbi_device *cdev, struct sk_buff *skb)
 	if (status == CPL_ERR_RTX_NEG_ADVICE)
 		goto rel_skb;
 
+	module_put(THIS_MODULE);
+
 	if (status && status != CPL_ERR_TCAM_FULL &&
 	    status != CPL_ERR_CONN_EXIST &&
 	    status != CPL_ERR_ARP_MISS)
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 674d498..9d63853 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -816,7 +816,7 @@ static void cxgbi_inform_iscsi_conn_closing(struct cxgbi_sock *csk)
 		read_lock_bh(&csk->callback_lock);
 		if (csk->user_data)
 			iscsi_conn_failure(csk->user_data,
-					ISCSI_ERR_CONN_FAILED);
+					ISCSI_ERR_TCP_CONN_CLOSE);
 		read_unlock_bh(&csk->callback_lock);
 	}
 }
-- 
2.1.3

