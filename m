From: frank.blaschka@de.ibm.com
Subject: [patch 04/10] [PATCH] af_iucv: remove unused timer infrastructure
Date: Tue, 20 Dec 2011 09:56:30 +0100
Message-ID: <20111220085735.905728353@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:48972 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684Ab1LTI6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:58:00 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:58 -0000
Content-Disposition: inline; filename=604-af_iucv-rm-timer.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

af_iucv contains timer infrastructure which is not exploited.
This patch removes the timer related code parts.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    1 -
 net/iucv/af_iucv.c         |   22 ----------------------
 2 files changed, 23 deletions(-)

--- a/include/net/iucv/af_iucv.h
+++ b/include/net/iucv/af_iucv.h
@@ -146,7 +146,6 @@ unsigned int iucv_sock_poll(struct file
 			    poll_table *wait);
 void iucv_sock_link(struct iucv_sock_list *l, struct sock *s);
 void iucv_sock_unlink(struct iucv_sock_list *l, struct sock *s);
-int  iucv_sock_wait_cnt(struct sock *sk, unsigned long timeo);
 void iucv_accept_enqueue(struct sock *parent, struct sock *sk);
 void iucv_accept_unlink(struct sock *sk);
 struct sock *iucv_accept_dequeue(struct sock *parent, struct socket *newsock);
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -406,25 +406,6 @@ static int afiucv_hs_send(struct iucv_me
 	return err;
 }
 
-/* Timers */
-static void iucv_sock_timeout(unsigned long arg)
-{
-	struct sock *sk = (struct sock *)arg;
-
-	bh_lock_sock(sk);
-	sk->sk_err = ETIMEDOUT;
-	sk->sk_state_change(sk);
-	bh_unlock_sock(sk);
-
-	iucv_sock_kill(sk);
-	sock_put(sk);
-}
-
-static void iucv_sock_clear_timer(struct sock *sk)
-{
-	sk_stop_timer(sk, &sk->sk_timer);
-}
-
 static struct sock *__iucv_get_sock_by_name(char *nm)
 {
 	struct sock *sk;
@@ -477,7 +458,6 @@ static void iucv_sock_close(struct sock
 	int err, blen;
 	struct sk_buff *skb;
 
-	iucv_sock_clear_timer(sk);
 	lock_sock(sk);
 
 	switch (sk->sk_state) {
@@ -589,8 +569,6 @@ static struct sock *iucv_sock_alloc(stru
 	sk->sk_protocol = proto;
 	sk->sk_state	= IUCV_OPEN;
 
-	setup_timer(&sk->sk_timer, iucv_sock_timeout, (unsigned long)sk);
-
 	iucv_sock_link(&iucv_sk_list, sk);
 	return sk;
 }
