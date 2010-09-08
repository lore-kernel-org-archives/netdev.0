From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 2/2] net/core: add lock context change annotations in net/core/sock.c
Date: Wed,  8 Sep 2010 22:48:48 +0900
Message-ID: <1283953728-15302-2-git-send-email-namhyung@gmail.com>
References: <1283953728-15302-1-git-send-email-namhyung@gmail.com>
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:33348 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab0IHNtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 09:49:16 -0400
In-Reply-To: <1283953728-15302-1-git-send-email-namhyung@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__lock_sock() and __release_sock() releases and regrabs lock but
were missing proper annotations. Add it. This removes following
warning from sparse. (Currently __lock_sock() does not emit any
warning about it but I think it is better to add also.)

 net/core/sock.c:1580:17: warning: context imbalance in '__release_sock' - unexpected unlock

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 net/core/sock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index b05b9b6..f3a06c4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1557,6 +1557,8 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
 static void __lock_sock(struct sock *sk)
+	__releases(&sk->sk_lock.slock)
+	__acquires(&sk->sk_lock.slock)
 {
 	DEFINE_WAIT(wait);
 
@@ -1573,6 +1575,8 @@ static void __lock_sock(struct sock *sk)
 }
 
 static void __release_sock(struct sock *sk)
+	__releases(&sk->sk_lock.slock)
+	__acquires(&sk->sk_lock.slock)
 {
 	struct sk_buff *skb = sk->sk_backlog.head;
 
-- 
1.7.2.2

