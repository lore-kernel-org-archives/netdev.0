From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/08: nf_conntrack: avoid additional compare.
Date: Thu,  3 Dec 2009 21:19:35 +0100 (MET)
Message-ID: <20091203201935.8831.34506.sendpatchset@x2.localnet>
References: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37697 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbZLCUT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:19:29 -0500
In-Reply-To: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5ae27aa2b16478a84d833ab4065798e752941c5a
Author: Changli Gao <xiaosuo@gmail.com>
Date:   Thu Nov 5 14:51:31 2009 +0100

    netfilter: nf_conntrack: avoid additional compare.
    
    Signed-off-by: Changli Gao <xiaosuo@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7c9ec3d..8e572d7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -511,11 +511,17 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 			cnt++;
 		}
 
-		if (ct && unlikely(nf_ct_is_dying(ct) ||
-				   !atomic_inc_not_zero(&ct->ct_general.use)))
-			ct = NULL;
-		if (ct || cnt >= NF_CT_EVICTION_RANGE)
+		if (ct != NULL) {
+			if (likely(!nf_ct_is_dying(ct) &&
+				   atomic_inc_not_zero(&ct->ct_general.use)))
+				break;
+			else
+				ct = NULL;
+		}
+
+		if (cnt >= NF_CT_EVICTION_RANGE)
 			break;
+
 		hash = (hash + 1) % nf_conntrack_htable_size;
 	}
 	rcu_read_unlock();
