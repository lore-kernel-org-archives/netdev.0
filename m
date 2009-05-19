From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 4/4] bnx2i: Add bnx2i iSCSI driver.
Date: Mon, 18 May 2009 18:50:59 -0700
Message-ID: <1242697859.10180.147.camel@HP1>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com>
 <1241208039-6813-5-git-send-email-mchan@broadcom.com>
 <4A01BF6A.90707@cs.wisc.edu> <1241715824.9177.8.camel@HP1>
 <4A034C2A.50107@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Karen Xie" <kxie@chelsio.com>, anilgv@broadcom.com,
	benli@broadcom.com
To: "Mike Christie" <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1513 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752757AbZESB5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 21:57:21 -0400
In-Reply-To: <4A034C2A.50107@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-05-07 at 14:01 -0700, Mike Christie wrote:
> Michael Chan wrote:
> > On Wed, 2009-05-06 at 09:48 -0700, Mike Christie wrote:
> >> I think cxgb3i is one day going to want to support the same features 
> >> bnx2i does. If that is right, then should we just make the NX2_UIO 
> >> events common iscsi events, and hook cxb3i in? It would not use the 
> >> iscsi set param interface at all and would work just like bnx2i. Is that 
> >> possible? What about future drivers? Are done making iscsi cards and 
> >> drivers. If so, thank goodness :)  If not then maybe we want to consider 
> >> some future driver using the #2 module and possibly using this.
> >>
> >> If cxgb3i is really only going to support static ip setup and we think 
> >> that bnx2i is going to be unique on how it sets up the network then I 
> >> NX2_UIO private events are fine. Or is this a case of we are thinking 
> >> that iscsi hardware people are creating crazy interfaces so there is no 
> >> why to predict what they are going to do so there is no point in trying 
> >> to design for them.
> > 
> > If there is any possibility that cxgb3i will use something similar to
> > bnx2i, I think we can change the message to a standard one and make the
> > message structure somewhat more generic.  We'll probably still need a
> > private area in the message for hardware or vendor specific information.
> > 
> 
> Ok sounds good to me.
> 

Here are the more generic NETLINK_ISCSI messages and the iscsi transport
code to support them, please review.

diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index d69a53a..60cb6cb 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -995,6 +995,39 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 }
 EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
 
+int iscsi_offload_mesg(struct Scsi_Host *shost,
+		       struct iscsi_transport *transport, uint32_t type,
+		       char *data, uint16_t data_size)
+{
+	struct nlmsghdr	*nlh;
+	struct sk_buff *skb;
+	struct iscsi_uevent *ev;
+	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (!skb) {
+		printk(KERN_ERR "can not deliver iscsi offload message:OOM\n");
+		return -ENOMEM;
+	}
+
+	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
+	ev = NLMSG_DATA(nlh);
+	memset(ev, 0, sizeof(*ev));
+	ev->type = type;
+	ev->transport_handle = iscsi_handle(transport);
+	switch (type) {
+	case ISCSI_KEVENT_PATH_REQ:
+		ev->r.req_path.host_no = shost->host_no;
+	case ISCSI_KEVENT_IF_DOWN:
+		ev->r.notify_if_down.host_no = shost->host_no;
+	}
+
+	memcpy((char*)ev + sizeof(*ev), data, data_size);
+
+	return iscsi_broadcast_skb(skb, GFP_KERNEL);
+}
+EXPORT_SYMBOL_GPL(iscsi_offload_mesg);
+
 void iscsi_conn_error_event(struct iscsi_cls_conn *conn, enum iscsi_err error)
 {
 	struct nlmsghdr	*nlh;
@@ -1393,6 +1426,30 @@ iscsi_set_host_param(struct iscsi_transport *transport,
 }
 
 static int
+iscsi_set_path(struct iscsi_transport *transport, struct iscsi_uevent *ev)
+{
+	struct Scsi_Host *shost;
+	struct iscsi_path *params;
+	int err;
+
+	if (!transport->set_path)
+		return -ENOSYS;
+
+	shost = scsi_host_lookup(ev->u.set_path.host_no);
+	if (!shost) {
+		printk(KERN_ERR "set path could not find host no %u\n",
+		       ev->u.set_path.host_no);
+		return -ENODEV;
+	}
+
+	params = (struct iscsi_path *)((char*)ev + sizeof(*ev));
+	err = transport->set_path(shost, params);
+				      
+	scsi_host_put(shost);
+	return err;
+}
+
+static int
 iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err = 0;
@@ -1411,7 +1468,8 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!try_module_get(transport->owner))
 		return -EINVAL;
 
