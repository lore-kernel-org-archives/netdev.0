From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 4/6] net: Fill in extack for mpls lwt encap
Date: Wed, 24 May 2017 21:54:40 -0600
Message-ID: <20170525035442.51407-5-dsahern@gmail.com>
References: <20170525035442.51407-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36404 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941523AbdEYDyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 23:54:55 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so36328764pfb.3
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 20:54:54 -0700 (PDT)
In-Reply-To: <20170525035442.51407-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fill in extack for errors in build_state for mpls lwt encap including
passing extack to nla_get_labels and adding error messages for failures
in it.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/mpls/af_mpls.c       | 49 ++++++++++++++++++++++++++++++++++++++----------
 net/mpls/internal.h      |  2 +-
 net/mpls/mpls_iptunnel.c | 12 +++++++-----
 3 files changed, 47 insertions(+), 16 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 257ec66009da..f3830951fb1c 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -728,8 +728,8 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 		goto errout;
 
 	if (newdst) {
-		err = nla_get_labels(newdst, max_labels,
-				     &nh->nh_labels, nh->nh_label);
+		err = nla_get_labels(newdst, max_labels, &nh->nh_labels,
+				     nh->nh_label, NULL);
 		if (err)
 			goto errout;
 	}
@@ -782,7 +782,8 @@ static u8 mpls_count_nexthops(struct rtnexthop *rtnh, int len,
 
 		nla = nla_find(attrs, attrlen, RTA_NEWDST);
 		if (nla &&
-		    nla_get_labels(nla, MAX_NEW_LABELS, &n_labels, NULL) != 0)
+		    nla_get_labels(nla, MAX_NEW_LABELS, &n_labels,
+				   NULL, NULL) != 0)
 			return 0;
 
 		*max_labels = max_t(u8, *max_labels, n_labels);
@@ -1541,8 +1542,8 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,
 }
 EXPORT_SYMBOL_GPL(nla_put_labels);
 
-int nla_get_labels(const struct nlattr *nla,
-		   u8 max_labels, u8 *labels, u32 label[])
+int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
+		   u32 label[], struct netlink_ext_ack *extack)
 {
 	unsigned len = nla_len(nla);
 	struct mpls_shim_hdr *nla_label;
@@ -1553,13 +1554,18 @@ int nla_get_labels(const struct nlattr *nla,
 	/* len needs to be an even multiple of 4 (the label size). Number
 	 * of labels is a u8 so check for overflow.
 	 */
-	if (len & 3 || len / 4 > 255)
+	if (len & 3 || len / 4 > 255) {
+		NL_SET_ERR_MSG_ATTR(extack, nla,
+				    "Invalid length for labels attribute");
 		return -EINVAL;
+	}
 
 	/* Limit the number of new labels allowed */
 	nla_labels = len/4;
-	if (nla_labels > max_labels)
+	if (nla_labels > max_labels) {
+		NL_SET_ERR_MSG(extack, "Too many labels");
 		return -EINVAL;
+	}
 
 	/* when label == NULL, caller wants number of labels */
 	if (!label)
@@ -1574,8 +1580,29 @@ int nla_get_labels(const struct nlattr *nla,
 		/* Ensure the bottom of stack flag is properly set
 		 * and ttl and tc are both clear.
 		 */
-		if ((dec.bos != bos) || dec.ttl || dec.tc)
+		if (dec.ttl) {
+			NL_SET_ERR_MSG_ATTR(extack, nla,
+					    "TTL in label must be 0");
+			return -EINVAL;
+		}
+
+		if (dec.tc) {
+			NL_SET_ERR_MSG_ATTR(extack, nla,
+					    "Traffic class in label must be 0");
 			return -EINVAL;
+		}
+
+		if (dec.bos != bos) {
+			NL_SET_BAD_ATTR(extack, nla);
+			if (bos) {
+				NL_SET_ERR_MSG(extack,
+					       "BOS bit must be set in first label");
+			} else {
+				NL_SET_ERR_MSG(extack,
+					       "BOS bit can only be set in first label");
+			}
+			return -EINVAL;
+		}
 
 		switch (dec.label) {
 		case MPLS_LABEL_IMPLNULL:
@@ -1583,6 +1610,8 @@ int nla_get_labels(const struct nlattr *nla,
 			 * assign and distribute, but which never
 			 * actually appears in the encapsulation.
 			 */
+			NL_SET_ERR_MSG_ATTR(extack, nla,
+					    "Implicit NULL Label (3) can not be used in encapsulation");
 			return -EINVAL;
 		}
 
@@ -1696,14 +1725,14 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		case RTA_NEWDST:
 			if (nla_get_labels(nla, MAX_NEW_LABELS,
 					   &cfg->rc_output_labels,
-					   cfg->rc_output_label))
+					   cfg->rc_output_label, NULL))
 				goto errout;
 			break;
 		case RTA_DST:
 		{
 			u8 label_count;
 			if (nla_get_labels(nla, 1, &label_count,
-					   &cfg->rc_label))
+					   &cfg->rc_label, NULL))
 				goto errout;
 
 			/* Reserved labels may not be set */
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 4db6a5971322..e59f299ceb3f 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -203,7 +203,7 @@ static inline struct mpls_dev *mpls_dev_get(const struct net_device *dev)
 int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
-		   u32 label[]);
+		   u32 label[], struct netlink_ext_ack *extack);
 int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
 		u8 via[]);
 bool mpls_output_possible(const struct net_device *dev);
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 15e1aa708e50..6e558a419f60 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -173,13 +173,14 @@ static int mpls_build_state(struct nlattr *nla,
 	if (ret < 0)
 		return ret;
 
-	if (!tb[MPLS_IPTUNNEL_DST])
+	if (!tb[MPLS_IPTUNNEL_DST]) {
+		NL_SET_ERR_MSG(extack, "MPLS_IPTUNNEL_DST attribute is missing");
 		return -EINVAL;
-
+	}
 
 	/* determine number of labels */
-	if (nla_get_labels(tb[MPLS_IPTUNNEL_DST],
-			   MAX_NEW_LABELS, &n_labels, NULL))
+	if (nla_get_labels(tb[MPLS_IPTUNNEL_DST], MAX_NEW_LABELS,
+			   &n_labels, NULL, extack))
 		return -EINVAL;
 
 	newts = lwtunnel_state_alloc(sizeof(*tun_encap_info) +
@@ -189,7 +190,8 @@ static int mpls_build_state(struct nlattr *nla,
 
 	tun_encap_info = mpls_lwtunnel_encap(newts);
 	ret = nla_get_labels(tb[MPLS_IPTUNNEL_DST], n_labels,
-			     &tun_encap_info->labels, tun_encap_info->label);
+			     &tun_encap_info->labels, tun_encap_info->label,
+			     extack);
 	if (ret)
 		goto errout;
 
-- 
2.11.0 (Apple Git-81)
