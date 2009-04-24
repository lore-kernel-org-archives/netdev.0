From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: [PATCH] xfrm: wrong hash value for temporary SA
Date: Fri, 24 Apr 2009 11:55:38 +0200
Message-ID: <49F18C9A.40207@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010507090109080806020309"
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:52867 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116AbZDXJzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 05:55:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010507090109080806020309
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

When kernel inserts a temporary SA for IKE, it uses the wrong hash value for dst
list. Two hash values were calcultated before: one with source address and one
with a wildcard source address.

Bug hinted by Junwei Zhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

--------------010507090109080806020309
Content-Type: text/x-diff;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 62a5425..6ccc3cd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -794,7 +794,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 {
 	static xfrm_address_t saddr_wildcard = { };
 	struct net *net = xp_net(pol);
-	unsigned int h;
+	unsigned int h, h_wildcard;
 	struct hlist_node *entry;
 	struct xfrm_state *x, *x0, *to_put;
 	int acquire_in_progress = 0;
@@ -819,8 +819,8 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	if (best)
 		goto found;
 
-	h = xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, family);
-	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
+	h_wildcard = xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, family);
+	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h_wildcard, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&

--------------010507090109080806020309--
