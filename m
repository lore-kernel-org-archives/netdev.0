From: David Howells <dhowells@redhat.com>
Subject: [PATCH 14/16] AFS: Add support for the CB.GetCapabilities operation
	[try #3]
Date: Wed, 25 Apr 2007 11:51:49 +0100
Message-ID: <20070425105149.10872.35443.stgit@warthog.cambridge.redhat.com>
References: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the CB.GetCapabilities operation with which the fileserver can
ask the client for the following information:

 (1) The list of network interfaces it has available as IPv4 address + netmask
     plus the MTUs.

 (2) The client's UUID.

 (3) The extended capabilities of the client, for which the only current one
     is unified error mapping (abort code interpretation).

To support this, the patch adds the following routines to AFS:

 (1) A function to iterate through all the network interfaces using RTNETLINK
     to extract IPv4 addresses and MTUs.

 (2) A function to iterate through all the network interfaces using RTNETLINK
     to pull out the MAC address of the lowest index interface to use in UUID
     construction.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/AFS_CM.h        |    3 
 fs/afs/Makefile        |    1 
 fs/afs/cmservice.c     |   98 ++++++++++
 fs/afs/internal.h      |   42 ++++
 fs/afs/main.c          |   49 +++++
 fs/afs/rxrpc.c         |   39 ++++
 fs/afs/use-rtnetlink.c |  473 ++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 705 insertions(+), 0 deletions(-)

diff --git a/fs/afs/AFS_CM.h b/fs/afs/AFS_CM.h
index 7c8e3d4..d4bd201 100644
--- a/fs/afs/AFS_CM.h
+++ b/fs/afs/AFS_CM.h
@@ -23,6 +23,9 @@ enum AFS_CM_Operations {
 	CBGetCE			= 208,	/* get cache file description */
 	CBGetXStatsVersion	= 209,	/* get version of extended statistics */
 	CBGetXStats		= 210,	/* get contents of extended statistics data */
+	CBGetCapabilities	= 65538, /* get client capabilities */
 };
 
+#define AFS_CAP_ERROR_TRANSLATION	0x1
+
 #endif /* AFS_FS_H */
diff --git a/fs/afs/Makefile b/fs/afs/Makefile
index cca198b..01545eb 100644
--- a/fs/afs/Makefile
+++ b/fs/afs/Makefile
@@ -18,6 +18,7 @@ kafs-objs := \
 	security.o \
 	server.o \
 	super.o \
+	use-rtnetlink.o \
 	vlclient.o \
 	vlocation.o \
 	vnode.o \
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 9cb3ac5..5139723 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -22,6 +22,8 @@ static int afs_deliver_cb_init_call_back_state(struct afs_call *,
 					       struct sk_buff *, bool);
 static int afs_deliver_cb_probe(struct afs_call *, struct sk_buff *, bool);
 static int afs_deliver_cb_callback(struct afs_call *, struct sk_buff *, bool);
+static int afs_deliver_cb_get_capabilities(struct afs_call *, struct sk_buff *,
+					   bool);
 static void afs_cm_destructor(struct afs_call *);
 
 /*
@@ -55,6 +57,16 @@ static const struct afs_call_type afs_SRXCBProbe = {
 };
 
 /*
+ * CB.GetCapabilities operation type
+ */
+static const struct afs_call_type afs_SRXCBGetCapabilites = {
+	.name		= "CB.GetCapabilities",
+	.deliver	= afs_deliver_cb_get_capabilities,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_cm_destructor,
+};
+
+/*
  * route an incoming cache manager call
  * - return T if supported, F if not
  */
@@ -74,6 +86,9 @@ bool afs_cm_incoming_call(struct afs_call *call)
 	case CBProbe:
 		call->type = &afs_SRXCBProbe;
 		return true;
+	case CBGetCapabilities:
+		call->type = &afs_SRXCBGetCapabilites;
+		return true;
 	default:
 		return false;
 	}
@@ -328,3 +343,86 @@ static int afs_deliver_cb_probe(struct afs_call *call, struct sk_buff *skb,
 	schedule_work(&call->work);
 	return 0;
 }
