From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 1/2] fib_trie: Avoid NULL pointer if local table is
 not allocated
Date: Thu, 12 Mar 2015 14:46:23 -0700
Message-ID: <20150312214623.1133.48565.stgit@ahduyck-vm-fedora20>
References: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Madhu Challa <challa@noironetworks.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756108AbbCLVq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 17:46:27 -0400
In-Reply-To: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function fib_unmerge assumed the local table had already been
allocated.  If that is not the case however when custom rules are applied
then this can result in a NULL pointer dereference.

In order to prevent this we must check the value of the local table pointer
and if it is NULL simply return 0 as there is no local table to separate
from the main.

Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")
Reported-by: Madhu Challa <challa@noironetworks.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_frontend.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c1caf9d..e5b6b05 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -156,9 +156,12 @@ int fib_unmerge(struct net *net)
 {
 	struct fib_table *old, *new;
 
+	/* attempt to fetch local table if it has been allocated */
 	old = fib_get_table(net, RT_TABLE_LOCAL);
-	new = fib_trie_unmerge(old);
+	if (!old)
+		return 0;
 
+	new = fib_trie_unmerge(old);
 	if (!new)
 		return -ENOMEM;
 
