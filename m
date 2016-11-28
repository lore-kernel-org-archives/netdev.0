From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [patch net] net: dsa: fix unbalanced dsa_switch_tree reference counting
Date: Mon, 28 Nov 2016 09:48:48 +0300
Message-ID: <1480315728-23398-1-git-send-email-nikita.yoush@cogentembedded.com>
Cc: Chris Healy <cphealy@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        linux-kernel@vger.kernel.org,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

_dsa_register_switch() gets a dsa_switch_tree object either via
dsa_get_dst() or via dsa_add_dst(). Former path does not increase kref
in returned object (resulting into caller not owning a reference),
while later path does create a new object (resulting into caller owning
a reference).

The rest of _dsa_register_switch() assumes that it owns a reference, and
calls dsa_put_dst().

This causes a memory breakage if first switch in the tree initialized
successfully, but second failed to initialize. In particular, freed
dsa_swith_tree object is left referenced by switch that was initialized,
and later access to sysfs attributes of that switch cause OOPS.

To fix, need to add kref_get() call to dsa_get_dst().

Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa2.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index f8a7d9aab437..5fff951a0a49 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -28,8 +28,10 @@ static struct dsa_switch_tree *dsa_get_dst(u32 tree)
 	struct dsa_switch_tree *dst;
 
 	list_for_each_entry(dst, &dsa_switch_trees, list)
-		if (dst->tree == tree)
+		if (dst->tree == tree) {
+			kref_get(&dst->refcount);
 			return dst;
+		}
 	return NULL;
 }
 
-- 
2.1.4
