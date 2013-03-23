From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH] bridge: fix crash when set mac address of br interface
Date: Sat, 23 Mar 2013 20:27:50 +0800
Message-ID: <1364041670-3408-1-git-send-email-honkiko@gmail.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	stephen@networkplumber.org, herbert@gondor.hengli.com.au,
	zhiguo.hong@emc.com, Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:56550 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab3CWM2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 08:28:09 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp2so3478444pbb.20
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 05:28:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I tried to set mac address of a bridge interface to a mac
address which already learned on this bridge, I got system hang.

The cause is straight forward: function br_fdb_change_mac_address
calls fdb_insert with NULL source nbp. Then an fdb lookup is
performed. If an fdb entry is found and it's local, it's OK. But
if it's not local, source is dereferenced for printk without NULL
check.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/bridge/br_fdb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 10b47d4..c581f12 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -421,7 +421,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 			return 0;
 		br_warn(br, "adding interface %s with same address "
 		       "as a received packet\n",
-		       source->dev->name);
+		       source ? source->dev->name : br->dev->name);
 		fdb_delete(br, fdb);
 	}
 
-- 
1.7.10.4
