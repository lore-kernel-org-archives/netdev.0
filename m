From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 13:56:06 +0300
Message-ID: <1297680967-11893-1-git-send-email-segoon@openwall.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60909 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab1BNK4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 05:56:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_netdev() may be called with too long name (more that IFNAMSIZ bytes).
Currently this leads to BUG().  Other insane inputs (bad txqs, rxqs) and
even OOM don't lead to BUG().  Made alloc_netdev() return NULL, like on
other errors.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested.

 net/core/dev.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6392ea0..12ef4b0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5761,7 +5761,10 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	size_t alloc_size;
 	struct net_device *p;
 
-	BUG_ON(strlen(name) >= sizeof(dev->name));
+	if (strnlen(name, sizeof(dev->name)) >= sizeof(dev->name)) {
+		pr_err("alloc_netdev: Too long device name \n");
+		return NULL;
+	}
 
 	if (txqs < 1) {
 		pr_err("alloc_netdev: Unable to allocate device "
-- 
1.7.0.4

