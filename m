From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4] iscsi class, libiscsi: Add net config.
Date: Thu, 23 Apr 2009 17:22:42 -0700
Message-ID: <1240532563-23048-4-git-send-email-mchan@broadcom.com>
References: <1240532563-23048-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: anilgv@broadcom.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com
To: davem@davemloft.net, michaelc@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4469 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755442AbZDXBOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 21:14:43 -0400
In-Reply-To: <1240532563-23048-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ISCSI_NETLINK messages to set/get iSCSI network parameters and
vendor specific information.

Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>
---
 drivers/scsi/scsi_transport_iscsi.c |   87 ++++++++++++++++++++++++++++++++++-
 include/scsi/iscsi_if.h             |   45 ++++++++++++++++++
 include/scsi/scsi_transport_iscsi.h |   58 +++++++++++++++++++++++
 3 files changed, 188 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 0947954..925f9b0 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -995,6 +995,36 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 }
 EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
 
+
+extern int iscsi_vendor_priv_mesg(struct Scsi_Host *shost, uint16_t priv_op,
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
+
 void iscsi_conn_error_event(struct iscsi_cls_conn *conn, enum iscsi_err error)
 {
 	struct nlmsghdr	*nlh;
@@ -1332,7 +1362,6 @@ iscsi_tgt_dscvr(struct iscsi_transport *transport,
 		return -ENODEV;
 	}
 
-
 	dst_addr = (struct sockaddr *)((char*)ev + sizeof(*ev));
 	err = transport->tgt_dscvr(shost, ev->u.tgt_dscvr.type,
 				   ev->u.tgt_dscvr.enable, dst_addr);
@@ -1364,6 +1393,52 @@ iscsi_set_host_param(struct iscsi_transport *transport,
 	return err;
 }
 
+
+static int
+iscsi_set_host_net_cfg(struct iscsi_transport *transport,
+		       struct iscsi_uevent *ev, int msg_type)
+{
+	char *data = (char*)ev + sizeof(*ev);
+	struct Scsi_Host *shost;
+	int err;
+
+	if (!transport->set_net_config)
+		return -ENOSYS;
+
+	shost = scsi_host_lookup(ev->u.set_net_config.host_no);
+	if (!shost) {
+		printk(KERN_ERR "set_net_config could not find host no %u\n",
+		       ev->u.set_host_param.host_no);
+		return -ENODEV;
+	}
+
+	err = transport->set_net_config(shost, data, ev->u.set_net_config.len);
+	scsi_host_put(shost);
+	return err;
+}
+
+static int
+iscsi_vendor_priv_msg(struct iscsi_transport *transport,
+		       struct iscsi_uevent *ev)
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
 static int
 iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
@@ -1383,7 +1458,8 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!try_module_get(transport->owner))
 		return -EINVAL;
 
-	priv->daemon_pid = NETLINK_CREDS(skb)->pid;
+	if (nlh->nlmsg_type != ISCSI_UEVENT_PRIVATE_MESG)
+		priv->daemon_pid = NETLINK_CREDS(skb)->pid;
 
 	switch (nlh->nlmsg_type) {
 	case ISCSI_UEVENT_CREATE_SESSION:
@@ -1477,6 +1553,13 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case ISCSI_UEVENT_SET_HOST_PARAM:
 		err = iscsi_set_host_param(transport, ev);
 		break;
+	case ISCSI_UEVENT_SET_NET_CONFIG:
+	case ISCSI_UEVENT_GET_NET_CONFIG:
+		err = iscsi_set_host_net_cfg(transport, ev, nlh->nlmsg_type);
+		break;
+	case ISCSI_UEVENT_PRIVATE_MESG:
+		err = iscsi_vendor_priv_msg(transport, ev);
+		break;
 	default:
 		err = -ENOSYS;
 		break;
diff --git a/include/scsi/iscsi_if.h b/include/scsi/iscsi_if.h
index d0ed522..9b602fe 100644
--- a/include/scsi/iscsi_if.h
+++ b/include/scsi/iscsi_if.h
@@ -52,6 +52,10 @@ enum iscsi_uevent_e {
 	ISCSI_UEVENT_UNBIND_SESSION	= UEVENT_BASE + 17,
 	ISCSI_UEVENT_CREATE_BOUND_SESSION	= UEVENT_BASE + 18,
 
+	ISCSI_UEVENT_SET_NET_CONFIG	= UEVENT_BASE + 20,
+	ISCSI_UEVENT_GET_NET_CONFIG	= UEVENT_BASE + 21,
+	ISCSI_UEVENT_PRIVATE_MESG	= UEVENT_BASE + 22,
+
 	/* up events */
 	ISCSI_KEVENT_RECV_PDU		= KEVENT_BASE + 1,
 	ISCSI_KEVENT_CONN_ERROR		= KEVENT_BASE + 2,
@@ -59,6 +63,8 @@ enum iscsi_uevent_e {
 	ISCSI_KEVENT_DESTROY_SESSION	= KEVENT_BASE + 4,
 	ISCSI_KEVENT_UNBIND_SESSION	= KEVENT_BASE + 5,
 	ISCSI_KEVENT_CREATE_SESSION	= KEVENT_BASE + 6,
+	ISCSI_KEVENT_NET_CONFIG		= KEVENT_BASE + 7,
+	ISCSI_KEVENT_PRIVATE_MESG	= KEVENT_BASE + 8,
 };
 
 enum iscsi_tgt_dscvr {
@@ -154,6 +160,16 @@ struct iscsi_uevent {
 			uint32_t	param; /* enum iscsi_host_param */
 			uint32_t	len;
 		} set_host_param;
+		struct msg_set_net_config {
+			uint32_t	host_no;
+			uint32_t	len;
+		} set_net_config;
+		struct msg_vendor_priv {
+			uint32_t	host_no;
+			uint16_t	priv_op;
+			uint16_t	mesg_size;
+			uint32_t	status;
+		} vendor_priv;
 	} u;
 	union {
 		/* messages k -> u */
@@ -187,6 +203,11 @@ struct iscsi_uevent {
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
 
@@ -398,4 +419,28 @@ struct iscsi_stats {
 		__attribute__ ((aligned (sizeof(uint64_t))));
 };
 
+/*
+ * Network interface configuration
+ */
+enum iscsi_net_param {
+	ISCSI_NET_PARAM_UNKNOWN			= 0x00,
+	ISCSI_NET_PARAM_MAC_ADDR		= ISCSI_NET_PARAM_UNKNOWN + 1,
+	ISCSI_NET_PARAM_IPV4_ADDR		= ISCSI_NET_PARAM_UNKNOWN + 2,
+	ISCSI_NET_PARAM_IPV6_ADDR		= ISCSI_NET_PARAM_UNKNOWN + 3,
+	ISCSI_NET_PARAM_IPV4_NETMASK		= ISCSI_NET_PARAM_UNKNOWN + 4,
+	ISCSI_NET_PARAM_IPV6_NETMASK		= ISCSI_NET_PARAM_UNKNOWN + 5,
+	ISCSI_NET_PARAM_IPV4_GATEWAY		= ISCSI_NET_PARAM_UNKNOWN + 6,
+	ISCSI_NET_PARAM_IPV6_GATEWAY		= ISCSI_NET_PARAM_UNKNOWN + 7,
+	ISCSI_NET_PARAM_BOOTPROTO		= ISCSI_NET_PARAM_UNKNOWN + 8,
+	ISCSI_NET_PARAM_IPV6_AUTO_PARAM		= ISCSI_NET_PARAM_UNKNOWN + 9,
+	ISCSI_NET_PARAM_MTU			= ISCSI_NET_PARAM_UNKNOWN + 10,
+	ISCSI_NET_PARAM_VLAN			= ISCSI_NET_PARAM_UNKNOWN + 11,
+};
+
+struct iscsi_net_config {
+	uint32_t param;
+	uint32_t length;
+	uint8_t value[1];
+};
+
 #endif
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index 457588e..ff91813 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -109,6 +109,9 @@ struct iscsi_transport {
 	int (*set_host_param) (struct Scsi_Host *shost,
 			       enum iscsi_host_param param, char *buf,
 			       int buflen);
+	int (*get_net_config) (struct Scsi_Host *shost,
+			       enum iscsi_net_param param, char *buf);
+	int (*set_net_config) (struct Scsi_Host *shost, char *buf, int buflen);
 	int (*send_pdu) (struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 			 char *data, uint32_t data_size);
 	void (*get_stats) (struct iscsi_cls_conn *conn,
@@ -132,6 +135,8 @@ struct iscsi_transport {
 	void (*ep_disconnect) (struct iscsi_endpoint *ep);
 	int (*tgt_dscvr) (struct Scsi_Host *shost, enum iscsi_tgt_dscvr type,
 			  uint32_t enable, struct sockaddr *dst_addr);
+	int (*nl_priv_recv) (struct Scsi_Host *shost, uint16_t priv_op,
+			     int status, char *data, int data_size);
 };
 
 /*
@@ -147,6 +152,8 @@ extern void iscsi_conn_error_event(struct iscsi_cls_conn *conn,
 				   enum iscsi_err error);
 extern int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
 			  char *data, uint32_t data_size);
+extern int iscsi_vendor_priv_mesg(struct Scsi_Host *shost, uint16_t priv_op,
+				  char *data, uint16_t data_size);
 
 struct iscsi_cls_conn {
 	struct list_head conn_list;	/* item in connlist */
@@ -217,6 +224,57 @@ struct iscsi_endpoint {
 	uint64_t id;
 };
 
+struct iscsi_vlan_if {
+	struct list_head	link;	/* item in vlan_dev list */
+	unsigned long		param_mask;
+	u16			vlan_id;
+	char			ipv4_addr[4];
+	u8			ipv4_mask;
+	char			ipv4_gw[4];
+	char			ipv6_addr[16];
+	u8			ipv6_mask;
+	char			ipv6_gw[16];
+};
+
+enum iscsi_net_valid_param {
+	NET_PARAM_MAC               = 0x1,
+	NET_PARAM_IPV4_ADDR         = 0x2,
+	NET_PARAM_IPV4_MASK         = 0x4,
+	NET_PARAM_IPV4_GW           = 0x8,
+	NET_PARAM_IPV6_ADDR         = 0x10,
+	NET_PARAM_IPV6_MASK         = 0x20,
+	NET_PARAM_IPV6_GW           = 0x40,
+	NET_PARAM_BOOT_PROTO        = 0x80,
+	NET_PARAM_CFG_ACCEPTED      = 0x8000,
+};
+
+/**
+ * struct iscsi_net_info - scsi host network interface parameters
+ * @param_mask:		bit mask of valid parameters
+ * @mac_addr:		MAC address
+ * @boot_proto:		boot protocola, static or dhcp
+ * @mtu:		current MTU setting
+ * @ipv4_addr:		IPv4 address
+ * @ipv4_mask:		IPv4 netmask
+ * @ipv4_gw:		IPv4 gateway
+ * @ipv6_addr:		IPv6 address
+ * @ipv6_mask:		IPv6 netmask
+ * @ipv6_gw:		IPv6 gateway
+ */
+struct iscsi_net_info {
+	unsigned long		param_mask;
+	u8			boot_proto;
+	unsigned char		mac_addr[6];
+	int			mtu;
+	char			ipv4_addr[4];
+	u8			ipv4_mask;
+	char			ipv4_gw[4];
+	char			ipv6_addr[16];
+	u8			ipv6_mask;
+	char			ipv6_gw[16];
+	struct list_head	vlan_if; /* linked list of vlan interfaces */
+};
+
 /*
  * session and connection functions that can be used by HW iSCSI LLDs
  */
-- 
1.5.6.GIT


