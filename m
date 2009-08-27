From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: af_inet.c cleanups
Date: Thu, 27 Aug 2009 15:35:03 +0200
Message-ID: <4A968B87.8090001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43923 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbZH0NfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 09:35:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/af_inet.c |  112 +++++++++++++++++++++----------------------
 1 files changed, 55 insertions(+), 57 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 197d024..6c30a73 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -124,7 +124,6 @@ static struct list_head inetsw[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw_lock);
 
 struct ipv4_config ipv4_config;
-
 EXPORT_SYMBOL(ipv4_config);
 
 /* New destruction routine */
@@ -139,12 +138,12 @@ void inet_sock_destruct(struct sock *sk)
 	sk_mem_reclaim(sk);
 
 	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
-		printk("Attempt to release TCP socket in state %d %p\n",
+		pr_err("Attempt to release TCP socket in state %d %p\n",
 		       sk->sk_state, sk);
 		return;
 	}
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk("Attempt to release alive inet socket %p\n", sk);
+		pr_err("Attempt to release alive inet socket %p\n", sk);
 		return;
 	}
 
@@ -157,6 +156,7 @@ void inet_sock_destruct(struct sock *sk)
 	dst_release(sk->sk_dst_cache);
 	sk_refcnt_debug_dec(sk);
 }
+EXPORT_SYMBOL(inet_sock_destruct);
 
 /*
  *	The routines beyond this point handle the behaviour of an AF_INET
@@ -219,6 +219,7 @@ out:
 	release_sock(sk);
 	return err;
 }
+EXPORT_SYMBOL(inet_listen);
 
 u32 inet_ehash_secret __read_mostly;
 EXPORT_SYMBOL(inet_ehash_secret);
@@ -435,9 +436,11 @@ int inet_release(struct socket *sock)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(inet_release);
 
 /* It is off by default, see below. */
 int sysctl_ip_nonlocal_bind __read_mostly;
+EXPORT_SYMBOL(sysctl_ip_nonlocal_bind);
 
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
@@ -519,6 +522,7 @@ out_release_sock:
 out:
 	return err;
 }
+EXPORT_SYMBOL(inet_bind);
 
 int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
 		       int addr_len, int flags)
@@ -532,6 +536,7 @@ int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
 		return -EAGAIN;
 	return sk->sk_prot->connect(sk, (struct sockaddr *)uaddr, addr_len);
 }
+EXPORT_SYMBOL(inet_dgram_connect);
 
 static long inet_wait_for_connect(struct sock *sk, long timeo)
 {
@@ -641,6 +646,7 @@ sock_error:
 		sock->state = SS_DISCONNECTING;
 	goto out;
 }
