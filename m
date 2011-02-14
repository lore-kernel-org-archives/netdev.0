From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH v2] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 17:42:58 +0300
Message-ID: <1297694579-23611-1-git-send-email-segoon@openwall.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_netdev() may be called with too long name (more that IFNAMSIZ bytes).
Currently this leads to BUG().  Other insane inputs (bad txqs, rxqs) and
even OOM don't lead to BUG().  Made alloc_netdev() return NULL, like on
other errors.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested.
 v2 - fixed checkpatch warning - space before "\n".

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
+		pr_err("alloc_netdev: Too long device name\n");
+		return NULL;
+	}
 
 	if (txqs < 1) {
 		pr_err("alloc_netdev: Unable to allocate device "
-- 
1.7.0.4
