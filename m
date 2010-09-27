From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sk_attach_filter() rcu fix
Date: Mon, 27 Sep 2010 17:57:44 +0200
Message-ID: <1285603064.3017.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46258 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933161Ab0I0P5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 11:57:49 -0400
Received: by fxm3 with SMTP id 3so1935822fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 08:57:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_attach_filter() is run with socket locked.

Use the appropriate rcu_dereference_protected() instead of blocking BH,
and rcu_dereference_bh().
There is no point adding BH prevention and memory barrier.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/filter.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 52b051f..93ac5d2 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -638,10 +638,9 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 		return err;
 	}
 
-	rcu_read_lock_bh();
-	old_fp = rcu_dereference_bh(sk->sk_filter);
+	old_fp = rcu_dereference_protected(sk->sk_filter,
+					   sock_owned_by_user(sk));
 	rcu_assign_pointer(sk->sk_filter, fp);
-	rcu_read_unlock_bh();
 
 	if (old_fp)
 		sk_filter_delayed_uncharge(sk, old_fp);


