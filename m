From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [PATCH] net: dsa: fix unbalanced dsa_switch_tree reference counting
Date: Fri, 25 Nov 2016 19:08:53 +0300
Message-ID: <1480090133-30412-1-git-send-email-nikita.yoush@cogentembedded.com>
Cc: Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        John Crispin <john@phrozen.org>,
        Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35040 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754878AbcKYQJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 11:09:39 -0500
Received: by mail-lf0-f41.google.com with SMTP id b14so53770427lfg.2
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 08:09:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
