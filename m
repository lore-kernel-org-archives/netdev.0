From: Robert Varga <nite@hq.alert.sk>
Subject: [PATCH] fix CONFIG_TCP_MD5SIG + CONFIG_PREEMPT timer BUG()
Date: Wed, 16 Sep 2009 01:01:26 +0200
Message-ID: <20090915230126.GA21539@hq.alert.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq.alert.sk ([195.95.205.245]:58665 "EHLO hq.alert.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698AbZIOXBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 19:01:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have recently came across a preemption imbalance detected by:

<4>huh, entered ffffffff80644630 with preempt_count 00000102, exited with 00000101?
<0>------------[ cut here ]------------
<2>kernel BUG at /usr/src/linux/kernel/timer.c:664!
<0>invalid opcode: 0000 [1] PREEMPT SMP

with ffffffff80644630 being inet_twdr_hangman().

This appeared after I enabled CONFIG_TCP_MD5SIG and played with it a
bit, so I looked at what might have caused it.

One thing that struck me as strange is tcp_twsk_destructor(), as it
calls tcp_put_md5sig_pool() -- which entails a put_cpu(), causing the
detected imbalance. Found on 2.6.23.9, but 2.6.31 is affected as well,
as far as I can tell.

Signed-off-by: Robert Varga <nite@hq.alert.sk>
---

--- vanilla/net/ipv4/tcp_minisocks.c	2009-09-10 00:13:59.000000000 +0200
+++ patched/net/ipv4/tcp_minisocks.c	2009-09-16 00:48:15.904089024 +0200
@@ -363,7 +363,7 @@ void tcp_twsk_destructor(struct sock *sk
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
 	if (twsk->tw_md5_keylen)
-		tcp_put_md5sig_pool();
+		tcp_free_md5sig_pool();
 #endif
 }
 
-- 
Bye,
Robert Varga

Reality continues to ruin my life. -- Calvin
