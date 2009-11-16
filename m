From: Rakesh Ranjan <rakesh@chelsio.com>
Subject: Re: [RFC-PATCH] libiscsi dhcp handler
Date: Mon, 16 Nov 2009 19:15:34 +0530
Message-ID: <4B01577E.2020003@chelsio.com>
References: <4B014F95.8000906@chelsio.com> <20091116.051835.125328285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010003000109080509070003"
Cc: michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	James.Bottomley@suse.de, kxie@chelsio.com,
	Rakesh Ranjan <rakesh@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753314AbZKPNpv@vger.kernel.org>
In-Reply-To: <20091116.051835.125328285.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010003000109080509070003
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Rakesh Ranjan <rakesh@chelsio.com>
> Date: Mon, 16 Nov 2009 18:41:49 +0530
> 
>> Herein attached patches to support dhcp based provisioning for iSCSI
>> offload capable cards. I have made dhcp code as generic as possible,
>> please go through the code. Based on the feedback I will submit final
>> version of these patches.
> 
> You can't really add objects to the build before the patch that
> adds the source for that object.
> 

Hi david,

Fixed patch attached.

Regards
Rakesh Ranjan

--------------010003000109080509070003
Content-Type: text/x-patch;
 name="0001-Required-changes-for-libiscsi-to-support-dhcp-based.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-Required-changes-for-libiscsi-to-support-dhcp-based.pat";
 filename*1="ch"

>From a643bfb01c4edbb2e686dd2500a564c93d402bba Mon Sep 17 00:00:00 2001
From: Rakesh Ranjan <rakesh@chelsio.com>
Date: Mon, 16 Nov 2009 19:07:40 +0530
Subject: [PATCH 1/2] Required changes for libiscsi to support dhcp based provisioning for offload capable cards.

These changes adds ISCSI_UEVENT_REQ_IPCONF message to invoke dhcp handler.

