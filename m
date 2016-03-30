From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH RFC] net: decrease the length of backlog queue immediately after it's detached from sk
Date: Wed, 30 Mar 2016 13:16:41 +0800
Message-ID: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:40199 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbcC3FRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 01:17:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When task A hold the sk owned in tcp_sendmsg, if lots of packets
arrive and the packets will be added to backlog queue. The packets
will be handled in release_sock called from tcp_sendmsg. When the
sk_backlog is removed from sk, the length will not decrease until
all the packets in backlog queue are handled. This may leads to the
new packets be dropped because the lenth is too big. So set the
lenth to 0 immediately after it's detached from sk.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/core/sock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 47fc8bb..108be05 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1933,6 +1933,7 @@ static void __release_sock(struct sock *sk)
 
 	do {
 		sk->sk_backlog.head = sk->sk_backlog.tail = NULL;
+		sk->sk_backlog.len = 0;
 		bh_unlock_sock(sk);
 
 		do {
-- 
2.5.0
