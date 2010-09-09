From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tunnels: missing rcu_assign_pointer()
Date: Thu, 09 Sep 2010 17:33:43 +0200
Message-ID: <1284046423.2589.188.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52279 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170Ab0IIPdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 11:33:49 -0400
Received: by fxm16 with SMTP id 16so964398fxm.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 08:33:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm4_tunnel_register() & xfrm6_tunnel_register() should
use rcu_assign_pointer() to make sure previous writes
(to handler->next) are committed to memory before chain
insertion.

deregister functions dont need a particular barrier.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
No risk of crash, because handler->next is NULL before register()
call, but a possibility of packet being dropped.

 net/ipv4/tunnel4.c |    2 +-
 net/ipv6/tunnel6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index df59d16..9a17bd2 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -39,7 +39,7 @@ int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family)
 	}
 
 	handler->next = *pprev;
-	*pprev = handler;
+	rcu_assign_pointer(*pprev, handler);
 
 	ret = 0;
 
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 3177fe0..d986472 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -51,7 +51,7 @@ int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family)
 	}
 
 	handler->next = *pprev;
-	*pprev = handler;
+	rcu_assign_pointer(*pprev, handler);
 
 	ret = 0;
 


