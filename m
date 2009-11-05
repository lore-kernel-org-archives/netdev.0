From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/02: xt_connlimit: fix regression caused by zero family
 value
Date: Thu, 05 Nov 2009 19:23:20 +0100
Message-ID: <4AF31818.3030103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080807020005010303030407"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42152 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758158AbZKESXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 13:23:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080807020005010303030407
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080807020005010303030407
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 0b3645af59740e4da29a18b96d8eaf68ddd2cea4
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Nov 5 15:02:25 2009 +0100

    netfilter: xt_connlimit: fix regression caused by zero family value
    
    Commit v2.6.28-rc1~7172~1092~2 was slightly incomplete; not all
    instances of par->match->family were changed to par->family.
    
    Netfilter bugzilla #610.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 6809809..38f03f7 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -103,7 +103,7 @@ static int count_them(struct xt_connlimit_data *data,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr,
 		      const union nf_inet_addr *mask,
-		      const struct xt_match *match)
+		      u_int8_t family)
 {
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
@@ -113,8 +113,7 @@ static int count_them(struct xt_connlimit_data *data,
 	bool addit = true;
 	int matches = 0;
 
-
-	if (match->family == NFPROTO_IPV6)
+	if (family == NFPROTO_IPV6)
 		hash = &data->iphash[connlimit_iphash6(addr, mask)];
 	else
 		hash = &data->iphash[connlimit_iphash(addr->ip & mask->ip)];
@@ -157,8 +156,7 @@ static int count_them(struct xt_connlimit_data *data,
 			continue;
 		}
 
-		if (same_source_net(addr, mask, &conn->tuple.src.u3,
-		    match->family))
+		if (same_source_net(addr, mask, &conn->tuple.src.u3, family))
 			/* same source network -> be counted! */
 			++matches;
 		nf_ct_put(found_ct);
@@ -207,7 +205,7 @@ connlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 	spin_lock_bh(&info->data->lock);
 	connections = count_them(info->data, tuple_ptr, &addr,
-	                         &info->mask, par->match);
+	                         &info->mask, par->family);
 	spin_unlock_bh(&info->data->lock);
 
 	if (connections < 0) {

--------------080807020005010303030407--
