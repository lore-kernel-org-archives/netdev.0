From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 6/7] mlx4_ib: Fix SIDR support of for UD QPs under SRIOV/RoCE
Date: Wed, 12 Mar 2014 12:00:42 +0200
Message-ID: <1394618443-20337-7-git-send-email-ogerlitz@mellanox.com>
References: <1394618443-20337-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com,
	Shani Michaelli <shanim@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59232 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752710AbaCLKZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 06:25:49 -0400
In-Reply-To: <1394618443-20337-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaelli <shanim@mellanox.com>

* Handle CM_SIDR_REQ_ATTR_ID and CM_SIDR_REP_ATTR_ID
  in multiplex_cm_handler and demux_cm_handler.

* Handle Service ID Resolution messages and REQ messages
  separately, for their formats are different.

Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/cm.c |   72 ++++++++++++++++++++++++++++++--------
 1 files changed, 57 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/cm.c b/drivers/infiniband/hw/mlx4/cm.c
index b8d9115..56a593e 100644
--- a/drivers/infiniband/hw/mlx4/cm.c
+++ b/drivers/infiniband/hw/mlx4/cm.c
@@ -61,6 +61,11 @@ struct cm_generic_msg {
 	__be32 remote_comm_id;
 };
 
+struct cm_sidr_generic_msg {
+	struct ib_mad_hdr hdr;
+	__be32 request_id;
+};
+
 struct cm_req_msg {
 	unsigned char unused[0x60];
 	union ib_gid primary_path_sgid;
@@ -69,28 +74,62 @@ struct cm_req_msg {
 
 static void set_local_comm_id(struct ib_mad *mad, u32 cm_id)
 {
-	struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
-	msg->local_comm_id = cpu_to_be32(cm_id);
+	if (mad->mad_hdr.attr_id == CM_SIDR_REQ_ATTR_ID) {
+		struct cm_sidr_generic_msg *msg =
+			(struct cm_sidr_generic_msg *)mad;
+		msg->request_id = cpu_to_be32(cm_id);
+	} else if (mad->mad_hdr.attr_id == CM_SIDR_REP_ATTR_ID) {
+		pr_err("trying to set local_comm_id in SIDR_REP\n");
+		return;
+	} else {
+		struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
+		msg->local_comm_id = cpu_to_be32(cm_id);
+	}
 }
 
 static u32 get_local_comm_id(struct ib_mad *mad)
 {
-	struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
-
-	return be32_to_cpu(msg->local_comm_id);
+	if (mad->mad_hdr.attr_id == CM_SIDR_REQ_ATTR_ID) {
+		struct cm_sidr_generic_msg *msg =
+			(struct cm_sidr_generic_msg *)mad;
+		return be32_to_cpu(msg->request_id);
+	} else if (mad->mad_hdr.attr_id == CM_SIDR_REP_ATTR_ID) {
+		pr_err("trying to set local_comm_id in SIDR_REP\n");
+		return -1;
+	} else {
+		struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
+		return be32_to_cpu(msg->local_comm_id);
+	}
 }
 
 static void set_remote_comm_id(struct ib_mad *mad, u32 cm_id)
 {
-	struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
-	msg->remote_comm_id = cpu_to_be32(cm_id);
+	if (mad->mad_hdr.attr_id == CM_SIDR_REP_ATTR_ID) {
+		struct cm_sidr_generic_msg *msg =
+			(struct cm_sidr_generic_msg *)mad;
+		msg->request_id = cpu_to_be32(cm_id);
+	} else if (mad->mad_hdr.attr_id == CM_SIDR_REQ_ATTR_ID) {
+		pr_err("trying to set remote_comm_id in SIDR_REQ\n");
+		return;
+	} else {
+		struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
+		msg->remote_comm_id = cpu_to_be32(cm_id);
+	}
 }
 
 static u32 get_remote_comm_id(struct ib_mad *mad)
 {
-	struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
-
-	return be32_to_cpu(msg->remote_comm_id);
+	if (mad->mad_hdr.attr_id == CM_SIDR_REP_ATTR_ID) {
+		struct cm_sidr_generic_msg *msg =
+			(struct cm_sidr_generic_msg *)mad;
+		return be32_to_cpu(msg->request_id);
+	} else if (mad->mad_hdr.attr_id == CM_SIDR_REQ_ATTR_ID) {
+		pr_err("trying to set remote_comm_id in SIDR_REQ\n");
+		return -1;
+	} else {
+		struct cm_generic_msg *msg = (struct cm_generic_msg *)mad;
+		return be32_to_cpu(msg->remote_comm_id);
+	}
 }
 
 static union ib_gid gid_from_req_msg(struct ib_device *ibdev, struct ib_mad *mad)
@@ -282,19 +321,21 @@ int mlx4_ib_multiplex_cm_handler(struct ib_device *ibdev, int port, int slave_id
 	u32 sl_cm_id;
 	int pv_cm_id = -1;
 
-	sl_cm_id = get_local_comm_id(mad);
-
 	if (mad->mad_hdr.attr_id == CM_REQ_ATTR_ID ||
-			mad->mad_hdr.attr_id == CM_REP_ATTR_ID) {
+			mad->mad_hdr.attr_id == CM_REP_ATTR_ID ||
+			mad->mad_hdr.attr_id == CM_SIDR_REQ_ATTR_ID) {
+		sl_cm_id = get_local_comm_id(mad);
 		id = id_map_alloc(ibdev, slave_id, sl_cm_id);
 		if (IS_ERR(id)) {
 			mlx4_ib_warn(ibdev, "%s: id{slave: %d, sl_cm_id: 0x%x} Failed to id_map_alloc\n",
 				__func__, slave_id, sl_cm_id);
 			return PTR_ERR(id);
 		}
-	} else if (mad->mad_hdr.attr_id == CM_REJ_ATTR_ID) {
+	} else if (mad->mad_hdr.attr_id == CM_REJ_ATTR_ID ||
+		   mad->mad_hdr.attr_id == CM_SIDR_REP_ATTR_ID) {
 		return 0;
 	} else {
+		sl_cm_id = get_local_comm_id(mad);
 		id = id_map_get(ibdev, &pv_cm_id, slave_id, sl_cm_id);
 	}
 
@@ -320,7 +361,8 @@ int mlx4_ib_demux_cm_handler(struct ib_device *ibdev, int port, int *slave,
 	u32 pv_cm_id;
 	struct id_map_entry *id;
 
-	if (mad->mad_hdr.attr_id == CM_REQ_ATTR_ID) {
+	if (mad->mad_hdr.attr_id == CM_REQ_ATTR_ID ||
+	    mad->mad_hdr.attr_id == CM_SIDR_REQ_ATTR_ID) {
 		union ib_gid gid;
 
 		if (!slave)
-- 
1.7.1
