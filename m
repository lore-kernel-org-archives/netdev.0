From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH 5/6] scsi: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Thu, 28 Mar 2013 00:53:15 +0800
Message-ID: <1364403195-32839-1-git-send-email-honkiko@gmail.com>
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, tgraf@suug.ch
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/scsi/scsi_netlink.c         |    4 +--
 drivers/scsi/scsi_transport_fc.c    |   21 +++++--------
 drivers/scsi/scsi_transport_iscsi.c |   56 +++++++++++++++++------------------
 3 files changed, 38 insertions(+), 43 deletions(-)

diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 65123a2..fe30ea9 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -50,7 +50,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 	u32 rlen;
 	int err, tport;
 
-	while (skb->len >= NLMSG_SPACE(0)) {
+	while (skb->len >= NLMSG_HDRLEN) {
 		err = 0;
 
 		nlh = nlmsg_hdr(skb);
@@ -70,7 +70,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 			goto next_msg;
 		}
 
-		hdr = NLMSG_DATA(nlh);
+		hdr = nlmsg_data(nlh);
 		if ((hdr->version != SCSI_NL_VERSION) ||
 		    (hdr->magic != SCSI_NL_MAGIC)) {
 			err = -EPROTOTYPE;
diff --git a/drivers/scsi/scsi_transport_fc.c b/drivers/scsi/scsi_transport_fc.c
index e894ca7..e106c27 100644
--- a/drivers/scsi/scsi_transport_fc.c
+++ b/drivers/scsi/scsi_transport_fc.c
@@ -35,7 +35,6 @@
 #include <scsi/scsi_transport.h>
 #include <scsi/scsi_transport_fc.h>
 #include <scsi/scsi_cmnd.h>
-#include <linux/netlink.h>
 #include <net/netlink.h>
 #include <scsi/scsi_netlink_fc.h>
 #include <scsi/scsi_bsg_fc.h>
@@ -534,7 +533,7 @@ fc_host_post_event(struct Scsi_Host *shost, u32 event_number,
 	struct nlmsghdr	*nlh;
 	struct fc_nl_event *event;
 	const char *name;
-	u32 len, skblen;
+	u32 len;
 	int err;
 
 	if (!scsi_nl_sock) {
@@ -543,21 +542,19 @@ fc_host_post_event(struct Scsi_Host *shost, u32 event_number,
 	}
 
 	len = FC_NL_MSGALIGN(sizeof(*event));
-	skblen = NLMSG_SPACE(len);
 
-	skb = alloc_skb(skblen, GFP_KERNEL);
+	skb = nlmsg_new(len, GFP_KERNEL);
 	if (!skb) {
 		err = -ENOBUFS;
 		goto send_fail;
 	}
 
-	nlh = nlmsg_put(skb, 0, 0, SCSI_TRANSPORT_MSG,
-				skblen - sizeof(*nlh), 0);
+	nlh = nlmsg_put(skb, 0, 0, SCSI_TRANSPORT_MSG, len, 0);
 	if (!nlh) {
 		err = -ENOBUFS;
 		goto send_fail_skb;
 	}
-	event = NLMSG_DATA(nlh);
+	event = nlmsg_data(nlh);
 
 	INIT_SCSI_NL_HDR(&event->snlh, SCSI_NL_TRANSPORT_FC,
 				FC_NL_ASYNC_EVENT, len);
@@ -604,7 +601,7 @@ fc_host_post_vendor_event(struct Scsi_Host *shost, u32 event_number,
 	struct sk_buff *skb;
 	struct nlmsghdr	*nlh;
 	struct fc_nl_event *event;
-	u32 len, skblen;
+	u32 len;
 	int err;
 
 	if (!scsi_nl_sock) {
@@ -613,21 +610,19 @@ fc_host_post_vendor_event(struct Scsi_Host *shost, u32 event_number,
 	}
 
 	len = FC_NL_MSGALIGN(sizeof(*event) + data_len);
-	skblen = NLMSG_SPACE(len);
 
-	skb = alloc_skb(skblen, GFP_KERNEL);
+	skb = nlmsg_new(len, GFP_KERNEL);
 	if (!skb) {
 		err = -ENOBUFS;
 		goto send_vendor_fail;
 	}
 
-	nlh = nlmsg_put(skb, 0, 0, SCSI_TRANSPORT_MSG,
-				skblen - sizeof(*nlh), 0);
+	nlh = nlmsg_put(skb, 0, 0, SCSI_TRANSPORT_MSG, len, 0);
 	if (!nlh) {
 		err = -ENOBUFS;
 		goto send_vendor_fail_skb;
 	}
-	event = NLMSG_DATA(nlh);
+	event = nlmsg_data(nlh);
 
 	INIT_SCSI_NL_HDR(&event->snlh, SCSI_NL_TRANSPORT_FC,
 				FC_NL_ASYNC_EVENT, len);
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 0a74b97..4de39e4 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -1344,7 +1344,7 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 	struct iscsi_uevent *ev;
 	char *pdu;
 	struct iscsi_internal *priv;
-	int len = NLMSG_SPACE(sizeof(*ev) + sizeof(struct iscsi_hdr) +
+	int len = nlmsg_total_size(sizeof(*ev) + sizeof(struct iscsi_hdr) +
 			      data_size);
 
 	priv = iscsi_if_transport_lookup(conn->transport);
@@ -1360,7 +1360,7 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 	}
 
 	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
-	ev = NLMSG_DATA(nlh);
+	ev = nlmsg_data(nlh);
 	memset(ev, 0, sizeof(*ev));
 	ev->transport_handle = iscsi_handle(conn->transport);
 	ev->type = ISCSI_KEVENT_RECV_PDU;
@@ -1381,7 +1381,7 @@ int iscsi_offload_mesg(struct Scsi_Host *shost,
 	struct nlmsghdr	*nlh;
 	struct sk_buff *skb;
 	struct iscsi_uevent *ev;
-	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
+	int len = nlmsg_total_size(sizeof(*ev) + data_size);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (!skb) {
@@ -1390,7 +1390,7 @@ int iscsi_offload_mesg(struct Scsi_Host *shost,
 	}
 
 	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
-	ev = NLMSG_DATA(nlh);
+	ev = nlmsg_data(nlh);
 	memset(ev, 0, sizeof(*ev));
 	ev->type = type;
 	ev->transport_handle = iscsi_handle(transport);
@@ -1415,7 +1415,7 @@ void iscsi_conn_error_event(struct iscsi_cls_conn *conn, enum iscsi_err error)
 	struct sk_buff	*skb;
 	struct iscsi_uevent *ev;
 	struct iscsi_internal *priv;
-	int len = NLMSG_SPACE(sizeof(*ev));
+	int len = nlmsg_total_size(sizeof(*ev));
 
 	priv = iscsi_if_transport_lookup(conn->transport);
 	if (!priv)
@@ -1429,7 +1429,7 @@ void iscsi_conn_error_event(struct iscsi_cls_conn *conn, enum iscsi_err error)
 	}
 
 	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
-	ev = NLMSG_DATA(nlh);
+	ev = nlmsg_data(nlh);
 	ev->transport_handle = iscsi_handle(conn->transport);
 	ev->type = ISCSI_KEVENT_CONN_ERROR;
 	ev->r.connerror.error = error;
@@ -1450,7 +1450,7 @@ void iscsi_conn_login_event(struct iscsi_cls_conn *conn,
 	struct sk_buff  *skb;
 	struct iscsi_uevent *ev;
 	struct iscsi_internal *priv;
-	int len = NLMSG_SPACE(sizeof(*ev));
+	int len = nlmsg_total_size(sizeof(*ev));
 
 	priv = iscsi_if_transport_lookup(conn->transport);
 	if (!priv)
@@ -1464,7 +1464,7 @@ void iscsi_conn_login_event(struct iscsi_cls_conn *conn,
 	}
 
 	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
-	ev = NLMSG_DATA(nlh);
+	ev = nlmsg_data(nlh);
 	ev->transport_handle = iscsi_handle(conn->transport);
 	ev->type = ISCSI_KEVENT_CONN_LOGIN_STATE;
 	ev->r.conn_login.state = state;
@@ -1484,7 +1484,7 @@ void iscsi_post_host_event(uint32_t host_no, struct iscsi_transport *transport,
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	struct iscsi_uevent *ev;
-	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
+	int len = nlmsg_total_size(sizeof(*ev) + data_size);
 
 	skb = alloc_skb(len, GFP_NOIO);
 	if (!skb) {
@@ -1494,7 +1494,7 @@ void iscsi_post_host_event(uint32_t host_no, struct iscsi_transport *transport,
 	}
 
 	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
-	ev = NLMSG_DATA(nlh);
+	ev = nlmsg_data(nlh);
 	ev->transport_handle = iscsi_handle(transport);
 	ev->type = ISCSI_KEVENT_HOST_EVENT;
 	ev->r.host_event.host_no = host_no;
@@ -1515,7 +1515,7 @@ void iscsi_ping_comp_event(uint32_t host_no, struct iscsi_transport *transport,
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	struct iscsi_uevent *ev;
-	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
+	int len = nlmsg_total_size(sizeof(*ev) + data_size);
 
 	skb = alloc_skb(len, GFP_NOIO);
 	if (!skb) {
@@ -1524,7 +1524,7 @@ void iscsi_ping_comp_event(uint32_t host_no, struct iscsi_transport *transport,
 	}
 
 	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
-	ev = NLMSG_DATA(nlh);
+	ev = nlmsg_data(nlh);
 	ev->transport_handle = iscsi_handle(transport);
 	ev->type = ISCSI_KEVENT_PING_COMP;
 	ev->r.ping_comp.host_no = host_no;
@@ -1543,7 +1543,7 @@ iscsi_if_send_reply(uint32_t group, int seq, int type, int done, int multi,
 {
 	struct sk_buff	*skb;
 	struct nlmsghdr	*nlh;
-	int len = NLMSG_SPACE(size);
+	int len = nlmsg_total_size(size);
 	int flags = multi ? NLM_F_MULTI : 0;
 	int t = done ? NLMSG_DONE : type;
 
@@ -1555,21 +1555,21 @@ iscsi_if_send_reply(uint32_t group, int seq, int type, int done, int multi,
 
 	nlh = __nlmsg_put(skb, 0, 0, t, (len - sizeof(*nlh)), 0);
 	nlh->nlmsg_flags = flags;
-	memcpy(NLMSG_DATA(nlh), payload, size);
+	memcpy(nlmsg_data(nlh), payload, size);
 	return iscsi_multicast_skb(skb, group, GFP_ATOMIC);
 }
 
 static int
 iscsi_if_get_stats(struct iscsi_transport *transport, struct nlmsghdr *nlh)
 {
-	struct iscsi_uevent *ev = NLMSG_DATA(nlh);
+	struct iscsi_uevent *ev = nlmsg_data(nlh);
 	struct iscsi_stats *stats;
 	struct sk_buff *skbstat;
 	struct iscsi_cls_conn *conn;
 	struct nlmsghdr	*nlhstat;
 	struct iscsi_uevent *evstat;
 	struct iscsi_internal *priv;
-	int len = NLMSG_SPACE(sizeof(*ev) +
+	int len = nlmsg_total_size(sizeof(*ev) +
 			      sizeof(struct iscsi_stats) +
 			      sizeof(struct iscsi_stats_custom) *
 			      ISCSI_STATS_CUSTOM_MAX);
@@ -1595,7 +1595,7 @@ iscsi_if_get_stats(struct iscsi_transport *transport, struct nlmsghdr *nlh)
 
 		nlhstat = __nlmsg_put(skbstat, 0, 0, 0,
 				      (len - sizeof(*nlhstat)), 0);
-		evstat = NLMSG_DATA(nlhstat);
+		evstat = nlmsg_data(nlhstat);
 		memset(evstat, 0, sizeof(*evstat));
 		evstat->transport_handle = iscsi_handle(conn->transport);
 		evstat->type = nlh->nlmsg_type;
@@ -1608,12 +1608,12 @@ iscsi_if_get_stats(struct iscsi_transport *transport, struct nlmsghdr *nlh)
 		memset(stats, 0, sizeof(*stats));
 
 		transport->get_stats(conn, stats);
-		actual_size = NLMSG_SPACE(sizeof(struct iscsi_uevent) +
+		actual_size = nlmsg_total_size(sizeof(struct iscsi_uevent) +
 					  sizeof(struct iscsi_stats) +
 					  sizeof(struct iscsi_stats_custom) *
 					  stats->custom_length);
 		actual_size -= sizeof(*nlhstat);
-		actual_size = NLMSG_LENGTH(actual_size);
+		actual_size = nlmsg_msg_size(actual_size);
 		skb_trim(skbstat, NLMSG_ALIGN(actual_size));
 		nlhstat->nlmsg_len = actual_size;
 
@@ -1637,7 +1637,7 @@ int iscsi_session_event(struct iscsi_cls_session *session,
 	struct iscsi_uevent *ev;
 	struct sk_buff  *skb;
 	struct nlmsghdr *nlh;
-	int rc, len = NLMSG_SPACE(sizeof(*ev));
+	int rc, len = nlmsg_total_size(sizeof(*ev));
 
 	priv = iscsi_if_transport_lookup(session->transport);
 	if (!priv)
@@ -1653,7 +1653,7 @@ int iscsi_session_event(struct iscsi_cls_session *session,
 	}
 
 	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
-	ev = NLMSG_DATA(nlh);
+	ev = nlmsg_data(nlh);
 	ev->transport_handle = iscsi_handle(session->transport);
 
 	ev->type = event;
@@ -2005,7 +2005,7 @@ iscsi_send_ping(struct iscsi_transport *transport, struct iscsi_uevent *ev)
 static int
 iscsi_get_chap(struct iscsi_transport *transport, struct nlmsghdr *nlh)
 {
-	struct iscsi_uevent *ev = NLMSG_DATA(nlh);
+	struct iscsi_uevent *ev = nlmsg_data(nlh);
 	struct Scsi_Host *shost = NULL;
 	struct iscsi_chap_rec *chap_rec;
 	struct iscsi_internal *priv;
@@ -2024,7 +2024,7 @@ iscsi_get_chap(struct iscsi_transport *transport, struct nlmsghdr *nlh)
 		return -EINVAL;
 
 	chap_buf_size = (ev->u.get_chap.num_entries * sizeof(*chap_rec));
-	len = NLMSG_SPACE(sizeof(*ev) + chap_buf_size);
+	len = nlmsg_total_size(sizeof(*ev) + chap_buf_size);
 
 	shost = scsi_host_lookup(ev->u.get_chap.host_no);
 	if (!shost) {
@@ -2045,7 +2045,7 @@ iscsi_get_chap(struct iscsi_transport *transport, struct nlmsghdr *nlh)
 
 		nlhchap = __nlmsg_put(skbchap, 0, 0, 0,
 				      (len - sizeof(*nlhchap)), 0);
-		evchap = NLMSG_DATA(nlhchap);
+		evchap = nlmsg_data(nlhchap);
 		memset(evchap, 0, sizeof(*evchap));
 		evchap->transport_handle = iscsi_handle(transport);
 		evchap->type = nlh->nlmsg_type;
@@ -2058,7 +2058,7 @@ iscsi_get_chap(struct iscsi_transport *transport, struct nlmsghdr *nlh)
 		err = transport->get_chap(shost, ev->u.get_chap.chap_tbl_idx,
 				    &evchap->u.get_chap.num_entries, buf);
 
-		actual_size = NLMSG_SPACE(sizeof(*ev) + chap_buf_size);
+		actual_size = nlmsg_total_size(sizeof(*ev) + chap_buf_size);
 		skb_trim(skbchap, NLMSG_ALIGN(actual_size));
 		nlhchap->nlmsg_len = actual_size;
 
@@ -2096,7 +2096,7 @@ static int
 iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, uint32_t *group)
 {
 	int err = 0;
-	struct iscsi_uevent *ev = NLMSG_DATA(nlh);
+	struct iscsi_uevent *ev = nlmsg_data(nlh);
 	struct iscsi_transport *transport = NULL;
 	struct iscsi_internal *priv;
 	struct iscsi_cls_session *session;
@@ -2263,7 +2263,7 @@ static void
 iscsi_if_rx(struct sk_buff *skb)
 {
 	mutex_lock(&rx_queue_mutex);
-	while (skb->len >= NLMSG_SPACE(0)) {
+	while (skb->len >= NLMSG_HDRLEN) {
 		int err;
 		uint32_t rlen;
 		struct nlmsghdr	*nlh;
@@ -2276,7 +2276,7 @@ iscsi_if_rx(struct sk_buff *skb)
 			break;
 		}
 
-		ev = NLMSG_DATA(nlh);
+		ev = nlmsg_data(nlh);
 		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
 		if (rlen > skb->len)
 			rlen = skb->len;
-- 
1.7.10.4