Signed-off-by: Rakesh Ranjan <rakesh@chelsio.com>
---
 drivers/scsi/scsi_transport_iscsi.c |   25 +++++++++++++++++++++++++
 include/scsi/iscsi_if.h             |    4 ++++
 include/scsi/libiscsi.h             |   20 ++++++++++++++++++++
 include/scsi/scsi_transport_iscsi.h |    1 +
 4 files changed, 50 insertions(+), 0 deletions(-)

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
index d67dda2..135f229 100644
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
+		struct mag_req_ipconf {
+			uint32_t	host_no;
+		} req_ipconf;
 	} u;
 	union {
 		/* messages k -> u */
diff --git a/include/scsi/libiscsi.h b/include/scsi/libiscsi.h
index a72edd4..a9af95e 100644
--- a/include/scsi/libiscsi.h
+++ b/include/scsi/libiscsi.h
@@ -330,6 +330,18 @@ struct iscsi_host {
 	char			workq_name[20];
 };
 
+/* libiscsi ipconfig */
+struct dhcp_info {
+	__be32 ltime;
+	__be32 serverid;
+	__be32 ipaddr;
+	__be32 netmask;
+	__be32 dnsaddr;
+	__be32 gipaddr;
+	__u8 *mac_addr;
+};
+
+
 /*
  * scsi host template
  */
@@ -427,6 +439,14 @@ extern void iscsi_pool_free(struct iscsi_pool *);
 extern int iscsi_pool_init(struct iscsi_pool *, int, void ***, int);
 
 /*
+ * libiscsi ipconfig helpers
+ */
+extern int libiscsi_do_ipconf(struct net_device *ndev,
+				struct dhcp_info *dinfo);
+extern int libiscsi_ipconfig_recv(struct net_device *ndev,
+					struct sk_buff *skb);
+
+/*
  * inline functions to deal with padding.
  */
 static inline unsigned int
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


--------------010003000109080509070003
Content-Type: text/x-patch;
 name="0002-dhcp-handler-for-libiscsi-to-support-dhcp-provisioni.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0002-dhcp-handler-for-libiscsi-to-support-dhcp-provisioni.pa";
 filename*1="tch"

>From 604f882083472b515342c43790eb252dd0e9a18b Mon Sep 17 00:00:00 2001
From: Rakesh Ranjan <rakesh@chelsio.com>
Date: Mon, 16 Nov 2009 19:10:00 +0530
Subject: [PATCH 2/2] dhcp handler for libiscsi to support dhcp provisioning for offload capable cards.

This module contains a compact dhcp handler to support dhcp based provisioning for
offload capable cards.

Signed-off-by: Rakesh Ranjan <rakesh@chelsio.com>
---
 drivers/scsi/Makefile            |    2 +-
 drivers/scsi/libiscsi_ipconfig.c |  466 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 467 insertions(+), 1 deletions(-)
 create mode 100644 drivers/scsi/libiscsi_ipconfig.c

diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
index 3ad61db..c53355f 100644
--- a/drivers/scsi/Makefile
+++ b/drivers/scsi/Makefile
@@ -129,7 +129,7 @@ obj-$(CONFIG_SCSI_HPTIOP)	+= hptiop.o
 obj-$(CONFIG_SCSI_STEX)		+= stex.o
 obj-$(CONFIG_SCSI_MVSAS)	+= mvsas/
 obj-$(CONFIG_PS3_ROM)		+= ps3rom.o
-obj-$(CONFIG_SCSI_CXGB3_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgb3i/
+obj-$(CONFIG_SCSI_CXGB3_ISCSI)	+= libiscsi.o libiscsi_ipconfig.o libiscsi_tcp.o cxgb3i/
 obj-$(CONFIG_SCSI_BNX2_ISCSI)	+= libiscsi.o bnx2i/
 obj-$(CONFIG_BE2ISCSI)		+= libiscsi.o be2iscsi/
 obj-$(CONFIG_SCSI_PMCRAID)	+= pmcraid.o
diff --git a/drivers/scsi/libiscsi_ipconfig.c b/drivers/scsi/libiscsi_ipconfig.c
new file mode 100644
index 0000000..4057aae
--- /dev/null
+++ b/drivers/scsi/libiscsi_ipconfig.c
@@ -0,0 +1,466 @@
+/* libiscsi_ipconfig.c: libiscsi dhcp client.
+ *
+ * Copyright (c) 2009 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Rakesh Ranjan (rakesh@chelsio.com)
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
+#include <scsi/libiscsi.h>
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
+
+static struct dhcp_client_state {
+	struct sk_buff *skb;
+	struct dhcp_pkt *pkt;
+	struct net_device *ndev;
+	struct list_head list;
+	struct dhcp_info dinfo;
+
+	volatile __u8 state;
+	__be32 xid;
+
+} client_state;
+
+static DEFINE_SPINLOCK(rcv_lock);
+
+static const char *RFC2132_VENDOR_CLASS_ID = "libiscsi client";
+
+static const u8 magic_cookie[4] = { 99, 130, 83, 99 };
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
+libiscsi_process_dhcp_opts(struct dhcp_client_state *client, u8 *optptr,
+								int len)
+{
+	u8 *end = optptr + len;
+	u8 type = 0;
+
+	while (optptr < end) {
+		switch (*optptr) {
+		case DHCP_OPTION_SUBNET_MASK:
+			memcpy(&client->dinfo.netmask, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_ROUTER:
+			memcpy(&client->dinfo.gipaddr, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_DNS_SERVER:
+			memcpy(&client->dinfo.dnsaddr, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_MSG_TYPE:
+			type = *(optptr + 2);
+			if (type == DHCPOFFER)
+				client->state = STATE_OFFER_REC;
+			else if (type == DHCPACK)
+				client->state = STATE_CONFIG_REC;
+			break;
+		case DHCP_OPTION_SERVER_ID:
+			memcpy(&client->dinfo.serverid, optptr + 2, 4);
+			break;
+		case DHCP_OPTION_LEASE_TIME:
+			memcpy(&client->dinfo.ltime, optptr + 2, 4);
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
+libiscsi_process_dhcp_pack(struct dhcp_client_state *client,
+					struct dhcp_pkt *pkt)
+{
+	u8 *start, *end;
+	int opt_len;
+
+	start = &pkt->options[4];
+	end = (u8 *) pkt + ntohs(pkt->iph.tot_len);
+	opt_len = end - start;
+
+	if (pkt->op == DHCP_REPLY &&
+		!memcmp(&pkt->xid, &client->xid, sizeof(client->xid)) &&
+		!memcmp(pkt->chwaddr, client->dinfo.mac_addr, pkt->hlen)) {
+		memcpy(&client->dinfo.ipaddr, &pkt->yipaddr, 4);
+		libiscsi_process_dhcp_opts(client, start, opt_len);
+	}
+}
+
+static int
+libiscsi_ipconfig_send(struct dhcp_client_state *client)
+{
+	int rc = 0;
+	struct sk_buff *lskb = client->skb;
+
+	lskb->dev = client->ndev;
+	lskb->protocol = htons(ETH_P_IP);
+
+	dev_hard_header(lskb, client->ndev, ntohs(lskb->protocol),
+					client->ndev->broadcast,
+					client->dinfo.mac_addr, lskb->len);
+	rc = dev_queue_xmit(lskb);
+
+	return rc;
+}
+
+int
+libiscsi_ipconfig_recv(struct net_device *ndev, struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	struct udphdr *udph;
+	struct ethhdr *eh;
+	struct dhcp_pkt *pkt;
+	struct sk_buff *pskb;
+	int len, opts_len;
+	struct dhcp_client_state *client;
+	int rc = 0;
+
+
+	client = &client_state;
+
+	if (unlikely(client->state == STATE_INIT))
+		goto out;
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
+	if (compare_ether_addr(eh->h_dest, client->dinfo.mac_addr))
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
+	if (memcmp(pkt->options, magic_cookie, 4))
+		goto drop;
+
+	spin_lock(&rcv_lock);
+
+	libiscsi_process_dhcp_pack(client, pkt);
+
+	spin_unlock(&rcv_lock);
+
+drop:
+	kfree(pskb);
+out:
+	return rc;
+}
+EXPORT_SYMBOL(libiscsi_ipconfig_recv);
+
+static int
+libiscsi_create_dhcp_msg(struct dhcp_client_state *client)
+{
+	struct iphdr *iph;
+	struct udphdr *udph;
+	struct sk_buff *skb;
+	struct dhcp_pkt *pkt;
+	int rc = 0;
+
+	skb = alloc_skb(sizeof(*pkt) +
+			LL_ALLOCATED_SPACE(client->ndev) + 15,
+			GFP_KERNEL);
+	if (!skb) {
+		rc = -ENOMEM;
+		return rc;
+	}
+
+	client->skb = skb;
+	skb_reserve(skb, LL_RESERVED_SPACE(client->ndev));
+
+	pkt = (struct dhcp_pkt *) skb_put(skb, sizeof(*pkt));
+	BUG_ON(!pkt);
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
+	memcpy(pkt->chwaddr, client->dinfo.mac_addr, ETH_ALEN);
+	pkt->secs = htons(jiffies / HZ);
+	pkt->xid = client->xid;
+
+	memcpy(pkt->options, magic_cookie, sizeof(magic_cookie));
+
+	return rc;
+}
+
+static int libiscsi_send_dhcp_request(struct dhcp_client_state *client)
+{
+	int rc = 0;
+	u8 *end;
+
+	rc = libiscsi_create_dhcp_msg(client);
+	if (rc)
+		return rc;
+
+	end = add_msg_type(&client->pkt->options[4], DHCPREQUEST);
+	end = add_server_id(&client->dinfo.serverid, end);
+	end = add_req_ipaddr(&client->dinfo.ipaddr, end);
+	end = add_vendor_cid(end);
+	end = add_end(end);
+
+	rc = libiscsi_ipconfig_send(client);
+
+	return rc;
+}
+
+static int libiscsi_send_dhcp_discover(struct dhcp_client_state *client)
+{
+	int rc = 0;
+	u8 *end;
+
+	rc = libiscsi_create_dhcp_msg(client);
+	if (rc)
+		return rc;
+
+	end = add_msg_type(&client->pkt->options[4], DHCPDISCOVER);
+	end = add_req_options(end);
+	end = add_vendor_cid(end);
+	end = add_end(end);
+
+	client->state = STATE_SENDING;
+	rc = libiscsi_ipconfig_send(client);
+
+	return rc;
+}
+
+static void
+libiscsi_wait_for_pack(struct dhcp_client_state *client, u8 state)
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
+int libiscsi_do_ipconf(struct net_device *ndev, struct dhcp_info *dinfo)
+{
+	int rc = 0;
+	int retry;
+	struct dhcp_client_state *client;
+	retry = 2;
+
+	client = &client_state;
+	client->dinfo.mac_addr = dinfo->mac_addr;
+	client->ndev = ndev;
+	client->state = STATE_INIT;
+
+	/* show time */
+	for (;;) {
+		get_random_bytes(&client->xid, sizeof(__be32));
+		libiscsi_send_dhcp_discover(client);
+		libiscsi_wait_for_pack(client, STATE_OFFER_REC);
+
+		if (client->state == STATE_OFFER_REC) {
+			libiscsi_send_dhcp_request(client);
+			libiscsi_wait_for_pack(client, STATE_CONFIG_REC);
+			if (client->state == STATE_CONFIG_REC) {
+				dinfo->ipaddr = client->dinfo.ipaddr;
+				dinfo->netmask = client->dinfo.netmask;
+				dinfo->ltime = client->dinfo.ltime;
+				client->state = STATE_INIT;
+				break;
+			}
+		}
+
+		if (!--retry) {
+			rc = -ENETUNREACH;
+			break;
+		}
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL(libiscsi_do_ipconf);
+
+MODULE_AUTHOR("Rakesh Ranjan");
+MODULE_DESCRIPTION("iSCSI ipconfig functions");
+MODULE_LICENSE("GPL");
-- 
1.6.0.6


--------------010003000109080509070003--
