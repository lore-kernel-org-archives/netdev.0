From: martinbj2008@gmail.com
Subject: [PATCH V1 net-next] net: only check perm protocol when register proto
Date: Tue, 15 Sep 2015 08:14:05 +0800
Message-ID: <1442276045-4233-1-git-send-email-martinbj2008@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	baker.kernel@gmail.com, Junwei Zhang <martinbj2008@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Junwei Zhang <martinbj2008@gmail.com>

the permanent protocol nodes are at the head of the list.
So only need check all these nodes.

and insert the new node after the last permanent protocol node,
no matter new node is permanent or not.

If the inserted proto conflicts with existing permanent protocol,
then goto out_permanent immediately.

Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
---
 net/ipv4/af_inet.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1d0c3ad..c61e0b5 100644
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
+		if ((INET_PROTOSW_PERMANENT & answer->flags) == 0)
 				break;
-			last_perm = lh;
-		}
-
-		answer = NULL;
+		if (protocol == answer->protocol)
+			goto out_permanent;
+		last_perm = lh;
 	}
-	if (answer)
-		goto out_permanent;
 
 	/* Add the new entry after the last permanent entry if any, so that
 	 * the new entry does not override a permanent entry when matched with
-- 
1.8.3.1
