From: roopa@cumulusnetworks.com
Subject: [PATCH net-next RFC] ipv4 neigh: match add/del dev lookup behaviour to SIOCSARP/SIOCDARP
Date: Mon, 23 Feb 2015 21:42:52 -0800
Message-ID: <1424756572-29379-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org
To: hadi@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42964 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbbBXFm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 00:42:58 -0500
Received: by padhz1 with SMTP id hz1so33370610pad.9
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 21:42:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Today neigh adds and dels using the netlink RTM_NEWNEIGH/RTM_DELNEIGH
messages require dst device to be specified. The equivalent ipv4 neigh
entry add/del using SIOCSARP/SIOCDARP does not require a device. It finds
the dst dev by doing a route lookup (ip_route_output).

This patch tries to match netlink ipv4 neigh add/del behaviour with
SIOCSARP/SIOCDARP for the case where user does not specify a device.
If user has not specified a dst device, it looks for the device via a
route lookup. If the route lookup fails, the behaviour is unchanged,
the user will get an -EINVAL as before
(This can be changed to return -ENODEV if needed. This patch leaves it at
-EINVAL to match current behaviour).

Testing this change requires an iproute2 patch to make dev optional
during ipv4 neigh adds/dels.

Reported-by: Jamal Hadi Salim <hadi@mojatatu.com>
Suggested-by: Jamal Hadi Salim <hadi@mojatatu.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/neighbour.c |   54 +++++++++++++++++++++++++++++++++-----------------
 1 file changed, 36 insertions(+), 18 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 70fe9e1..3fa2602 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -29,6 +29,7 @@
 #endif
 #include <linux/times.h>
 #include <net/net_namespace.h>
+#include <net/route.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/sock.h>
@@ -1622,6 +1623,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct neighbour *neigh;
 	struct net_device *dev = NULL;
 	int err = -EINVAL;
+	void *dst;
 
 	ASSERT_RTNL();
 	if (nlmsg_len(nlh) < sizeof(*ndm))
@@ -1632,30 +1634,39 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto out;
 
 	ndm = nlmsg_data(nlh);
+	tbl = neigh_find_table(ndm->ndm_family);
+	if (tbl == NULL)
+		return -EAFNOSUPPORT;
+
+	if (nla_len(dst_attr) < tbl->key_len)
+		goto out;
+
+	dst = nla_data(dst_attr);
 	if (ndm->ndm_ifindex) {
 		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto out;
 		}
-	}
+	} else if (ndm->ndm_family == AF_INET) {
+		struct rtable *rt;
 
-	tbl = neigh_find_table(ndm->ndm_family);
-	if (tbl == NULL)
-		return -EAFNOSUPPORT;
-
-	if (nla_len(dst_attr) < tbl->key_len)
-		goto out;
+		rt =  ip_route_output(net, *(__be32 *)dst, 0, RTO_ONLINK, 0);
+		if (!IS_ERR(rt)) {
+			dev = rt->dst.dev;
+			ip_rt_put(rt);
+		}
+	}
 
 	if (ndm->ndm_flags & NTF_PROXY) {
-		err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
+		err = pneigh_delete(tbl, net, dst, dev);
 		goto out;
 	}
 
 	if (dev == NULL)
 		goto out;
 
-	neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
+	neigh = neigh_lookup(tbl, dst, dev);
 	if (neigh == NULL) {
 		err = -ENOENT;
 		goto out;
@@ -1692,24 +1703,31 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto out;
 
 	ndm = nlmsg_data(nlh);
+	tbl = neigh_find_table(ndm->ndm_family);
+	if (tbl == NULL)
+		return -EAFNOSUPPORT;
+
+	if (nla_len(tb[NDA_DST]) < tbl->key_len)
+		goto out;
+
+	dst = nla_data(tb[NDA_DST]);
 	if (ndm->ndm_ifindex) {
 		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto out;
 		}
+	} else if (ndm->ndm_family == AF_INET) {
+		struct rtable *rt;
 
-		if (tb[NDA_LLADDR] && nla_len(tb[NDA_LLADDR]) < dev->addr_len)
-			goto out;
+		rt =  ip_route_output(net, *(__be32 *)dst, 0, RTO_ONLINK, 0);
+		if (!IS_ERR(rt)) {
+			dev = rt->dst.dev;
+			ip_rt_put(rt);
+		}
 	}
-
-	tbl = neigh_find_table(ndm->ndm_family);
-	if (tbl == NULL)
-		return -EAFNOSUPPORT;
-
-	if (nla_len(tb[NDA_DST]) < tbl->key_len)
+	if (dev && tb[NDA_LLADDR] && nla_len(tb[NDA_LLADDR]) < dev->addr_len)
 		goto out;
-	dst = nla_data(tb[NDA_DST]);
 	lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
 
 	if (ndm->ndm_flags & NTF_PROXY) {
-- 
1.7.10.4
