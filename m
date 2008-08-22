From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/4 2.6.28] open-iscsi - support for digest offload and payload DDP
Date: Fri, 22 Aug 2008 11:40:08 -0700
Message-ID: <200808221840.m7MIe83k004429@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Cc: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, daisyc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, wenxiong-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, bhua-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


[PATCH 3/4 2.6.28] open-iscsi - support for digest offload and payload DDP.

From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Added PDU digest offload and payload direct-placement support in open-iscsi.

Signed-off-by: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---

 drivers/scsi/iscsi_tcp.c            |   61 ++++++++++++++++++++++++-----------
 drivers/scsi/iscsi_tcp.h            |   14 ++++++++
 drivers/scsi/libiscsi.c             |   51 +++++++++++++++++++++++------
 include/scsi/iscsi_if.h             |    1 +
 include/scsi/libiscsi.h             |    2 +
 include/scsi/scsi_transport_iscsi.h |    9 +++++
 6 files changed, 106 insertions(+), 32 deletions(-)


diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 2a2f009..915416c 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -97,7 +97,7 @@ static int iscsi_tcp_hdr_recv_done(struct iscsi_tcp_conn *tcp_conn,
  * data is copied to the indicated sg entry, at the given
  * offset.
  */
-static inline void
+void
 iscsi_tcp_segment_init_sg(struct iscsi_segment *segment,
 			  struct scatterlist *sg, unsigned int offset)
 {
@@ -107,6 +107,7 @@ iscsi_tcp_segment_init_sg(struct iscsi_segment *segment,
 			    segment->total_size - segment->total_copied);
 	segment->data = NULL;
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_segment_init_sg);
 
 /**
  * iscsi_tcp_segment_map - map the current S/G page
@@ -117,7 +118,7 @@ iscsi_tcp_segment_init_sg(struct iscsi_segment *segment,
  * because the iscsi passthrough and internal IO paths will never use high
  * mem pages.
  */
-static inline void
+void
 iscsi_tcp_segment_map(struct iscsi_segment *segment, int recv)
 {
 	struct scatterlist *sg;
@@ -143,8 +144,9 @@ iscsi_tcp_segment_map(struct iscsi_segment *segment, int recv)
 	segment->sg_mapped = kmap_atomic(sg_page(sg), KM_SOFTIRQ0);
 	segment->data = segment->sg_mapped + sg->offset + segment->sg_offset;
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_segment_map);
 
-static inline void
+void
 iscsi_tcp_segment_unmap(struct iscsi_segment *segment)
 {
 	debug_tcp("iscsi_tcp_segment_unmap %p\n", segment);
@@ -156,6 +158,7 @@ iscsi_tcp_segment_unmap(struct iscsi_segment *segment)
 		segment->data = NULL;
 	}
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_segment_unmap);
 
 /*
  * Splice the digest buffer into the buffer
@@ -376,6 +379,8 @@ static inline int
 iscsi_tcp_dgst_verify(struct iscsi_tcp_conn *tcp_conn,
 		      struct iscsi_segment *segment)
 {
+	if (tcp_conn->iscsi_conn->session->tt->caps & CAP_DIGEST_OFFLOAD)
+		return ((segment->status & ISCSI_SEGMENT_DGST_ERR) ? 0 : 1);
 	if (!segment->digest_len)
 		return 1;
 
@@ -448,7 +453,7 @@ iscsi_segment_seek_sg(struct iscsi_segment *segment,
  * function is called we do not yet know the final size of the header and want
  * to delay the digest processing until we know that.
  */
