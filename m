From: martinbj2008@gmail.com
Subject: [PATCH V2 net-next] net: only check perm protocol when register proto
Date: Fri, 18 Sep 2015 00:00:05 -0400
Message-ID: <1442548805-5489-1-git-send-email-martinbj2008@gmail.com>
References: <20150917.162041.2147817140272126896.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Junwei Zhang <martinbj2008@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150917.162041.2147817140272126896.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Junwei Zhang <martinbj2008@gmail.com>

The permanent protocol nodes are at the head of the list,
So only need check all these nodes.

No matter the new node is permanent or not,
insert the new node after the last permanent protocol node,

If the new node conflicts with existing permanent node,
return error.

Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
---
V2: Fix indentation
    rewrite statement
 
 net/ipv4/af_inet.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1d0c3ad..8a55664 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1043,22 +1043,16 @@ void inet_register_protosw(struct inet_protosw *p)
 		goto out_illegal;
 
 	/* If we are trying to override a permanent protocol, bail. */
-	answer = NULL;
 	last_perm = &inetsw[p->type];
 	list_for_each(lh, &inetsw[p->type]) {
 		answer = list_entry(lh, struct inet_protosw, list);
-
 		/* Check only the non-wild match. */
-		if (INET_PROTOSW_PERMANENT & answer->flags) {
-			if (protocol == answer->protocol)
-				break;
-			last_perm = lh;
-		}
-
-		answer = NULL;
+		if ((INET_PROTOSW_PERMANENT & answer->flags) == 0)
+			break;
+		if (protocol == answer->protocol)
+			goto out_permanent;
+		last_perm = lh;
 	}
-	if (answer)
-		goto out_permanent;
 
 	/* Add the new entry after the last permanent entry if any, so that
 	 * the new entry does not override a permanent entry when matched with
-- 
2.1.4
