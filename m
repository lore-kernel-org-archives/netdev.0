From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] bpf: sockmap update/simplify memory accounting
 scheme
Date: Fri, 01 Sep 2017 11:29:26 -0700
Message-ID: <20170901182926.8981.77450.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38580 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdIAS3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 14:29:47 -0400
Received: by mail-pg0-f65.google.com with SMTP id t3so569420pgt.5
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 11:29:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of tracking wmem_queued and sk_mem_charge by incrementing
in the verdict SK_REDIRECT paths and decrementing in the tx work
path use skb_set_owner_w and sock_writeable helpers. This solves
a few issues with the current code. First, in SK_REDIRECT inc on
sk_wmem_queued and sk_mem_charge were being done without the peers
sock lock being held. Under stress this can result in accounting
errors when tx work and/or multiple verdict decisions are working
on the peer psock.

Additionally, this cleans up the code because we can rely on the
default destructor to decrement memory accounting on kfree_skb. Also
this will trigger sk_write_space when space becomes available on
kfree_skb() which wasn't happening before and prevent __sk_free
from being called until all in-flight packets are completed.

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/sockmap.c |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index db0d99d..f6ffde9 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -111,7 +111,7 @@ static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 
 static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
 {
-	struct sock *sock;
+	struct sock *sk;
 	int rc;
 
 	/* Because we use per cpu values to feed input from sock redirect
@@ -123,16 +123,16 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
 	rc = smap_verdict_func(psock, skb);
 	switch (rc) {
 	case SK_REDIRECT:
-		sock = do_sk_redirect_map();
+		sk = do_sk_redirect_map();
 		preempt_enable();
-		if (likely(sock)) {
-			struct smap_psock *peer = smap_psock_sk(sock);
+		if (likely(sk)) {
+			struct smap_psock *peer = smap_psock_sk(sk);
 
 			if (likely(peer &&
 				   test_bit(SMAP_TX_RUNNING, &peer->state) &&
-				   sk_stream_memory_free(peer->sock))) {
-				peer->sock->sk_wmem_queued += skb->truesize;
-				sk_mem_charge(peer->sock, skb->truesize);
+				   !sock_flag(sk, SOCK_DEAD) &&
+				   sock_writeable(sk))) {
+				skb_set_owner_w(skb, sk);
 				skb_queue_tail(&peer->rxqueue, skb);
 				schedule_work(&peer->tx_work);
 				break;
@@ -282,16 +282,12 @@ static void smap_tx_work(struct work_struct *w)
 				/* Hard errors break pipe and stop xmit */
 				smap_report_sk_error(psock, n ? -n : EPIPE);
 				clear_bit(SMAP_TX_RUNNING, &psock->state);
-				sk_mem_uncharge(psock->sock, skb->truesize);
-				psock->sock->sk_wmem_queued -= skb->truesize;
 				kfree_skb(skb);
 				goto out;
 			}
 			rem -= n;
 			off += n;
 		} while (rem);
-		sk_mem_uncharge(psock->sock, skb->truesize);
-		psock->sock->sk_wmem_queued -= skb->truesize;
 		kfree_skb(skb);
 	}
 out:
