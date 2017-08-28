From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 3/9] bpf: sockmap add missing rcu_read_(un)lock in
 smap_data_ready
Date: Mon, 28 Aug 2017 07:10:45 -0700
Message-ID: <20170828141045.14143.37805.stgit@john-Precision-Tower-5810>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35287 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751236AbdH1OK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:10:59 -0400
Received: by mail-pg0-f65.google.com with SMTP id r133so459207pgr.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:10:59 -0700 (PDT)
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

References to psock must be done inside RCU critical section.

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/sockmap.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index a6882e5..266011c8 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -227,11 +227,14 @@ static void smap_data_ready(struct sock *sk)
 {
 	struct smap_psock *psock;
 
-	write_lock_bh(&sk->sk_callback_lock);
+	rcu_read_lock();
 	psock = smap_psock_sk(sk);
-	if (likely(psock))
+	if (likely(psock)) {
+		write_lock_bh(&sk->sk_callback_lock);
 		strp_data_ready(&psock->strp);
-	write_unlock_bh(&sk->sk_callback_lock);
+		write_unlock_bh(&sk->sk_callback_lock);
+	}
+	rcu_read_unlock();
 }
 
 static void smap_tx_work(struct work_struct *w)
