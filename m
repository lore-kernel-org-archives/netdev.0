From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] pptp: fix illegal memory access caused by multiple bind()s
Date: Fri, 22 Jan 2016 01:39:43 +0100
Message-ID: <1453423183-4211-1-git-send-email-hannes@stressinduktion.org>
Cc: Dmitry Kozlov <xeb@mail.ru>, Sasha Levin <sasha.levin@oracle.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Dave Jones <davej@codemonkey.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45732 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820AbcAVAjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 19:39:51 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 0505220640
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 19:39:50 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several times already this has been reported as kasan reports caused by
syzkaller and trinity and people always looked at RCU races, but it is
much more simple. :)

In case we bind a pptp socket multiple times, we simply add it to
the callid_sock list but don't remove the old binding. Thus the old
socket stays in the bucket with unused call_id indexes and doesn't get
cleaned up. This causes various forms of kasan reports which were hard
to pinpoint.

Simply don't allow multiple binds and correct error handling in
pptp_bind. Also keep sk_state bits in place in pptp_connect.

Fixes: 00959ade36acad ("PPTP: PPP over IPv4 (Point-to-Point Tunneling Protocol)")
Cc: Dmitry Kozlov <xeb@mail.ru>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Dave Jones <davej@codemonkey.org.uk>
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ppp/pptp.c | 34 ++++++++++++++++++++++++----------
 1 file changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 90868ca5e3412f..ae0905ed4a32b5 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -129,24 +129,27 @@ static int lookup_chan_dst(u16 call_id, __be32 d_addr)
 	return i < MAX_CALLID;
 }
 
-static int add_chan(struct pppox_sock *sock)
+static int add_chan(struct pppox_sock *sock,
+		    struct pptp_addr *sa)
 {
 	static int call_id;
 
 	spin_lock(&chan_lock);
-	if (!sock->proto.pptp.src_addr.call_id)	{
+	if (!sa->call_id)	{
 		call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, call_id + 1);
 		if (call_id == MAX_CALLID) {
 			call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, 1);
 			if (call_id == MAX_CALLID)
 				goto out_err;
 		}
-		sock->proto.pptp.src_addr.call_id = call_id;
-	} else if (test_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap))
+		sa->call_id = call_id;
+	} else if (test_bit(sa->call_id, callid_bitmap)) {
 		goto out_err;
+	}
 
-	set_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
-	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id], sock);
+	sock->proto.pptp.src_addr = *sa;
+	set_bit(sa->call_id, callid_bitmap);
+	rcu_assign_pointer(callid_sock[sa->call_id], sock);
 	spin_unlock(&chan_lock);
 
 	return 0;
@@ -416,7 +419,6 @@ static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr,
 	struct sock *sk = sock->sk;
 	struct sockaddr_pppox *sp = (struct sockaddr_pppox *) uservaddr;
 	struct pppox_sock *po = pppox_sk(sk);
-	struct pptp_opt *opt = &po->proto.pptp;
 	int error = 0;
 
 	if (sockaddr_len < sizeof(struct sockaddr_pppox))
@@ -424,10 +426,22 @@ static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr,
 
 	lock_sock(sk);
 
-	opt->src_addr = sp->sa_addr.pptp;
-	if (add_chan(po))
+	if (sk->sk_state & PPPOX_DEAD) {
+		error = -EALREADY;
+		goto out;
+	}
+
+	if (sk->sk_state & PPPOX_BOUND) {
 		error = -EBUSY;
+		goto out;
+	}
+
+	if (add_chan(po, &sp->sa_addr.pptp))
+		error = -EBUSY;
+	else
+		sk->sk_state |= PPPOX_BOUND;
 
+out:
 	release_sock(sk);
 	return error;
 }
@@ -498,7 +512,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	}
 
 	opt->dst_addr = sp->sa_addr.pptp;
-	sk->sk_state = PPPOX_CONNECTED;
+	sk->sk_state |= PPPOX_CONNECTED;
 
  end:
 	release_sock(sk);
-- 
2.5.0
