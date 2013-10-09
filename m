From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: fix build errors if ipv6 is disabled
Date: Wed, 09 Oct 2013 03:05:48 -0700
Message-ID: <1381313148.4971.13.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381295165.4971.7.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:50828 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757159Ab3JIKFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 06:05:50 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so820133pab.1
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 03:05:49 -0700 (PDT)
In-Reply-To: <1381295165.4971.7.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

CONFIG_IPV6=n is still a valid choice ;)

It appears we can remove dead code.

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: add the missing right parenthesis in ping_bind()

 include/net/ip6_checksum.h |    2 ++
 net/ipv4/ping.c            |    8 +++++---
 net/ipv4/tcp_metrics.c     |    4 ++++
 net/sunrpc/svcsock.c       |    2 ++
 security/lsm_audit.c       |    2 ++
 5 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 1944406..9e3c540 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -66,12 +66,14 @@ static inline void __tcp_v6_send_check(struct sk_buff *skb,
 	}
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
 static inline void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 
 	__tcp_v6_send_check(skb, &np->saddr, &sk->sk_v6_daddr);
 }
+#endif
 
 int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
 #endif
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index ccefc07..a10988a 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -415,10 +415,12 @@ int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		 (int)sk->sk_bound_dev_if);
 
 	err = 0;
-	if ((sk->sk_family == AF_INET && isk->inet_rcv_saddr) ||
-	    (sk->sk_family == AF_INET6 &&
-	     !ipv6_addr_any(&sk->sk_v6_rcv_saddr)))
+	if (sk->sk_family == AF_INET && isk->inet_rcv_saddr)
 		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6 && !ipv6_addr_any(&sk->sk_v6_rcv_saddr))
+		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
+#endif
 
 	if (snum)
 		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 27535fd..8fcc2cb 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -251,10 +251,12 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 		addr.addr.a4 = tw->tw_daddr;
 		hash = (__force unsigned int) addr.addr.a4;
 		break;
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		*(struct in6_addr *)addr.addr.a6 = tw->tw_v6_daddr;
 		hash = ipv6_addr_hash(&tw->tw_v6_daddr);
 		break;
+#endif
 	default:
 		return NULL;
 	}
@@ -286,10 +288,12 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 		addr.addr.a4 = inet_sk(sk)->inet_daddr;
 		hash = (__force unsigned int) addr.addr.a4;
 		break;
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		*(struct in6_addr *)addr.addr.a6 = sk->sk_v6_daddr;
 		hash = ipv6_addr_hash(&sk->sk_v6_daddr);
 		break;
+#endif
 	default:
 		return NULL;
 	}
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0045c7c..b6e59f0 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -291,12 +291,14 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 				&inet_sk(sk)->inet_rcv_saddr,
 				inet_sk(sk)->inet_num);
 		break;
+#if IS_ENABLED(CONFIG_IPV6)
 	case PF_INET6:
 		len = snprintf(buf, remaining, "ipv6 %s %pI6 %d\n",
 				proto_name,
 				&sk->sk_v6_rcv_saddr,
 				inet_sk(sk)->inet_num);
 		break;
+#endif
 	default:
 		len = snprintf(buf, remaining, "*unknown-%d*\n",
 				sk->sk_family);
diff --git a/security/lsm_audit.c b/security/lsm_audit.c
index 80554fc..234bc2a 100644
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -302,6 +302,7 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 						"faddr", "fport");
 				break;
 			}
+#if IS_ENABLED(CONFIG_IPV6)
 			case AF_INET6: {
 				struct inet_sock *inet = inet_sk(sk);
 
@@ -313,6 +314,7 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 						"faddr", "fport");
 				break;
 			}
+#endif
 			case AF_UNIX:
 				u = unix_sk(sk);
 				if (u->path.dentry) {