+EXPORT_SYMBOL(inet_stream_connect);
 
 /*
  *	Accept a pending connection. The TCP layer now gives BSD semantics.
@@ -668,6 +674,7 @@ int inet_accept(struct socket *sock, struct socket *newsock, int flags)
 do_err:
 	return err;
 }
+EXPORT_SYMBOL(inet_accept);
 
 
 /*
@@ -699,6 +706,7 @@ int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 	*uaddr_len = sizeof(*sin);
 	return 0;
 }
+EXPORT_SYMBOL(inet_getname);
 
 int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		 size_t size)
@@ -711,9 +719,11 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 
 	return sk->sk_prot->sendmsg(iocb, sk, msg, size);
 }
+EXPORT_SYMBOL(inet_sendmsg);
 
 
-static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
+static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+			     size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 
@@ -780,6 +790,7 @@ int inet_shutdown(struct socket *sock, int how)
 	release_sock(sk);
 	return err;
 }
+EXPORT_SYMBOL(inet_shutdown);
 
 /*
  *	ioctl() calls you can issue on an INET socket. Most of these are
@@ -798,44 +809,45 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	struct net *net = sock_net(sk);
 
 	switch (cmd) {
-		case SIOCGSTAMP:
-			err = sock_get_timestamp(sk, (struct timeval __user *)arg);
-			break;
-		case SIOCGSTAMPNS:
-			err = sock_get_timestampns(sk, (struct timespec __user *)arg);
-			break;
-		case SIOCADDRT:
-		case SIOCDELRT:
-		case SIOCRTMSG:
-			err = ip_rt_ioctl(net, cmd, (void __user *)arg);
-			break;
-		case SIOCDARP:
-		case SIOCGARP:
-		case SIOCSARP:
-			err = arp_ioctl(net, cmd, (void __user *)arg);
-			break;
-		case SIOCGIFADDR:
-		case SIOCSIFADDR:
-		case SIOCGIFBRDADDR:
-		case SIOCSIFBRDADDR:
-		case SIOCGIFNETMASK:
-		case SIOCSIFNETMASK:
-		case SIOCGIFDSTADDR:
-		case SIOCSIFDSTADDR:
-		case SIOCSIFPFLAGS:
-		case SIOCGIFPFLAGS:
-		case SIOCSIFFLAGS:
-			err = devinet_ioctl(net, cmd, (void __user *)arg);
-			break;
-		default:
-			if (sk->sk_prot->ioctl)
-				err = sk->sk_prot->ioctl(sk, cmd, arg);
-			else
-				err = -ENOIOCTLCMD;
-			break;
+	case SIOCGSTAMP:
+		err = sock_get_timestamp(sk, (struct timeval __user *)arg);
+		break;
+	case SIOCGSTAMPNS:
+		err = sock_get_timestampns(sk, (struct timespec __user *)arg);
+		break;
+	case SIOCADDRT:
+	case SIOCDELRT:
+	case SIOCRTMSG:
+		err = ip_rt_ioctl(net, cmd, (void __user *)arg);
+		break;
+	case SIOCDARP:
+	case SIOCGARP:
+	case SIOCSARP:
+		err = arp_ioctl(net, cmd, (void __user *)arg);
+		break;
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+	case SIOCGIFBRDADDR:
+	case SIOCSIFBRDADDR:
+	case SIOCGIFNETMASK:
+	case SIOCSIFNETMASK:
+	case SIOCGIFDSTADDR:
+	case SIOCSIFDSTADDR:
+	case SIOCSIFPFLAGS:
+	case SIOCGIFPFLAGS:
+	case SIOCSIFFLAGS:
+		err = devinet_ioctl(net, cmd, (void __user *)arg);
+		break;
+	default:
+		if (sk->sk_prot->ioctl)
+			err = sk->sk_prot->ioctl(sk, cmd, arg);
+		else
+			err = -ENOIOCTLCMD;
+		break;
 	}
 	return err;
 }
+EXPORT_SYMBOL(inet_ioctl);
 
 const struct proto_ops inet_stream_ops = {
 	.family		   = PF_INET,
@@ -862,6 +874,7 @@ const struct proto_ops inet_stream_ops = {
 	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
 };
+EXPORT_SYMBOL(inet_stream_ops);
 
 const struct proto_ops inet_dgram_ops = {
 	.family		   = PF_INET,
@@ -887,6 +900,7 @@ const struct proto_ops inet_dgram_ops = {
 	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
 };
+EXPORT_SYMBOL(inet_dgram_ops);
 
 /*
  * For SOCK_RAW sockets; should be the same as inet_dgram_ops but without
@@ -1016,6 +1030,7 @@ out_illegal:
 	       p->type);
 	goto out;
 }
+EXPORT_SYMBOL(inet_register_protosw);
 
 void inet_unregister_protosw(struct inet_protosw *p)
 {
@@ -1031,6 +1046,7 @@ void inet_unregister_protosw(struct inet_protosw *p)
 		synchronize_net();
 	}
 }
+EXPORT_SYMBOL(inet_unregister_protosw);
 
 /*
  *      Shall we try to damage output packets if routing dev changes?
@@ -1141,7 +1157,6 @@ int inet_sk_rebuild_header(struct sock *sk)
 
 	return err;
 }
-
 EXPORT_SYMBOL(inet_sk_rebuild_header);
 
 static int inet_gso_send_check(struct sk_buff *skb)
@@ -1369,7 +1384,6 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 	}
 	return rc;
 }
-
 EXPORT_SYMBOL_GPL(inet_ctl_sock_create);
 
 unsigned long snmp_fold_field(void *mib[], int offt)
@@ -1676,19 +1690,3 @@ static int __init ipv4_proc_init(void)
 
 MODULE_ALIAS_NETPROTO(PF_INET);
 
-EXPORT_SYMBOL(inet_accept);
-EXPORT_SYMBOL(inet_bind);
-EXPORT_SYMBOL(inet_dgram_connect);
-EXPORT_SYMBOL(inet_dgram_ops);
-EXPORT_SYMBOL(inet_getname);
-EXPORT_SYMBOL(inet_ioctl);
-EXPORT_SYMBOL(inet_listen);
-EXPORT_SYMBOL(inet_register_protosw);
-EXPORT_SYMBOL(inet_release);
-EXPORT_SYMBOL(inet_sendmsg);
-EXPORT_SYMBOL(inet_shutdown);
-EXPORT_SYMBOL(inet_sock_destruct);
-EXPORT_SYMBOL(inet_stream_connect);
-EXPORT_SYMBOL(inet_stream_ops);
-EXPORT_SYMBOL(inet_unregister_protosw);
-EXPORT_SYMBOL(sysctl_ip_nonlocal_bind);
