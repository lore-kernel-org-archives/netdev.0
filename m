From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/2] [NEIGH]: rtnetlink neighbour cleanups
Date: Fri, 4 Mar 2005 03:29:40 +0100
Message-ID: <20050304022940.GB31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11.orig/net/core/neighbour.c	2005-03-04 00:45:05.000000000 +0100
+++ linux-2.6.11/net/core/neighbour.c	2005-03-04 02:25:26.000000000 +0100
@@ -1430,6 +1430,7 @@
 
 	read_lock(&neigh_tbl_lock);
 	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
+		struct rtattr *dst_attr = nda[NDA_DST - 1];
 		struct neighbour *n;
 
 		if (tbl->family != ndm->ndm_family)
@@ -1437,20 +1438,18 @@
 		read_unlock(&neigh_tbl_lock);
 
 		err = -EINVAL;
-		if (!nda[NDA_DST - 1] ||
-		    nda[NDA_DST - 1]->rta_len != RTA_LENGTH(tbl->key_len))
+		if (!dst_attr || RTA_PAYLOAD(dst_attr) < tbl->key_len)
 			goto out_dev_put;
 
 		if (ndm->ndm_flags & NTF_PROXY) {
-			err = pneigh_delete(tbl,
-					    RTA_DATA(nda[NDA_DST - 1]), dev);
+			err = pneigh_delete(tbl, RTA_DATA(dst_attr), dev);
 			goto out_dev_put;
 		}
 
 		if (!dev)
 			goto out;
 
-		n = neigh_lookup(tbl, RTA_DATA(nda[NDA_DST - 1]), dev);
+		n = neigh_lookup(tbl, RTA_DATA(dst_attr), dev);
 		if (n) {
 			err = neigh_update(n, NULL, NUD_FAILED, 
 					   NEIGH_UPDATE_F_OVERRIDE|
@@ -1482,6 +1481,8 @@
 
 	read_lock(&neigh_tbl_lock);
 	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
+		struct rtattr *lladdr_attr = nda[NDA_LLADDR - 1];
+		struct rtattr *dst_attr = nda[NDA_DST - 1];
 		int override = 1;
 		struct neighbour *n;
 
@@ -1490,48 +1491,49 @@
 		read_unlock(&neigh_tbl_lock);
 
 		err = -EINVAL;
-		if (!nda[NDA_DST - 1] ||
-		    nda[NDA_DST - 1]->rta_len != RTA_LENGTH(tbl->key_len))
+		if (!dst_attr || RTA_PAYLOAD(dst_attr) < tbl->key_len)
 			goto out_dev_put;
+
 		if (ndm->ndm_flags & NTF_PROXY) {
 			err = -ENOBUFS;
-			if (pneigh_lookup(tbl,
-					  RTA_DATA(nda[NDA_DST - 1]), dev, 1))
+			if (pneigh_lookup(tbl, RTA_DATA(dst_attr), dev, 1))
 				err = 0;
 			goto out_dev_put;
 		}
+
 		err = -EINVAL;
 		if (!dev)
 			goto out;
-		if (nda[NDA_LLADDR - 1] &&
-		    nda[NDA_LLADDR - 1]->rta_len != RTA_LENGTH(dev->addr_len))
+		if (lladdr_attr && RTA_PAYLOAD(lladdr_attr) < dev->addr_len)
 			goto out_dev_put;
-		err = 0;
-		n = neigh_lookup(tbl, RTA_DATA(nda[NDA_DST - 1]), dev);
+	
+		n = neigh_lookup(tbl, RTA_DATA(dst_attr), dev);
 		if (n) {
-			if (nlh->nlmsg_flags & NLM_F_EXCL)
+			if (nlh->nlmsg_flags & NLM_F_EXCL) {
 				err = -EEXIST;
+				neigh_release(n);
+				goto out_dev_put;
+			}
+			
 			override = nlh->nlmsg_flags & NLM_F_REPLACE;
-		} else if (!(nlh->nlmsg_flags & NLM_F_CREATE))
+		} else if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
 			err = -ENOENT;
-		else {
-			n = __neigh_lookup_errno(tbl, RTA_DATA(nda[NDA_DST - 1]),
-						 dev);
+			goto out_dev_put;
+		} else {
+			n = __neigh_lookup_errno(tbl, RTA_DATA(dst_attr), dev);
 			if (IS_ERR(n)) {
 				err = PTR_ERR(n);
-				n = NULL;
+				goto out_dev_put;
 			}
 		}
-		if (!err) {
-			err = neigh_update(n, nda[NDA_LLADDR - 1] ?
-						RTA_DATA(nda[NDA_LLADDR - 1]) :
-						NULL,
-					   ndm->ndm_state,
-					   (override ? NEIGH_UPDATE_F_OVERRIDE : 0) |
-					   NEIGH_UPDATE_F_ADMIN);
-		}
-		if (n)
-			neigh_release(n);
+
+		err = neigh_update(n,
+				   lladdr_attr ? RTA_DATA(lladdr_attr) : NULL,
+				   ndm->ndm_state,
+				   (override ? NEIGH_UPDATE_F_OVERRIDE : 0) |
+				   NEIGH_UPDATE_F_ADMIN);
+
+		neigh_release(n);
 		goto out_dev_put;
 	}
 
