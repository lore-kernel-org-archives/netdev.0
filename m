From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: remove a WARN_ON() in net_enable_timestamp()
Date: Fri, 22 Mar 2013 17:38:28 -0700
Message-ID: <1363999108.4431.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Laurent Chavey <chavey@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:52449 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933549Ab3CWAib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 20:38:31 -0400
Received: by mail-pa0-f43.google.com with SMTP id rl6so172038pac.16
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 17:38:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

The WARN_ON(in_interrupt()) in net_enable_timestamp() can get false
positive, in socket clone path, run from softirq context :

[ 3641.624425] WARNING: at net/core/dev.c:1532 net_enable_timestamp+0x7b/0x80()
[ 3641.668811] Call Trace:
[ 3641.671254]  <IRQ>  [<ffffffff80286817>] warn_slowpath_common+0x87/0xc0
[ 3641.677871]  [<ffffffff8028686a>] warn_slowpath_null+0x1a/0x20
[ 3641.683683]  [<ffffffff80742f8b>] net_enable_timestamp+0x7b/0x80
[ 3641.689668]  [<ffffffff80732ce5>] sk_clone_lock+0x425/0x450
[ 3641.695222]  [<ffffffff8078db36>] inet_csk_clone_lock+0x16/0x170
[ 3641.701213]  [<ffffffff807ae449>] tcp_create_openreq_child+0x29/0x820
[ 3641.707663]  [<ffffffff807d62e2>] ? ipt_do_table+0x222/0x670
[ 3641.713354]  [<ffffffff807aaf5b>] tcp_v4_syn_recv_sock+0xab/0x3d0
[ 3641.719425]  [<ffffffff807af63a>] tcp_check_req+0x3da/0x530
[ 3641.724979]  [<ffffffff8078b400>] ? inet_hashinfo_init+0x60/0x80
[ 3641.730964]  [<ffffffff807ade6f>] ? tcp_v4_rcv+0x79f/0xbe0
[ 3641.736430]  [<ffffffff807ab9bd>] tcp_v4_do_rcv+0x38d/0x4f0
[ 3641.741985]  [<ffffffff807ae14a>] tcp_v4_rcv+0xa7a/0xbe0

Its safe at this point because the parent socket owns a reference
on the netstamp_needed, so we cant have a 0 -> 1 transition, which
requires to lock a mutex.

Instead of refining the check, lets remove it, as all known callers
are safe. If it ever changes in the future, static_key_slow_inc()
will complain anyway.

Reported-by: Laurent Chavey <chavey@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d540ced..b13e5c7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1545,7 +1545,6 @@ void net_enable_timestamp(void)
 		return;
 	}
 #endif
-	WARN_ON(in_interrupt());
 	static_key_slow_inc(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_enable_timestamp);
