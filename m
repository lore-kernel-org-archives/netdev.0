From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sctp_close/sk_free: kernel BUG at arch/x86/mm/physaddr.c:18!
Date: Wed, 05 Sep 2012 18:57:00 +0200
Message-ID: <1346864220.13121.157.camel@edumazet-glaptop>
References: <20120904140411.GB15068@localhost>
	 <5046361C.5070602@pengutronix.de> <87mx15zfze.fsf@xmission.com>
	 <20120905145508.GA9450@localhost>  <50476931.20100@pengutronix.de>
	 <1346859046.13121.144.camel@edumazet-glaptop>
	 <1346859645.13121.146.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1346859645.13121.146.camel@edumazet-glaptop>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-05 at 17:40 +0200, Eric Dumazet wrote:

> Could you test the following patch please ?
> 
> (Not sure why sctp doesnt memset/bzero its whole socket by the way...)
> 
> Thanks

Here is a more complete patch, as there are three potential problems,
not only one :

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4f70ef0..845372b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -149,11 +149,8 @@ void inet_sock_destruct(struct sock *sk)
 		pr_err("Attempt to release alive inet socket %p\n", sk);
 		return;
 	}
-	if (sk->sk_type == SOCK_STREAM) {
-		struct fastopen_queue *fastopenq =
-			inet_csk(sk)->icsk_accept_queue.fastopenq;
-		kfree(fastopenq);
-	}
+	if (sk->sk_protocol == IPPROTO_TCP)
+		kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8464b79..f0c5b9c 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -314,7 +314,7 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 	newsk = req->sk;
 
 	sk_acceptq_removed(sk);
-	if (sk->sk_type == SOCK_STREAM && queue->fastopenq != NULL) {
+	if (sk->sk_protocol == IPPROTO_TCP && queue->fastopenq != NULL) {
 		spin_lock_bh(&queue->fastopenq->lock);
 		if (tcp_rsk(req)->listener) {
 			/* We are still waiting for the final ACK from 3WHS
@@ -775,7 +775,7 @@ void inet_csk_listen_stop(struct sock *sk)
 
 		percpu_counter_inc(sk->sk_prot->orphan_count);
 
-		if (sk->sk_type == SOCK_STREAM && tcp_rsk(req)->listener) {
+		if (sk->sk_protocol == IPPROTO_TCP && tcp_rsk(req)->listener) {
 			BUG_ON(tcp_sk(child)->fastopen_rsk != req);
 			BUG_ON(sk != tcp_rsk(req)->listener);
 


