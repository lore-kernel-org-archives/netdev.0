From: Dilip Daya <dilip.daya@hp.com>
Subject: network-namespace and unix-domain-sockets
Date: Fri, 28 Sep 2012 10:12:44 -0400
Message-ID: <1348841564.32187.7.camel@pro6455b.example.com>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-XnNjqiG1yJ+oDaydGCtG"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:38612 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714Ab2I1OMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 10:12:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XnNjqiG1yJ+oDaydGCtG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi Eric,

=> kernel 3.6.0-rc6 + network-namespace + unix-domain-sockets

srv/cli sample programs at:
<http://tkhanson.net/cgit.cgi/misc.git/plain/unixdomain/Unix_domain_sockets.html>
Executing UNIX domain sockets between two network-namespaces fails but
successful if both srv and cli are executed within a network-namespace.

Test results:

(1) Executing both srv and cli within default/host network-namespace:

On host/default netns:
# ./cli 
testing...
^C

On host/default netns:
# ./srv 
read 11 bytes: testing...

EOF


(2) Executing srv in default/host netns and cli within netns named
netns0:

On host/default netns:
# ip netns
netns1
netns0

On host/default netns:
# ./srv 

Within netns name netns0:
# ip netns exec netns0 ./cli
connect error: Connection refused


=> I find difference between __unix_find_socket_byname()  and
                              *unix_find_socket_byinode()

	---
		if (!net_eq(sock_net(s), net))
			continue;
	---

=> Is there an explanation for why __unix_find_socket_byname() was left
   netns aware and *unix_find_socket_byinode() is not netns aware ?

=> Please see attached patch. Is this valid? or will it break something?
   I've tested network namespaces with this patch applied and I did not 
   find any issues.

-DilipD.

--=-XnNjqiG1yJ+oDaydGCtG
Content-Disposition: attachment; filename="unix_sockets_netns.patch"
Content-Type: text/x-patch; name="unix_sockets_netns.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- linux-3.6-rc6/net/unix/af_unix.c_orig	2012-09-27 14:25:27.000000000 -0400
+++ linux-3.6-rc6/net/unix/af_unix.c	2012-09-27 14:44:41.000000000 -0400
@@ -258,8 +258,7 @@ static inline void unix_insert_socket(st
 	spin_unlock(&unix_table_lock);
 }
 
-static struct sock *__unix_find_socket_byname(struct net *net,
-					      struct sockaddr_un *sunname,
+static struct sock *__unix_find_socket_byname(struct sockaddr_un *sunname,
 					      int len, int type, unsigned int hash)
 {
 	struct sock *s;
@@ -268,9 +267,6 @@ static struct sock *__unix_find_socket_b
 	sk_for_each(s, node, &unix_socket_table[hash ^ type]) {
 		struct unix_sock *u = unix_sk(s);
 
-		if (!net_eq(sock_net(s), net))
-			continue;
-
 		if (u->addr->len == len &&
 		    !memcmp(u->addr->name, sunname, len))
 			goto found;
@@ -280,15 +276,14 @@ found:
 	return s;
 }
 
-static inline struct sock *unix_find_socket_byname(struct net *net,
-						   struct sockaddr_un *sunname,
+static inline struct sock *unix_find_socket_byname(struct sockaddr_un *sunname,
 						   int len, int type,
 						   unsigned int hash)
 {
 	struct sock *s;
 
 	spin_lock(&unix_table_lock);
-	s = __unix_find_socket_byname(net, sunname, len, type, hash);
+	s = __unix_find_socket_byname(sunname, len, type, hash);
 	if (s)
 		sock_hold(s);
 	spin_unlock(&unix_table_lock);
@@ -740,7 +735,7 @@ retry:
 	spin_lock(&unix_table_lock);
 	ordernum = (ordernum+1)&0xFFFFF;
 
-	if (__unix_find_socket_byname(net, addr->name, addr->len, sock->type,
+	if (__unix_find_socket_byname(addr->name, addr->len, sock->type,
 				      addr->hash)) {
 		spin_unlock(&unix_table_lock);
 		/*
@@ -805,7 +800,7 @@ static struct sock *unix_find_other(stru
 		}
 	} else {
 		err = -ECONNREFUSED;
-		u = unix_find_socket_byname(net, sunname, len, type, hash);
+		u = unix_find_socket_byname(sunname, len, type, hash);
 		if (u) {
 			struct dentry *dentry;
 			dentry = unix_sk(u)->path.dentry;
@@ -913,7 +908,7 @@ static int unix_bind(struct socket *sock
 	} else {
 		spin_lock(&unix_table_lock);
 		err = -EADDRINUSE;
-		if (__unix_find_socket_byname(net, sunaddr, addr_len,
+		if (__unix_find_socket_byname(sunaddr, addr_len,
 					      sk->sk_type, hash)) {
 			unix_release_addr(addr);
 			goto out_unlock;

--=-XnNjqiG1yJ+oDaydGCtG--
