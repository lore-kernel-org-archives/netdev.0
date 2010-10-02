From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: [PATCH 1/2] net: Fix the condition passed to sk_wait_event()
Date: Sat, 2 Oct 2010 16:49:16 -0700 (PDT)
Message-ID: <339313.23381.qm@web53706.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53706.mail.re2.yahoo.com ([206.190.37.27]:43504 "HELO
	web53706.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751995Ab0JBXtR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Oct 2010 19:49:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the sk_wait_event() condition in the sk_stream_wait_connect() 
function. With this change, we correctly check for the TCPF_ESTABLISHED and 
TCPF_CLOSE_WAIT states and avoid potentially returning success when there
might be an error on the socket.

Signed-off-by: Nagendra Singh Tomar <tomer_iisc@xxxxxxxxx>
---
--- linux-2.6.35.7/net/core/stream.c.orig	2010-03-24 09:30:00.000000000 +0530
+++ linux-2.6.35.7/net/core/stream.c	2010-03-24 09:30:17.000000000 +0530
@@ -73,9 +73,8 @@ int sk_stream_wait_connect(struct sock *
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		sk->sk_write_pending++;
 		done = sk_wait_event(sk, timeo_p,
-				     !sk->sk_err &&
-				     !((1 << sk->sk_state) &
-				       ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
+				     ((1 << sk->sk_state) &
+				       (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
 		finish_wait(sk_sleep(sk), &wait);
 		sk->sk_write_pending--;
 	} while (!done);

---



      
