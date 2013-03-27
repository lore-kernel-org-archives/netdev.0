From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] netlink: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Wed, 27 Mar 2013 08:06:02 +0800
Message-ID: <1364342762-26861-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, tgraf@suug.ch, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:46938 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab3C0AG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 20:06:26 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so3870968dad.32
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 17:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas, please review it. Next should we made nlmsg_* available
for uapi?

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/connector/connector.c        |    8 ++---
 drivers/scsi/scsi_netlink.c          |    4 +--
 drivers/scsi/scsi_transport_fc.c     |   10 +++---
 drivers/scsi/scsi_transport_iscsi.c  |   56 +++++++++++++++++-----------------
 drivers/staging/gdm72xx/netlink_k.c  |   12 ++++----
 kernel/audit.c                       |   10 +++---
 net/bridge/netfilter/ebt_ulog.c      |    4 +--
 net/core/rtnetlink.c                 |    4 +--
 net/decnet/dn_table.c                |    4 +--
 net/decnet/netfilter/dn_rtmsg.c      |    6 ++--
 net/ieee802154/netlink.c             |    4 +--
 net/ipv4/fib_frontend.c              |    6 ++--
 net/ipv4/ipmr.c                      |   10 +++---
 net/ipv4/netfilter/ipt_ULOG.c        |    4 +--
 net/ipv4/udp_diag.c                  |    2 +-
 net/ipv6/ip6mr.c                     |   10 +++---
 net/netfilter/ipset/ip_set_core.c    |    5 ++-
 net/netfilter/nfnetlink.c            |    7 ++---
 net/netfilter/nfnetlink_log.c        |    4 +--
 net/netfilter/nfnetlink_queue_core.c |    2 +-
 net/netlink/af_netlink.c             |    4 +--
 net/sched/cls_api.c                  |    4 +--
 net/sched/sch_api.c                  |    2 +-
 net/tipc/netlink.c                   |    6 ++--
 security/selinux/hooks.c             |    4 +--
 security/selinux/netlink.c           |    3 +-
 26 files changed, 96 insertions(+), 99 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index f1b7e24..395a224 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -23,7 +23,7 @@
 #include <linux/module.h>
 #include <linux/list.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/moduleparam.h>
 #include <linux/connector.h>
 #include <linux/slab.h>
@@ -95,7 +95,7 @@ int cn_netlink_send(struct cn_msg *msg, u32 __group, gfp_t gfp_mask)
 	if (!netlink_has_listeners(dev->nls, group))
 		return -ESRCH;
 
-	size = NLMSG_SPACE(sizeof(*msg) + msg->len);
+	size = nlmsg_total_size(sizeof(*msg) + msg->len);
 
 	skb = alloc_skb(size, gfp_mask);
 	if (!skb)
@@ -124,7 +124,7 @@ static int cn_call_callback(struct sk_buff *skb)
 {
 	struct cn_callback_entry *i, *cbq = NULL;
 	struct cn_dev *dev = &cdev;
-	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(skb));
+	struct cn_msg *msg = nlmsg_data(nlmsg_hdr(skb));
 	struct netlink_skb_parms *nsp = &NETLINK_CB(skb);
 	int err = -ENODEV;
 
@@ -162,7 +162,7 @@ static void cn_rx_skb(struct sk_buff *__skb)
 
 	skb = skb_get(__skb);
 
