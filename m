From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [DECNET] address: Convert to new netlink interface
Date: Sun, 19 Nov 2006 23:23:29 +0100
Message-ID: <20061119222420.394152702@lsx.localdomain>
References: <20061119222326.208529546@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:8631 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933470AbWKSWZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 17:25:40 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_dn_new_api
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extends the netlink interface to support the __le16 type and
converts address addition, deletion and, dumping to use the
new netlink interface.

Fixes multiple occasions of possible illegal memory references
due to not validated netlink attributes.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/netlink.h
===================================================================
--- net-2.6.20.orig/include/net/netlink.h	2006-11-19 18:36:40.000000000 +0100
+++ net-2.6.20/include/net/netlink.h	2006-11-19 21:43:12.000000000 +0100
@@ -829,6 +829,9 @@
 #define NLA_PUT_U16(skb, attrtype, value) \
 	NLA_PUT_TYPE(skb, u16, attrtype, value)
 
+#define NLA_PUT_LE16(skb, attrtype, value) \
+	NLA_PUT_TYPE(skb, __le16, attrtype, value)
+
 #define NLA_PUT_U32(skb, attrtype, value) \
 	NLA_PUT_TYPE(skb, u32, attrtype, value)
 
@@ -875,6 +878,15 @@
 }
 
 /**
+ * nla_get_le16 - return payload of __le16 attribute
+ * @nla: __le16 netlink attribute
+ */
+static inline __le16 nla_get_le16(struct nlattr *nla)
+{
+	return *(__le16 *) nla_data(nla);
+}
+
+/**
  * nla_get_u8 - return payload of u8 attribute
  * @nla: u8 netlink attribute
  */
Index: net-2.6.20/net/decnet/dn_dev.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_dev.c	2006-11-19 18:36:45.000000000 +0100
+++ net-2.6.20/net/decnet/dn_dev.c	2006-11-19 22:07:33.000000000 +0100
@@ -647,41 +647,62 @@
 	return dn_dev;
 }
 
-static int dn_dev_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static struct nla_policy dn_ifa_policy[IFA_MAX+1] __read_mostly = {
+	[IFA_ADDRESS]		= { .type = NLA_U16 },
+	[IFA_LOCAL]		= { .type = NLA_U16 },
+	[IFA_LABEL]		= { .type = NLA_STRING,
+				    .len = IFNAMSIZ - 1 },
+};
+
+static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct rtattr **rta = arg;
+	struct nlattr *tb[IFA_MAX+1];
 	struct dn_dev *dn_db;
-	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
+	struct ifaddrmsg *ifm;
 	struct dn_ifaddr *ifa, **ifap;
+	int err = -EADDRNOTAVAIL;
 
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
+	if (err < 0)
+		goto errout;
+
+	ifm = nlmsg_data(nlh);
 	if ((dn_db = dn_dev_by_index(ifm->ifa_index)) == NULL)
-		return -EADDRNOTAVAIL;
+		goto errout;
 
-	for(ifap = &dn_db->ifa_list; (ifa=*ifap) != NULL; ifap = &ifa->ifa_next) {
-		void *tmp = rta[IFA_LOCAL-1];
-		if ((tmp && memcmp(RTA_DATA(tmp), &ifa->ifa_local, 2)) ||
-		    (rta[IFA_LABEL-1] && rtattr_strcmp(rta[IFA_LABEL-1], ifa->ifa_label)))
+	for (ifap = &dn_db->ifa_list; (ifa = *ifap); ifap = &ifa->ifa_next) {
+		if (tb[IFA_LOCAL] &&
+		    nla_memcmp(tb[IFA_LOCAL], &ifa->ifa_local, 2))
+			continue;
+
+		if (tb[IFA_LABEL] && nla_strcmp(tb[IFA_LABEL], ifa->ifa_label))
 			continue;
 
 		dn_dev_del_ifa(dn_db, ifap, 1);
 		return 0;
 	}
 
-	return -EADDRNOTAVAIL;
+errout:
+	return err;
 }
 
