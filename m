From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 7/9] bpf: sockmap indicate sock events to listeners
Date: Mon, 28 Aug 2017 07:12:01 -0700
Message-ID: <20170828141201.14143.84669.stgit@john-Precision-Tower-5810>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34323 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751170AbdH1OMP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:12:15 -0400
Received: by mail-pg0-f68.google.com with SMTP id 63so465517pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:12:15 -0700 (PDT)
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After userspace pushes sockets into a sockmap it may not be receiving
data (assuming stream_{parser|verdict} programs are attached). But, it
may still want to manage the socks. A common pattern is to poll/select
for a POLLRDHUP event so we can close the sock.

This patch adds the logic to wake up these listeners.

Also add TCP_SYN_SENT to the list of events to handle. We don't want
to break the connection just because we happen to be in this state.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/sockmap.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 38bf4e4..bcc326a 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -162,6 +162,7 @@ static void smap_state_change(struct sock *sk)
 {
 	struct smap_psock_map_entry *e, *tmp;
 	struct smap_psock *psock;
+	struct socket_wq *wq;
 	struct sock *osk;
 
 	rcu_read_lock();
@@ -171,6 +172,7 @@ static void smap_state_change(struct sock *sk)
 	 * is established.
 	 */
 	switch (sk->sk_state) {
+	case TCP_SYN_SENT:
 	case TCP_SYN_RECV:
 	case TCP_ESTABLISHED:
 		break;
@@ -208,6 +210,10 @@ static void smap_state_change(struct sock *sk)
 		smap_report_sk_error(psock, EPIPE);
 		break;
 	}
+
+	wq = rcu_dereference(sk->sk_wq);
+	if (skwq_has_sleeper(wq))
+		wake_up_interruptible_all(&wq->wait);
 	rcu_read_unlock();
 }
 
