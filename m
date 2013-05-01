From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Tue, 30 Apr 2013 18:12:41 -0700
Message-ID: <1367370761.11020.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>,
	linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:45655 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934177Ab3EABMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 21:12:47 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so645229pab.10
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 18:12:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using bit fields is dangerous on ppc64, as the compiler uses 64bit
instructions to manipulate them. If the 64bit word includes any
atomic_t or spinlock_t, we can lose critical concurrent changes.

This is happening in af_unix, where unix_sk(sk)->gc_candidate/
gc_maybe_cycle/lock share the same 64bit word.

This leads to fatal deadlock, as one/several cpus spin forever
on a spinlock that will never be available again.

Reported-by: Ambrose Feinstein <ambrose@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
---

Could ppc64 experts confirm using byte is safe, or should we really add
a 32bit hole after the spinlock ? If so, I wonder how many other places
need a change...

 include/net/af_unix.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a8836e8..4520a23f 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -57,8 +57,8 @@ struct unix_sock {
 	struct list_head	link;
 	atomic_long_t		inflight;
 	spinlock_t		lock;
-	unsigned int		gc_candidate : 1;
-	unsigned int		gc_maybe_cycle : 1;
+	unsigned char		gc_candidate;
+	unsigned char		gc_maybe_cycle;
 	unsigned char		recursion_level;
 	struct socket_wq	peer_wq;
 };
