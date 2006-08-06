From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/7] [NEIGH]: Convert neighbour deletion to new netlink api
Date: Mon, 07 Aug 2006 00:00:01 +0200
Message-ID: <20060807171049.731389201@postel.suug.ch>
References: <20060807170944.259251279@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:462 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750793AbWHGRMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 13:12:10 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_neigh_del
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes:
  Return ENOENT if the neighbour is not found (was EINVAL)
  Return EAFNOSUPPORT if no table matches the specified
  address family.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/neighbour.c
===================================================================
--- net-2.6.19.git.orig/net/core/neighbour.c
+++ net-2.6.19.git/net/core/neighbour.c
@@ -30,6 +30,7 @@
 #include <net/dst.h>
 #include <net/sock.h>
 #include <net/netevent.h>
+#include <net/netlink.h>
 #include <linux/rtnetlink.h>
 #include <linux/random.h>
 #include <linux/string.h>
@@ -1437,48 +1438,62 @@ int neigh_table_clear(struct neigh_table
 
 int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct ndmsg *ndm = NLMSG_DATA(nlh);
-	struct rtattr **nda = arg;
+	struct ndmsg *ndm;
+	struct nlattr *dst_attr;
 	struct neigh_table *tbl;
 	struct net_device *dev = NULL;
-	int err = -ENODEV;
+	int err = -EINVAL;
 
-	if (ndm->ndm_ifindex &&
-	    (dev = dev_get_by_index(ndm->ndm_ifindex)) == NULL)
+	if (nlmsg_len(nlh) < sizeof(*ndm))
+		goto out;
+
+	dst_attr = nlmsg_find_attr(nlh, sizeof(*ndm), NDA_DST);
+	if (dst_attr == NULL)
 		goto out;
 
+	ndm = nlmsg_data(nlh);
+	if (ndm->ndm_ifindex) {
+		dev = dev_get_by_index(ndm->ndm_ifindex);
+		if (dev == NULL) {
+			err = -ENODEV;
+			goto out;
+		}
+	}
+
 	read_lock(&neigh_tbl_lock);
 	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
-		struct rtattr *dst_attr = nda[NDA_DST - 1];
-		struct neighbour *n;
+		struct neighbour *neigh;
 
 		if (tbl->family != ndm->ndm_family)
 			continue;
 		read_unlock(&neigh_tbl_lock);
 
-		err = -EINVAL;
-		if (!dst_attr || RTA_PAYLOAD(dst_attr) < tbl->key_len)
+		if (nla_len(dst_attr) < tbl->key_len)
 			goto out_dev_put;
 
 		if (ndm->ndm_flags & NTF_PROXY) {
-			err = pneigh_delete(tbl, RTA_DATA(dst_attr), dev);
+			err = pneigh_delete(tbl, nla_data(dst_attr), dev);
 			goto out_dev_put;
 		}
 
-		if (!dev)
-			goto out;
+		if (dev == NULL)
+			goto out_dev_put;
 
-		n = neigh_lookup(tbl, RTA_DATA(dst_attr), dev);
-		if (n) {
-			err = neigh_update(n, NULL, NUD_FAILED, 
-					   NEIGH_UPDATE_F_OVERRIDE|
-					   NEIGH_UPDATE_F_ADMIN);
-			neigh_release(n);
+		neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
+		if (neigh == NULL) {
+			err = -ENOENT;
+			goto out_dev_put;
 		}
+
+		err = neigh_update(neigh, NULL, NUD_FAILED,
+				   NEIGH_UPDATE_F_OVERRIDE |
+				   NEIGH_UPDATE_F_ADMIN);
+		neigh_release(neigh);
 		goto out_dev_put;
 	}
 	read_unlock(&neigh_tbl_lock);
-	err = -EADDRNOTAVAIL;
+	err = -EAFNOSUPPORT;
+
 out_dev_put:
 	if (dev)
 		dev_put(dev);