-static int dn_dev_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct rtattr **rta = arg;
+	struct nlattr *tb[IFA_MAX+1];
 	struct net_device *dev;
 	struct dn_dev *dn_db;
-	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
+	struct ifaddrmsg *ifm;
 	struct dn_ifaddr *ifa;
-	int rv;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
+	if (err < 0)
+		return err;
 
-	if (rta[IFA_LOCAL-1] == NULL)
+	if (tb[IFA_LOCAL] == NULL)
 		return -EINVAL;
 
+	ifm = nlmsg_data(nlh);
 	if ((dev = __dev_get_by_index(ifm->ifa_index)) == NULL)
 		return -ENODEV;
 
@@ -695,22 +716,25 @@
 	if ((ifa = dn_dev_alloc_ifa()) == NULL)
 		return -ENOBUFS;
 
-	if (!rta[IFA_ADDRESS - 1])
-		rta[IFA_ADDRESS - 1] = rta[IFA_LOCAL - 1];
-	memcpy(&ifa->ifa_local, RTA_DATA(rta[IFA_LOCAL-1]), 2);
-	memcpy(&ifa->ifa_address, RTA_DATA(rta[IFA_ADDRESS-1]), 2);
+	if (tb[IFA_ADDRESS] == NULL)
+		tb[IFA_ADDRESS] = tb[IFA_LOCAL];
+
+	ifa->ifa_local = nla_get_le16(tb[IFA_LOCAL]);
+	ifa->ifa_address = nla_get_le16(tb[IFA_ADDRESS]);
 	ifa->ifa_flags = ifm->ifa_flags;
 	ifa->ifa_scope = ifm->ifa_scope;
 	ifa->ifa_dev = dn_db;
-	if (rta[IFA_LABEL-1])
-		rtattr_strlcpy(ifa->ifa_label, rta[IFA_LABEL-1], IFNAMSIZ);
+
+	if (tb[IFA_LABEL])
+		nla_strlcpy(ifa->ifa_label, tb[IFA_LABEL], IFNAMSIZ);
 	else
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 
-	rv = dn_dev_insert_ifa(dn_db, ifa);
-	if (rv)
+	err = dn_dev_insert_ifa(dn_db, ifa);
+	if (err)
 		dn_dev_free_ifa(ifa);
-	return rv;
+
+	return err;
 }
 
 static inline size_t dn_ifaddr_nlmsg_size(void)
@@ -721,34 +745,34 @@
 	       + nla_total_size(2); /* IFA_LOCAL */
 }
 
-static int dn_dev_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
-				u32 pid, u32 seq, int event, unsigned int flags)
+static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
+			     u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb->tail;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
-	ifm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*ifm), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
 
+	ifm = nlmsg_data(nlh);
 	ifm->ifa_family = AF_DECnet;
 	ifm->ifa_prefixlen = 16;
 	ifm->ifa_flags = ifa->ifa_flags | IFA_F_PERMANENT;
 	ifm->ifa_scope = ifa->ifa_scope;
 	ifm->ifa_index = ifa->ifa_dev->dev->ifindex;
+
 	if (ifa->ifa_address)
-		RTA_PUT(skb, IFA_ADDRESS, 2, &ifa->ifa_address);
+		NLA_PUT_LE16(skb, IFA_ADDRESS, ifa->ifa_address);
 	if (ifa->ifa_local)
-		RTA_PUT(skb, IFA_LOCAL, 2, &ifa->ifa_local);
+		NLA_PUT_LE16(skb, IFA_LOCAL, ifa->ifa_local);
 	if (ifa->ifa_label[0])
