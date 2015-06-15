From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 04/11] IB/cm: Expose DGID in SIDR request events
Date: Mon, 15 Jun 2015 11:47:09 +0300
Message-ID: <1434358036-15526-5-git-send-email-haggaie@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The destination GID can be used to uniquely resolve the request. Expose the
GID in SIDR request events when it is available, so that the rdma_cm module
can use that information.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cm.c | 7 +++++++
 include/rdma/ib_cm.h         | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index c5f5f89e274a..46f99ec4080a 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -2983,6 +2983,13 @@ static void cm_format_sidr_req_event(struct cm_work *work,
 	param->pkey = __be16_to_cpu(sidr_req_msg->pkey);
 	param->listen_id = listen_id;
 	param->service_id = sidr_req_msg->service_id;
+	if (work->mad_recv_wc->wc->wc_flags & IB_WC_GRH) {
+		param->grh = 1;
+		memcpy(&param->dgid, &work->mad_recv_wc->recv_buf.grh->dgid,
+		       sizeof(param->dgid));
+	} else {
+		param->grh = 0;
+	}
 	param->port = work->port->port_num;
 	work->cm_event.private_data = &sidr_req_msg->private_data;
 }
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 1b567bbc3ad4..3a5d70d79790 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -224,6 +224,8 @@ struct ib_cm_apr_event_param {
 struct ib_cm_sidr_req_event_param {
 	struct ib_cm_id		*listen_id;
 	__be64			service_id;
+	union ib_gid		dgid;
+	u8			grh:1;
 	u8			port;
 	u16			pkey;
 };
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
