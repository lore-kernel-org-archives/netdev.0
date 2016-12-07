From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 48/50] netfilter: x_tables: avoid warn and OOM killer on vmalloc call
Date: Wed,  7 Dec 2016 22:52:54 +0100
Message-ID: <1481147576-5690-49-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60216 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933427AbcLGVyA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:54:00 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 986C732F
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7D766DA851
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 67662DA860
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:57 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Andrey Konovalov reported that this vmalloc call is based on an
userspace request and that it's spewing traces, which may flood the logs
and cause DoS if abused.

Florian Westphal also mentioned that this call should not trigger OOM
killer.

This patch brings the vmalloc call in sync to kmalloc and disables the
warn trace on allocation failure and also disable OOM killer invocation.

Note, however, that under such stress situation, other places may
trigger OOM killer invocation.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index f6ce4a7036e6..2ff499680cc6 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -959,7 +959,9 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
 	if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
 		info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
 	if (!info) {
-		info = vmalloc(sz);
+		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN |
+				     __GFP_NORETRY | __GFP_HIGHMEM,
+				 PAGE_KERNEL);
 		if (!info)
 			return NULL;
 	}
-- 
2.1.4