-		RTA_PUT(skb, IFA_LABEL, IFNAMSIZ, &ifa->ifa_label);
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+		NLA_PUT_STRING(skb, IFA_LABEL, ifa->ifa_label);
+
+	return nlmsg_end(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-        skb_trim(skb, b - skb->data);
-        return -1;
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 static void dn_ifaddr_notify(int event, struct dn_ifaddr *ifa)
@@ -760,7 +784,7 @@
 	if (skb == NULL)
 		goto errout;
 
-	err = dn_dev_fill_ifaddr(skb, ifa, 0, 0, event, 0);
+	err = dn_nl_fill_ifaddr(skb, ifa, 0, 0, event, 0);
 	/* failure implies BUG in dn_ifaddr_nlmsg_size() */
 	BUG_ON(err < 0);
 
@@ -770,39 +794,43 @@
 		rtnl_set_sk_err(RTNLGRP_DECnet_IFADDR, err);
 }
 
-static int dn_dev_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
+static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx, dn_idx;
-	int s_idx, s_dn_idx;
+	int idx, dn_idx = 0, skip_ndevs, skip_naddr;
 	struct net_device *dev;
 	struct dn_dev *dn_db;
 	struct dn_ifaddr *ifa;
 
-	s_idx = cb->args[0];
-	s_dn_idx = dn_idx = cb->args[1];
+	skip_ndevs = cb->args[0];
+	skip_naddr = cb->args[1];
+
 	read_lock(&dev_base_lock);
-	for(dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
-		if (idx < s_idx)
+	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
+		if (idx < skip_ndevs)
 			continue;
-		if (idx > s_idx)
-			s_dn_idx = 0;
+		else if (idx > skip_ndevs) {
+			/* Only skip over addresses for first dev dumped
+			 * in this iteration (idx == skip_ndevs) */
+			skip_naddr = 0;
+		}
+
 		if ((dn_db = dev->dn_ptr) == NULL)
 			continue;
 
-		for(ifa = dn_db->ifa_list, dn_idx = 0; ifa; ifa = ifa->ifa_next, dn_idx++) {
-			if (dn_idx < s_dn_idx)
+		for (ifa = dn_db->ifa_list, dn_idx = 0; ifa;
+		     ifa = ifa->ifa_next, dn_idx++) {
+			if (dn_idx < skip_naddr)
 				continue;
 
-			if (dn_dev_fill_ifaddr(skb, ifa,
-					       NETLINK_CB(cb->skb).pid,
-					       cb->nlh->nlmsg_seq,
-					       RTM_NEWADDR,
-					       NLM_F_MULTI) <= 0)
+			if (dn_nl_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
+					      cb->nlh->nlmsg_seq, RTM_NEWADDR,
+					      NLM_F_MULTI) < 0)
 				goto done;
 		}
 	}
 done:
 	read_unlock(&dev_base_lock);
+
 	cb->args[0] = idx;
 	cb->args[1] = dn_idx;
 
@@ -1419,9 +1447,9 @@
 
 static struct rtnetlink_link dnet_rtnetlink_table[RTM_NR_MSGTYPES] =
 {
-	[RTM_NEWADDR  - RTM_BASE] = { .doit	= dn_dev_rtm_newaddr,	},
-	[RTM_DELADDR  - RTM_BASE] = { .doit	= dn_dev_rtm_deladdr,	},
-	[RTM_GETADDR  - RTM_BASE] = { .dumpit	= dn_dev_dump_ifaddr,	},
+	[RTM_NEWADDR  - RTM_BASE] = { .doit	= dn_nl_newaddr,	},
+	[RTM_DELADDR  - RTM_BASE] = { .doit	= dn_nl_deladdr,	},
+	[RTM_GETADDR  - RTM_BASE] = { .dumpit	= dn_nl_dump_ifaddr,	},
 #ifdef CONFIG_DECNET_ROUTER
 	[RTM_NEWROUTE - RTM_BASE] = { .doit	= dn_fib_rtm_newroute,	},
 	[RTM_DELROUTE - RTM_BASE] = { .doit	= dn_fib_rtm_delroute,	},

--

