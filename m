From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 2/2] sock_diag: initial udp_info metrics
Date: Mon,  5 Oct 2015 15:55:27 -0400
Message-ID: <1444074927-27098-3-git-send-email-kraigatgoog@gmail.com>
References: <1444074927-27098-1-git-send-email-kraigatgoog@gmail.com>
Cc: kraigatgoog@gmail.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34774 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbbJETzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 15:55:33 -0400
Received: by qgez77 with SMTP id z77so160132120qge.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 12:55:32 -0700 (PDT)
In-Reply-To: <1444074927-27098-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Define per-UDP socket metrics for counting datagrams in and out and
bytes in and out.  These four metrics are also exposed though the
INET_DIAG_UDP_INFO netlink attribute of the SOCK_DIAG_BY_FAMILY interface.

Performance test configuration to maximize cache misses across CPU sockets
 2x 12-core Xeon
 Single 10GbE link, 8 RX/8 TX queues

Receive test: Single process with 10 threads each reading a single byte
from a UDP socket (pinned to cores 6-10 and 18-22). RX queues pinned to
cores 2-5 and 14-17. RX queues/soft interrupts were saturated with a
remote trafgen process. Userspace threads used ~90% of each core. This
configuration allowed a receive rate of ~440K datagrams per second.
There was no noticeable change in throughput after this patch.  The
dominating factor both before and after is the taking of the socket lock
in udp_recvmsg in order to free an skb (skb_free_datagram_locked).

Send test: A single process with 8 threads sending one byte messages
through a single UDP socket (pinned to cores 6-9 and 18-21). TX queues
pinned to the same cores with XPS.  Transmit complete interrupts pinned
to cores 2-5 and 14-17. This configuration allowed a send rate
of ~2 million datagrams per second. This benchmark did not show noticeable
change in datagram throughput.  udp_sndmsg appears to already incur
this cacheline miss because of the IS_UDPLITE check and the dominating
bottle neck of the function is the route lookup.

Tested:
  lpaa15:~# nc -4 -l -u -p 8888   |    lpaa16:~# nc -4 -u lpaa15 8888
  a                              <-    a
  bb                             ->    bb
  ccc                            <-    ccc
  ^C
  lpaa15:~# nc -6 -l -u -p 8888   |    lpaa16:~# nc -6 -u lpaa15 8888
  a                              <-    a
  bb                             ->    bb
  ccc                            <-    ccc
  ^C

  While also running:
  lpaa15:~# /tmp/ss -Ei dst lpaa16
  Netid  State  Recv-Q Send-Q Local Address:Port           Peer Address:Port
  udp    ESTAB  0      -1     10.246.7.143:8888            10.246.7.144:39130
    bytes_in: 6 bytes_out: 3 dgrams_in: 2 dgrams_out: 1
  udp6   ESTAB  0      -1     fd1d:c486:7f89:1709::1:8888  fd1d:c486:7f89:1709::2:48675
    bytes_in: 6 bytes_out: 3 dgrams_in: 2 dgrams_out: 1

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/udp.h      |  7 +++++++
 include/net/udp.h        |  2 ++
 include/uapi/linux/udp.h |  4 ++++
 net/ipv4/udp.c           | 26 ++++++++++++++++++++++++--
 net/ipv4/udp_diag.c      | 12 ++++++++++++
 net/ipv6/udp.c           | 14 +++++++++++++-
 6 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 87c0949..7969675 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -19,6 +19,7 @@
 
 #include <net/inet_sock.h>
 #include <linux/skbuff.h>
+#include <linux/spinlock_types.h>
 #include <net/netns/hash.h>
 #include <uapi/linux/udp.h>
 
@@ -55,6 +56,12 @@ struct udp_sock {
 	 * when the socket is uncorked.
 	 */
 	__u16		 len;		/* total length of pending frames */
+
+	spinlock_t	 stats_lock;	/* lock for statistics counters */
+	__u64		 dgrams_out;	/* total datagrams sent*/
+	__u64		 bytes_out;	/* total bytes sent */
+	__u64		 dgrams_in;	/* total datagrams received */
+	__u64		 bytes_in;	/* total bytes received */
 	/*
 	 * Fields specific to UDP-Lite.
 	 */
diff --git a/include/net/udp.h b/include/net/udp.h
index 6d4ed18..7e4a95b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -185,6 +185,8 @@ static inline void udp_lib_hash(struct sock *sk)
 void udp_lib_unhash(struct sock *sk);
 void udp_lib_rehash(struct sock *sk, u16 new_hash);
 
+int udp_lib_init_sock(struct sock *sk);
+
 static inline void udp_lib_close(struct sock *sk, long timeout)
 {
 	sk_common_release(sk);
diff --git a/include/uapi/linux/udp.h b/include/uapi/linux/udp.h
index 6ba37dc..36cc00c 100644
--- a/include/uapi/linux/udp.h
+++ b/include/uapi/linux/udp.h
@@ -38,6 +38,10 @@ struct udphdr {
 #define UDP_ENCAP_L2TPINUDP	3 /* rfc2661 */
 
 struct udp_info {
+	__u64 udpi_dgrams_out;
+	__u64 udpi_bytes_out;
+	__u64 udpi_dgrams_in;
+	__u64 udpi_bytes_in;
 };
 
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 156ba75..0909118 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -797,6 +797,7 @@ static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	struct udphdr *uh;
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
@@ -843,9 +844,14 @@ send:
 					   UDP_MIB_SNDBUFERRORS, is_udplite);
 			err = 0;
 		}
-	} else
+	} else {
 		UDP_INC_STATS_USER(sock_net(sk),
 				   UDP_MIB_OUTDATAGRAMS, is_udplite);
+		spin_lock(&up->stats_lock);
+		up->dgrams_out++;
+		up->bytes_out += len - sizeof(struct udphdr);
+		spin_unlock(&up->stats_lock);
+	}
 	return err;
 }
 
