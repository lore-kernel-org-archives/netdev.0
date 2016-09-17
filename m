From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] rxrpc: Make IPv6 support conditional on CONFIG_IPV6
Date: Sat, 17 Sep 2016 07:26:01 +0100
Message-ID: <147409356125.30214.18028040340873709660.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add CONFIG_AF_RXRPC_IPV6 and make the IPv6 support code conditional on it.
This is then made conditional on CONFIG_IPV6.

Without this, the following can be seen:

   net/built-in.o: In function `rxrpc_init_peer':
>> peer_object.c:(.text+0x18c3c8): undefined reference to `ip6_route_output_flags'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Kconfig        |    7 +++++++
 net/rxrpc/af_rxrpc.c     |    7 ++++++-
 net/rxrpc/conn_object.c  |    2 ++
 net/rxrpc/local_object.c |    2 ++
 net/rxrpc/output.c       |    2 ++
 net/rxrpc/peer_event.c   |    4 +++-
 net/rxrpc/peer_object.c  |   10 ++++++++++
 net/rxrpc/utils.c        |    2 ++
 8 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index 784c53163b7b..13396c74b5c1 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -19,6 +19,13 @@ config AF_RXRPC
 
 	  See Documentation/networking/rxrpc.txt.
 
+config AF_RXRPC_IPV6
+	bool "IPv6 support for RxRPC"
+	depends on (IPV6 = m && AF_RXRPC = m) || (IPV6 = y && AF_RXRPC)
+	help
+	  Say Y here to allow AF_RXRPC to use IPV6 UDP as well as IPV4 UDP as
+	  its network transport.
+
 
 config AF_RXRPC_DEBUG
 	bool "RxRPC dynamic debugging"
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index f61f7b2d1ca4..09f81befc705 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -109,12 +109,14 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 		tail = offsetof(struct sockaddr_rxrpc, transport.sin.__pad);
 		break;
 
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		if (srx->transport_len < sizeof(struct sockaddr_in6))
 			return -EINVAL;
 		tail = offsetof(struct sockaddr_rxrpc, transport) +
 			sizeof(struct sockaddr_in6);
 		break;
+#endif
 
 	default:
 		return -EAFNOSUPPORT;
@@ -413,9 +415,11 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 		case AF_INET:
 			rx->srx.transport_len = sizeof(struct sockaddr_in);
 			break;
+#ifdef CONFIG_AF_RXRPC_IPV6
 		case AF_INET6:
 			rx->srx.transport_len = sizeof(struct sockaddr_in6);
 			break;
+#endif
 		default:
 			ret = -EAFNOSUPPORT;
 			goto error_unlock;
@@ -570,7 +574,8 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 		return -EAFNOSUPPORT;
 
 	/* we support transport protocol UDP/UDP6 only */
-	if (protocol != PF_INET && protocol != PF_INET6)
+	if (protocol != PF_INET &&
+	    IS_ENABLED(CONFIG_AF_RXRPC_IPV6) && protocol != PF_INET6)
 		return -EPROTONOSUPPORT;
 
 	if (sock->type != SOCK_DGRAM)
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index c0ddba787fd4..bb1f29280aea 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -134,6 +134,7 @@ struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *local,
 			    srx.transport.sin.sin_addr.s_addr)
 				goto not_found;
 			break;
+#ifdef CONFIG_AF_RXRPC_IPV6
 		case AF_INET6:
 			if (peer->srx.transport.sin6.sin6_port !=
 			    srx.transport.sin6.sin6_port ||
@@ -142,6 +143,7 @@ struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *local,
 				   sizeof(struct in6_addr)) != 0)
 				goto not_found;
 			break;
