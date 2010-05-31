From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] netfilter: don't xt_jumpstack_alloc twice in xt_register_table
Date: Mon, 31 May 2010 19:06:38 +0800
Message-ID: <1275303998-2435-1-git-send-email-dfeng@redhat.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Xiaotian Feng <dfeng@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab0EaLHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 07:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xt_register_table, xt_jumpstack_alloc is called first, later
xt_replace_table is used. But in xt_replace_table, xt_jumpstack_alloc
will be used again. Then the memory allocated by previous xt_jumpstack_alloc
will be leaked. We can simply remove the previous xt_jumpstack_alloc because
there aren't any users of newinfo between xt_jumpstack_alloc and
xt_replace_table.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jan Engelhardt <jengelh@medozas.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/netfilter/x_tables.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 445de70..47b1e79 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -844,10 +844,6 @@ struct xt_table *xt_register_table(struct net *net,
 	struct xt_table_info *private;
 	struct xt_table *t, *table;
 
-	ret = xt_jumpstack_alloc(newinfo);
-	if (ret < 0)
-		return ERR_PTR(ret);
-
 	/* Don't add one object to multiple lists. */
 	table = kmemdup(input_table, sizeof(struct xt_table), GFP_KERNEL);
 	if (!table) {
-- 
1.7.0.1

