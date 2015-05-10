From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v3 for-next 07/13] IB/cm: Expose service ID in request events
Date: Sun, 10 May 2015 13:26:38 +0300
Message-ID: <1431253604-9214-8-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Expose the service ID on an incoming CM or SIDR request to the event
handler. This will allow the RDMA CM module to de-multiplex connection
requests based on the information encoded in the service ID.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cm.c | 3 +++
 include/rdma/ib_cm.h         | 1 +
 2 files changed, 4 insertions(+)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 0be96a19734d..fc33fb215e55 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -1381,6 +1381,7 @@ static void cm_format_paths_from_req(struct cm_req_msg *req_msg,
 	primary_path->packet_life_time =
 		cm_req_get_primary_local_ack_timeout(req_msg);
 	primary_path->packet_life_time -= (primary_path->packet_life_time > 0);
+	primary_path->service_id = req_msg->service_id;
 
 	if (req_msg->alt_local_lid) {
 		memset(alt_path, 0, sizeof *alt_path);
@@ -1402,6 +1403,7 @@ static void cm_format_paths_from_req(struct cm_req_msg *req_msg,
 		alt_path->packet_life_time =
 			cm_req_get_alt_local_ack_timeout(req_msg);
 		alt_path->packet_life_time -= (alt_path->packet_life_time > 0);
+		alt_path->service_id = req_msg->service_id;
 	}
 }
 
@@ -3105,6 +3107,7 @@ static void cm_format_sidr_req_event(struct cm_work *work,
 	param = &work->cm_event.param.sidr_req_rcvd;
 	param->pkey = __be16_to_cpu(sidr_req_msg->pkey);
 	param->listen_id = listen_id;
+	param->service_id = sidr_req_msg->service_id;
 	param->port = work->port->port_num;
 	work->cm_event.private_data = &sidr_req_msg->private_data;
 }
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 4a17394bb556..17e072d1677c 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -223,6 +223,7 @@ struct ib_cm_apr_event_param {
 
 struct ib_cm_sidr_req_event_param {
 	struct ib_cm_id		*listen_id;
+	__be64			service_id;
 	u8			port;
 	u16			pkey;
 };
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
