From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] unix: correct sk_rmem_alloc accounting
Date: Wed, 23 Jan 2013 22:43:11 +0800
Message-ID: <1358952191-3374-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Yannick Koehler <yannick@koehler.name>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:34302 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab3AWOna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 09:43:30 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so3844639dak.30
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 06:43:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

Yannick reported [1] we probably forgot to account ->sk_rmem_alloc
before moving the skb to other->sk_receive_queue. I believe
he is right. So, just call skb_set_owner_r() before every time
we queuing skb into other->sk_receive_queue. 

1. http://marc.info/?l=linux-netdev&m=135882012924930&w=2

Reported-by: Yannick Koehler <yannick@koehler.name>
Cc: Yannick Koehler <yannick@koehler.name>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5b5c876..7e9dba3 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1205,6 +1205,7 @@ restart:
 
 	unix_state_unlock(sk);
 
+	skb_set_owner_r(skb, other);
 	/* take ten and and send info to listening sock */
 	spin_lock(&other->sk_receive_queue.lock);
 	__skb_queue_tail(&other->sk_receive_queue, skb);
@@ -1579,6 +1580,7 @@ restart:
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
 	maybe_add_creds(skb, sock, other);
+	skb_set_owner_r(skb, other);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
@@ -1694,6 +1696,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto pipe_err_free;
 
 		maybe_add_creds(skb, sock, other);
+		skb_set_owner_r(skb, other);
 		skb_queue_tail(&other->sk_receive_queue, skb);
 		if (max_level > unix_sk(other)->recursion_level)
 			unix_sk(other)->recursion_level = max_level;
