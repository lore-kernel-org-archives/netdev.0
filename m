From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: two more missing bh disable
Date: Wed, 04 May 2016 15:27:29 -0700
Message-ID: <1462400849.13075.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462320650.5535.334.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160504.005450.32648328658519474.davem@davemloft.net>
	 <1462386131.5535.353.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160504.170641.134283593327091145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33010 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409AbcEDW1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 18:27:31 -0400
Received: by mail-pa0-f54.google.com with SMTP id xk12so28852247pac.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 15:27:30 -0700 (PDT)
In-Reply-To: <20160504.170641.134283593327091145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

percpu_counter only have protection against preemption.

TCP stack uses them possibly from BH, so we need BH protection
in contexts that could be run in process context

Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c |    2 ++
 net/ipv4/tcp_ipv4.c             |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7ce112aa3a7b50c8c2c97b4e59e86128f90fd7f6..fa8c39804bdbae867dd5c08f1e308202c1aa1c52 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -706,7 +706,9 @@ void inet_csk_destroy_sock(struct sock *sk)
 
 	sk_refcnt_debug_release(sk);
 
+	local_bh_disable();
 	percpu_counter_dec(sk->sk_prot->orphan_count);
+	local_bh_enable();
 	sock_put(sk);
 }
 EXPORT_SYMBOL(inet_csk_destroy_sock);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 761bc492c5e3070212efe91c3940e4712d9d6ef6..a7ab9472d64560d86ea24ac1b6e1a7800f89989d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1839,7 +1839,9 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	tcp_free_fastopen_req(tp);
 	tcp_saved_syn_free(tp);
 
+	local_bh_disable();
 	sk_sockets_allocated_dec(sk);
+	local_bh_enable();
 
 	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
 		sock_release_memcg(sk);
