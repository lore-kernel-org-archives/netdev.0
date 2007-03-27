From: dagriego@gmail.com (David Griego)
Subject: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 14:47:54 -0700
Message-ID: <20070327214754.GA11677@dag-work>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.ne
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.236]:24900 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932911AbXC0Vr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:47:57 -0400
Received: by nz-out-0506.google.com with SMTP id s1so2558228nze
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 14:47:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds an IOCTL for aborting established TCP connections, and is
designed to be an HA performance improvement for cleaning up, failure 
notification, and application termination.

Signed-off-by:  David Griego <dagriego@gmail.com>
---

 include/linux/ipv6.h          |    8 ++++
 include/linux/socket.h        |    5 ++
 include/linux/sockios.h       |    1 
 include/net/inet_hashtables.h |    6 +++
 net/ipv4/tcp.c                |   15 +++++++
 net/ipv4/tcp_ipv4.c           |   86 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 121 insertions(+), 0 deletions(-)
---

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index f824113..42f6765 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -467,6 +467,14 @@ #define INET6_MATCH(__sk, __hash, __sadd
 	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&& \
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 
+#define TCP_IPV6_WILDCARD_MATCH(__sk, __saddr, __sport,__daddr, __dport) \
+	((ipv6_addr_any(&__saddr) 					|| \
+	  ipv6_addr_equal(&__saddr, &inet6_sk(__sk)->saddr))		&& \
+	 ((!__sport) || (ntohs(__sport) == inet_sk(__sk)->num))		&& \
+	 (ipv6_addr_any(&__daddr)					|| \
+	   ipv6_addr_equal(&__daddr, &inet6_sk(__sk)->daddr))		&& \
+	 ((!__dport) || (__dport ==  inet_sk(__sk)->dport)))
+
 #endif /* __KERNEL__ */
 
 #endif /* _IPV6_H */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index fcd35a2..0bf7b0a 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -48,6 +48,11 @@ struct linger {
 
 #define sockaddr_storage __kernel_sockaddr_storage
 
+struct tcp_abort_sockaddr_storage {
+	struct sockaddr_storage local;	/* local address for lookup */
+	struct sockaddr_storage remote;	/* Remote address for lookup */
+};
+
 /*
  *	As we do 4.4BSD message passing we use a 4.4BSD message passing
  *	system, not 4.3. Thus msg_accrights(len) are now missing. They
diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index abef759..b850577 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -140,4 +140,5 @@ #define SIOCDEVPRIVATE	0x89F0	/* to 89FF
  */
  
 #define SIOCPROTOPRIVATE 0x89E0 /* to 89EF */
+#define SIOCABORTCONN SIOCPROTOPRIVATE + 1
 #endif	/* _LINUX_SOCKIOS_H */
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index d27ee8c..735739a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -339,6 +339,12 @@ #define INET_TW_MATCH(__sk, __hash,__coo
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #endif /* 64-bit arch */
 
+#define TCP_IPV4_WILDCARD_MATCH(__sk, __saddr, __sport,__daddr, __dport)    \
+	(((__saddr == INADDR_ANY) || (__saddr ==  inet_sk(__sk)->saddr)) && \
+	 ((!__sport) || (ntohs(__sport) == inet_sk(__sk)->num)) 	 && \
+	 ((__daddr == INADDR_ANY) || (__daddr == inet_sk(__sk)->daddr))  && \
+	 ((!__dport) || (__dport ==  inet_sk(__sk)->dport)))
+
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so we need
  * not check it for lookups anymore, thanks Alexey. -DaveM
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3834b10..b3e7a6f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -442,6 +442,21 @@ int tcp_ioctl(struct sock *sk, int cmd, 
 		else
 			answ = tp->write_seq - tp->snd_una;
 		break;
+	case SIOCABORTCONN:
+	{
+		struct tcp_abort_sockaddr_storage tcp_abort;
+		void __user *data = (void __user *)arg;
+
+		if (!capable(CAP_NET_ADMIN)){
+			return -EACCES;
+		}
+
+		/* Check permissions */
+		if (copy_from_user(&tcp_abort, data, sizeof(tcp_abort))) {
+			return -EFAULT;
+		}
+		return tcp_handle_abort_req(&tcp_abort.local, &tcp_abort.remote);
+	}
 	default:
 		return -ENOIOCTLCMD;
 	};
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ba74bb..add483b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -123,6 +123,91 @@ void tcp_unhash(struct sock *sk)
 	inet_unhash(&tcp_hashinfo, sk);
 }
 
