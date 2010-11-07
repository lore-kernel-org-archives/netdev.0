From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 6/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:32:56 -0500
Message-ID: <1289147576.3090.143.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57457 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704Ab0KGQc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:32:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp linux-2.6.37-rc1.orig/net/netlink/af_netlink.c linux-2.6.37-rc1/net/netlink/af_netlink.c
--- linux-2.6.37-rc1.orig/net/netlink/af_netlink.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/netlink/af_netlink.c	2010-11-07 10:48:47.000000000 -0500
@@ -162,7 +162,8 @@ static void netlink_sock_destruct(struct
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk(KERN_ERR "Freeing alive netlink socket %p\n", sk);
+		printk(KERN_ERR "Freeing alive netlink socket %lu\n",
+			sock_i_ino(sk));
 		return;
 	}
 
@@ -1990,14 +1991,15 @@ static int netlink_seq_show(struct seq_f
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %-8d %-8d %-8lu\n",
-			   s,
+		seq_printf(seq, "%d %-3d %-6d %08x %-8d %-8d"
+			   " %d %-8d %-8d %-8lu\n",
+			   0,
 			   s->sk_protocol,
 			   nlk->pid,
 			   nlk->groups ? (u32)nlk->groups[0] : 0,
 			   sk_rmem_alloc_get(s),
 			   sk_wmem_alloc_get(s),
-			   nlk->cb,
+			   0,
 			   atomic_read(&s->sk_refcnt),
 			   atomic_read(&s->sk_drops),
 			   sock_i_ino(s)



