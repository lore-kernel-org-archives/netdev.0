From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: [PATCH] Crash in tun
Date: Thu, 19 Jul 2012 18:13:36 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1207191746170.7550@artax.karlin.mff.cuni.cz>
References: <alpine.DEB.2.00.1207190213001.16299@artax.karlin.mff.cuni.cz> <1342678175.2626.3849.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Maxim Krasnyansky <maxk@qualcomm.com>, vtun@office.satix.net,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from artax.karlin.mff.cuni.cz ([195.113.26.195]:38226 "EHLO
	artax.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab2GSQNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 12:13:37 -0400
In-Reply-To: <1342678175.2626.3849.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 19 Jul 2012, Eric Dumazet wrote:

> Hi Mikulas
> 
> A fix for this problem is : http://patchwork.ozlabs.org/patch/170440/

If you call tun_free_netdev beacuse of a jump to an error label 
err_free_sk, your patch still calls it with NULL file, causing a memory 
corruption and a possible crash.

Your patch doesn't fix sockets_in_use underflow.

Maybe we can commit this patch --- it introduces a new flag 
SOCK_EXTERNALLY_ALLOCATED to work around both problems. (it looks quite 
nicer than my previous patch with file = (void *)1).

Mikulas

---

tun: fix a crash bug and a memory leak

This patch fixes a crash
tun_chr_close -> netdev_run_todo -> tun_free_netdev -> sk_release_kernel ->
sock_release -> iput(SOCK_INODE(sock))
introduced by commit 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d

The problem is that this socket is embedded in struct tun_struct, it has
no inode, iput is called on invalid inode, which modifies invalid memory
and optionally causes a crash.

sock_release also decrements sockets_in_use, this causes a bug that
"sockets: used" field in /proc/*/net/sockstat keeps on decreasing when
creating and closing tun devices.

This patch introduces a flag SOCK_EXTERNALLY_ALLOCATED that instructs
sock_release to not free the inode and not decrement sockets_in_use,
fixing both memory corruption and sockets_in_use underflow.

It should be backported to 3.3 an 3.4 stabke.

Signed-off-by: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Cc: stable@kernel.org

---
 drivers/net/tun.c   |    3 +++
 include/linux/net.h |    1 +
 net/socket.c        |    3 +++
 3 files changed, 7 insertions(+)

Index: linux-3.4.5-fast/drivers/net/tun.c
===================================================================
--- linux-3.4.5-fast.orig/drivers/net/tun.c	2012-07-19 17:55:16.000000000 +0200
+++ linux-3.4.5-fast/drivers/net/tun.c	2012-07-19 17:58:30.000000000 +0200
@@ -358,6 +358,8 @@ static void tun_free_netdev(struct net_d
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
+	BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED, &tun->socket.flags));
+
 	sk_release_kernel(tun->socket.sk);
 }
 
@@ -1115,6 +1117,7 @@ static int tun_set_iff(struct net *net,
 		tun->flags = flags;
 		tun->txflt.count = 0;
 		tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
+		set_bit(SOCK_EXTERNALLY_ALLOCATED, &tun->socket.flags);
 
 		err = -ENOMEM;
 		sk = sk_alloc(&init_net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
Index: linux-3.4.5-fast/include/linux/net.h
===================================================================
--- linux-3.4.5-fast.orig/include/linux/net.h	2012-07-19 17:54:31.000000000 +0200
+++ linux-3.4.5-fast/include/linux/net.h	2012-07-19 17:55:03.000000000 +0200
@@ -72,6 +72,7 @@ struct net;
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
+#define SOCK_EXTERNALLY_ALLOCATED 5
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
Index: linux-3.4.5-fast/net/socket.c
===================================================================
--- linux-3.4.5-fast.orig/net/socket.c	2012-07-19 17:56:55.000000000 +0200
+++ linux-3.4.5-fast/net/socket.c	2012-07-19 17:57:50.000000000 +0200
@@ -522,6 +522,9 @@ void sock_release(struct socket *sock)
 	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
 
+	if (test_bit(SOCK_EXTERNALLY_ALLOCATED, &sock->flags))
+		return;
+
 	percpu_sub(sockets_in_use, 1);
 	if (!sock->file) {
 		iput(SOCK_INODE(sock));