+
+/*
+ * allow the fileserver to ask about the cache manager's capabilities
+ */
+static void SRXAFSCB_GetCapabilities(struct work_struct *work)
+{
+	struct afs_interface *ifs;
+	struct afs_call *call = container_of(work, struct afs_call, work);
+	int loop, nifs;
+
+	struct {
+		struct /* InterfaceAddr */ {
+			__be32 nifs;
+			__be32 uuid[11];
+			__be32 ifaddr[32];
+			__be32 netmask[32];
+			__be32 mtu[32];
+		} ia;
+		struct /* Capabilities */ {
+			__be32 capcount;
+			__be32 caps[1];
+		} cap;
+	} reply;
+
+	_enter("");
+
+	nifs = 0;
+	ifs = kcalloc(32, sizeof(*ifs), GFP_KERNEL);
+	if (ifs) {
+		nifs = afs_get_ipv4_interfaces(ifs, 32, false);
+		if (nifs < 0) {
+			kfree(ifs);
+			ifs = NULL;
+			nifs = 0;
+		}
+	}
+
+	memset(&reply, 0, sizeof(reply));
+	reply.ia.nifs = htonl(nifs);
+
+	reply.ia.uuid[0] = htonl(afs_uuid.time_low);
+	reply.ia.uuid[1] = htonl(afs_uuid.time_mid);
+	reply.ia.uuid[2] = htonl(afs_uuid.time_hi_and_version);
+	reply.ia.uuid[3] = htonl((s8) afs_uuid.clock_seq_hi_and_reserved);
+	reply.ia.uuid[4] = htonl((s8) afs_uuid.clock_seq_low);
+	for (loop = 0; loop < 6; loop++)
+		reply.ia.uuid[loop + 5] = htonl((s8) afs_uuid.node[loop]);
+
+	if (ifs) {
+		for (loop = 0; loop < nifs; loop++) {
+			reply.ia.ifaddr[loop] = ifs[loop].address.s_addr;
+			reply.ia.netmask[loop] = ifs[loop].netmask.s_addr;
+			reply.ia.mtu[loop] = htonl(ifs[loop].mtu);
+		}
+	}
+
+	reply.cap.capcount = htonl(1);
+	reply.cap.caps[0] = htonl(AFS_CAP_ERROR_TRANSLATION);
+	afs_send_simple_reply(call, &reply, sizeof(reply));
+
+	_leave("");
+}
+
+/*
+ * deliver request data to a CB.GetCapabilities call
+ */
+static int afs_deliver_cb_get_capabilities(struct afs_call *call,
+					   struct sk_buff *skb, bool last)
+{
+	_enter(",{%u},%d", skb->len, last);
+
+	if (skb->len > 0)
+		return -EBADMSG;
+	if (!last)
+		return 0;
+
+	/* no unmarshalling required */
+	call->state = AFS_CALL_REPLYING;
+
+	INIT_WORK(&call->work, SRXAFSCB_GetCapabilities);
+	schedule_work(&call->work);
+	return 0;
+}
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index d49201e..9107d3f 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -346,6 +346,40 @@ struct afs_permits {
 	struct afs_permit	permits[0];	/* the permits so far examined */
 };
 
+/*
+ * record of one of a system's set of network interfaces
+ */
+struct afs_interface {
+	unsigned	index;		/* interface index */
+	struct in_addr	address;	/* IPv4 address bound to interface */
+	struct in_addr	netmask;	/* netmask applied to address */
+	unsigned	mtu;		/* MTU of interface */
+};
+
+/*
+ * UUID definition [internet draft]
+ * - the timestamp is a 60-bit value, split 32/16/12, and goes in 100ns
+ *   increments since midnight 15th October 1582
+ *   - add AFS_UUID_TO_UNIX_TIME to convert unix time in 100ns units to UUID
+ *     time
+ * - the clock sequence is a 14-bit counter to avoid duplicate times
+ */
+struct afs_uuid {
+	u32		time_low;			/* low part of timestamp */
+	u16		time_mid;			/* mid part of timestamp */
+	u16		time_hi_and_version;		/* high part of timestamp and version  */
+#define AFS_UUID_TO_UNIX_TIME	0x01b21dd213814000
+#define AFS_UUID_TIMEHI_MASK	0x0fff
+#define AFS_UUID_VERSION_TIME	0x1000	/* time-based UUID */
+#define AFS_UUID_VERSION_NAME	0x3000	/* name-based UUID */
+#define AFS_UUID_VERSION_RANDOM	0x4000	/* (pseudo-)random generated UUID */
+	u8		clock_seq_hi_and_reserved;	/* clock seq hi and variant */
+#define AFS_UUID_CLOCKHI_MASK	0x3f
+#define AFS_UUID_VARIANT_STD	0x80
+	u8		clock_seq_low;			/* clock seq low */
+	u8		node[6];			/* spatially unique node ID (MAC addr) */
+};
+
 /*****************************************************************************/
 /*
  * callback.c
@@ -430,6 +464,7 @@ extern void afs_clear_inode(struct inode *);
 /*
  * main.c
  */
