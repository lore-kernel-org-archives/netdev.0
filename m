From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_ns: add __rcu annotations
Date: Mon, 25 Oct 2010 15:20:11 +0200
Message-ID: <1288012811.2826.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51400 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab0JYNUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 09:20:16 -0400
Received: by wwe15 with SMTP id 15so3479253wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 06:20:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add __rcu annotation to (struct net)->gen, and use
rcu_dereference_protected() in net_assign_generic()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/net_namespace.h |    2 +-
 net/core/net_namespace.c    |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 65af9a0..1bf812b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -88,7 +88,7 @@ struct net {
 #ifdef CONFIG_WEXT_CORE
 	struct sk_buff_head	wext_nlevents;
 #endif
-	struct net_generic	*gen;
+	struct net_generic __rcu	*gen;
 
 	/* Note : following structs are cache line aligned */
 #ifdef CONFIG_XFRM
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index c988e68..3f86026 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -42,7 +42,9 @@ static int net_assign_generic(struct net *net, int id, void *data)
 	BUG_ON(!mutex_is_locked(&net_mutex));
 	BUG_ON(id == 0);
 
-	ng = old_ng = net->gen;
+	old_ng = rcu_dereference_protected(net->gen,
+					   lockdep_is_held(&net_mutex));
+	ng = old_ng;
 	if (old_ng->len >= id)
 		goto assign;
 


