From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v1 04/12] IB/cm: Expose service ID in request events
Date: Mon, 22 Jun 2015 15:42:33 +0300
Message-ID: <1434976961-27424-5-git-send-email-haggaie@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52093 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933319AbbFVMnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2015 08:43:07 -0400
In-Reply-To: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose the service ID on an incoming CM or SIDR request to the event
handler. This will allow the RDMA CM module to de-multiplex connection
requests based on the information encoded in the service ID.

Acked-by: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/infiniband/core/cm.c | 3 +++
 include/rdma/ib_cm.h         | 1 +
 2 files changed, 4 insertions(+)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 0103534472e0..dd92c999e6e9 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -1256,6 +1256,7 @@ static void cm_format_paths_from_req(struct cm_req_msg *req_msg,
 	primary_path->packet_life_time =
 		cm_req_get_primary_local_ack_timeout(req_msg);
 	primary_path->packet_life_time -= (primary_path->packet_life_time > 0);
+	primary_path->service_id = req_msg->service_id;
 
 	if (req_msg->alt_local_lid) {
 		memset(alt_path, 0, sizeof *alt_path);
@@ -1277,6 +1278,7 @@ static void cm_format_paths_from_req(struct cm_req_msg *req_msg,
 		alt_path->packet_life_time =
 			cm_req_get_alt_local_ack_timeout(req_msg);
 		alt_path->packet_life_time -= (alt_path->packet_life_time > 0);
+		alt_path->service_id = req_msg->service_id;
 	}
 }
 
@@ -2980,6 +2982,7 @@ static void cm_format_sidr_req_event(struct cm_work *work,
 	param = &work->cm_event.param.sidr_req_rcvd;
 	param->pkey = __be16_to_cpu(sidr_req_msg->pkey);
 	param->listen_id = listen_id;
+	param->service_id = sidr_req_msg->service_id;
 	param->port = work->port->port_num;
 	work->cm_event.private_data = &sidr_req_msg->private_data;
 }
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 39ed2d2fbd51..1b567bbc3ad4 100644
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
