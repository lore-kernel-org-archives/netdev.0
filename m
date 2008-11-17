From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: make /proc/net/protocols namespace aware
Date: Mon, 17 Nov 2008 11:50:28 +0100
Message-ID: <49214C74.3020303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070206090900070705000305"
Cc: "Denis V. Lunev" <den@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43623 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbYKQKui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 05:50:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070206090900070705000305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Converting /proc/net/protocols to be namespace aware is quite easy
and permits us to use sock_prot_inuse_get().

This provides seperate counters for each protocol. For example
we can really count TCPv6 sockets and TCPv4 sockets, while previously,
we had the same value, and this value was not namespace aware.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/core/sock.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)


--------------070206090900070705000305
Content-Type: text/plain;
 name="af_unix_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_unix_inuse.patch"

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a1eb596..36856ca 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -361,6 +361,7 @@ static void unix_sock_destructor(struct sock *sk)
 		unix_release_addr(u->addr);
 
 	atomic_dec(&unix_nr_socks);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 #ifdef UNIX_REFCNT_DEBUG
 	printk(KERN_DEBUG "UNIX %p is destroyed, %d are still alive.\n", sk,
 		atomic_read(&unix_nr_socks));
@@ -612,6 +613,9 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 out:
 	if (sk == NULL)
 		atomic_dec(&unix_nr_socks);
+	else
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+		
 	return sk;
 }
 

--------------070206090900070705000305--