+extern struct afs_uuid afs_uuid;
 #ifdef AFS_CACHING_SUPPORT
 extern struct cachefs_netfs afs_cache_netfs;
 #endif
@@ -470,6 +505,7 @@ extern struct afs_call *afs_alloc_flat_call(const struct afs_call_type *,
 extern void afs_flat_call_destructor(struct afs_call *);
 extern void afs_transfer_reply(struct afs_call *, struct sk_buff *);
 extern void afs_send_empty_reply(struct afs_call *);
+extern void afs_send_simple_reply(struct afs_call *, const void *, size_t);
 extern int afs_extract_data(struct afs_call *, struct sk_buff *, bool, void *,
 			    size_t);
 
@@ -501,6 +537,12 @@ extern int afs_fs_init(void);
 extern void afs_fs_exit(void);
 
 /*
+ * use-rtnetlink.c
+ */
+extern int afs_get_ipv4_interfaces(struct afs_interface *, size_t, bool);
+extern int afs_get_MAC_address(u8 [6]);
+
+/*
  * vlclient.c
  */
 #ifdef AFS_CACHING_SUPPORT
diff --git a/fs/afs/main.c b/fs/afs/main.c
index 0cf1b02..40c2704 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -40,6 +40,51 @@ struct cachefs_netfs afs_cache_netfs = {
 };
 #endif
 
+struct afs_uuid afs_uuid;
+
+/*
+ * get a client UUID
+ */
+static int __init afs_get_client_UUID(void)
+{
+	struct timespec ts;
+	u64 uuidtime;
+	u16 clockseq;
+	int ret;
+
+	/* read the MAC address of one of the external interfaces and construct
+	 * a UUID from it */
+	ret = afs_get_MAC_address(afs_uuid.node);
+	if (ret < 0)
+		return ret;
+
+	getnstimeofday(&ts);
+	uuidtime = (u64) ts.tv_sec * 1000 * 1000 * 10;
+	uuidtime += ts.tv_nsec / 100;
+	uuidtime += AFS_UUID_TO_UNIX_TIME;
+	afs_uuid.time_low = uuidtime;
+	afs_uuid.time_mid = uuidtime >> 32;
+	afs_uuid.time_hi_and_version = (uuidtime >> 48) & AFS_UUID_TIMEHI_MASK;
+	afs_uuid.time_hi_and_version = AFS_UUID_VERSION_TIME;
+
+	get_random_bytes(&clockseq, 2);
+	afs_uuid.clock_seq_low = clockseq;
+	afs_uuid.clock_seq_hi_and_reserved =
+		(clockseq >> 8) & AFS_UUID_CLOCKHI_MASK;
+	afs_uuid.clock_seq_hi_and_reserved = AFS_UUID_VARIANT_STD;
+
+	_debug("AFS UUID: %08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
+	       afs_uuid.time_low,
+	       afs_uuid.time_mid,
+	       afs_uuid.time_hi_and_version,
+	       afs_uuid.clock_seq_hi_and_reserved,
+	       afs_uuid.clock_seq_low,
+	       afs_uuid.node[0], afs_uuid.node[1], afs_uuid.node[2],
+	       afs_uuid.node[3], afs_uuid.node[4], afs_uuid.node[5]);
+
+	return 0;
+}
+
 /*
  * initialise the AFS client FS module
  */
@@ -49,6 +94,10 @@ static int __init afs_init(void)
 
 	printk(KERN_INFO "kAFS: Red Hat AFS client v0.1 registering.\n");
 
+	ret = afs_get_client_UUID();
+	if (ret < 0)
+		return ret;
+
 	/* register the /proc stuff */
 	ret = afs_proc_init();
 	if (ret < 0)
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 2d05d8a..cf826a5 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -714,6 +714,45 @@ void afs_send_empty_reply(struct afs_call *call)
 }
 
 /*
+ * send a simple reply
+ */
+void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
+{
+	struct msghdr msg;
+	struct iovec iov[1];
+
+	_enter("");
+
+	iov[0].iov_base		= (void *) buf;
+	iov[0].iov_len		= len;
+	msg.msg_name		= NULL;
+	msg.msg_namelen		= 0;
+	msg.msg_iov		= iov;
+	msg.msg_iovlen		= 1;
+	msg.msg_control		= NULL;
+	msg.msg_controllen	= 0;
+	msg.msg_flags		= 0;
+
+	call->state = AFS_CALL_AWAIT_ACK;
+	switch (rxrpc_kernel_send_data(call->rxcall, &msg, len)) {
+	case 0:
+		_leave(" [replied]");
+		return;
+
+	case -ENOMEM:
+		_debug("oom");
+		rxrpc_kernel_abort_call(call->rxcall, RX_USER_ABORT);
+	default:
+		rxrpc_kernel_end_call(call->rxcall);
+		call->rxcall = NULL;
+		call->type->destructor(call);
+		afs_free_call(call);
+		_leave(" [error]");
+		return;
+	}
+}
+
+/*
  * extract a piece of data from the received data socket buffers
  */
 int afs_extract_data(struct afs_call *call, struct sk_buff *skb,
diff --git a/fs/afs/use-rtnetlink.c b/fs/afs/use-rtnetlink.c
new file mode 100644
index 0000000..82f0daa
--- /dev/null
+++ b/fs/afs/use-rtnetlink.c
@@ -0,0 +1,473 @@
+/* RTNETLINK client
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <linux/if_addr.h>
+#include <linux/if_arp.h>
+#include <linux/inetdevice.h>
+#include <net/netlink.h>
+#include "internal.h"
+
+struct afs_rtm_desc {
+	struct socket		*nlsock;
+	struct afs_interface	*bufs;
+	u8			*mac;
+	size_t			nbufs;
+	size_t			maxbufs;
+	void			*data;
+	ssize_t			datalen;
+	size_t			datamax;
+	int			msg_seq;
+	unsigned		mac_index;
+	bool			wantloopback;
+	int (*parse)(struct afs_rtm_desc *, struct nlmsghdr *);
+};
+
+/*
+ * parse an RTM_GETADDR response
+ */
+static int afs_rtm_getaddr_parse(struct afs_rtm_desc *desc,
+				 struct nlmsghdr *nlhdr)
+{
+	struct afs_interface *this;
+	struct ifaddrmsg *ifa;
+	struct rtattr *rtattr;
+	const char *name;
+	size_t len;
+
+	ifa = (struct ifaddrmsg *) NLMSG_DATA(nlhdr);
+
+	_enter("{ix=%d,af=%d}", ifa->ifa_index, ifa->ifa_family);
+
+	if (ifa->ifa_family != AF_INET) {
+		_leave(" = 0 [family %d]", ifa->ifa_family);
+		return 0;
+	}
+	if (desc->nbufs >= desc->maxbufs) {
+		_leave(" = 0 [max %zu/%zu]", desc->nbufs, desc->maxbufs);
+		return 0;
+	}
+
+	this = &desc->bufs[desc->nbufs];
+
+	this->index = ifa->ifa_index;
+	this->netmask.s_addr = inet_make_mask(ifa->ifa_prefixlen);
+	this->mtu = 0;
+
+	rtattr = NLMSG_DATA(nlhdr) + NLMSG_ALIGN(sizeof(struct ifaddrmsg));
+	len = NLMSG_PAYLOAD(nlhdr, sizeof(struct ifaddrmsg));
+
+	name = "unknown";
+	for (; RTA_OK(rtattr, len); rtattr = RTA_NEXT(rtattr, len)) {
+		switch (rtattr->rta_type) {
+		case IFA_ADDRESS:
+			memcpy(&this->address, RTA_DATA(rtattr), 4);
+			break;
+		case IFA_LABEL:
+			name = RTA_DATA(rtattr);
+			break;
+		}
+	}
+
+	_debug("%s: "NIPQUAD_FMT"/"NIPQUAD_FMT,
+	       name, NIPQUAD(this->address), NIPQUAD(this->netmask));
+
+	desc->nbufs++;
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * parse an RTM_GETLINK response for MTUs
+ */
+static int afs_rtm_getlink_if_parse(struct afs_rtm_desc *desc,
+				    struct nlmsghdr *nlhdr)
+{
+	struct afs_interface *this;
+	struct ifinfomsg *ifi;
+	struct rtattr *rtattr;
+	const char *name;
+	size_t len, loop;
+
+	ifi = (struct ifinfomsg *) NLMSG_DATA(nlhdr);
+
+	_enter("{ix=%d}", ifi->ifi_index);
+
+	for (loop = 0; loop < desc->nbufs; loop++) {
+		this = &desc->bufs[loop];
+		if (this->index == ifi->ifi_index)
+			goto found;
+	}
+
+	_leave(" = 0 [no match]");
+	return 0;
+
+found:
+	if (ifi->ifi_type == ARPHRD_LOOPBACK && !desc->wantloopback) {
+		_leave(" = 0 [loopback]");
+		return 0;
+	}
+
+	rtattr = NLMSG_DATA(nlhdr) + NLMSG_ALIGN(sizeof(struct ifinfomsg));
+	len = NLMSG_PAYLOAD(nlhdr, sizeof(struct ifinfomsg));
+
+	name = "unknown";
+	for (; RTA_OK(rtattr, len); rtattr = RTA_NEXT(rtattr, len)) {
+		switch (rtattr->rta_type) {
+		case IFLA_MTU:
+			memcpy(&this->mtu, RTA_DATA(rtattr), 4);
+			break;
+		case IFLA_IFNAME:
+			name = RTA_DATA(rtattr);
+			break;
+		}
+	}
+
+	_debug("%s: "NIPQUAD_FMT"/"NIPQUAD_FMT" mtu %u",
+	       name, NIPQUAD(this->address), NIPQUAD(this->netmask),
+	       this->mtu);
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * parse an RTM_GETLINK response for the MAC address belonging to the lowest
+ * non-internal interface
+ */
+static int afs_rtm_getlink_mac_parse(struct afs_rtm_desc *desc,
+				     struct nlmsghdr *nlhdr)
+{
+	struct ifinfomsg *ifi;
+	struct rtattr *rtattr;
+	const char *name;
+	size_t remain, len;
+	bool set;
+
+	ifi = (struct ifinfomsg *) NLMSG_DATA(nlhdr);
+
+	_enter("{ix=%d}", ifi->ifi_index);
+
+	if (ifi->ifi_index >= desc->mac_index) {
+		_leave(" = 0 [high]");
+		return 0;
+	}
+	if (ifi->ifi_type == ARPHRD_LOOPBACK) {
+		_leave(" = 0 [loopback]");
+		return 0;
+	}
+
+	rtattr = NLMSG_DATA(nlhdr) + NLMSG_ALIGN(sizeof(struct ifinfomsg));
+	remain = NLMSG_PAYLOAD(nlhdr, sizeof(struct ifinfomsg));
+
+	name = "unknown";
+	set = false;
+	for (; RTA_OK(rtattr, remain); rtattr = RTA_NEXT(rtattr, remain)) {
+		switch (rtattr->rta_type) {
+		case IFLA_ADDRESS:
+			len = RTA_PAYLOAD(rtattr);
+			memcpy(desc->mac, RTA_DATA(rtattr),
+			       min_t(size_t, len, 6));
+			desc->mac_index = ifi->ifi_index;
+			set = true;
+			break;
+		case IFLA_IFNAME:
+			name = RTA_DATA(rtattr);
+			break;
+		}
+	}
+
+	if (set)
+		_debug("%s: %02x:%02x:%02x:%02x:%02x:%02x",
+		       name,
+		       desc->mac[0], desc->mac[1], desc->mac[2],
+		       desc->mac[3], desc->mac[4], desc->mac[5]);
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * read the rtnetlink response and pass to parsing routine
+ */
+static int afs_read_rtm(struct afs_rtm_desc *desc)
+{
+	struct nlmsghdr *nlhdr, tmphdr;
+	struct msghdr msg;
+	struct kvec iov[1];
+	void *data;
+	bool last = false;
+	int len, ret, remain;
+
+	_enter("");
+
+	do {
+		/* first of all peek to see how big the packet is */
+		memset(&msg, 0, sizeof(msg));
+		iov[0].iov_base = &tmphdr;
+		iov[0].iov_len = sizeof(tmphdr);
+		len = kernel_recvmsg(desc->nlsock, &msg, iov, 1,
+				     sizeof(tmphdr), MSG_PEEK | MSG_TRUNC);
+		if (len < 0) {
+			_leave(" = %d [peek]", len);
+			return len;
+		}
+		if (len == 0)
+			continue;
+		if (len < sizeof(tmphdr) || len < NLMSG_PAYLOAD(&tmphdr, 0)) {
+			_leave(" = -EMSGSIZE");
+			return -EMSGSIZE;
+		}
+
+		if (desc->datamax < len) {
+			kfree(desc->data);
+			desc->data = NULL;
+			data = kmalloc(len, GFP_KERNEL);
+			if (!data)
+				return -ENOMEM;
+			desc->data = data;
+		}
+		desc->datamax = len;
+
+		/* read all the data from this packet */
+		iov[0].iov_base = desc->data;
+		iov[0].iov_len = desc->datamax;
+		desc->datalen = kernel_recvmsg(desc->nlsock, &msg, iov, 1,
+					       desc->datamax, 0);
+		if (desc->datalen < 0) {
+			_leave(" = %ld [recv]", desc->datalen);
+			return desc->datalen;
+		}
+
+		nlhdr = desc->data;
+
+		/* check if the header is valid */
+		if (!NLMSG_OK(nlhdr, desc->datalen) ||
+		    nlhdr->nlmsg_type == NLMSG_ERROR) {
+			_leave(" = -EIO");
+			return -EIO;
+		}
+
+		/* see if this is the last message */
+		if (nlhdr->nlmsg_type == NLMSG_DONE ||
+		    !(nlhdr->nlmsg_flags & NLM_F_MULTI))
+			last = true;
+
+		/* parse the bits we got this time */
+		nlmsg_for_each_msg(nlhdr, desc->data, desc->datalen, remain) {
+			ret = desc->parse(desc, nlhdr);
+			if (ret < 0) {
+				_leave(" = %d [parse]", ret);
+				return ret;
+			}
+		}
+
+	} while (!last);
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * list the interface bound addresses to get the address and netmask
+ */
+static int afs_rtm_getaddr(struct afs_rtm_desc *desc)
+{
+	struct msghdr msg;
+	struct kvec iov[1];
+	int ret;
+
+	struct {
+		struct nlmsghdr nl_msg __attribute__((aligned(NLMSG_ALIGNTO)));
+		struct ifaddrmsg addr_msg __attribute__((aligned(NLMSG_ALIGNTO)));
+	} request;
+
+	_enter("");
+
+	memset(&request, 0, sizeof(request));
+
+	request.nl_msg.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifaddrmsg));
+	request.nl_msg.nlmsg_type = RTM_GETADDR;
+	request.nl_msg.nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP;
+	request.nl_msg.nlmsg_seq = desc->msg_seq++;
+	request.nl_msg.nlmsg_pid = 0;
+
+	memset(&msg, 0, sizeof(msg));
+	iov[0].iov_base = &request;
+	iov[0].iov_len = sizeof(request);
+
+	ret = kernel_sendmsg(desc->nlsock, &msg, iov, 1, iov[0].iov_len);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * list the interface link statuses to get the MTUs
+ */
+static int afs_rtm_getlink(struct afs_rtm_desc *desc)
+{
+	struct msghdr msg;
+	struct kvec iov[1];
+	int ret;
+
+	struct {
+		struct nlmsghdr nl_msg __attribute__((aligned(NLMSG_ALIGNTO)));
+		struct ifinfomsg link_msg __attribute__((aligned(NLMSG_ALIGNTO)));
+	} request;
+
+	_enter("");
+
+	memset(&request, 0, sizeof(request));
+
+	request.nl_msg.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	request.nl_msg.nlmsg_type = RTM_GETLINK;
+	request.nl_msg.nlmsg_flags = NLM_F_REQUEST | NLM_F_ROOT;
+	request.nl_msg.nlmsg_seq = desc->msg_seq++;
+	request.nl_msg.nlmsg_pid = 0;
+
+	memset(&msg, 0, sizeof(msg));
+	iov[0].iov_base = &request;
+	iov[0].iov_len = sizeof(request);
+
+	ret = kernel_sendmsg(desc->nlsock, &msg, iov, 1, iov[0].iov_len);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * cull any interface records for which there isn't an MTU value
+ */
+static void afs_cull_interfaces(struct afs_rtm_desc *desc)
+{
+	struct afs_interface *bufs = desc->bufs;
+	size_t nbufs = desc->nbufs;
+	int loop, point = 0;
+
+	_enter("{%zu}", nbufs);
+
+	for (loop = 0; loop < nbufs; loop++) {
+		if (desc->bufs[loop].mtu != 0) {
+			if (loop != point) {
+				ASSERTCMP(loop, >, point);
+				bufs[point] = bufs[loop];
+			}
+			point++;
+		}
+	}
+
+	desc->nbufs = point;
+	_leave(" [%zu/%zu]", desc->nbufs, nbufs);
+}
+
+/*
+ * get a list of this system's interface IPv4 addresses, netmasks and MTUs
+ * - returns the number of interface records in the buffer
+ */
+int afs_get_ipv4_interfaces(struct afs_interface *bufs, size_t maxbufs,
+			    bool wantloopback)
+{
+	struct afs_rtm_desc desc;
+	int ret, loop;
+
+	_enter("");
+
+	memset(&desc, 0, sizeof(desc));
+	desc.bufs = bufs;
+	desc.maxbufs = maxbufs;
+	desc.wantloopback = wantloopback;
+
+	ret = sock_create_kern(AF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE,
+			       &desc.nlsock);
+	if (ret < 0) {
+		_leave(" = %d [sock]", ret);
+		return ret;
+	}
+
+	/* issue RTM_GETADDR */
+	desc.parse = afs_rtm_getaddr_parse;
+	ret = afs_rtm_getaddr(&desc);
+	if (ret < 0)
+		goto error;
+	ret = afs_read_rtm(&desc);
+	if (ret < 0)
+		goto error;
+
+	/* issue RTM_GETLINK */
+	desc.parse = afs_rtm_getlink_if_parse;
+	ret = afs_rtm_getlink(&desc);
+	if (ret < 0)
+		goto error;
+	ret = afs_read_rtm(&desc);
+	if (ret < 0)
+		goto error;
+
+	afs_cull_interfaces(&desc);
+	ret = desc.nbufs;
+
+	for (loop = 0; loop < ret; loop++)
+		_debug("[%d] "NIPQUAD_FMT"/"NIPQUAD_FMT" mtu %u",
+		       bufs[loop].index,
+		       NIPQUAD(bufs[loop].address),
+		       NIPQUAD(bufs[loop].netmask),
+		       bufs[loop].mtu);
+
+error:
+	kfree(desc.data);
+	sock_release(desc.nlsock);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * get a MAC address from a random ethernet interface that has a real one
+ * - the buffer should be 6 bytes in size
+ */
+int afs_get_MAC_address(u8 mac[6])
+{
+	struct afs_rtm_desc desc;
+	int ret;
+
+	_enter("");
+
+	memset(&desc, 0, sizeof(desc));
+	desc.mac = mac;
+	desc.mac_index = UINT_MAX;
+
+	ret = sock_create_kern(AF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE,
+			       &desc.nlsock);
+	if (ret < 0) {
+		_leave(" = %d [sock]", ret);
+		return ret;
+	}
+
+	/* issue RTM_GETLINK */
+	desc.parse = afs_rtm_getlink_mac_parse;
+	ret = afs_rtm_getlink(&desc);
+	if (ret < 0)
+		goto error;
+	ret = afs_read_rtm(&desc);
+	if (ret < 0)
+		goto error;
+
+	if (desc.mac_index < UINT_MAX) {
+		/* got a MAC address */
+		_debug("[%d] %02x:%02x:%02x:%02x:%02x:%02x",
+		       desc.mac_index,
+		       mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+	} else {
+		ret = -ENONET;
+	}
+
+error:
+	sock_release(desc.nlsock);
+	_leave(" = %d", ret);
+	return ret;
+}

