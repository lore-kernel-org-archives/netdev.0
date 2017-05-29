From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: nft_set_rbtree: handle element re-addition after deletion
Date: Mon, 29 May 2017 13:34:30 +0200
Message-ID: <1496057672-6751-3-git-send-email-pablo@netfilter.org>
References: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53130 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751187AbdE2Lew (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 07:34:52 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 96753303D0C
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 85A34100A45
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2FE921850F
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:39 +0200 (CEST)
In-Reply-To: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing code selects no next branch to be inspected when
re-inserting an inactive element into the rb-tree, looping endlessly.
This patch restricts the check for active elements to the EEXIST case
only.

Fixes: e701001e7cbe ("netfilter: nft_rbtree: allow adjacent intervals with dynamic updates")
Reported-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
Tested-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_rbtree.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index e97e2fb53f0a..fbdbaa00dd5f 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -116,17 +116,17 @@ static int __nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 		else if (d > 0)
 			p = &parent->rb_right;
 		else {
-			if (nft_set_elem_active(&rbe->ext, genmask)) {
-				if (nft_rbtree_interval_end(rbe) &&
-				    !nft_rbtree_interval_end(new))
-					p = &parent->rb_left;
-				else if (!nft_rbtree_interval_end(rbe) &&
-					 nft_rbtree_interval_end(new))
-					p = &parent->rb_right;
-				else {
-					*ext = &rbe->ext;
-					return -EEXIST;
-				}
+			if (nft_rbtree_interval_end(rbe) &&
+			    !nft_rbtree_interval_end(new)) {
+				p = &parent->rb_left;
+			} else if (!nft_rbtree_interval_end(rbe) &&
+				   nft_rbtree_interval_end(new)) {
+				p = &parent->rb_right;
+			} else if (nft_set_elem_active(&rbe->ext, genmask)) {
+				*ext = &rbe->ext;
+				return -EEXIST;
+			} else {
+				p = &parent->rb_left;
 			}
 		}
 	}
-- 
2.1.4