+#endif
 		default:
 			BUG();
 		}
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index f5b9bb0d3f98..e3fad80b0795 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -58,6 +58,7 @@ static long rxrpc_local_cmp_key(const struct rxrpc_local *local,
 			memcmp(&local->srx.transport.sin.sin_addr,
 			       &srx->transport.sin.sin_addr,
 			       sizeof(struct in_addr));
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		/* If the choice of UDP6 port is left up to the transport, then
 		 * the endpoint record doesn't match.
@@ -67,6 +68,7 @@ static long rxrpc_local_cmp_key(const struct rxrpc_local *local,
 			memcmp(&local->srx.transport.sin6.sin6_addr,
 			       &srx->transport.sin6.sin6_addr,
 			       sizeof(struct in6_addr));
+#endif
 	default:
 		BUG();
 	}
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index d7cd87f17f0d..06a9aca739d1 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -259,6 +259,7 @@ send_fragmentable:
 		}
 		break;
 
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		opt = IPV6_PMTUDISC_DONT;
 		ret = kernel_setsockopt(conn->params.local->socket,
@@ -274,6 +275,7 @@ send_fragmentable:
 					  (char *)&opt, sizeof(opt));
 		}
 		break;
+#endif
 	}
 
 	up_write(&conn->params.local->defrag_sem);
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 74217589cf44..9e0725f5652b 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -66,6 +66,7 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 		}
 		break;
 
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		srx.transport.sin6.sin6_port = serr->port;
 		srx.transport_len = sizeof(struct sockaddr_in6);
@@ -78,7 +79,7 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 			break;
 		case SO_EE_ORIGIN_ICMP:
 			_net("Rx ICMP on v6 sock");
-			memcpy(&srx.transport.sin6.sin6_addr.s6_addr + 12,
+			memcpy(srx.transport.sin6.sin6_addr.s6_addr + 12,
 			       skb_network_header(skb) + serr->addr_offset,
 			       sizeof(struct in_addr));
 			break;
@@ -89,6 +90,7 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 			break;
 		}
 		break;
+#endif
 
 	default:
 		BUG();
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index dfc07b41a472..f3e5766910fd 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -52,11 +52,13 @@ static unsigned long rxrpc_peer_hash_key(struct rxrpc_local *local,
 		size = sizeof(srx->transport.sin.sin_addr);
 		p = (u16 *)&srx->transport.sin.sin_addr;
 		break;
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		hash_key += (u16 __force)srx->transport.sin.sin_port;
 		size = sizeof(srx->transport.sin6.sin6_addr);
 		p = (u16 *)&srx->transport.sin6.sin6_addr;
 		break;
+#endif
 	default:
 		WARN(1, "AF_RXRPC: Unsupported transport address family\n");
 		return 0;
@@ -100,12 +102,14 @@ static long rxrpc_peer_cmp_key(const struct rxrpc_peer *peer,
 			memcmp(&peer->srx.transport.sin.sin_addr,
 			       &srx->transport.sin.sin_addr,
 			       sizeof(struct in_addr));
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		return ((u16 __force)peer->srx.transport.sin6.sin6_port -
 			(u16 __force)srx->transport.sin6.sin6_port) ?:
 			memcmp(&peer->srx.transport.sin6.sin6_addr,
 			       &srx->transport.sin6.sin6_addr,
 			       sizeof(struct in6_addr));
+#endif
 	default:
 		BUG();
 	}
@@ -159,7 +163,9 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 	struct rtable *rt;
 	struct flowi fl;
 	struct flowi4 *fl4 = &fl.u.ip4;
+#ifdef CONFIG_AF_RXRPC_IPV6
 	struct flowi6 *fl6 = &fl.u.ip6;
+#endif
 
 	peer->if_mtu = 1500;
 
@@ -177,6 +183,7 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 		dst = &rt->dst;
 		break;
 
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		fl6->flowi6_iif = LOOPBACK_IFINDEX;
 		fl6->flowi6_scope = RT_SCOPE_UNIVERSE;
@@ -191,6 +198,7 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 			return;
 		}
 		break;
+#endif
 
 	default:
 		BUG();
@@ -241,9 +249,11 @@ static void rxrpc_init_peer(struct rxrpc_peer *peer, unsigned long hash_key)
 	case AF_INET:
 		peer->hdrsize = sizeof(struct iphdr);
 		break;
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		peer->hdrsize = sizeof(struct ipv6hdr);
 		break;
+#endif
 	default:
 		BUG();
 	}
diff --git a/net/rxrpc/utils.c b/net/rxrpc/utils.c
index b88914d53ca5..ff7af71c4b49 100644
--- a/net/rxrpc/utils.c
+++ b/net/rxrpc/utils.c
@@ -30,6 +30,7 @@ int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *srx, struct sk_buff *skb)
 		srx->transport.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
 		return 0;
 
+#ifdef CONFIG_AF_RXRPC_IPV6
 	case ETH_P_IPV6:
 		srx->transport_type = SOCK_DGRAM;
 		srx->transport_len = sizeof(srx->transport.sin6);
@@ -37,6 +38,7 @@ int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *srx, struct sk_buff *skb)
 		srx->transport.sin6.sin6_port = udp_hdr(skb)->source;
 		srx->transport.sin6.sin6_addr = ipv6_hdr(skb)->saddr;
 		return 0;
+#endif
 
 	default:
 		pr_warn_ratelimited("AF_RXRPC: Unknown eth protocol %u\n",