-static void
+void
 iscsi_tcp_hdr_recv_prep(struct iscsi_tcp_conn *tcp_conn)
 {
 	debug_tcp("iscsi_tcp_hdr_recv_prep(%p%s)\n", tcp_conn,
@@ -457,6 +462,7 @@ iscsi_tcp_hdr_recv_prep(struct iscsi_tcp_conn *tcp_conn)
 				tcp_conn->in.hdr_buf, sizeof(struct iscsi_hdr),
 				iscsi_tcp_hdr_recv_done, NULL);
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_hdr_recv_prep);
 
 /*
  * Handle incoming reply to any other type of command
@@ -486,7 +492,8 @@ iscsi_tcp_data_recv_prep(struct iscsi_tcp_conn *tcp_conn)
 	struct iscsi_conn *conn = tcp_conn->iscsi_conn;
 	struct hash_desc *rx_hash = NULL;
 
-	if (conn->datadgst_en)
+	if (conn->datadgst_en &&
+	    !(conn->session->tt->caps & CAP_DIGEST_OFFLOAD))
 		rx_hash = &tcp_conn->rx_hash;
 
 	iscsi_segment_init_linear(&tcp_conn->in.segment,
@@ -497,7 +504,7 @@ iscsi_tcp_data_recv_prep(struct iscsi_tcp_conn *tcp_conn)
 /*
  * must be called with session lock
  */
-static void
+void
 iscsi_tcp_cleanup_task(struct iscsi_conn *conn, struct iscsi_task *task)
 {
 	struct iscsi_tcp_task *tcp_task = task->dd_data;
@@ -521,6 +528,7 @@ iscsi_tcp_cleanup_task(struct iscsi_conn *conn, struct iscsi_task *task)
 		tcp_task->r2t = NULL;
 	}
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_cleanup_task);
 
 /**
  * iscsi_data_rsp - SCSI Data-In Response processing
@@ -737,7 +745,7 @@ iscsi_tcp_process_data_in(struct iscsi_tcp_conn *tcp_conn,
  * by data, the receive buffer is set up to copy the incoming data
  * to the correct location.
  */
