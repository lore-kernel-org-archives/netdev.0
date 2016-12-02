From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2] netfilter: avoid warn and OOM killer on vmalloc call
Date: Fri,  2 Dec 2016 07:46:38 -0200
Message-ID: <e10fd8b5206bfde5526e3bbf2b5ff9af584b0a6f.1480671893.git.marcelo.leitner@gmail.com>
Cc: fw@strlen.de, nhorman@tuxdriver.com,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: andreyknvl@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 net/netfilter/x_tables.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index fc4977456c30e098197b4f987b758072c9cf60d9..dece525bf83a0098dad607fce665cd0bde228362 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -958,7 +958,9 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
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
2.9.3
