From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net neigh: neigh_delete() and neigh_add() changes
Date: Mon, 04 Oct 2010 16:27:36 +0200
Message-ID: <1286202456.18293.293.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41496 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab0JDO1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 10:27:43 -0400
Received: by fxm14 with SMTP id 14so1761896fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 07:27:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

neigh_delete() and neigh_add() dont need to touch device refcount,
we hold RTNL when calling them, so device cannot disappear under us.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/neighbour.c |   39 +++++++++++++++++----------------------
 1 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b142a0d..d6996e0 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1531,6 +1531,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct net_device *dev = NULL;
 	int err = -EINVAL;
 
+	ASSERT_RTNL();
 	if (nlmsg_len(nlh) < sizeof(*ndm))
 		goto out;
 
@@ -1540,7 +1541,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex) {
-		dev = dev_get_by_index(net, ndm->ndm_ifindex);
+		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto out;
@@ -1556,34 +1557,31 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		read_unlock(&neigh_tbl_lock);
 
 		if (nla_len(dst_attr) < tbl->key_len)
-			goto out_dev_put;
+			goto out;
 
 		if (ndm->ndm_flags & NTF_PROXY) {
 			err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
-			goto out_dev_put;
+			goto out;
 		}
 
 		if (dev == NULL)
-			goto out_dev_put;
+			goto out;
 
 		neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
 		if (neigh == NULL) {
 			err = -ENOENT;
-			goto out_dev_put;
+			goto out;
 		}
 
 		err = neigh_update(neigh, NULL, NUD_FAILED,
 				   NEIGH_UPDATE_F_OVERRIDE |
 				   NEIGH_UPDATE_F_ADMIN);
 		neigh_release(neigh);
-		goto out_dev_put;
+		goto out;
 	}
 	read_unlock(&neigh_tbl_lock);
 	err = -EAFNOSUPPORT;
 
-out_dev_put:
-	if (dev)
-		dev_put(dev);
 out:
 	return err;
 }
@@ -1597,6 +1595,7 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct net_device *dev = NULL;
 	int err;
 
+	ASSERT_RTNL();
 	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
 	if (err < 0)
 		goto out;
@@ -1607,14 +1606,14 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex) {
-		dev = dev_get_by_index(net, ndm->ndm_ifindex);
+		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto out;
 		}
 
 		if (tb[NDA_LLADDR] && nla_len(tb[NDA_LLADDR]) < dev->addr_len)
-			goto out_dev_put;
+			goto out;
 	}
 
 	read_lock(&neigh_tbl_lock);
@@ -1628,7 +1627,7 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		read_unlock(&neigh_tbl_lock);
 
 		if (nla_len(tb[NDA_DST]) < tbl->key_len)
-			goto out_dev_put;
+			goto out;
 		dst = nla_data(tb[NDA_DST]);
 		lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
 
@@ -1641,29 +1640,29 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 				pn->flags = ndm->ndm_flags;
 				err = 0;
 			}
-			goto out_dev_put;
+			goto out;
 		}
 
 		if (dev == NULL)
-			goto out_dev_put;
+			goto out;
 
 		neigh = neigh_lookup(tbl, dst, dev);
 		if (neigh == NULL) {
 			if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
 				err = -ENOENT;
-				goto out_dev_put;
+				goto out;
 			}
 
 			neigh = __neigh_lookup_errno(tbl, dst, dev);
 			if (IS_ERR(neigh)) {
 				err = PTR_ERR(neigh);
-				goto out_dev_put;
+				goto out;
 			}
 		} else {
 			if (nlh->nlmsg_flags & NLM_F_EXCL) {
 				err = -EEXIST;
 				neigh_release(neigh);
-				goto out_dev_put;
+				goto out;
 			}
 
 			if (!(nlh->nlmsg_flags & NLM_F_REPLACE))
@@ -1676,15 +1675,11 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		} else
 			err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
 		neigh_release(neigh);
-		goto out_dev_put;
+		goto out;
 	}
 
 	read_unlock(&neigh_tbl_lock);
 	err = -EAFNOSUPPORT;
-
-out_dev_put:
-	if (dev)
-		dev_put(dev);
 out:
 	return err;
 }


