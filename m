From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/3] net: Add incoming CPU mask to sockets
Date: Tue, 26 May 2015 09:34:09 -0700
Message-ID: <1432658049-3400132-4-git-send-email-tom@herbertland.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:20861 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751888AbbEZQe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 12:34:28 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4QGXtOE032099
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:34:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1umqqhghfh-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:34:27 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 129849fc03c511e5b0050002c9521c9e-a97f83a0 for <netdev@vger.kernel.org>;	Tue,
 26 May 2015 09:34:26 -0700
In-Reply-To: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added matching of CPU to a socket CPU mask. This is useful for TCP
listeners and unconnected UDP. This works with SO_REUSEPORT to steer
packets to listener sockets based on CPU affinity.

In this patch:
 - Add SO_INCOMING_CPU_MASK
 - Add a CPU mask pointer to struct sock
 - Get/setsockopt to get/set a the mask on a socket
 - Compat functions for the sockopts
 - Add sk_match_incoming_cpu_mask to check is running CPU is in a mask
   for a socket
 - Call sk_match_incoming_cpu_mask from inet compute_score and UDP
   functions for IPv4 and IPv6

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 arch/alpha/include/uapi/asm/socket.h   |  2 +
 arch/avr32/include/uapi/asm/socket.h   |  2 +
 arch/cris/include/uapi/asm/socket.h    |  2 +
 arch/frv/include/uapi/asm/socket.h     |  2 +
 arch/ia64/include/uapi/asm/socket.h    |  2 +
 arch/m32r/include/uapi/asm/socket.h    |  2 +
 arch/mips/include/uapi/asm/socket.h    |  2 +
 arch/mn10300/include/uapi/asm/socket.h |  2 +
 arch/parisc/include/uapi/asm/socket.h  |  2 +
 arch/powerpc/include/uapi/asm/socket.h |  2 +
 arch/s390/include/uapi/asm/socket.h    |  2 +
 arch/sparc/include/uapi/asm/socket.h   |  2 +
 arch/xtensa/include/uapi/asm/socket.h  |  2 +
 include/net/sock.h                     | 31 +++++++++++++
 include/uapi/asm-generic/socket.h      |  2 +
 net/compat.c                           | 56 ++++++++++++++++++++++++
 net/core/sock.c                        | 80 ++++++++++++++++++++++++++++++++++
 net/ipv4/inet_hashtables.c             |  3 ++
 net/ipv4/udp.c                         |  6 +++
 net/ipv6/inet6_hashtables.c            |  3 ++
 net/ipv6/udp.c                         |  3 ++
 21 files changed, 210 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 9a20821..eae65a2 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 2b65ed6..89515e3 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index e2503d9f..65fcf0e 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -87,6 +87,8 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 4823ad1..1af3b78 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -85,5 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 59be3d8..7ef59d3 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 7bc4cb2..53a697c 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index dec3c85..063d59d 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index cab7d6d..3c9f8e9 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index a5cd40c..557a09b 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -84,4 +84,6 @@
 #define SO_ATTACH_BPF		0x402B
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	0x402C
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index c046666..a72fac6 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 296942d..b901044 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index e6a16c4..95835a1 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -81,6 +81,8 @@
 #define SO_ATTACH_BPF		0x0034
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	0x0035
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 4120af0..0167812 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index bcf6114..8407c3b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -123,6 +123,11 @@ typedef struct {
 #endif
 } socket_lock_t;
 
+struct rcu_cpumask {
+	struct rcu_head rcu;
+	unsigned long cpumask[0];
+};
+
 struct sock;
 struct proto;
 struct net;
@@ -150,6 +155,7 @@ typedef __u64 __bitwise __addrpair;
  *	@skc_node: main hash linkage for various protocol lookup tables
  *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
  *	@skc_tx_queue_mapping: tx queue number for this connection
+ *	@skc_incoming_cpu_mask: CPU mask for listeners
  *	@skc_refcnt: reference count
  *
  *	This is the minimal network layer representation of sockets, the header
@@ -212,9 +218,12 @@ struct sock_common {
 		struct hlist_nulls_node skc_nulls_node;
 	};
 
+	struct rcu_cpumask __rcu *skc_incoming_cpu_mask;
+
 	/* Cachelines above this point are read mostly and are used in socket
 	 * lookup.
 	 */
+
 	int			skc_tx_queue_mapping
 				____cacheline_aligned_in_smp;
 