-static int
+int
 iscsi_tcp_hdr_dissect(struct iscsi_conn *conn, struct iscsi_hdr *hdr)
 {
 	int rc = 0, opcode, ahslen;
@@ -793,7 +801,8 @@ iscsi_tcp_hdr_dissect(struct iscsi_conn *conn, struct iscsi_hdr *hdr)
 			 * we move on to the next scatterlist entry and
 			 * update the digest per-entry.
 			 */
-			if (conn->datadgst_en)
+			if (conn->datadgst_en &&
+			    !(conn->session->tt->caps & CAP_DIGEST_OFFLOAD))
 				rx_hash = &tcp_conn->rx_hash;
 
 			debug_tcp("iscsi_tcp_begin_data_in(%p, offset=%d, "
@@ -881,6 +890,7 @@ iscsi_tcp_hdr_dissect(struct iscsi_conn *conn, struct iscsi_hdr *hdr)
 
 	return rc;
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_hdr_dissect);
 
 /**
  * iscsi_tcp_hdr_recv_done - process PDU header
@@ -919,7 +929,8 @@ iscsi_tcp_hdr_recv_done(struct iscsi_tcp_conn *tcp_conn,
 	/* We're done processing the header. See if we're doing
 	 * header digests; if so, set up the recv_digest buffer
 	 * and go back for more. */
-	if (conn->hdrdgst_en) {
+	if (conn->hdrdgst_en &&
+	    !(conn->session->tt->caps & CAP_DIGEST_OFFLOAD)) {
 		if (segment->digest_len == 0) {
 			iscsi_tcp_segment_splice_digest(segment,
 							segment->recv_digest);
@@ -944,7 +955,8 @@ iscsi_tcp_hdr_recv_done(struct iscsi_tcp_conn *tcp_conn,
  * @offset: offset in skb
  * @len: skb->len - offset
  **/
-static int
+
+int
 iscsi_tcp_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 	       unsigned int offset, size_t len)
 {
@@ -1158,7 +1170,7 @@ iscsi_tcp_xmit_qlen(struct iscsi_conn *conn)
 	return segment->total_copied - segment->total_size;
 }
 
-static inline int
+static int
 iscsi_tcp_flush(struct iscsi_conn *conn)
 {
 	int rc;
@@ -1205,7 +1217,8 @@ iscsi_tcp_send_hdr_prep(struct iscsi_conn *conn, void *hdr, size_t hdrlen)
 	 * sure that both iscsi_tcp_task and mtask have
 	 * sufficient room.
 	 */
-	if (conn->hdrdgst_en) {
+	if (conn->hdrdgst_en &&
+	    !(conn->session->tt->caps & CAP_DIGEST_OFFLOAD)) {
 		iscsi_tcp_dgst_header(&tcp_conn->tx_hash, hdr, hdrlen,
 				      hdr + hdrlen);
 		hdrlen += ISCSI_DIGEST_SIZE;
@@ -1243,7 +1256,8 @@ iscsi_tcp_send_data_prep(struct iscsi_conn *conn, struct scatterlist *sg,
 	hdr_spec_len = ntoh24(tcp_conn->out.hdr->dlength);
 	WARN_ON(iscsi_padded(len) != iscsi_padded(hdr_spec_len));
 
-	if (conn->datadgst_en)
+	if (conn->datadgst_en &&
+	    !(conn->session->tt->caps & CAP_DIGEST_OFFLOAD))
 		tx_hash = &tcp_conn->tx_hash;
 
 	return iscsi_segment_seek_sg(&tcp_conn->out.data_segment,
@@ -1267,7 +1281,8 @@ iscsi_tcp_send_linear_data_prepare(struct iscsi_conn *conn, void *data,
 	hdr_spec_len = ntoh24(tcp_conn->out.hdr->dlength);
 	WARN_ON(iscsi_padded(len) != iscsi_padded(hdr_spec_len));
 
-	if (conn->datadgst_en)
+	if (conn->datadgst_en &&
+	    !(conn->session->tt->caps & CAP_DIGEST_OFFLOAD))
 		tx_hash = &tcp_conn->tx_hash;
 
 	iscsi_segment_init_linear(&tcp_conn->out.data_segment,
@@ -1329,7 +1344,7 @@ iscsi_solicit_data_cont(struct iscsi_conn *conn, struct iscsi_task *task,
  * @task: scsi command task
  * @sc: scsi command
  **/
-static int
+int
 iscsi_tcp_task_init(struct iscsi_task *task)
 {
 	struct iscsi_tcp_task *tcp_task = task->dd_data;
@@ -1378,6 +1393,7 @@ iscsi_tcp_task_init(struct iscsi_task *task)
 	task->imm_count = 0;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_task_init);
 
 /*
  * iscsi_tcp_task_xmit - xmit normal PDU task
@@ -1387,7 +1403,7 @@ iscsi_tcp_task_init(struct iscsi_task *task)
  * -EAGAIN if there's still data in the queue, or != 0 for any other kind
  * of error.
  */
-static int
+int
 iscsi_tcp_task_xmit(struct iscsi_task *task)
 {
 	struct iscsi_conn *conn = task->conn;
@@ -1398,7 +1414,7 @@ iscsi_tcp_task_xmit(struct iscsi_task *task)
 
 flush:
 	/* Flush any pending data first. */
-	rc = iscsi_tcp_flush(conn);
+	rc = conn->session->tt->flush_conn(conn);
 	if (rc < 0)
 		return rc;
 
@@ -1490,6 +1506,7 @@ fail:
 	iscsi_conn_failure(conn, rc);
 	return -EIO;
 }
+EXPORT_SYMBOL_GPL(iscsi_tcp_task_xmit);
 
 static struct iscsi_cls_conn *
 iscsi_tcp_conn_create(struct iscsi_cls_session *cls_session, uint32_t conn_idx)
@@ -1696,7 +1713,7 @@ free_socket:
 	return err;
 }
 
-static int
+int
 iscsi_r2tpool_alloc(struct iscsi_session *session)
 {
 	int i;
@@ -1742,8 +1759,9 @@ r2t_alloc_fail:
 	}
 	return -ENOMEM;
 }
+EXPORT_SYMBOL_GPL(iscsi_r2tpool_alloc);
 
-static void
+void
 iscsi_r2tpool_free(struct iscsi_session *session)
 {
 	int i;
@@ -1756,6 +1774,7 @@ iscsi_r2tpool_free(struct iscsi_session *session)
 		iscsi_pool_free(&tcp_task->r2tpool);
 	}
 }
+EXPORT_SYMBOL_GPL(iscsi_r2tpool_free);
 
 static int
 iscsi_conn_set_param(struct iscsi_cls_conn *cls_conn, enum iscsi_param param,
@@ -1904,6 +1923,7 @@ static void iscsi_tcp_session_destroy(struct iscsi_cls_session *cls_session)
 	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
 
 	iscsi_r2tpool_free(cls_session->dd_data);
+	iscsi_session_teardown(cls_session);
 
 	iscsi_host_remove(shost);
 	iscsi_host_free(shost);
@@ -1927,7 +1947,7 @@ static struct scsi_host_template iscsi_sht = {
 	.cmd_per_lun		= ISCSI_DEF_CMD_PER_LUN,
 	.eh_abort_handler       = iscsi_eh_abort,
 	.eh_device_reset_handler= iscsi_eh_device_reset,
-	.eh_host_reset_handler	= iscsi_eh_host_reset,
+	.eh_target_reset_handler= iscsi_eh_target_reset,
 	.use_clustering         = DISABLE_CLUSTERING,
 	.slave_configure        = iscsi_tcp_slave_configure,
 	.proc_name		= "iscsi_tcp",
@@ -1978,6 +1998,7 @@ static struct iscsi_transport iscsi_tcp_transport = {
 	.get_session_param	= iscsi_session_get_param,
 	.start_conn		= iscsi_conn_start,
 	.stop_conn		= iscsi_tcp_conn_stop,
+	.flush_conn		= iscsi_tcp_flush,
 	/* iscsi host params */
 	.get_host_param		= iscsi_host_get_param,
 	.set_host_param		= iscsi_host_set_param,
diff --git a/drivers/scsi/iscsi_tcp.h b/drivers/scsi/iscsi_tcp.h
index 498d8ca..62747c7 100644
--- a/drivers/scsi/iscsi_tcp.h
+++ b/drivers/scsi/iscsi_tcp.h
@@ -32,7 +32,9 @@ struct iscsi_segment;
 typedef int iscsi_segment_done_fn_t(struct iscsi_tcp_conn *,
 				    struct iscsi_segment *);
 
+#define ISCSI_SEGMENT_DGST_ERR	0x1
 struct iscsi_segment {
+	unsigned int		status;
 	unsigned char		*data;
 	unsigned int		size;
 	unsigned int		copied;
@@ -130,4 +132,16 @@ struct iscsi_tcp_task {
 	struct iscsi_data_task	unsol_dtask;	/* Data-Out header buf */
 };
 
+void iscsi_tcp_segment_init_sg(struct iscsi_segment *, struct scatterlist *,
+			       unsigned int);
+void iscsi_tcp_segment_map(struct iscsi_segment *, int);
+void iscsi_tcp_segment_unmap(struct iscsi_segment *);
+void iscsi_tcp_hdr_recv_prep(struct iscsi_tcp_conn *);
+void iscsi_tcp_cleanup_task(struct iscsi_conn *, struct iscsi_task *);
+int iscsi_tcp_hdr_dissect(struct iscsi_conn *conn, struct iscsi_hdr *);
+int iscsi_tcp_task_init(struct iscsi_task *);
+int iscsi_tcp_task_xmit(struct iscsi_task *);
+int iscsi_r2tpool_alloc(struct iscsi_session *);
+void iscsi_r2tpool_free(struct iscsi_session *);
+
 #endif /* ISCSI_H */
diff --git a/drivers/scsi/libiscsi.c b/drivers/scsi/libiscsi.c
index 299e075..0504aa1 100644
--- a/drivers/scsi/libiscsi.c
+++ b/drivers/scsi/libiscsi.c
@@ -218,7 +218,12 @@ static int iscsi_prep_scsi_cmd_pdu(struct iscsi_task *task)
 	hdr->opcode = ISCSI_OP_SCSI_CMD;
 	hdr->flags = ISCSI_ATTR_SIMPLE;
 	int_to_scsilun(sc->device->lun, (struct scsi_lun *)hdr->lun);
-	hdr->itt = build_itt(task->itt, session->age);
+	if (session->tt->reserve_itt) {
+		rc = session->tt->reserve_itt(task, &hdr->itt);
+		if (rc)
+			return rc;
+	} else
+		hdr->itt = build_itt(task->itt, session->age);
 	hdr->cmdsn = cpu_to_be32(session->cmdsn);
 	session->cmdsn++;
 	hdr->exp_statsn = cpu_to_be32(conn->exp_statsn);
@@ -332,6 +337,9 @@ static void iscsi_complete_command(struct iscsi_task *task)
 	struct iscsi_session *session = conn->session;
 	struct scsi_cmnd *sc = task->sc;
 
+	if (session->tt->release_itt)
+		session->tt->release_itt(task, task->hdr->itt);
+
 	list_del_init(&task->running);
 	task->state = ISCSI_TASK_COMPLETED;
 	task->sc = NULL;
@@ -442,7 +450,12 @@ static int iscsi_prep_mgmt_task(struct iscsi_conn *conn,
 	 */
 	nop->cmdsn = cpu_to_be32(session->cmdsn);
 	if (hdr->itt != RESERVED_ITT) {
-		hdr->itt = build_itt(task->itt, session->age);
+		if (session->tt->reserve_itt) {
+			int rc = session->tt->reserve_itt(task, &hdr->itt);
+			if (rc)
+				return rc;
+		} else
+			hdr->itt = build_itt(task->itt, session->age);
 		/*
 		 * TODO: We always use immediate, so we never hit this.
 		 * If we start to send tmfs or nops as non-immediate then
@@ -691,7 +704,12 @@ static int iscsi_handle_reject(struct iscsi_conn *conn, struct iscsi_hdr *hdr,
 
 		if (ntoh24(reject->dlength) >= sizeof(struct iscsi_hdr)) {
 			memcpy(&rejected_pdu, data, sizeof(struct iscsi_hdr));
-			itt = get_itt(rejected_pdu.itt);
+			if (conn->session->tt->parse_itt) {
+				conn->session->tt->parse_itt(conn,
+							     rejected_pdu.itt,
+							     &itt, NULL);
+			} else
+				itt = get_itt(rejected_pdu.itt);
 			iscsi_conn_printk(KERN_ERR, conn,
 					  "itt 0x%x had pdu (op 0x%x) rejected "
 					  "due to DataDigest error.\n", itt,
@@ -719,7 +737,10 @@ static struct iscsi_task *iscsi_itt_to_task(struct iscsi_conn *conn, itt_t itt)
 	if (itt == RESERVED_ITT)
 		return NULL;
 
-	i = get_itt(itt);
+	if (conn->session->tt->parse_itt)
+		conn->session->tt->parse_itt(conn, itt, &i, NULL);
+	else
+		i = get_itt(itt);
 	if (i >= session->cmds_max)
 		return NULL;
 
@@ -750,9 +771,12 @@ int __iscsi_complete_pdu(struct iscsi_conn *conn, struct iscsi_hdr *hdr,
 	if (rc)
 		return rc;
 
-	if (hdr->itt != RESERVED_ITT)
-		itt = get_itt(hdr->itt);
-	else
+	if (hdr->itt != RESERVED_ITT) {
+		if (conn->session->tt->parse_itt)
+			conn->session->tt->parse_itt(conn, hdr->itt, &itt, NULL);
+		else
+			itt = get_itt(hdr->itt);
+	} else
 		itt = ~0U;
 
 	debug_scsi("[op 0x%x cid %d itt 0x%x len %d]\n",
@@ -899,20 +923,25 @@ EXPORT_SYMBOL_GPL(iscsi_complete_pdu);
 int iscsi_verify_itt(struct iscsi_conn *conn, itt_t itt)
 {
 	struct iscsi_session *session = conn->session;
-	uint32_t i;
+	uint32_t i, age;
 
 	if (itt == RESERVED_ITT)
 		return 0;
 
-	if (((__force u32)itt & ISCSI_AGE_MASK) !=
-	    (session->age << ISCSI_AGE_SHIFT)) {
+	if (conn->session->tt->parse_itt)
+		conn->session->tt->parse_itt(conn, hdr->itt, &i, &age);
+	else {
+		i = get_itt(itt);
+		age = ((__force u32)itt >> ISCSI_AGE_SHIFT) & ISCSI_AGE_MASK;
+	}
+
+	if (age != session->age) {
 		iscsi_conn_printk(KERN_ERR, conn,
 				  "received itt %x expected session age (%x)\n",
 				  (__force u32)itt, session->age);
 		return ISCSI_ERR_BAD_ITT;
 	}
 
-	i = get_itt(itt);
 	if (i >= session->cmds_max) {
 		iscsi_conn_printk(KERN_ERR, conn,
 				  "received invalid itt index %u (max cmds "
diff --git a/include/scsi/iscsi_if.h b/include/scsi/iscsi_if.h
index 16be12f..75afc58 100644
--- a/include/scsi/iscsi_if.h
+++ b/include/scsi/iscsi_if.h
@@ -333,6 +333,7 @@ enum iscsi_host_param {
 #define CAP_FW_DB		0x200
 #define CAP_SENDTARGETS_OFFLOAD	0x400
 #define CAP_DATA_PATH_OFFLOAD	0x800
+#define CAP_DIGEST_OFFLOAD	0x1000
 
 /*
  * These flags describes reason of stop_conn() call
diff --git a/include/scsi/libiscsi.h b/include/scsi/libiscsi.h
index 5e75bb7..31f916f 100644
--- a/include/scsi/libiscsi.h
+++ b/include/scsi/libiscsi.h
@@ -75,7 +75,7 @@ enum {
 /* this must be a power of two greater than ISCSI_MGMT_CMDS_MAX */
 #define ISCSI_TOTAL_CMDS_MIN		16
 #define ISCSI_AGE_SHIFT			28
-#define ISCSI_AGE_MASK			(0xf << ISCSI_AGE_SHIFT)
+#define ISCSI_AGE_MASK			0xf
 
 #define ISCSI_ADDRESS_BUF_LEN		64
 
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index 8b6c91d..76337bc 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -56,6 +56,10 @@ struct sockaddr;
  *			is not supported, and a -Exx value on other error
  * @start_conn:		set connection to be operational
  * @stop_conn:		suspend/recover/terminate connection
+ * @flush_conn:		flush a connection's transmit queue
+ * @parse_itt:		parse the itt rcv'ed in BHS
+ * @reserve_itt:	construct a task itt to be sent in BHS
+ * @release_itt:	release a itt (constructed by reserve_itt)
  * @send_pdu:		send iSCSI PDU, Login, Logout, NOP-Out, Reject, Text.
  * @session_recovery_timedout: notify LLD a block during recovery timed out
  * @init_task:		Initialize a iscsi_task and any internal structs.
@@ -113,6 +117,11 @@ struct iscsi_transport {
 			 char *data, uint32_t data_size);
 	void (*get_stats) (struct iscsi_cls_conn *conn,
 			   struct iscsi_stats *stats);
+	int (*flush_conn) (struct iscsi_conn *conn);
+	void (*parse_itt)(struct iscsi_conn *conn, itt_t hdr_itt,
+			  int *idx, int *age);
+	int (*reserve_itt)(struct iscsi_task *task, itt_t *hdr_itt);
+	void (*release_itt)(struct iscsi_task *task, itt_t hdr_itt);
 	int (*init_task) (struct iscsi_task *task);
 	int (*xmit_task) (struct iscsi_task *task);
 	void (*cleanup_task) (struct iscsi_conn *conn,
