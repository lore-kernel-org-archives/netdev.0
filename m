From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC-PATCH] dhcp provisioning support in cxgb3i
Date: Thu, 29 Oct 2009 18:46:52 +0530
Message-ID: <4AE995C4.4080909@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020408070406080404000508"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, "open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org" <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--------------020408070406080404000508
Content-Type: text/plain; charset=ISO-8859-1

Hi Mike,

Herein attached patches for having dhcp provisioning support in cxgb3i. 
I have added one new iscsi netlink message ISCSI_UEVENT_REQ_IPCONF. 
Please have a look and share suggestions.

Regards
Rakesh Ranjan

--~--~---------~--~----~------------~-------~--~----~
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi
-~----------~----~----~----~------~----~------~--~---


--------------020408070406080404000508
Content-Type: text/x-patch
Content-Disposition: inline;
	filename="0001-added-one-new-netlink-message-ISCSI_UEVENT_REQ_IPCON.patch"

>From 4b522723ab93b54504eeb738cc02f354635cec53 Mon Sep 17 00:00:00 2001
From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 29 Oct 2009 17:41:42 +0530
Subject: [PATCH] added one new netlink message ISCSI_UEVENT_REQ_IPCONF in libiscsi to support dhcp functionality in cxgb3i


Signed-off-by: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/scsi/scsi_transport_iscsi.c |   25 +++++++++++++++++++++++++
 include/scsi/iscsi_if.h             |    4 ++++
 include/scsi/scsi_transport_iscsi.h |    1 +
 3 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index ad897df..4897a3f 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -1508,6 +1508,28 @@ iscsi_set_path(struct iscsi_transport *transport, struct iscsi_uevent *ev)
 }
 
 static int
+iscsi_req_ipconf(struct iscsi_transport *transport, struct iscsi_uevent *ev)
+{
+	struct Scsi_Host *shost;
+	int err;
+
+	if (!transport->req_ipconf)
+		return -ENOSYS;
+
+	shost = scsi_host_lookup(ev->u.req_ipconf.host_no);
+	if (!shost) {
+		printk(KERN_ERR "ipconf req could not find host no %u\n",
+				ev->u.req_ipconf.host_no);
+		return -ENODEV;
+	}
+
+	err = transport->req_ipconf(shost);
+
+	scsi_host_put(shost);
+	return err;
+}
+
+static int
 iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, uint32_t *group)
 {
 	int err = 0;
@@ -1627,6 +1649,9 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, uint32_t *group)
 	case ISCSI_UEVENT_PATH_UPDATE:
 		err = iscsi_set_path(transport, ev);
 		break;
+	case ISCSI_UEVENT_REQ_IPCONF:
+		err = iscsi_req_ipconf(transport, ev);
+		break;
 	default:
 		err = -ENOSYS;
 		break;