@@ -314,6 +323,7 @@ struct sock {
 #define sk_node			__sk_common.skc_node
 #define sk_nulls_node		__sk_common.skc_nulls_node
 #define sk_refcnt		__sk_common.skc_refcnt
+#define sk_incoming_cpu_mask	__sk_common.skc_incoming_cpu_mask
 #define sk_tx_queue_mapping	__sk_common.skc_tx_queue_mapping
 
 #define sk_dontcopy_begin	__sk_common.skc_dontcopy_begin
@@ -2220,6 +2230,27 @@ static inline bool sk_fullsock(const struct sock *sk)
 	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
 }
 
+static inline bool sk_match_incoming_cpu_mask(const struct sock *sk)
+{
+	struct rcu_cpumask *mask;
+	bool ret = false;
+
+	if (!sk->sk_incoming_cpu_mask)
+		return ret;
+
+	rcu_read_lock();
+
+	mask = rcu_dereference(sk->sk_incoming_cpu_mask);
+	if (likely(mask) &&
+	    cpumask_test_cpu(raw_smp_processor_id(),
+			     to_cpumask(mask->cpumask)))
+		ret = true;
+
+	rcu_read_unlock();
+
+	return ret;
+}
+
 void sock_enable_timestamp(struct sock *sk, int flag);
 int sock_get_timestamp(struct sock *, struct timeval __user *);
 int sock_get_timestampns(struct sock *, struct timespec __user *);
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 5c15c2a..d41c8b9 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -87,4 +87,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_INCOMING_CPU_MASK	51
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/compat.c b/net/compat.c
index 5cfd26a..f9fc5ce 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -351,6 +351,23 @@ static int do_set_sock_timeout(struct socket *sock, int level,
 	return err;
 }
 
