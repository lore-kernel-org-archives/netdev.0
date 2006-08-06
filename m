From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/7] [NEIGH]: Convert neighbour addition to new netlink api
Date: Mon, 07 Aug 2006 00:00:02 +0200
Message-ID: <20060807171049.902566143@postel.suug.ch>
References: <20060807170944.259251279@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:1998 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750797AbWHGRMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 13:12:15 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_neigh_add
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes:
    Return EAFNOSUPPORT if no table matches the specified
    address family.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/neighbour.c
===================================================================
--- net-2.6.19.git.orig/net/core/neighbour.c
+++ net-2.6.19.git/net/core/neighbour.c
@@ -1503,76 +1503,88 @@ out:
 
 int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct ndmsg *ndm = NLMSG_DATA(nlh);
-	struct rtattr **nda = arg;
+	struct ndmsg *ndm;
+	struct nlattr *tb[NDA_MAX+1];
 	struct neigh_table *tbl;
 	struct net_device *dev = NULL;
-	int err = -ENODEV;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	if (err < 0)
+		goto out;
 
-	if (ndm->ndm_ifindex &&
-	    (dev = dev_get_by_index(ndm->ndm_ifindex)) == NULL)
+	err = -EINVAL;
+	if (tb[NDA_DST] == NULL)
 		goto out;
 
+	ndm = nlmsg_data(nlh);
+	if (ndm->ndm_ifindex) {
+		dev = dev_get_by_index(ndm->ndm_ifindex);
+		if (dev == NULL) {
+			err = -ENODEV;
+			goto out;
+		}
+
+		if (tb[NDA_LLADDR] && nla_len(tb[NDA_LLADDR]) < dev->addr_len)
+			goto out_dev_put;
+	}
+
 	read_lock(&neigh_tbl_lock);
 	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
-		struct rtattr *lladdr_attr = nda[NDA_LLADDR - 1];
-		struct rtattr *dst_attr = nda[NDA_DST - 1];
-		int override = 1;
-		struct neighbour *n;
+		int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
+		struct neighbour *neigh;
+		void *dst, *lladdr;
 
 		if (tbl->family != ndm->ndm_family)
 			continue;
 		read_unlock(&neigh_tbl_lock);
 
-		err = -EINVAL;
-		if (!dst_attr || RTA_PAYLOAD(dst_attr) < tbl->key_len)
+		if (nla_len(tb[NDA_DST]) < tbl->key_len)
 			goto out_dev_put;
+		dst = nla_data(tb[NDA_DST]);
+		lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
 
 		if (ndm->ndm_flags & NTF_PROXY) {
-			err = -ENOBUFS;
-			if (pneigh_lookup(tbl, RTA_DATA(dst_attr), dev, 1))
-				err = 0;
+			err = 0;
+			if (pneigh_lookup(tbl, dst, dev, 1) == NULL)
+				err = -ENOBUFS;
 			goto out_dev_put;
 		}
 
-		err = -EINVAL;
-		if (!dev)
-			goto out;
-		if (lladdr_attr && RTA_PAYLOAD(lladdr_attr) < dev->addr_len)
+		if (dev == NULL)
 			goto out_dev_put;
+
+		neigh = neigh_lookup(tbl, dst, dev);
+		if (neigh == NULL) {
+			if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
+				err = -ENOENT;
+				goto out_dev_put;
+			}
 	
-		n = neigh_lookup(tbl, RTA_DATA(dst_attr), dev);
-		if (n) {
-			if (nlh->nlmsg_flags & NLM_F_EXCL) {
-				err = -EEXIST;
-				neigh_release(n);
+			neigh = __neigh_lookup_errno(tbl, dst, dev);
+			if (IS_ERR(neigh)) {
+				err = PTR_ERR(neigh);
 				goto out_dev_put;
 			}
-			
-			override = nlh->nlmsg_flags & NLM_F_REPLACE;
-		} else if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
-			err = -ENOENT;
-			goto out_dev_put;
 		} else {
-			n = __neigh_lookup_errno(tbl, RTA_DATA(dst_attr), dev);
-			if (IS_ERR(n)) {
-				err = PTR_ERR(n);
+			if (nlh->nlmsg_flags & NLM_F_EXCL) {
+				err = -EEXIST;
+				neigh_release(neigh);
 				goto out_dev_put;
 			}
-		}
 
-		err = neigh_update(n,
-				   lladdr_attr ? RTA_DATA(lladdr_attr) : NULL,
-				   ndm->ndm_state,
-				   (override ? NEIGH_UPDATE_F_OVERRIDE : 0) |
-				   NEIGH_UPDATE_F_ADMIN);
+			if (!(nlh->nlmsg_flags & NLM_F_REPLACE))
+				flags &= ~NEIGH_UPDATE_F_OVERRIDE;
+		}
 
-		neigh_release(n);
+		err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
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

