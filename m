From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: [RFC PATCH] [XFRM]: Fix ordering issue in xfrm_dst_hash_transfer().
Date: Fri, 15 Feb 2008 13:24:24 +1100 (EST)
Message-ID: <20080215.132424.85799616.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, sdecugis@hongo.wide.ad.jp,
	kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46196 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735AbYBOCXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 21:23:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep ordering of policy entries with same selector in xfrm_dst_hash_transfer().

Issue should not appear in usual cases because multiple policy entries with
same selector are basically not allowed so far.
Bug was pointed out by Sebastien Decugis <sdecugis@hongo.wide.ad.jp>.

We could convert bydst from hlist to list and use list_add_tail() instead.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

----
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 47219f9..9fc4c31 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -331,15 +331,31 @@ static void xfrm_dst_hash_transfer(struct hlist_head *list,
 				   struct hlist_head *ndsttable,
 				   unsigned int nhashmask)
 {
-	struct hlist_node *entry, *tmp;
+	struct hlist_node *entry, *tmp, *entry0 = NULL;
 	struct xfrm_policy *pol;
+	unsigned int h0 = 0;
 
+redo:
 	hlist_for_each_entry_safe(pol, entry, tmp, list, bydst) {
 		unsigned int h;
 
 		h = __addr_hash(&pol->selector.daddr, &pol->selector.saddr,
 				pol->family, nhashmask);
-		hlist_add_head(&pol->bydst, ndsttable+h);
+		if (!entry0) {
+			hlist_del(entry);
+			hlist_add_head(&pol->bydst, ndsttable+h);
+			h0 = h;
+		} else {
+			if (h != h0)
+				continue;
+			hlist_del(entry);
+			hlist_add_after(entry0, &pol->bydst);
+		}
+		entry0 = entry;
+	}
+	if (!hlist_empty(list)) {
+		entry0 = NULL;
+		goto redo;
 	}
 }
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