-	if (skb->len >= NLMSG_SPACE(0)) {
+	if (skb->len >= nlmsg_total_size(0)) {
 		nlh = nlmsg_hdr(skb);
 
 		if (nlh->nlmsg_len < sizeof(struct cn_msg) ||
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 65123a2..c39abff 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -50,7 +50,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 	u32 rlen;
 	int err, tport;
 
-	while (skb->len >= NLMSG_SPACE(0)) {
+	while (skb->len >= nlmsg_total_size(0)) {
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
index e894ca7..394aedb 100644
--- a/drivers/scsi/scsi_transport_fc.c
+++ b/drivers/scsi/scsi_transport_fc.c
@@ -35,7 +35,7 @@
 #include <scsi/scsi_transport.h>
 #include <scsi/scsi_transport_fc.h>
 #include <scsi/scsi_cmnd.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <net/netlink.h>
 #include <scsi/scsi_netlink_fc.h>
 #include <scsi/scsi_bsg_fc.h>
@@ -543,7 +543,7 @@ fc_host_post_event(struct Scsi_Host *shost, u32 event_number,
 	}
 
 	len = FC_NL_MSGALIGN(sizeof(*event));
-	skblen = NLMSG_SPACE(len);
+	skblen = nlmsg_total_size(len);
 
 	skb = alloc_skb(skblen, GFP_KERNEL);
 	if (!skb) {
@@ -557,7 +557,7 @@ fc_host_post_event(struct Scsi_Host *shost, u32 event_number,
 		err = -ENOBUFS;
 		goto send_fail_skb;
 	}
-	event = NLMSG_DATA(nlh);
+	event = nlmsg_data(nlh);
 
 	INIT_SCSI_NL_HDR(&event->snlh, SCSI_NL_TRANSPORT_FC,
 				FC_NL_ASYNC_EVENT, len);
@@ -613,7 +613,7 @@ fc_host_post_vendor_event(struct Scsi_Host *shost, u32 event_number,
 	}
 
 	len = FC_NL_MSGALIGN(sizeof(*event) + data_len);
-	skblen = NLMSG_SPACE(len);
+	skblen = nlmsg_total_size(len);
 
 	skb = alloc_skb(skblen, GFP_KERNEL);
 	if (!skb) {
@@ -627,7 +627,7 @@ fc_host_post_vendor_event(struct Scsi_Host *shost, u32 event_number,
 		err = -ENOBUFS;
 		goto send_vendor_fail_skb;
 	}
-	event = NLMSG_DATA(nlh);
+	event = nlmsg_data(nlh);
 
 	INIT_SCSI_NL_HDR(&event->snlh, SCSI_NL_TRANSPORT_FC,
 				FC_NL_ASYNC_EVENT, len);
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 0a74b97..d1a44f5 100644
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
+	while (skb->len >= nlmsg_total_size(0)) {
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
diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gdm72xx/netlink_k.c
index 52c25ba..59cc00f 100644
--- a/drivers/staging/gdm72xx/netlink_k.c
+++ b/drivers/staging/gdm72xx/netlink_k.c
@@ -15,7 +15,7 @@
 
 #include <linux/module.h>
 #include <linux/etherdevice.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <asm/byteorder.h>
 #include <net/sock.h>
 
@@ -25,12 +25,12 @@
 
 #define ND_MAX_GROUP			30
 #define ND_IFINDEX_LEN			sizeof(int)
-#define ND_NLMSG_SPACE(len)		(NLMSG_SPACE(len) + ND_IFINDEX_LEN)
+#define ND_NLMSG_SPACE(len)		(nlmsg_total_size(len) + ND_IFINDEX_LEN)
 #define ND_NLMSG_DATA(nlh) \
-	((void *)((char *)NLMSG_DATA(nlh) + ND_IFINDEX_LEN))
+	((void *)((char *)nlmsg_data(nlh) + ND_IFINDEX_LEN))
 #define ND_NLMSG_S_LEN(len)		(len+ND_IFINDEX_LEN)
 #define ND_NLMSG_R_LEN(nlh)		(nlh->nlmsg_len-ND_IFINDEX_LEN)
-#define ND_NLMSG_IFIDX(nlh)		NLMSG_DATA(nlh)
+#define ND_NLMSG_IFIDX(nlh)		nlmsg_data(nlh)
 #define ND_MAX_MSG_LEN			8096
 
 #if defined(DEFINE_MUTEX)
@@ -51,7 +51,7 @@ static void netlink_rcv_cb(struct sk_buff *skb)
 	void *msg;
 	int ifindex;
 
-	if (skb->len >= NLMSG_SPACE(0)) {
+	if (skb->len >= nlmsg_total_size(0)) {
 		nlh = (struct nlmsghdr *)skb->data;
 
 		if (skb->len < nlh->nlmsg_len ||
@@ -124,7 +124,7 @@ int netlink_send(struct sock *sock, int group, u16 type, void *msg, int len)
 		return -EINVAL;
 	}
 
-	skb = alloc_skb(NLMSG_SPACE(len), GFP_ATOMIC);
+	skb = alloc_skb(nlmsg_total_size(len), GFP_ATOMIC);
 	if (!skb) {
 		pr_err("netlink_broadcast ret=%d\n", ret);
 		return -ENOMEM;
diff --git a/kernel/audit.c b/kernel/audit.c
index d596e53..6405995 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -58,7 +58,7 @@
 #ifdef CONFIG_SECURITY
 #include <linux/security.h>
 #endif
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/freezer.h>
 #include <linux/tty.h>
 #include <linux/pid_namespace.h>
@@ -910,7 +910,7 @@ static void audit_receive_skb(struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh;
 	/*
-	 * len MUST be signed for NLMSG_NEXT to be able to dec it below 0
+	 * len MUST be signed for nlmsg_next to be able to dec it below 0
 	 * if the nlmsg_len was not aligned
 	 */
 	int len;
@@ -919,13 +919,13 @@ static void audit_receive_skb(struct sk_buff *skb)
 	nlh = nlmsg_hdr(skb);
 	len = skb->len;
 
-	while (NLMSG_OK(nlh, len)) {
+	while (nlmsg_ok(nlh, len)) {
 		err = audit_receive_msg(skb, nlh);
 		/* if err or if this message says it wants a response */
 		if (err || (nlh->nlmsg_flags & NLM_F_ACK))
 			netlink_ack(skb, nlh, err);
 
-		nlh = NLMSG_NEXT(nlh, len);
+		nlh = nlmsg_next(nlh, len);
 	}
 }
 
@@ -1483,7 +1483,7 @@ void audit_log_end(struct audit_buffer *ab)
 		audit_log_lost("rate limit exceeded");
 	} else {
 		struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
-		nlh->nlmsg_len = ab->skb->len - NLMSG_SPACE(0);
+		nlh->nlmsg_len = ab->skb->len - nlmsg_total_size(0);
 
 		if (audit_pid) {
 			skb_queue_tail(&audit_skb_queue, ab->skb);
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 3bf43f7..75f23ba 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -35,7 +35,7 @@
 #include <linux/skbuff.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_bridge/ebtables.h>
@@ -134,7 +134,7 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 	else
 		copy_len = uloginfo->cprange;
 
-	size = NLMSG_SPACE(sizeof(*pm) + copy_len);
+	size = nlmsg_total_size(sizeof(*pm) + copy_len);
 	if (size > nlbufsiz) {
 		pr_debug("Size %Zd needed, but nlbufsiz=%d\n", size, nlbufsiz);
 		return;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index aeb8131..1ba25fb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2613,10 +2613,10 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	type -= RTM_BASE;
 
 	/* All the messages must have at least 1 byte length */
-	if (nlh->nlmsg_len < NLMSG_LENGTH(sizeof(struct rtgenmsg)))
+	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(struct rtgenmsg)))
 		return 0;
 
-	family = ((struct rtgenmsg *)NLMSG_DATA(nlh))->rtgen_family;
+	family = ((struct rtgenmsg *)nlmsg_data(nlh))->rtgen_family;
 	sz_idx = type>>2;
 	kind = type&3;
 
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index fc42a0a..d98563a 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -19,7 +19,7 @@
 #include <linux/sockios.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/rtnetlink.h>
 #include <linux/proc_fs.h>
 #include <linux/netdevice.h>
@@ -492,7 +492,7 @@ int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	if (!net_eq(net, &init_net))
 		return 0;
 
-	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
+	if (nlmsg_attrlen(cb->nlh, 0) >= sizeof(struct rtmsg) &&
 		((struct rtmsg *)nlmsg_data(cb->nlh))->rtm_flags&RTM_F_CLONED)
 			return dn_cache_dump(skb, cb);
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index dfe4201..a26c4b6 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -19,7 +19,7 @@
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
 #include <linux/spinlock.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netfilter_decnet.h>
 
 #include <net/sock.h>
@@ -39,7 +39,7 @@ static struct sk_buff *dnrmg_build_message(struct sk_buff *rt_skb, int *errp)
 	unsigned char *ptr;
 	struct nf_dn_rtmsg *rtm;
 
-	size = NLMSG_SPACE(rt_skb->len);
+	size = nlmsg_total_size(rt_skb->len);
 	size += NLMSG_ALIGN(sizeof(struct nf_dn_rtmsg));
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
@@ -53,7 +53,7 @@ static struct sk_buff *dnrmg_build_message(struct sk_buff *rt_skb, int *errp)
 		*errp = -ENOMEM;
 		return NULL;
 	}
-	rtm = (struct nf_dn_rtmsg *)NLMSG_DATA(nlh);
+	rtm = (struct nf_dn_rtmsg *)nlmsg_data(nlh);
 	rtm->nfdn_ifindex = rt_skb->dev->ifindex;
 	ptr = NFDN_RTMSG(rtm);
 	skb_copy_from_linear_data(rt_skb, ptr, rt_skb->len);
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 97351e1..9247252 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -65,7 +65,7 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
 {
 	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
+	void *hdr = genlmsg_data(nlmsg_data(msg->data));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
@@ -98,7 +98,7 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
 {
 	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
+	void *hdr = genlmsg_data(nlmsg_data(msg->data));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 0e74398..1452422 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -957,8 +957,8 @@ static void nl_fib_input(struct sk_buff *skb)
 
 	net = sock_net(skb->sk);
 	nlh = nlmsg_hdr(skb);
-	if (skb->len < NLMSG_SPACE(0) || skb->len < nlh->nlmsg_len ||
-	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn)))
+	if (skb->len < nlmsg_total_size(0) || skb->len < nlh->nlmsg_len ||
+	    nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frn)))
 		return;
 
 	skb = skb_clone(skb, GFP_KERNEL);
@@ -966,7 +966,7 @@ static void nl_fib_input(struct sk_buff *skb)
 		return;
 	nlh = nlmsg_hdr(skb);
 
-	frn = (struct fib_result_nl *) NLMSG_DATA(nlh);
+	frn = (struct fib_result_nl *) nlmsg_data(nlh);
 	tb = fib_get_table(net, frn->tb_id_in);
 
 	nl_fib_lookup(frn, tb);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f95b3a..e7b4bde 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -626,9 +626,9 @@ static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
-			nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
-			e = NLMSG_DATA(nlh);
+			e = nlmsg_data(nlh);
 			e->error = -ETIMEDOUT;
 			memset(&e->msg, 0, sizeof(e->msg));
 
@@ -910,14 +910,14 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
-			if (__ipmr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (__ipmr_fill_mroute(mrt, skb, c, nlmsg_data(nlh)) > 0) {
 				nlh->nlmsg_len = skb_tail_pointer(skb) -
 						 (u8 *)nlh;
 			} else {
 				nlh->nlmsg_type = NLMSG_ERROR;
-				nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+				nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 				skb_trim(skb, nlh->nlmsg_len);
-				e = NLMSG_DATA(nlh);
+				e = nlmsg_data(nlh);
 				e->error = -EMSGSIZE;
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 7d168dc..e7f8cad 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -37,7 +37,7 @@
 #include <linux/skbuff.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netdevice.h>
 #include <linux/mm.h>
 #include <linux/moduleparam.h>
@@ -172,7 +172,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	else
 		copy_len = loginfo->copy_range;
 
-	size = NLMSG_SPACE(sizeof(*pm) + copy_len);
+	size = nlmsg_total_size(sizeof(*pm) + copy_len);
 
 	ub = &ulog_buffers[groupnum];
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 505b30a..bafd65c 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -64,7 +64,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		goto out;
 
 	err = -ENOMEM;
-	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
+	rep = alloc_skb(nlmsg_total_size((sizeof(struct inet_diag_msg) +
 				     sizeof(struct inet_diag_meminfo) +
 				     64)), GFP_KERNEL);
 	if (!rep)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 96bfb4e..241fb8a 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -842,9 +842,9 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
-			nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
-			((struct nlmsgerr *)NLMSG_DATA(nlh))->error = -ETIMEDOUT;
+			((struct nlmsgerr *)nlmsg_data(nlh))->error = -ETIMEDOUT;
 			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else
 			kfree_skb(skb);
@@ -1100,13 +1100,13 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 
-			if (__ip6mr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (__ip6mr_fill_mroute(mrt, skb, c, nlmsg_data(nlh)) > 0) {
 				nlh->nlmsg_len = skb_tail_pointer(skb) - (u8 *)nlh;
 			} else {
 				nlh->nlmsg_type = NLMSG_ERROR;
-				nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+				nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 				skb_trim(skb, nlh->nlmsg_len);
-				((struct nlmsgerr *)NLMSG_DATA(nlh))->error = -EMSGSIZE;
+				((struct nlmsgerr *)nlmsg_data(nlh))->error = -EMSGSIZE;
 			}
 			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 1ba9dbc..86f5e26 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -15,7 +15,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
-#include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <net/netlink.h>
 
@@ -1085,7 +1084,7 @@ static int
 dump_init(struct netlink_callback *cb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(cb->skb);
-	int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+	int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
 	struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
 	struct nlattr *attr = (void *)nlh + min_len;
 	u32 dump_type;
@@ -1301,7 +1300,7 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 		struct sk_buff *skb2;
 		struct nlmsgerr *errmsg;
 		size_t payload = sizeof(*errmsg) + nlmsg_len(nlh);
-		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+		int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
 		struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
 		struct nlattr *cmdattr;
 		u32 *errline;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 0b1b32c..375f86b 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -24,10 +24,9 @@
 #include <linux/skbuff.h>
 #include <asm/uaccess.h>
 #include <net/sock.h>
-#include <net/netlink.h>
 #include <linux/init.h>
 
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netfilter/nfnetlink.h>
 
 MODULE_LICENSE("GPL");
@@ -144,7 +143,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
-	if (nlh->nlmsg_len < NLMSG_LENGTH(sizeof(struct nfgenmsg)))
+	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(struct nfgenmsg)))
 		return 0;
 
 	type = nlh->nlmsg_type;
@@ -172,7 +171,7 @@ replay:
 	}
 
 	{
-		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+		int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
 		u_int8_t cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
 		struct nlattr *cda[ss->cb[cb_id].attr_count + 1];
 		struct nlattr *attr = (void *)nlh + min_len;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index f248db5..4a2593f 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -19,7 +19,7 @@
 #include <linux/ipv6.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_log.h>
 #include <linux/spinlock.h>
@@ -609,7 +609,7 @@ nfulnl_log_packet(u_int8_t pf,
 	/* FIXME: do we want to make the size calculation conditional based on
 	 * what is actually present?  way more branches and checks, but more
 	 * memory efficient... */
-	size =    NLMSG_SPACE(sizeof(struct nfgenmsg))
+	size =    nlmsg_total_size(sizeof(struct nfgenmsg))
 		+ nla_total_size(sizeof(struct nfulnl_msg_packet_hdr))
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 1cb4854..ae70b9e 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -236,7 +236,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	struct nf_conn *ct = NULL;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
 
-	size =    NLMSG_SPACE(sizeof(struct nfgenmsg))
+	size =    nlmsg_total_size(sizeof(struct nfgenmsg))
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hdr))
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a500ce2..ce2e006 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1646,7 +1646,7 @@ struct nlmsghdr *
 __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int flags)
 {
 	struct nlmsghdr *nlh;
-	int size = NLMSG_LENGTH(len);
+	int size = nlmsg_msg_size(len);
 
 	nlh = (struct nlmsghdr*)skb_put(skb, NLMSG_ALIGN(size));
 	nlh->nlmsg_type = type;
@@ -1655,7 +1655,7 @@ __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int fla
 	nlh->nlmsg_pid = portid;
 	nlh->nlmsg_seq = seq;
 	if (!__builtin_constant_p(size) || NLMSG_ALIGN(size) - size != 0)
-		memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
+		memset(nlmsg_data(nlh) + len, 0, NLMSG_ALIGN(size) - size);
 	return nlh;
 }
 EXPORT_SYMBOL(__nlmsg_put);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9d71d4d..4b4f515 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -22,7 +22,7 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <net/net_namespace.h>
@@ -428,7 +428,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct Qdisc_class_ops *cops;
 	struct tcf_dump_args arg;
 
-	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
+	if (cb->nlh->nlmsg_len < nlmsg_msg_size(sizeof(*tcm)))
 		return skb->len;
 	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d7468ba..0272f61 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1642,7 +1642,7 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	int t, s_t;
 
-	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
+	if (cb->nlh->nlmsg_len < nlmsg_msg_size(sizeof(*tcm)))
 		return 0;
 	dev = dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 6675914..8bcd498 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -44,7 +44,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct nlmsghdr *rep_nlh;
 	struct nlmsghdr *req_nlh = info->nlhdr;
 	struct tipc_genlmsghdr *req_userhdr = info->userhdr;
-	int hdr_space = NLMSG_SPACE(GENL_HDRLEN + TIPC_GENL_HDRLEN);
+	int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
 	u16 cmd;
 
 	if ((req_userhdr->cmd & 0xC000) && (!capable(CAP_NET_ADMIN)))
@@ -53,8 +53,8 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 		cmd = req_userhdr->cmd;
 
 	rep_buf = tipc_cfg_do_cmd(req_userhdr->dest, cmd,
-			NLMSG_DATA(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
-			NLMSG_PAYLOAD(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
+			nlmsg_data(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
+			nlmsg_attrlen(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
 			hdr_space);
 
 	if (rep_buf) {
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fa28c8..0116b84 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -60,7 +60,7 @@
 #include <linux/bitops.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>	/* for network interface checks */
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/dccp.h>
@@ -4475,7 +4475,7 @@ static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 	struct nlmsghdr *nlh;
 	struct sk_security_struct *sksec = sk->sk_security;
 
-	if (skb->len < NLMSG_SPACE(0)) {
+	if (skb->len < nlmsg_total_size(0)) {
 		err = -EINVAL;
 		goto out;
 	}
diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 14d810e..420cf1d 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -16,7 +16,6 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
 #include <linux/selinux_netlink.h>
 #include <net/net_namespace.h>
 #include <net/netlink.h>
@@ -77,7 +76,7 @@ static void selnl_notify(int msgtype, void *data)
 
 	len = selnl_msglen(msgtype);
 
-	skb = alloc_skb(NLMSG_SPACE(len), GFP_USER);
+	skb = alloc_skb(nlmsg_total_size(len), GFP_USER);
 	if (!skb)
 		goto oom;
 
-- 
1.7.10.4