+int tcp_handle_abort_req(struct sockaddr_storage *local, 
+		struct sockaddr_storage *remote)
+{
+	int i, ret = -ENOENT;
+
+	/* Check for supported address families */
+	if((local->ss_family != remote->ss_family) ||
+	   ((local->ss_family != AF_INET) && (local->ss_family != AF_INET6)))
+		return -EINVAL;
+
+	local_bh_disable();
+
+	/* cycle through all the established connecton buckets */
+	for (i = 0; i < tcp_hashinfo.ehash_size; ++i) {
+		struct sock *sk;
+		struct hlist_node *node;
+restart_bucket:
+
+		read_lock(&tcp_hashinfo.ehash[i].lock);
+		sk_for_each(sk, node, &tcp_hashinfo.ehash[i].chain) {
+			if (sk->sk_family != local->ss_family) {
+				continue;
+			}
+
+			switch(local->ss_family) {
+			case AF_INET:
+				{
+				struct sockaddr_in *ipv4_local = 
+					(struct sockaddr_in *)local;
+				struct sockaddr_in *ipv4_remote = 
+					(struct sockaddr_in *)remote;
+
+				if(TCP_IPV4_WILDCARD_MATCH(sk,
+						ipv4_local->sin_addr.s_addr,
+						ipv4_local->sin_port,
+						ipv4_remote->sin_addr.s_addr,
+						ipv4_remote->sin_port))
+					break;
+				continue;
+			}
+#ifdef CONFIG_IPV6
+			case AF_INET6:
+				{
+				struct sockaddr_in6 *ipv6_local =
+					(struct sockaddr_in6 *)local;
+				struct sockaddr_in6 *ipv6_remote = 
+					(struct sockaddr_in6 *)remote;
+				
+				if(TCP_IPV6_WILDCARD_MATCH(sk,
+						ipv6_local->sin6_addr,
+						ipv6_local->sin6_port,
+						ipv6_remote->sin6_addr,
+						ipv6_remote->sin6_port))
+					break;
+				continue;
+			}
+#endif /*CONFIG_IPV6 */
+			default: /* Not a supported address family */
+				continue;
+			}
+
+			/* Found a match so kill it */
+			ret = 0;
+			sock_hold(sk);
+			read_unlock(&tcp_hashinfo.ehash[i].lock);
+			local_bh_enable();
+			tcp_disconnect(sk, O_NONBLOCK);
+			local_bh_disable();
+			sock_put(sk);
+
+			/* Broke link and let go of the list lock, so restart
+			 * our search for matches at the begining of this
+			 * hash bucket
+			 */
+			goto restart_bucket;
+		}
+
+		read_unlock(&tcp_hashinfo.ehash[i].lock);
+	}
+
+	local_bh_enable();
+
+	return ret;
+}
+
 static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(skb->nh.iph->daddr,
@@ -2462,6 +2547,7 @@ EXPORT_SYMBOL(ipv4_specific);
 EXPORT_SYMBOL(tcp_hashinfo);
 EXPORT_SYMBOL(tcp_prot);
 EXPORT_SYMBOL(tcp_unhash);
+EXPORT_SYMBOL(tcp_handle_abort_req);
 EXPORT_SYMBOL(tcp_v4_conn_request);
 EXPORT_SYMBOL(tcp_v4_connect);
 EXPORT_SYMBOL(tcp_v4_do_rcv);
-- 
1.4.1

