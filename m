From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/18] netfilter: nf_conntrack: consolidate lock/unlock into unlock_wait
Date: Tue, 15 Mar 2016 02:28:02 +0100
Message-ID: <1458005282-24665-19-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33264 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487AbcCOB2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 21:28:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5F147114F54
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 515B7DA8F7
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 77C3FDA39B
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:33 +0100 (CET)
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <hofrat@osadl.org>

The spin_lock()/spin_unlock() is synchronizing on the
nf_conntrack_locks_all_lock which is equivalent to
spin_unlock_wait() but the later should be more efficient.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f60b4fd..afde5f5 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -74,8 +74,7 @@ void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
 	spin_lock(lock);
 	while (unlikely(nf_conntrack_locks_all)) {
 		spin_unlock(lock);
-		spin_lock(&nf_conntrack_locks_all_lock);
-		spin_unlock(&nf_conntrack_locks_all_lock);
+		spin_unlock_wait(&nf_conntrack_locks_all_lock);
 		spin_lock(lock);
 	}
 }
@@ -121,8 +120,7 @@ static void nf_conntrack_all_lock(void)
 	nf_conntrack_locks_all = true;
 
 	for (i = 0; i < CONNTRACK_LOCKS; i++) {
-		spin_lock(&nf_conntrack_locks[i]);
-		spin_unlock(&nf_conntrack_locks[i]);
+		spin_unlock_wait(&nf_conntrack_locks[i]);
 	}
 }
 
-- 
2.1.4
