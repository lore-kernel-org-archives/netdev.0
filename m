From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] locking, percpu counters: introduce separate lock
	classes
Date: Tue, 30 Dec 2008 14:58:15 +1100
Message-ID: <20081230035815.GA16454@gondor.apana.org.au>
References: <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu> <20081229114907.GA10170@gondor.apana.org.au> <20081229115827.GA441@elte.hu> <20081229120132.GA10363@gondor.apana.org.au> <20081229121626.GF9628@elte.hu> <20081229123819.GA18321@elte.hu> <20081229124444.GA20306@elte.hu> <20081229141417.GA1493@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58879 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751481AbYL3D6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 22:58:35 -0500
Content-Disposition: inline
In-Reply-To: <20081229141417.GA1493@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2008 at 03:14:17PM +0100, Ingo Molnar wrote:
>
> my testing efforts today are not particularly dominated by luck :-)
> 
> Below is the latest splat that i got with Peter's patch plus the revert of 
> dd24c00191 applied.

> [   78.679386] 
> [   78.679389] =================================
> [   78.680039] [ INFO: inconsistent lock state ]
> [   78.680039] 2.6.28-tip-03885-g44c31d5-dirty #13188
> [   78.680039] ---------------------------------
> [   78.680039] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> [   78.680039] ssh/4054 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [   78.680039]  (key#8){-+..}, at: [<c042710e>] __percpu_counter_add+0x52/0x7a
> [   78.680039] {softirq-on-W} state was registered at:
> [   78.680039]   [<c0163e6e>] __lock_acquire+0x288/0xa93
> [   78.680039]   [<c01646d6>] lock_acquire+0x5d/0x7a
> [   78.680039]   [<c0ae0473>] _spin_lock+0x20/0x2f
> [   78.680039]   [<c042710e>] __percpu_counter_add+0x52/0x7a
> [   78.680039]   [<c09c3e2f>] percpu_counter_add+0xf/0x12
> [   78.680039]   [<c09c50ef>] tcp_v4_init_sock+0xe5/0xea

Right, this is the correct version of the earlier splat :)

Anyway, I've extended Peter's patch to cover the other cases.
Please let me know if it still bitches with this + Peter's fbc
patch.

net: Fix percpu counters deadlock

When we converted the protocol atomic counters such as the orphan
count and the total socket count deadlocks were introduced due to
the mismatch in BH status of the spots that used the percpu counter
operations.

Based on the diagnosis and patch by Peter Zijlstra, this patch
fixes these issues by disabling BH where we may be in process
context.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d5c2bac..1747cca 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -964,7 +964,6 @@ adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
-	percpu_counter_inc(sk->sk_prot->orphan_count);
 
 	/*
 	 * It is the last release_sock in its life. It will remove backlog.
@@ -978,6 +977,8 @@ adjudge_to_death:
 	bh_lock_sock(sk);
 	WARN_ON(sock_owned_by_user(sk));
 
+	percpu_counter_inc(sk->sk_prot->orphan_count);
+
 	/* Have we already been destroyed by a softirq or backlog? */
 	if (state != DCCP_CLOSED && sk->sk_state == DCCP_CLOSED)
 		goto out;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c7cda1c..f26ab38 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -633,8 +633,6 @@ void inet_csk_listen_stop(struct sock *sk)
 
 		acc_req = req->dl_next;
 
-		percpu_counter_inc(sk->sk_prot->orphan_count);
-
 		local_bh_disable();
 		bh_lock_sock(child);
 		WARN_ON(sock_owned_by_user(child));
@@ -644,6 +642,8 @@ void inet_csk_listen_stop(struct sock *sk)
 
 		sock_orphan(child);
 
+		percpu_counter_inc(sk->sk_prot->orphan_count);
+
 		inet_csk_destroy_sock(child);
 
 		bh_unlock_sock(child);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 614958b..eb62e58 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -38,6 +38,7 @@
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/udplite.h>
+#include <linux/bottom_half.h>
 #include <linux/inetdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -50,13 +51,17 @@
 static int sockstat_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
+	int orphans, sockets;
+
+	local_bh_disable();
+	orphans = percpu_counter_sum_positive(&tcp_orphan_count),
+	sockets = percpu_counter_sum_positive(&tcp_sockets_allocated),
+	local_bh_enable();
 
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
-		   sock_prot_inuse_get(net, &tcp_prot),
-		   (int)percpu_counter_sum_positive(&tcp_orphan_count),
-		   tcp_death_row.tw_count,
-		   (int)percpu_counter_sum_positive(&tcp_sockets_allocated),
+		   sock_prot_inuse_get(net, &tcp_prot), orphans,
+		   tcp_death_row.tw_count, sockets,
 		   atomic_read(&tcp_memory_allocated));
 	seq_printf(seq, "UDP: inuse %d mem %d\n",
 		   sock_prot_inuse_get(net, &udp_prot),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1f3d529..f28acf1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1836,7 +1836,6 @@ adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
-	percpu_counter_inc(sk->sk_prot->orphan_count);
 
 	/* It is the last release_sock in its life. It will remove backlog. */
 	release_sock(sk);
@@ -1849,6 +1848,8 @@ adjudge_to_death:
 	bh_lock_sock(sk);
 	WARN_ON(sock_owned_by_user(sk));
 
+	percpu_counter_inc(sk->sk_prot->orphan_count);
+
 	/* Have we already been destroyed by a softirq or backlog? */
 	if (state != TCP_CLOSE && sk->sk_state == TCP_CLOSE)
 		goto out;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1017248..9d839fa 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -51,6 +51,7 @@
  */
 
 
+#include <linux/bottom_half.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/module.h>
@@ -1797,7 +1798,9 @@ static int tcp_v4_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
+	local_bh_disable();
 	percpu_counter_inc(&tcp_sockets_allocated);
+	local_bh_enable();
 
 	return 0;
 }
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8702b06..e8b8337 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -23,6 +23,7 @@
  *      2 of the License, or (at your option) any later version.
  */
 
+#include <linux/bottom_half.h>
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -1830,7 +1831,9 @@ static int tcp_v6_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
+	local_bh_disable();
 	percpu_counter_inc(&tcp_sockets_allocated);
+	local_bh_enable();
 
 	return 0;
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
