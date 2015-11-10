From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix a race in dst_release()
Date: Mon, 09 Nov 2015 17:51:23 -0800
Message-ID: <1447120283.17135.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Greg Thelen <gthelen@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33239 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbKJBvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 20:51:25 -0500
Received: by pabfh17 with SMTP id fh17so217567109pab.0
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 17:51:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Only cpu seeing dst refcount going to 0 can safely
dereference dst->flags. 

Otherwise an other cpu might already have freed the dst.

Fixes: 27b75c95f10d ("net: avoid RCU for NOCACHE dst")
Reported-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dst.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 2a1818065e12..e6dc77252fe9 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -306,7 +306,7 @@ void dst_release(struct dst_entry *dst)
 		if (unlikely(newrefcnt < 0))
 			net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
 					     __func__, dst, newrefcnt);
-		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
+		if (!newrefcnt && unlikely(dst->flags & DST_NOCACHE))
 			call_rcu(&dst->rcu_head, dst_destroy_rcu);
 	}
 }
