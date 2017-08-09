From: gfree.wind@vip.163.com
Subject: [PATCH net-next 1/1] driver: pptp: Remove unnecessary statements in pptp_sock_destruct
Date: Wed,  9 Aug 2017 23:57:56 +0800
Message-ID: <1502294276-20051-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: xeb@mail.ru, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:58457 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752709AbdHIQDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:03:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

In the commit ddab82821fa6 ("ppp: Fix a scheduling-while-atomic bug in
del_chan"), I moved the synchronize_rcu() from del_chan() to pptp_release
after del_chan() to avoid one scheduling-while-atomic bug.

Actually the del_chan() and pppox_unbind_sock are unneccessary in the
pptp_sock_destruct. Because the pptp sock refcnt wouldn't reach zero until
sk_state is set as PPPOX_DEAD in pptp_release. By that time, the del_chan()
and pppox_unbind_sock() have been invoked already and the condition check
"!(sk->sk_state & PPPOX_DEAD)" of this sock must be false in pptp_sock_destruct.

So we could remove these statements in pptp_sock_destruct, and then restore
the synchronize_rcu() into del_chan.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 drivers/net/ppp/pptp.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 6dde9a0..8632e1a 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -131,6 +131,7 @@ static void del_chan(struct pppox_sock *sock)
 	clear_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
 	RCU_INIT_POINTER(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
 	spin_unlock(&chan_lock);
+	synchronize_rcu();
 }
 
 static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
@@ -519,7 +520,6 @@ static int pptp_release(struct socket *sock)
 
 	po = pppox_sk(sk);
 	del_chan(po);
-	synchronize_rcu();
 
 	pppox_unbind_sock(sk);
 	sk->sk_state = PPPOX_DEAD;
@@ -535,10 +535,6 @@ static int pptp_release(struct socket *sock)
 
 static void pptp_sock_destruct(struct sock *sk)
 {
-	if (!(sk->sk_state & PPPOX_DEAD)) {
-		del_chan(pppox_sk(sk));
-		pppox_unbind_sock(sk);
-	}
 	skb_queue_purge(&sk->sk_receive_queue);
 }
 
-- 
1.9.1
