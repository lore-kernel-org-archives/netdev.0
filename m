From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 1/2] net: Fix the condition passed to sk_wait_event()
Date: Sat, 2 Oct 2010 05:08:13 -0700 (PDT)
Message-ID: <590816.4455.qm@web53707.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the first part of the split up patch submitted in http://www.spinics.net/lists/netdev/msg142617.html

This patch fixes the sk_wait_event() condition in the sk_stream_wait_connect() function. With this change, we correctly check for the TCPF_ESTABLISHED and TCPF_CLOSE_WAIT states and avoid potentially returning success when there is an error on the socket.

Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>
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
