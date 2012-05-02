From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] net: l2tp: unlock socket lock before returning from l2tp_ip_sendmsg
Date: Wed,  2 May 2012 15:10:37 +0200
Message-ID: <1335964237-1139-1-git-send-email-levinsasha928@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, Sasha Levin <levinsasha928@gmail.com>
To: davem@davemloft.net, jchapman@katalix.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58098 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431Ab2EBNJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 09:09:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_ip_sendmsg could return without releasing socket lock, making it all the
way to userspace, and generating the following warning:

[  130.891594] ================================================
[  130.894569] [ BUG: lock held when returning to user space! ]
[  130.897257] 3.4.0-rc5-next-20120501-sasha #104 Tainted: G        W
[  130.900336] ------------------------------------------------
[  130.902996] trinity/8384 is leaving the kernel with locks still held!
[  130.906106] 1 lock held by trinity/8384:
[  130.907924]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff82b9503f>] l2tp_ip_sendmsg+0x2f/0x550

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/l2tp/l2tp_ip.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 585d93e..a4d8364 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -442,8 +442,10 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 
 		daddr = lip->l2tp_addr.s_addr;
 	} else {
-		if (sk->sk_state != TCP_ESTABLISHED)
-			return -EDESTADDRREQ;
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			rc = -EDESTADDRREQ;
+			goto out;
+		}
 
 		daddr = inet->inet_daddr;
 		connected = 1;
-- 
1.7.8.5
