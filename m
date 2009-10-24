From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net,socket: introduce build_sockaddr_check helper to
	catch overflow at build time
Date: Sat, 24 Oct 2009 20:32:26 +0400
Message-ID: <20091024163226.GA5204@lenovo>
References: <20091022.044914.36401063.davem@davemloft.net> <20091022135557.GA5162@lenovo> <20091023214306.GA30616@lenovo> <20091024.061209.39469983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:35421 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbZJXQcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 12:32:25 -0400
Received: by ewy4 with SMTP id 4so2475790ewy.37
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 09:32:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091024.061209.39469983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[David Miller - Sat, Oct 24, 2009 at 06:12:09AM -0700]
| From: Cyrill Gorcunov <gorcunov@gmail.com>
| Date: Sat, 24 Oct 2009 01:43:06 +0400
| 
| > Or say it could be something like that
| > 
| > #define __sockaddr(type, src)	\
| > 	({ build_sockaddr_check(sizeof(type)); (type *) src; })
| > 
| > and say in function af_inet.c:inet_getname instead of
| > 
| > 	struct sockaddr_in *sin	= (struct sockaddr_in *)uaddr;
| > 
| > we may write like
| > 
| > 	struct sockaddr_in *sin	= __sockaddr(struct sockaddr_in, uaddr);
| > 
| > which would check the size.
| 
| Or even a "DECLARE_SOCKADDR(type, src, dest)" which encapsulates the
| entire declaration statement.
| 

Something like this I suppose?

	-- Cyrill
---
net,socket: introduce DECLARE_SOCKADDR helper to catch overflow at build time

proto_ops->getname implies copying protocol specific data
into storage unit (particulary to __kernel_sockaddr_storage).
So when we implement new protocol support we should keep such
a detail in mind (which is easy to forget about).

Lets introduce DECLARE_SOCKADDR helper which check if
storage unit is not overfowed at build time.

Eventually inet_getname is switched to use DECLARE_SOCKADDR
(to show example of usage).

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 include/linux/net.h    |    3 +++
 include/linux/socket.h |    3 +++
 net/ipv4/af_inet.c     |    2 +-
 3 files changed, 7 insertions(+), 1 deletion(-)

Index: linux-2.6.git/include/linux/net.h
=====================================================================
--- linux-2.6.git.orig/include/linux/net.h
+++ linux-2.6.git/include/linux/net.h
@@ -198,6 +198,9 @@ struct proto_ops {
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
 };
 
+#define DECLARE_SOCKADDR(type, dst, src)	\
+	type dst = ({ __sockaddr_check_size(sizeof(*dst)); (type) src; })
+
 struct net_proto_family {
 	int		family;
 	int		(*create)(struct net *net, struct socket *sock, int protocol);
Index: linux-2.6.git/include/linux/socket.h
=====================================================================
--- linux-2.6.git.orig/include/linux/socket.h
+++ linux-2.6.git/include/linux/socket.h
@@ -24,6 +24,9 @@ struct __kernel_sockaddr_storage {
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
 
+#define __sockaddr_check_size(size)	\
+	BUILD_BUG_ON(((size) > sizeof(struct __kernel_sockaddr_storage)))
+
 #ifdef __KERNEL__
 # ifdef CONFIG_PROC_FS
 struct seq_file;
Index: linux-2.6.git/net/ipv4/af_inet.c
=====================================================================
--- linux-2.6.git.orig/net/ipv4/af_inet.c
+++ linux-2.6.git/net/ipv4/af_inet.c
@@ -685,7 +685,7 @@ int inet_getname(struct socket *sock, st
 {
 	struct sock *sk		= sock->sk;
 	struct inet_sock *inet	= inet_sk(sk);
-	struct sockaddr_in *sin	= (struct sockaddr_in *)uaddr;
+	DECLARE_SOCKADDR(struct sockaddr_in *, sin, uaddr);
 
 	sin->sin_family = AF_INET;
 	if (peer) {
