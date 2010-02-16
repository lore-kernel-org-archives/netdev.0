From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 11/62: xt_connlimit: netns support
Date: Tue, 16 Feb 2010 15:55:35 +0100 (MET)
Message-ID: <20100216145532.2796.28088.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51974 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264Ab0BPOzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:36 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 83fc81024bd8572f31db784f8c0079e999a4fa44
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Jan 18 08:07:50 2010 +0100

    netfilter: xt_connlimit: netns support
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 8103bef..0d9d18e 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -90,7 +90,8 @@ same_source_net(const union nf_inet_addr *addr,
 	}
 }
 
-static int count_them(struct xt_connlimit_data *data,
+static int count_them(struct net *net,
+		      struct xt_connlimit_data *data,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr,
 		      const union nf_inet_addr *mask,
@@ -113,7 +114,7 @@ static int count_them(struct xt_connlimit_data *data,
 
 	/* check the saved connections */
 	list_for_each_entry_safe(conn, tmp, hash, list) {
-		found    = nf_conntrack_find_get(&init_net, &conn->tuple);
+		found    = nf_conntrack_find_get(net, &conn->tuple);
 		found_ct = NULL;
 
 		if (found != NULL)
@@ -171,6 +172,7 @@ static int count_them(struct xt_connlimit_data *data,
 static bool
 connlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
+	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct xt_connlimit_info *info = par->matchinfo;
 	union nf_inet_addr addr;
 	struct nf_conntrack_tuple tuple;
@@ -195,7 +197,7 @@ connlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	}
 
 	spin_lock_bh(&info->data->lock);
-	connections = count_them(info->data, tuple_ptr, &addr,
+	connections = count_them(net, info->data, tuple_ptr, &addr,
 	                         &info->mask, par->family);
 	spin_unlock_bh(&info->data->lock);
 
