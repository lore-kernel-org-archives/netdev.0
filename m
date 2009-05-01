From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4] iscsi class, libiscsi: Add net config.
Date: Fri, 1 May 2009 13:00:38 -0700
Message-ID: <1241208039-6813-4-git-send-email-mchan@broadcom.com>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: davem@davemloft.net, michaelc@cs.wisc.edu,
	James.Bottomley@HansenPartnership.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1241208039-6813-1-git-send-email-mchan@broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ISCSI_NETLINK messages to get/set vendor specific information.
This is to support bnx2i that handles net config of private iSCSI
IP address in userspace.

Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>
Acked-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/scsi_transport_iscsi.c |   59 ++++++++++++++++++++++++++++++++++-
 include/scsi/iscsi_if.h             |   14 ++++++++
 include/scsi/scsi_transport_iscsi.h |    6 +++
 3 files changed, 78 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 0947954..ef3af96 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -995,6 +995,37 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 }
 EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
 
+extern int iscsi_vendor_priv_mesg(struct Scsi_Host *shost,
+				  struct iscsi_transport *transport,
+				  uint16_t priv_op,
+				  char *data, uint16_t data_size)
+{
+	struct nlmsghdr	*nlh;
+	struct sk_buff *skb;
+	struct iscsi_uevent *ev;
+	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (!skb) {
+		printk(KERN_ERR "can not deliver vendor private message:OOM\n");
+		return -ENOMEM;
+	}
+
+	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
+	ev = NLMSG_DATA(nlh);
+	memset(ev, 0, sizeof(*ev));
+	ev->type = ISCSI_KEVENT_PRIVATE_MESG;
+	ev->transport_handle = iscsi_handle(transport);
+	ev->r.vendor_priv.host_no = shost->host_no;
+	ev->r.vendor_priv.priv_op = priv_op;
+	ev->r.vendor_priv.mesg_size = data_size;
+
+	memcpy((char*)ev + sizeof(*ev), data, data_size);
+
+	return iscsi_broadcast_skb(skb, GFP_KERNEL);
+}
+EXPORT_SYMBOL_GPL(iscsi_vendor_priv_mesg);
+
 void iscsi_conn_error_event(struct iscsi_cls_conn *conn, enum iscsi_err error)
 {
 	struct nlmsghdr	*nlh;
@@ -1365,6 +1396,28 @@ iscsi_set_host_param(struct iscsi_transport *transport,
 }
 
 static int
+iscsi_vendor_priv_msg(struct iscsi_transport *transport,
+		      struct iscsi_uevent *ev)
+{
+	struct Scsi_Host *shost;
+	int err;
+
+	shost = scsi_host_lookup(ev->u.vendor_priv.host_no);
+	if (!shost) {
+		printk(KERN_ERR "target discovery could not find host no %u\n",
+		       ev->u.tgt_dscvr.host_no);
+		return -ENODEV;
+	}
+
+	err = transport->nl_priv_recv(shost, ev->u.vendor_priv.priv_op,
+				      ev->u.vendor_priv.status,
+				      (char *)((char*)ev + sizeof(*ev)),
+				      ev->u.vendor_priv.mesg_size);
+	scsi_host_put(shost);
+	return err;
+}
+
+static int
 iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err = 0;
@@ -1383,7 +1436,8 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!try_module_get(transport->owner))
 		return -EINVAL;
 
-	priv->daemon_pid = NETLINK_CREDS(skb)->pid;
+	if (nlh->nlmsg_type != ISCSI_UEVENT_PRIVATE_MESG)
+		priv->daemon_pid = NETLINK_CREDS(skb)->pid;
 
 	switch (nlh->nlmsg_type) {
 	case ISCSI_UEVENT_CREATE_SESSION:
@@ -1477,6 +1531,9 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case ISCSI_UEVENT_SET_HOST_PARAM:
 		err = iscsi_set_host_param(transport, ev);
 		break;
+	case ISCSI_UEVENT_PRIVATE_MESG:
+		err = iscsi_vendor_priv_msg(transport, ev);
+		break;
 	default:
 		err = -ENOSYS;
 		break;
diff --git a/include/scsi/iscsi_if.h b/include/scsi/iscsi_if.h
index d0ed522..9e67946 100644
--- a/include/scsi/iscsi_if.h
+++ b/include/scsi/iscsi_if.h
@@ -52,6 +52,8 @@ enum iscsi_uevent_e {
 	ISCSI_UEVENT_UNBIND_SESSION	= UEVENT_BASE + 17,
 	ISCSI_UEVENT_CREATE_BOUND_SESSION	= UEVENT_BASE + 18,
 
+	ISCSI_UEVENT_PRIVATE_MESG	= UEVENT_BASE + 20,
+
 	/* up events */
 	ISCSI_KEVENT_RECV_PDU		= KEVENT_BASE + 1,
 	ISCSI_KEVENT_CONN_ERROR		= KEVENT_BASE + 2,
@@ -59,6 +61,7 @@ enum iscsi_uevent_e {
 	ISCSI_KEVENT_DESTROY_SESSION	= KEVENT_BASE + 4,
 	ISCSI_KEVENT_UNBIND_SESSION	= KEVENT_BASE + 5,
 	ISCSI_KEVENT_CREATE_SESSION	= KEVENT_BASE + 6,
+	ISCSI_KEVENT_PRIVATE_MESG	= KEVENT_BASE + 7,
 };
 
 enum iscsi_tgt_dscvr {
@@ -154,6 +157,12 @@ struct iscsi_uevent {
 			uint32_t	param; /* enum iscsi_host_param */
 			uint32_t	len;
 		} set_host_param;
+		struct msg_vendor_priv {
+			uint32_t	host_no;
+			uint16_t	priv_op;
+			uint16_t	mesg_size;
+			uint32_t	status;
+		} vendor_priv;
 	} u;
 	union {
 		/* messages k -> u */
@@ -187,6 +196,11 @@ struct iscsi_uevent {
 		struct msg_transport_connect_ret {
 			uint64_t	handle;
 		} ep_connect_ret;
+		struct msg_vendor_priv_ret {
+			uint32_t	host_no;
+			uint16_t	priv_op;
+			uint16_t	mesg_size;
+		} vendor_priv;
 	} r;
 } __attribute__ ((aligned (sizeof(uint64_t))));
 
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index 457588e..14dab4e 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -132,6 +132,8 @@ struct iscsi_transport {
 	void (*ep_disconnect) (struct iscsi_endpoint *ep);
 	int (*tgt_dscvr) (struct Scsi_Host *shost, enum iscsi_tgt_dscvr type,
 			  uint32_t enable, struct sockaddr *dst_addr);
+	int (*nl_priv_recv) (struct Scsi_Host *shost, uint16_t priv_op,
+			     int status, char *data, int data_size);
 };
 
 /*
@@ -147,6 +149,10 @@ extern void iscsi_conn_error_event(struct iscsi_cls_conn *conn,
 				   enum iscsi_err error);
 extern int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 			  char *data, uint32_t data_size);
+extern int iscsi_vendor_priv_mesg(struct Scsi_Host *shost,
+				  struct iscsi_transport *transport,
+				  uint16_t priv_op,
+				  char *data, uint16_t data_size);
 
 struct iscsi_cls_conn {
 	struct list_head conn_list;	/* item in connlist */
-- 
1.5.6.GIT