-	priv->daemon_pid = NETLINK_CREDS(skb)->pid;
+	if (nlh->nlmsg_type != ISCSI_UEVENT_PATH_UPDATE)
+		priv->daemon_pid = NETLINK_CREDS(skb)->pid;
 
 	switch (nlh->nlmsg_type) {
 	case ISCSI_UEVENT_CREATE_SESSION:
@@ -1506,6 +1564,9 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case ISCSI_UEVENT_SET_HOST_PARAM:
 		err = iscsi_set_host_param(transport, ev);
 		break;
+	case ISCSI_UEVENT_PATH_UPDATE:
+		err = iscsi_set_path(transport, ev);
+		break;
 	default:
 		err = -ENOSYS;
 		break;
diff --git a/include/scsi/iscsi_if.h b/include/scsi/iscsi_if.h
index 2c1a4af..cb33e78 100644
--- a/include/scsi/iscsi_if.h
+++ b/include/scsi/iscsi_if.h
@@ -53,6 +53,8 @@ enum iscsi_uevent_e {
 	ISCSI_UEVENT_CREATE_BOUND_SESSION		= UEVENT_BASE + 18,
 	ISCSI_UEVENT_TRANSPORT_EP_CONNECT_THROUGH_HOST	= UEVENT_BASE + 19,
 
+	ISCSI_UEVENT_PATH_UPDATE	= UEVENT_BASE + 20,
+
 	/* up events */
 	ISCSI_KEVENT_RECV_PDU		= KEVENT_BASE + 1,
 	ISCSI_KEVENT_CONN_ERROR		= KEVENT_BASE + 2,
@@ -60,6 +62,9 @@ enum iscsi_uevent_e {
 	ISCSI_KEVENT_DESTROY_SESSION	= KEVENT_BASE + 4,
 	ISCSI_KEVENT_UNBIND_SESSION	= KEVENT_BASE + 5,
 	ISCSI_KEVENT_CREATE_SESSION	= KEVENT_BASE + 6,
+
+	ISCSI_KEVENT_PATH_REQ		= KEVENT_BASE + 7,
+	ISCSI_KEVENT_IF_DOWN		= KEVENT_BASE + 8,
 };
 
 enum iscsi_tgt_dscvr {
@@ -159,6 +164,9 @@ struct iscsi_uevent {
 			uint32_t	param; /* enum iscsi_host_param */
 			uint32_t	len;
 		} set_host_param;
+		struct msg_set_path {
+			uint32_t	host_no;
+		} set_path;
 	} u;
 	union {
 		/* messages k -> u */
@@ -192,10 +200,39 @@ struct iscsi_uevent {
 		struct msg_transport_connect_ret {
 			uint64_t	handle;
 		} ep_connect_ret;
+		struct msg_req_path {
+			uint32_t	host_no;
+		} req_path;
+		struct msg_notify_if_down {
+			uint32_t	host_no;
+		} notify_if_down;
 	} r;
 } __attribute__ ((aligned (sizeof(uint64_t))));
 
 /*
+ * To keep the struct iscsi_uevent size the same for userspace code
+ * compatibility, the main structure for ISCSI_UEVENT_PATH_UPDATE and
+ * ISCSI_KEVENT_PATH_REQ is defined separately and comes after the
+ * struct iscsi_uevent in the NETLINK_ISCSI message.
+ */
+struct iscsi_path {
+	uint64_t	handle;
+	uint8_t		mac_addr[6];
+	uint8_t		mac_addr_old[6];
+	uint32_t	ip_addr_len;	/* 4 or 16 */
+	union {
+		struct in_addr	v4_addr;
+		struct in6_addr	v6_addr;
+	} src;
+	union {
+		struct in_addr	v4_addr;
+		struct in6_addr	v6_addr;
+	} dst;
+	uint16_t	vlan_id;
+	uint16_t	pmtu;
+};
+
+/*
  * Common error codes
  */
 enum iscsi_err {
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index 8cb7a31..349c7f3 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -133,6 +133,7 @@ struct iscsi_transport {
 	void (*ep_disconnect) (struct iscsi_endpoint *ep);
 	int (*tgt_dscvr) (struct Scsi_Host *shost, enum iscsi_tgt_dscvr type,
 			  uint32_t enable, struct sockaddr *dst_addr);
+	int (*set_path) (struct Scsi_Host *shost, struct iscsi_path *params);
 };
 
 /*
@@ -149,6 +150,10 @@ extern void iscsi_conn_error_event(struct iscsi_cls_conn *conn,
 extern int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 			  char *data, uint32_t data_size);
 
+extern int iscsi_offload_mesg(struct Scsi_Host *shost,
+			      struct iscsi_transport *transport, uint32_t type,
+			      char *data, uint16_t data_size);
+
 struct iscsi_cls_conn {
 	struct list_head conn_list;	/* item in connlist */
 	void *dd_data;			/* LLD private data */



