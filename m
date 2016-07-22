From: fgao@ikuai8.com
Subject: [PATCH 1/1] netfilter: h323: Use mod_timer instead of set_expect_timeout
Date: Fri, 22 Jul 2016 12:59:15 +0800
Message-ID: <1469163555-13170-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

It could simplify the codes without any side effect.
The set_expect_timeout is used to modify the timer expired time.
It tries to delete timer, and add it again.
So we could use mod_timer directly.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Intial Patch

 net/netfilter/nf_conntrack_h323_main.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 9511af0..bb77a97 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1273,19 +1273,6 @@ static struct nf_conntrack_expect *find_expect(struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int set_expect_timeout(struct nf_conntrack_expect *exp,
-			      unsigned int timeout)
-{
-	if (!exp || !del_timer(&exp->timeout))
-		return 0;
-
-	exp->timeout.expires = jiffies + timeout * HZ;
-	add_timer(&exp->timeout);
-
-	return 1;
-}
-
-/****************************************************************************/
 static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff, unsigned char **data,
@@ -1486,7 +1473,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 				 "timeout to %u seconds for",
 				 info->timeout);
 			nf_ct_dump_tuple(&exp->tuple);
-			set_expect_timeout(exp, info->timeout);
+			mod_timer(&exp->timeout, jiffies + info->timeout * HZ);
 		}
 		spin_unlock_bh(&nf_conntrack_expect_lock);
 	}
-- 
1.9.1