@@ -1277,6 +1283,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
@@ -1333,9 +1340,14 @@ try_again:
 		goto out_free;
 	}
 
-	if (!peeked)
+	if (!peeked) {
 		UDP_INC_STATS_USER(sock_net(sk),
 				UDP_MIB_INDATAGRAMS, is_udplite);
+		spin_lock(&up->stats_lock);
+		up->dgrams_in++;
+		up->bytes_in += skb->len - sizeof(struct udphdr);
+		spin_unlock(&up->stats_lock);
+	}
 
 	sock_recv_ts_and_drops(msg, sk, skb);
 
@@ -2036,6 +2048,15 @@ int udp_rcv(struct sk_buff *skb)
 	return __udp4_lib_rcv(skb, &udp_table, IPPROTO_UDP);
 }
 
+int udp_lib_init_sock(struct sock *sk)
+{
+	struct udp_sock *up = udp_sk(sk);
+
+	spin_lock_init(&up->stats_lock);
+	return 0;
+}
+EXPORT_SYMBOL(udp_lib_init_sock);
+
 void udp_destroy_sock(struct sock *sk)
 {
 	struct udp_sock *up = udp_sk(sk);
@@ -2273,6 +2294,7 @@ struct proto udp_prot = {
 	.connect	   = ip4_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
+	.init		   = udp_lib_init_sock,
 	.destroy	   = udp_destroy_sock,
 	.setsockopt	   = udp_setsockopt,
 	.getsockopt	   = udp_getsockopt,
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index db48698..346be40 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -161,8 +161,20 @@ static int udp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
 static void udp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		void *info)
 {
+	struct udp_sock *up = udp_sk(sk);
+	struct udp_info *i = info;
+
 	r->idiag_rqueue = sk_rmem_alloc_get(sk);
 	r->idiag_wqueue = sk_wmem_alloc_get(sk);
+	if (!info)
+		return;
+
+	spin_lock(&up->stats_lock);
+	i->udpi_dgrams_out = up->dgrams_out;
+	i->udpi_bytes_out = up->bytes_out;
+	i->udpi_dgrams_in = up->dgrams_in;
+	i->udpi_bytes_in = up->bytes_in;
+	spin_unlock(&up->stats_lock);
 }
 
 static const struct inet_diag_handler udp_diag_handler = {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0aba654..0db2ad4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -394,6 +394,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
 	int peeked, off = 0;
@@ -464,6 +465,10 @@ try_again:
 		else
 			UDP6_INC_STATS_USER(sock_net(sk),
 					UDP_MIB_INDATAGRAMS, is_udplite);
+		spin_lock(&up->stats_lock);
+		up->dgrams_in++;
+		up->bytes_in += skb->len - sizeof(struct udphdr);
+		spin_unlock(&up->stats_lock);
 	}
 
 	sock_recv_ts_and_drops(msg, sk, skb);
@@ -1024,6 +1029,7 @@ static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
 static int udp_v6_send_skb(struct sk_buff *skb, struct flowi6 *fl6)
 {
 	struct sock *sk = skb->sk;
+	struct udp_sock *up = udp_sk(sk);
 	struct udphdr *uh;
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
@@ -1065,9 +1071,14 @@ send:
 					    UDP_MIB_SNDBUFERRORS, is_udplite);
 			err = 0;
 		}
-	} else
+	} else {
 		UDP6_INC_STATS_USER(sock_net(sk),
 				    UDP_MIB_OUTDATAGRAMS, is_udplite);
+		spin_lock(&up->stats_lock);
+		up->dgrams_out++;
+		up->bytes_out += len - sizeof(struct udphdr);
+		spin_unlock(&up->stats_lock);
+	}
 	return err;
 }
 
@@ -1522,6 +1533,7 @@ struct proto udpv6_prot = {
 	.connect	   = ip6_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
+	.init		   = udp_lib_init_sock,
 	.destroy	   = udpv6_destroy_sock,
 	.setsockopt	   = udpv6_setsockopt,
 	.getsockopt	   = udpv6_getsockopt,
-- 
2.6.0.rc2.230.g3dd15c0
