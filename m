From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] route: put lwstate before freeing dst to avoid use after free
Date: Tue, 25 Aug 2015 14:25:14 -0400
Message-ID: <1440527114-12746-1-git-send-email-sasha.levin@oracle.com>
Cc: jbenc@redhat.com, roopa@cumulusnetworks.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35116 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246AbbHYSZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:25:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 61adedf3 ("route: move lwtunnel state to dst_entry") is trying to
release lwstate after getting rid of dst, which causes a use-after-free
trying to access dst->lwstate.

Fixes: 61adedf3 ("route: move lwtunnel state to dst_entry")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/core/dst.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 50dcdbb..477035e 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -262,11 +262,12 @@ again:
 	if (dst->dev)
 		dev_put(dst->dev);
 
+	lwtstate_put(dst->lwtstate);
+
 	if (dst->flags & DST_METADATA)
 		kfree(dst);
 	else
 		kmem_cache_free(dst->ops->kmem_cachep, dst);
-	lwtstate_put(dst->lwtstate);
 
 	dst = child;
 	if (dst) {
-- 
1.7.10.4
