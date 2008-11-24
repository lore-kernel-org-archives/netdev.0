From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] net: af_unix should disable preempt around
	sock_prot_inuse_add()
Date: Mon, 24 Nov 2008 15:54:57 +0300
Message-ID: <20081124125457.GA6255@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, dada1@cosmosbay.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:40793 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbYKXMzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 07:55:04 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1033811nfc.21
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 04:55:02 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



BUG: using smp_processor_id() in preemptible [00000000] code: ini

caller is sock_prot_inuse_add+0x24/0x42
Pid: 738, comm: init-early.sh Tainted: G        W  2.6.28-rc6-nex

Call Trace:
 [<ffffffff8037fb72>] debug_smp_processor_id+0xca/0xe0
 [<ffffffff8046afc9>] sock_prot_inuse_add+0x24/0x42
 [<ffffffff804baf2c>] unix_create1+0x161/0x176
 [<ffffffff804bb03d>] unix_stream_connect+0x94/0x3b0
 [<ffffffff80468a84>] sys_connect+0x68/0x8e
 [<ffffffff8020b75b>] system_call_fastpath+0x16/0x1b

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 net/unix/af_unix.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a9b3c90..f7a1d46 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -361,7 +361,9 @@ static void unix_sock_destructor(struct sock *sk)
 		unix_release_addr(u->addr);
 
 	atomic_dec(&unix_nr_socks);
+	preempt_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	preempt_enable();
 #ifdef UNIX_REFCNT_DEBUG
 	printk(KERN_DEBUG "UNIX %p is destroyed, %d are still alive.\n", sk,
 		atomic_read(&unix_nr_socks));
@@ -612,9 +614,11 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 out:
 	if (sk == NULL)
 		atomic_dec(&unix_nr_socks);
-	else
+	else {
+		preempt_disable();
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-
+		preempt_enable();
+	}
 	return sk;
 }
 
