From: Radu Iliescu <radui@bricsys.com>
Subject: [PATCH] llc: Fix race condition in llc_ui_recvmsg
Date: Thu, 19 Jan 2012 15:57:57 +0200
Message-ID: <1326981477-1698-1-git-send-email-riliescu@ixiacom.com>
Cc: netdev@vger.kernel.org, dbaluta@ixiacom.com,
	Radu Iliescu <riliescu@ixiacom.com>
To: acme@ghostprotocols.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52821 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300Ab2ASN7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 08:59:13 -0500
Received: by eekc14 with SMTP id c14so1332443eek.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 05:59:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race on sk_receive_queue between llc_ui_recvmsg and
sock_queue_rcv_skb.

Our current solution is to protect skb_eat in llc_ui_recvmsg
with the queue spinlock.

Perhaps there is a better solution.
Maybe there is a lock missing in llc_sap_state_process or above.
I've tried to follow the locking in tcp on sk_receive_queue,
but is not clear how is done.

Please take a look and comment.

Signed-off-by: Radu Iliescu <riliescu@ixiacom.com>
---
 net/llc/af_llc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index a18e6c3..46a60a4 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -719,6 +719,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 	unsigned long used;
 	int target;	/* Read at least this many bytes */
 	long timeo;
+	long cpu_flags;
 
 	lock_sock(sk);
 	copied = -ENOTCONN;
@@ -838,7 +839,9 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 			goto copy_uaddr;
 
 		if (!(flags & MSG_PEEK)) {
+			spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
 			sk_eat_skb(sk, skb, 0);
+			spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 			*seq = 0;
 		}
 
@@ -859,7 +862,9 @@ copy_uaddr:
 		llc_cmsg_rcv(msg, skb);
 
 	if (!(flags & MSG_PEEK)) {
+			spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
 			sk_eat_skb(sk, skb, 0);
+			spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 			*seq = 0;
 	}
 
-- 
1.7.0.4
