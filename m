From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tc: oops in em_meta
Date: Fri, 25 Jan 2008 15:00:57 -0800
Message-ID: <20080125150057.41776614@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50652 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760709AbYAYXBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 18:01:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If userspace passes a unknown match index into em_meta, then em_meta_change
will return an error and the data for the match will not be set. This then
causes an null pointer dereference when the cleanup is done in the error
path via tcf_em_tree_destroy. Since the tree structure comes kzalloc,
it is initialized to NULL.

Discovered when testing a new version of tc command against an accidental
older kernel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---

Patch against net-2.6.25 tree, should be backported to earlier
stable kernels as well.

--- a/net/sched/em_meta.c	2008-01-25 14:52:08.000000000 -0800
+++ b/net/sched/em_meta.c	2008-01-25 14:52:26.000000000 -0800
@@ -735,11 +735,13 @@ static int em_meta_match(struct sk_buff 
 
 static inline void meta_delete(struct meta_match *meta)
 {
-	struct meta_type_ops *ops = meta_type_ops(&meta->lvalue);
+	if (meta) {
+		struct meta_type_ops *ops = meta_type_ops(&meta->lvalue);
 
-	if (ops && ops->destroy) {
-		ops->destroy(&meta->lvalue);
-		ops->destroy(&meta->rvalue);
+		if (ops && ops->destroy) {
+			ops->destroy(&meta->lvalue);
+			ops->destroy(&meta->rvalue);
+		}
 	}
 
 	kfree(meta);
