From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 1/2] dccp: Unlock sock before calling sk_free()
Date: Wed,  1 Mar 2017 16:35:07 -0300
Message-ID: <20170301193508.25760-1-acme@kernel.org>
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        Thomas Gleixner <tglx@linutronix.de>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:46824 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbdCAVoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 16:44:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

The code where sk_clone() came from created a new socket and locked it,
but then, on the error path didn't unlock it.

This problem stayed there for a long while, till b0691c8ee7c2 ("net:
Unlock sock before calling sk_free()") fixed it, but unfortunately the
callers of sk_clone() (now sk_clone_locked()) were not audited and the
one in dccp_create_openreq_child() remained.

Now in the age of the syskaller fuzzer, this was finally uncovered, as
reported by Dmitry:

 ---- 8< ----

I've got the following report while running syzkaller fuzzer on
86292b33d4b7 ("Merge branch 'akpm' (patches from Andrew)")

  [ BUG: held lock freed! ]
  4.10.0+ #234 Not tainted
  -------------------------
  syz-executor6/6898 is freeing memory
  ffff88006286cac0-ffff88006286d3b7, with a lock still held there!
   (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>] spin_lock
  include/linux/spinlock.h:299 [inline]
   (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>]
  sk_clone_lock+0x3d9/0x12c0 net/core/sock.c:1504
  5 locks held by syz-executor6/6898:
   #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff839a34b4>] lock_sock
  include/net/sock.h:1460 [inline]
   #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff839a34b4>]
  inet_stream_connect+0x44/0xa0 net/ipv4/af_inet.c:681
   #1:  (rcu_read_lock){......}, at: [<ffffffff83bc1c2a>]
  inet6_csk_xmit+0x12a/0x5d0 net/ipv6/inet6_connection_sock.c:126
   #2:  (rcu_read_lock){......}, at: [<ffffffff8369b424>] __skb_unlink
  include/linux/skbuff.h:1767 [inline]
   #2:  (rcu_read_lock){......}, at: [<ffffffff8369b424>] __skb_dequeue
  include/linux/skbuff.h:1783 [inline]
   #2:  (rcu_read_lock){......}, at: [<ffffffff8369b424>]
  process_backlog+0x264/0x730 net/core/dev.c:4835
   #3:  (rcu_read_lock){......}, at: [<ffffffff83aeb5c0>]
  ip6_input_finish+0x0/0x1700 net/ipv6/ip6_input.c:59
   #4:  (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>] spin_lock
  include/linux/spinlock.h:299 [inline]
   #4:  (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>]
  sk_clone_lock+0x3d9/0x12c0 net/core/sock.c:1504

Fix it just like was done by b0691c8ee7c2 ("net: Unlock sock before calling
sk_free()").

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/r/20170301153510.GE15145@kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/minisocks.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 53eddf99e4f6..d20d948a98ed 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -122,6 +122,7 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
 			/* It is still raw copy of parent, so invalidate
 			 * destructor and make plain sk_free() */
 			newsk->sk_destruct = NULL;
+			bh_unlock_sock(newsk);
 			sk_free(newsk);
 			return NULL;
 		}
-- 
2.9.3