diff --git a/include/scsi/iscsi_if.h b/include/scsi/iscsi_if.h
index d67dda2..939b1d6 100644
--- a/include/scsi/iscsi_if.h
+++ b/include/scsi/iscsi_if.h
@@ -59,6 +59,7 @@ enum iscsi_uevent_e {
 	ISCSI_UEVENT_TRANSPORT_EP_CONNECT_THROUGH_HOST	= UEVENT_BASE + 19,
 
 	ISCSI_UEVENT_PATH_UPDATE	= UEVENT_BASE + 20,
+	ISCSI_UEVENT_REQ_IPCONF		= UEVENT_BASE + 21,
 
 	/* up events */
 	ISCSI_KEVENT_RECV_PDU		= KEVENT_BASE + 1,
@@ -172,6 +173,9 @@ struct iscsi_uevent {
 		struct msg_set_path {
 			uint32_t	host_no;
 		} set_path;
+		struct msg_req_ipconf {
+			uint32_t	host_no;
+		} req_ipconf;
 	} u;
 	union {
 		/* messages k -> u */
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index 349c7f3..3e5fd96 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -134,6 +134,7 @@ struct iscsi_transport {
 	int (*tgt_dscvr) (struct Scsi_Host *shost, enum iscsi_tgt_dscvr type,
 			  uint32_t enable, struct sockaddr *dst_addr);
 	int (*set_path) (struct Scsi_Host *shost, struct iscsi_path *params);
+	int (*req_ipconf) (struct Scsi_Host *shost);
 };
 
 /*
-- 
1.6.0.6


--------------020408070406080404000508
Content-Type: text/x-patch
Content-Disposition: inline;
	filename="0002-Implemented-dhcp-client-support-in-cxgb3i.patch"

>From c64cae0fc1c281159141d9e624331f00e434f056 Mon Sep 17 00:00:00 2001
From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 29 Oct 2009 17:43:51 +0530
Subject: [PATCH] Implemented dhcp client support in cxgb3i


Signed-off-by: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/scsi/cxgb3i/Kbuild            |    2 +-
 drivers/scsi/cxgb3i/cxgb3i.h          |    4 +
 drivers/scsi/cxgb3i/cxgb3i_ipconfig.c |  519 +++++++++++++++++++++++++++++++++
 drivers/scsi/cxgb3i/cxgb3i_iscsi.c    |   23 ++-
 drivers/scsi/cxgb3i/cxgb3i_offload.c  |    3 +-
 5 files changed, 548 insertions(+), 3 deletions(-)
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i_ipconfig.c

diff --git a/drivers/scsi/cxgb3i/Kbuild b/drivers/scsi/cxgb3i/Kbuild
index 70d060b..b0f1a3d 100644
--- a/drivers/scsi/cxgb3i/Kbuild
+++ b/drivers/scsi/cxgb3i/Kbuild
@@ -1,4 +1,4 @@
 EXTRA_CFLAGS += -I$(srctree)/drivers/net/cxgb3
 
-cxgb3i-y := cxgb3i_init.o cxgb3i_iscsi.o cxgb3i_pdu.o cxgb3i_offload.o cxgb3i_ddp.o
+cxgb3i-y := cxgb3i_init.o cxgb3i_iscsi.o cxgb3i_pdu.o cxgb3i_offload.o cxgb3i_ddp.o cxgb3i_ipconfig.o
 obj-$(CONFIG_SCSI_CXGB3_ISCSI) += cxgb3i.o
diff --git a/drivers/scsi/cxgb3i/cxgb3i.h b/drivers/scsi/cxgb3i/cxgb3i.h
index e3133b5..37b9a0d 100644
--- a/drivers/scsi/cxgb3i/cxgb3i.h
+++ b/drivers/scsi/cxgb3i/cxgb3i.h
@@ -158,4 +158,8 @@ int cxgb3i_conn_xmit_pdu(struct iscsi_task *);
 void cxgb3i_release_itt(struct iscsi_task *task, itt_t hdr_itt);
 int cxgb3i_reserve_itt(struct iscsi_task *task, itt_t *hdr_itt);
 
+int cxgb3i_ipconfig_init(struct cxgb3i_hba *hba);
+void cxgb3i_ipconfig_exit(struct cxgb3i_hba *hba);
+int cxgb3i_do_ipconf(struct cxgb3i_hba *hba);
+
 #endif
diff --git a/drivers/scsi/cxgb3i/cxgb3i_ipconfig.c b/drivers/scsi/cxgb3i/cxgb3i_ipconfig.c
new file mode 100644
index 0000000..09eddb4
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i_ipconfig.c
@@ -0,0 +1,519 @@
+/* cxgb3i_ipconfig.c: Chelsio S3xx iSCSI dhcp client.
+ *
+ * Copyright (c) 2009 Chelsio Communications, Inc.
+ * Copyright (c) 2008 Mike Christie
+ * Copyright (c) 2008 Red Hat, Inc.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Rakesh Ranjan (rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/in.h>
+#include <linux/delay.h>
+#include <linux/if_arp.h>
+#include <net/ip.h>
+#include <scsi/iscsi_if.h>
+
+#include "common.h"
+#include "cxgb3i.h"
+
+#define DHCP_REQUEST        1
+#define DHCP_REPLY          2
+#define DHCP_HTYPE_ETHERNET 1
+#define DHCP_HLEN_ETHERNET  6
+#define DHCP_MSG_LEN      236
+
+#define DHCPC_SERVER_PORT  67
+#define DHCPC_CLIENT_PORT  68
+
+/*  DHCP message types */
+#define DHCPDISCOVER	1
+#define DHCPOFFER	2
+#define DHCPREQUEST	3
+#define DHCPDECLINE	4
+#define DHCPACK		5
+#define DHCPNAK		6
+#define DHCPRELEASE	7
+#define DHCPINFORM	8
+
+/* DHCP options */
+#define DHCP_OPTION_SUBNET_MASK		1
+#define DHCP_OPTION_ROUTER		3
+#define DHCP_OPTION_DNS_SERVER		6
+#define	DHCP_OPTION_MTU			26
+#define DHCP_OPTION_REQ_IPADDR		50
+#define DHCP_OPTION_LEASE_TIME		51
+#define DHCP_OPTION_MSG_TYPE		53
+#define DHCP_OPTION_SERVER_ID		54
+#define DHCP_OPTION_REQ_LIST		55
+#define	DHCP_OPTION_VCID		60
+#define DHCP_OPTION_END			255
+
+enum {
+	STATE_INIT	= 0,
+	STATE_SENDING,
+	STATE_OFFER_REC,
+	STATE_CONFIG_REC,
+};
+
+struct dhcp_pkt {
+	struct iphdr iph;
+	struct udphdr udph;
+	u8 op;
+	u8 htype;
+	u8 hlen;
+	u8 hops;
+	__be32 xid;
+	__be16 secs;
+	__be16 flags;
+	__be32 cipaddr;
+	__be32 yipaddr;
+	__be32 sipaddr;
+	__be32 ripaddr;
+	u8 chwaddr[16];
+	u8 sname[64];
+	u8 bfile[128];
+	u8 options[312];
+};
+
+struct hba_client_state {
+	struct sk_buff *skb;
+	struct dhcp_pkt *pkt;
+	struct cxgb3i_hba *hba;
+	volatile __u8 state;
+
+	__u8 *mac_addr;
+	__be32 xid;
+	__be32 ltime;
+	__be32 serverid;
+	__be32 ipaddr;
+	__be32 netmask;
+	__be32 dnsaddr;
+	__be32 gipaddr;
+};
+
+
+
+static struct hba_client_state *hcstate[MAX_NPORTS];
+
+static const char *RFC2132_VENDOR_CLASS_ID = "CXGB3I_Client";
+
+static const u8 magic_cookie[4] = { 99, 130, 83, 99 };
+
+
+
+static inline u8 *add_msg_type(u8 *optptr, u8 type)
+{
+	*optptr++ = DHCP_OPTION_MSG_TYPE;
+	*optptr++ = 1;
+	*optptr++ = type;
+	return optptr;
+}
+
+static inline u8 *add_req_options(u8 *optptr)
+{
+	*optptr++ = DHCP_OPTION_REQ_LIST;
+	*optptr++ = 4;
+	*optptr++ = DHCP_OPTION_SUBNET_MASK;
+	*optptr++ = DHCP_OPTION_ROUTER;
+	*optptr++ = DHCP_OPTION_DNS_SERVER;
+	*optptr++ = DHCP_OPTION_MTU;
+	return optptr;
+}
+
+static inline u8 *add_vendor_cid(u8 *optptr)
+{
+	u8 len = strlen(RFC2132_VENDOR_CLASS_ID);
+	*optptr++ = DHCP_OPTION_VCID;
+	*optptr++ = len;
+	memcpy(optptr, RFC2132_VENDOR_CLASS_ID, len);
+	optptr += len;
+	return optptr;
+}
+
+static inline u8 *add_server_id(__be32 *sid, u8 *optptr)
+{
+	*optptr++ = DHCP_OPTION_SERVER_ID;
+	*optptr++ = 4;
+	memcpy(optptr, sid, 4);
+	return optptr + 4;
+}
+
+static inline u8 *add_req_ipaddr(__be32 *ip, u8 *optptr)
+{
+	*optptr++ = DHCP_OPTION_REQ_IPADDR;
+	*optptr++ = 4;
+	memcpy(optptr, ip, 4);
+	return optptr + 4;
+}
+
+static inline u8 *add_end(u8 *optptr)
+{
+	*optptr++ = DHCP_OPTION_END;
+	return optptr;
+}
+
+static void
+cxgb3i_process_dhcp_opts(struct hba_client_state *client, u8 *optptr, int len)
+{
+	u8 *end = optptr + len;
+	u8 type = 0;
+
+	while (optptr < end) {
+		switch (*optptr) {
+		case DHCP_OPTION_SUBNET_MASK:
+			memcpy(&client->netmask, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_ROUTER:
+			memcpy(&client->gipaddr, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_DNS_SERVER:
+			memcpy(&client->dnsaddr, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_MSG_TYPE:
+			type = *(optptr + 2);
+			if (type == DHCPOFFER)
+				client->state = STATE_OFFER_REC;
+			else if (type == DHCPACK)
+				client->state = STATE_CONFIG_REC;
+			break;
+		case DHCP_OPTION_SERVER_ID:
+			memcpy(&client->serverid, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_LEASE_TIME:
+			memcpy(&client->ltime, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_END:
+			break;
+		}
+
+		optptr += optptr[1] + 2;
+	}
+}
+
+static void
+cxgb3i_process_dhcp_pack(struct hba_client_state *client, struct dhcp_pkt *pkt)
+{
+	u8 *start, *end;
+	int opt_len;
+
+	start = &pkt->options[4];
+	end = (u8 *) pkt + ntohs(pkt->iph.tot_len);
+	opt_len = end - start;
+
+	if (pkt->op == DHCP_REPLY &&
+			!memcmp(&pkt->xid, &client->xid, sizeof(client->xid)) &&
+			!memcmp(pkt->chwaddr, client->mac_addr, pkt->hlen)) {
+		memcpy(&client->ipaddr, &pkt->yipaddr, 4);
+		cxgb3i_process_dhcp_opts(client, start, opt_len);
+	}
+}
+
+static int cxgb3i_ipconfig_send(struct port_info *pi, struct sk_buff **skb)
+{
+	int rc = 0;
+	struct sk_buff *lskb = *skb;
+	struct net_device *ndev = (hcstate[pi->port_id])->hba->ndev;
+
+	lskb->dev = ndev;
+	lskb->protocol = htons(ETH_P_IP);
+
+	dev_hard_header(lskb, ndev, ntohs(lskb->protocol), ndev->broadcast,
+				pi->iscsic.mac_addr, lskb->len);
+	rc = dev_queue_xmit(lskb);
+
+	return rc;
+}
+
+static int cxgb3i_ipconfig_recv(struct port_info *pi, struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	struct udphdr *udph;
+	struct ethhdr *eh;
+	struct dhcp_pkt *pkt;
+	struct sk_buff *pskb;
+	int len, opts_len;
+	struct hba_client_state *client = hcstate[pi->port_id];
+	int rc = 0;
+
+	if (unlikely(client->state == STATE_INIT))
+		goto out;
+
+	cxgb3i_log_debug("client->state : %d\n", client->state);
+
+	if (skb->pkt_type != PACKET_OTHERHOST)
+		goto out;
+
+	pskb = skb_copy(skb, GFP_ATOMIC);
+	if (!pskb) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	eh = eth_hdr(pskb);
+	if (!is_valid_ether_addr(eh->h_dest))
+		goto drop;
+
+	if (compare_ether_addr(eh->h_dest, pi->iscsic.mac_addr))
+		goto drop;
+
+	if (!pskb_may_pull(pskb, sizeof(struct iphdr) + sizeof(struct udphdr)))
+		goto drop;
+
+
+	skb_reset_network_header(pskb);
+	pkt = (struct dhcp_pkt *) skb_network_header(pskb);
+	iph = &pkt->iph;
+
+	if (iph->ihl != 5 || iph->version != 4 || iph->protocol != IPPROTO_UDP)
+		goto drop;
+
+	if (iph->frag_off & htons(IP_OFFSET | IP_MF))
+		goto drop;
+
+	if (skb->len < ntohs(iph->tot_len))
+		goto drop;
+
+	if (ip_fast_csum((u8 *)iph, iph->ihl))
+		goto drop;
+
+	udph = &pkt->udph;
+	if (udph->source != htons(67) || udph->dest != htons(68))
+		goto drop;
+
+	if (ntohs(iph->tot_len) < ntohs(udph->len) + sizeof(struct iphdr))
+		goto drop;
+
+	len = ntohs(udph->len) - sizeof(struct udphdr);
+	opts_len = len - (sizeof(*pkt) -
+			sizeof(struct iphdr) -
+			sizeof(struct udphdr) -
+			sizeof(pkt->options));
+	if (opts_len < 0)
+		goto drop;
+
+	if (memcmp(pkt->options, magic_cookie, 4)) {
+		cxgb3i_log_error("Bad DHCP cookie recieved, aborting");
+		goto drop;
+	}
+
+	cxgb3i_log_debug("Received DHCP offer, processing");
+
+	cxgb3i_process_dhcp_pack(client, pkt);
+
+drop:
+	kfree(pskb);
+out:
+	return rc;
+}
+
+static int
+cxgb3i_create_dhcp_msg(struct hba_client_state *client)
+{
+	struct iphdr *iph;
+	struct udphdr *udph;
+	struct sk_buff *skb;
+	struct dhcp_pkt *pkt;
+	int rc = 0;
+	struct port_info *pi = netdev_priv(client->hba->ndev);
+
+	skb = alloc_skb(sizeof(*pkt) +
+			LL_ALLOCATED_SPACE(client->hba->ndev) + 15,
+			GFP_ATOMIC);
+	if (!skb) {
+		rc = -ENOMEM;
+		return rc;
+	}
+
+	client->skb = skb;
+	skb_reserve(skb, LL_RESERVED_SPACE(client->hba->ndev));
+
+	pkt = (struct dhcp_pkt *) skb_put(skb, sizeof(*pkt));
+	client->pkt = pkt;
+	memset(pkt, 0, sizeof(*pkt));
+
+	skb_reset_network_header(skb);
+
+	/* construct IP header */
+	iph = &pkt->iph;
+	iph->version = 4;
+	iph->ihl = 5;
+	iph->tot_len = htons(sizeof(struct dhcp_pkt));
+	iph->frag_off = htons(IP_DF);
+	iph->ttl = 64;
+	iph->protocol = IPPROTO_UDP;
+	iph->daddr = htonl(INADDR_BROADCAST);
+	iph->check = ip_fast_csum((u8 *) iph, iph->ihl);
+
+	/* Construct UDP header */
+	udph = &pkt->udph;
+	udph->source = htons(DHCPC_CLIENT_PORT);
+	udph->dest = htons(DHCPC_SERVER_PORT);
+	udph->len = htons(sizeof(struct dhcp_pkt) - sizeof(struct iphdr));
+
+	pkt->op = DHCP_REQUEST;
+	pkt->htype = DHCP_HTYPE_ETHERNET;
+	pkt->hlen = ETH_ALEN;
+
+	memcpy(pkt->chwaddr, pi->iscsic.mac_addr, ETH_ALEN);
+	pkt->secs = htons(jiffies / HZ);
+	pkt->xid = client->xid;
+
+	memcpy(pkt->options, magic_cookie, sizeof(magic_cookie));
+
+	return rc;
+}
+
+static int cxgb3i_send_dhcp_request(struct hba_client_state *client)
+{
+	int rc = 0;
+	u8 *end;
+	struct port_info *pi = netdev_priv(client->hba->ndev);
+
+	rc = cxgb3i_create_dhcp_msg(client);
+	if (rc)
+		return rc;
+
+	end = add_msg_type(&client->pkt->options[4], DHCPREQUEST);
+	end = add_server_id(&client->serverid, end);
+	end = add_req_ipaddr(&client->ipaddr, end);
+	end = add_vendor_cid(end);
+	end = add_end(end);
+
+	rc = cxgb3i_ipconfig_send(pi, &client->skb);
+
+	return rc;
+}
+
+static int cxgb3i_send_dhcp_discover(struct hba_client_state *client)
+{
+	int rc = 0;
+	u8 *end;
+	struct port_info *pi = netdev_priv(client->hba->ndev);
+
+	rc = cxgb3i_create_dhcp_msg(client);
+	if (rc)
+		return rc;
+
+	end = add_msg_type(&client->pkt->options[4], DHCPDISCOVER);
+	end = add_req_options(end);
+	end = add_vendor_cid(end);
+	end = add_end(end);
+
+	client->state = STATE_SENDING;
+	rc = cxgb3i_ipconfig_send(pi, &client->skb);
+
+	return rc;
+}
+
+static void
+cxgb3i_wait_for_pack(struct hba_client_state *client, u8 state)
+{
+	unsigned long tout, ntout;
+
+	get_random_bytes(&tout, sizeof(tout));
+	tout = (tout % (unsigned)HZ) + (HZ * 2);
+
+	ntout = jiffies + tout;
+	while (time_before(jiffies, ntout) && (client->state != state))
+		schedule_timeout_uninterruptible(1);
+}
+
+int cxgb3i_do_ipconf(struct cxgb3i_hba *hba)
+{
+	int rc = 0;
+	int retry;
+	struct hba_client_state *client = NULL;
+	struct port_info *pi = netdev_priv(hba->ndev);
+
+	client = hcstate[pi->port_id];
+	retry = 2;
+
+	/* show time */
+	for (;;) {
+		get_random_bytes(&client->xid, sizeof(__be32));
+		cxgb3i_send_dhcp_discover(client);
+		cxgb3i_wait_for_pack(client, STATE_OFFER_REC);
+
+		if (client->state == STATE_OFFER_REC) {
+			cxgb3i_log_debug("DHCPOFFER received for hba [%p]\n",
+									hba);
+			cxgb3i_send_dhcp_request(client);
+			cxgb3i_wait_for_pack(client, STATE_CONFIG_REC);
+			if (client->state == STATE_CONFIG_REC) {
+				cxgb3i_log_info("setting ip address of hba %p "
+					"to %pI4\n", hba, &client->ipaddr);
+				cxgb3i_set_private_ipv4addr(hba->ndev,
+								client->ipaddr);
+				client->state = STATE_INIT;
+				break;
+			}
+		}
+
+		if (!--retry) {
+			cxgb3i_log_info("IPCONFIG timed out for hba [%p]\n",
+									hba);
+			rc = -ENETUNREACH;
+			break;
+		}
+	}
+
+	return rc;
+}
+
+int cxgb3i_ipconfig_init(struct cxgb3i_hba *hba)
+{
+	int rc = 0;
+	struct hba_client_state *client = NULL;
+	struct port_info *pi = netdev_priv(hba->ndev);
+
+	client = kzalloc(sizeof(*client), GFP_KERNEL);
+	if (!client) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	client->hba = hba;
+	client->mac_addr = pi->iscsic.mac_addr;
+	client->state = STATE_INIT;
+
+	hcstate[pi->port_id] = client;
+	cxgb3i_log_debug("added hcstate[%d] : %p\n", pi->port_id,
+						hcstate[pi->port_id]);
+
+	pi->iscsic.send = cxgb3i_ipconfig_send;
+	pi->iscsic.recv = cxgb3i_ipconfig_recv;
+	pi->iscsic.flags = 1;
+
+out:
+	return rc;
+}
+
+void cxgb3i_ipconfig_exit(struct cxgb3i_hba *hba)
+{
+	struct net_device *ndev = hba->ndev;
+	struct port_info *pi = netdev_priv(ndev);
+
+	cxgb3i_set_private_ipv4addr(hba->ndev, 0);
+
+	pi->iscsic.flags = 0;
+	pi->iscsic.send = NULL;
+	pi->iscsic.recv = NULL;
+
+	if (hcstate[pi->port_id]) {
+		cxgb3i_log_info("removing hcstate[%d] : %p\n", pi->port_id,
+							hcstate[pi->port_id]);
+		kfree(hcstate[pi->port_id]);
+	}
+
+}
+
diff --git a/drivers/scsi/cxgb3i/cxgb3i_iscsi.c b/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
index 2631bdd..2bb5e63 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
+++ b/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
@@ -240,6 +240,13 @@ struct cxgb3i_hba *cxgb3i_hba_host_add(struct cxgb3i_adapter *snic,
 		goto pci_dev_put;
 	}
 
+	err = cxgb3i_ipconfig_init(hba);
+	if (err) {
+		cxgb3i_log_info("snic 0x%p, ndev 0x%p, host_add failed.\n",
+				snic, ndev);
+		goto pci_dev_put;
+	}
+
 	cxgb3i_api_debug("shost 0x%p, hba 0x%p, no %u.\n",
 			 shost, hba, shost->host_no);
 
@@ -259,6 +266,7 @@ void cxgb3i_hba_host_remove(struct cxgb3i_hba *hba)
 {
 	cxgb3i_api_debug("shost 0x%p, hba 0x%p, no %u.\n",
 			 hba->shost, hba, hba->shost->host_no);
+	cxgb3i_ipconfig_exit(hba);
 	iscsi_host_remove(hba->shost);
 	pci_dev_put(hba->snic->pdev);
 	iscsi_host_free(hba->shost);
@@ -737,13 +745,14 @@ static int cxgb3i_host_get_param(struct Scsi_Host *shost,
 				 enum iscsi_host_param param, char *buf)
 {
 	struct cxgb3i_hba *hba = iscsi_host_priv(shost);
+	struct port_info *pi = netdev_priv(hba->ndev);
 	int len = 0;
 
 	cxgb3i_api_debug("hba %s, param %d.\n", hba->ndev->name, param);
 
 	switch (param) {
 	case ISCSI_HOST_PARAM_HWADDRESS:
-		len = sysfs_format_mac(buf, hba->ndev->dev_addr, 6);
+		len = sysfs_format_mac(buf, pi->iscsic.mac_addr, ETH_ALEN);
 		break;
 	case ISCSI_HOST_PARAM_NETDEV_NAME:
 		len = sprintf(buf, "%s\n", hba->ndev->name);
@@ -762,6 +771,17 @@ static int cxgb3i_host_get_param(struct Scsi_Host *shost,
 	return len;
 }
 
+static int cxgb3i_req_ipconf(struct Scsi_Host *shost)
+{
+	int rc;
+
+	struct cxgb3i_hba *hba = iscsi_host_priv(shost);
+
+	rc = cxgb3i_do_ipconf(hba);
+
+	return rc;
+}
+
 /**
  * cxgb3i_conn_get_stats - returns iSCSI stats
  * @cls_conn:	pointer to iscsi cls conn
@@ -976,6 +996,7 @@ static struct iscsi_transport cxgb3i_iscsi_transport = {
 	.ep_disconnect		= cxgb3i_ep_disconnect,
 	/* Error recovery timeout call */
 	.session_recovery_timedout = iscsi_session_recovery_timedout,
+	.req_ipconf		= cxgb3i_req_ipconf,
 };
 
 int cxgb3i_iscsi_init(void)
diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.c b/drivers/scsi/cxgb3i/cxgb3i_offload.c
index c1d5be4..8fdafeb 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_offload.c
+++ b/drivers/scsi/cxgb3i/cxgb3i_offload.c
@@ -269,7 +269,8 @@ static void make_act_open_req(struct s3_conn *c3cn, struct sk_buff *skb,
 	req->local_ip = c3cn->saddr.sin_addr.s_addr;
 	req->peer_ip = c3cn->daddr.sin_addr.s_addr;
 	req->opt0h = htonl(calc_opt0h(c3cn) | V_L2T_IDX(e->idx) |
-			   V_TX_CHANNEL(e->smt_idx));
+			   V_TX_CHANNEL(e->smt_idx) |
+			   V_SRC_MAC_SEL(SAN_MAC_IDX));
 	req->opt0l = htonl(calc_opt0l(c3cn));
 	req->params = 0;
 }
-- 
1.6.0.6


--------------020408070406080404000508--