+static int do_set_incoming_cpu_mask(struct socket *sock, int level,
+		int optname, char __user *optval, unsigned int optlen)
+{
+	compat_ulong_t __user *user_mask_ptr =
+	    (compat_ulong_t __user *)optval;
+	struct cpumask __user *mask = compat_alloc_user_space(cpumask_size());
+	int err;
+
+	err = compat_get_user_cpu_mask(user_mask_ptr, optlen, mask);
+	if (err)
+		return err;
+
+	return sock_setsockopt(sock, level, optname,
+			       (char __user *)cpumask_bits(mask),
+			       cpumask_size());
+}
+
 static int compat_sock_setsockopt(struct socket *sock, int level, int optname,
 				char __user *optval, unsigned int optlen)
 {
@@ -360,6 +377,10 @@ static int compat_sock_setsockopt(struct socket *sock, int level, int optname,
 	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
 		return do_set_sock_timeout(sock, level, optname, optval, optlen);
 
+	if (optname == SO_INCOMING_CPU_MASK)
+		return do_set_incoming_cpu_mask(sock, level, optname,
+						optval, optlen);
+
 	return sock_setsockopt(sock, level, optname, optval, optlen);
 }
 
@@ -419,11 +440,46 @@ static int do_get_sock_timeout(struct socket *sock, int level, int optname,
 	return err;
 }
 
+static int do_get_incoming_cpu_mask(struct socket *sock, int level,
+		int optname, char __user *optval, unsigned int __user *optlen)
+{
+	compat_ulong_t __user *user_mask_ptr =
+	    (compat_ulong_t __user *)optval;
+	struct cpumask __user *mask = compat_alloc_user_space(cpumask_size());
+	int len, err;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	if ((len * BITS_PER_BYTE) < nr_cpu_ids)
+		return -EINVAL;
+	if (len & (sizeof(compat_ulong_t) - 1))
+		return -EINVAL;
+
+	if (put_user(cpumask_size(), optlen))
+		return -EFAULT;
+
+	err = sock_getsockopt(sock, level, optname,
+			      (char __user *)cpumask_bits(mask), optlen);
+	if (err == 0)
+		if (get_user(len, optlen) ||
+		    compat_put_bitmap(user_mask_ptr,
+				      cpumask_bits(mask), len * 8))
+			err = -EFAULT;
+
+	return err;
+}
+
 static int compat_sock_getsockopt(struct socket *sock, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
 	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
 		return do_get_sock_timeout(sock, level, optname, optval, optlen);
+
+	if (optname == SO_INCOMING_CPU_MASK)
+		return do_get_incoming_cpu_mask(sock, level, optname,
+						optval, optlen);
+
 	return sock_getsockopt(sock, level, optname, optval, optlen);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 29124fc..25fc8a7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -672,6 +672,71 @@ bool sk_mc_loop(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_mc_loop);
 
+static int do_set_incoming_cpu_mask(struct sock *sk, char __user *optval,
+				    unsigned int optlen)
+{
+	struct rcu_cpumask *new_mask, *old_mask;
+	unsigned long *k;
+
+	old_mask = rcu_dereference_protected(sk->sk_incoming_cpu_mask,
+					     sock_owned_by_user(sk));
+
+	if (optlen == 0) {
+		RCU_INIT_POINTER(sk->sk_incoming_cpu_mask, NULL);
+		if (old_mask) {
+			kfree_rcu(old_mask, rcu);
+			return 0;
+		}
+	}
+
+	if (optlen & (sizeof(unsigned long) - 1))
+		return -EINVAL;
+
+	new_mask = kzalloc(sizeof(*new_mask) + cpumask_size(), GFP_KERNEL);
+	if (!new_mask)
+		return -ENOMEM;
+
+	k = cpumask_bits(to_cpumask(new_mask->cpumask));
+	if (copy_from_user(k, optval, min_t(int, optlen, cpumask_size())))
+		return -EFAULT;
+
+	rcu_assign_pointer(sk->sk_incoming_cpu_mask, new_mask);
+
+	if (old_mask)
+		kfree_rcu(old_mask, rcu);
+
+	return 0;
+}
+
+static int do_get_incoming_cpu_mask(struct sock *sk, char __user *optval,
+				    unsigned int __user *optlen,
+				    unsigned int len)
+{
+	struct rcu_cpumask *mask;
+	unsigned long *k;
+	int err = 0;
+
+	if (len < cpumask_size())
+		return -EINVAL;
+
+	if (len & (sizeof(unsigned long) - 1))
+		return -EINVAL;
+
+	rcu_read_lock();
+
+	mask = rcu_dereference(sk->sk_incoming_cpu_mask);
+
+	k = cpumask_bits(to_cpumask(mask->cpumask));
+	if (copy_to_user(optval, k, cpumask_size()))
+		err = -EFAULT;
+	else
+		put_user(cpumask_size(), optlen);
+
+	rcu_read_unlock();
+
+	return err;
+}
+
 /*
  *	This is meant for all protocols to use and covers goings on
  *	at the socket level. Everything here is generic.
@@ -990,6 +1055,10 @@ set_rcvbuf:
 					 sk->sk_max_pacing_rate);
 		break;
 
+	case SO_INCOMING_CPU_MASK:
+		ret = do_set_incoming_cpu_mask(sk, optval, optlen);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1250,6 +1319,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_incoming_cpu;
 		break;
 
+	case SO_INCOMING_CPU_MASK:
+		return do_get_incoming_cpu_mask(sk, optval, optlen, len);
+
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
@@ -1429,6 +1501,7 @@ EXPORT_SYMBOL(sk_alloc);
 static void __sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
+	struct rcu_cpumask *incoming_cpu_mask;
 
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
@@ -1440,6 +1513,12 @@ static void __sk_free(struct sock *sk)
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 	}
 
+	incoming_cpu_mask = rcu_dereference(sk->sk_incoming_cpu_mask);
+	if (incoming_cpu_mask) {
+		kfree_rcu(incoming_cpu_mask, rcu);
+		RCU_INIT_POINTER(sk->sk_incoming_cpu_mask, NULL);
+	}
+
 	sock_disable_timestamp(sk, SK_FLAGS_TIMESTAMP);
 
 	if (atomic_read(&sk->sk_omem_alloc))
@@ -1543,6 +1622,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_err	   = 0;
 		newsk->sk_priority = 0;
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
+		RCU_INIT_POINTER(newsk->sk_incoming_cpu_mask, NULL);
 		atomic64_set(&newsk->sk_cookie, 0);
 		/*
 		 * Before updating sk_refcnt, we must commit prior changes to memory
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 3766bdd..2e9a95f 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -184,6 +184,9 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
+
+		if (sk_match_incoming_cpu_mask(sk))
+			score += 4;
 	}
 	return score;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d10b7e0..dc6a3da 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -375,6 +375,9 @@ static inline int compute_score(struct sock *sk, struct net *net,
 		score += 4;
 	}
 
+	if (sk_match_incoming_cpu_mask(sk))
+		score += 4;
+
 	return score;
 }
 
@@ -418,6 +421,9 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		score += 4;
 	}
 
+	if (sk_match_incoming_cpu_mask(sk))
+		score += 4;
+
 	return score;
 }
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 871641b..8cc4ba9 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -114,6 +114,9 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
+
+		if (sk_match_incoming_cpu_mask(sk))
+			score += 4;
 	}
 	return score;
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c2ec416..a0c9a80 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -182,6 +182,9 @@ static inline int compute_score(struct sock *sk, struct net *net,
 		score++;
 	}
 
+	if (sk_match_incoming_cpu_mask(sk))
+		score++;
+
 	return score;
 }
 
-- 
1.8.1
