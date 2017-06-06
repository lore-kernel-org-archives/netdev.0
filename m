From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add TCPMemoryPressuresChrono counter
Date: Tue, 06 Jun 2017 12:19:27 -0700
Message-ID: <1496776767.736.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33743 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdFFTTe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 15:19:34 -0400
Received: by mail-pg0-f65.google.com with SMTP id a70so5513526pge.0
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 12:19:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

DRAM supply shortage and poor memory pressure tracking in TCP
stack makes any change in SO_SNDBUF/SO_RCVBUF (or equivalent autotuning
limits) and tcp_mem[] quite hazardous.

TCPMemoryPressures SNMP counter is an indication of tcp_mem sysctl
limits being hit, but only tracking number of transitions.

If TCP stack behavior under stress was perfect :
1) It would maintain memory usage close to the limit.
2) Memory pressure state would be entered for short times.

We certainly prefer 100 events lasting 10ms compared to one event
lasting 200 seconds.

This patch adds a new SNMP counter tracking cumulative duration of
memory pressure events, given in ms units.

$ cat /proc/sys/net/ipv4/tcp_mem
3088    4117    6176
$ grep TCP /proc/net/sockstat
TCP: inuse 180 orphan 0 tw 2 alloc 234 mem 4140
$ nstat -n ; sleep 10 ; nstat |grep Pressure
TcpExtTCPMemoryPressures        1700
TcpExtTCPMemoryPressuresChrono  5209

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h        |   22 ++--------------------
 include/net/tcp.h         |    3 ++-
 include/uapi/linux/snmp.h |    1 +
 net/core/sock.c           |   20 ++++++++++++++++++++
 net/decnet/af_decnet.c    |    2 +-
 net/ipv4/proc.c           |    1 +
 net/ipv4/tcp.c            |   27 +++++++++++++++++++++++----
 net/ipv4/tcp_ipv4.c       |    1 +
 net/ipv6/tcp_ipv6.c       |    1 +
 net/sctp/socket.c         |    2 +-
 10 files changed, 53 insertions(+), 27 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3467d9e89e7dba1c35fa44a6268a28735f795319..858891c36f94ad2577726d6d21cf871dbcd55d98 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1080,6 +1080,7 @@ struct proto {
 	bool			(*stream_memory_free)(const struct sock *sk);
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(struct sock *sk);
+	void			(*leave_memory_pressure)(struct sock *sk);
 	atomic_long_t		*memory_allocated;	/* Current allocated memory. */
 	struct percpu_counter	*sockets_allocated;	/* Current number of sockets. */
 	/*
@@ -1088,7 +1089,7 @@ struct proto {
 	 * All the __sk_mem_schedule() is of this nature: accounting
 	 * is strict, actions are advisory and have some latency.
 	 */
-	int			*memory_pressure;
+	unsigned long		*memory_pressure;
 	long			*sysctl_mem;
 	int			*sysctl_wmem;
 	int			*sysctl_rmem;
@@ -1193,25 +1194,6 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
 	return !!*sk->sk_prot->memory_pressure;
 }
 
-static inline void sk_leave_memory_pressure(struct sock *sk)
-{
-	int *memory_pressure = sk->sk_prot->memory_pressure;
-
-	if (!memory_pressure)
-		return;
-
-	if (*memory_pressure)
-		*memory_pressure = 0;
-}
-
-static inline void sk_enter_memory_pressure(struct sock *sk)
-{
-	if (!sk->sk_prot->enter_memory_pressure)
-		return;
-
-	sk->sk_prot->enter_memory_pressure(sk);
-}
-
 static inline long
 sk_memory_allocated(const struct sock *sk)
 {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 82462db97183abebb33628eb5e04a5c5f04ea873..03482a5a069a18c776bd2071f0d74c8e56c0bed2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -279,7 +279,7 @@ extern int sysctl_tcp_pacing_ca_ratio;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
-extern int tcp_memory_pressure;
+extern unsigned long tcp_memory_pressure;
 
 /* optimized version of sk_under_memory_pressure() for TCP sockets */
 static inline bool tcp_under_memory_pressure(const struct sock *sk)
@@ -1322,6 +1322,7 @@ extern void tcp_openreq_init_rwin(struct request_sock *req,
 				  const struct dst_entry *dst);
 
 void tcp_enter_memory_pressure(struct sock *sk);
+void tcp_leave_memory_pressure(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
 {
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 95cffcb21dfdba7c974706131d0f43e21435e82d..d8569329579816213255169d0c183f4400835f7b 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -228,6 +228,7 @@ enum
 	LINUX_MIB_TCPABORTONLINGER,		/* TCPAbortOnLinger */
 	LINUX_MIB_TCPABORTFAILED,		/* TCPAbortFailed */
 	LINUX_MIB_TCPMEMORYPRESSURES,		/* TCPMemoryPressures */
+	LINUX_MIB_TCPMEMORYPRESSURESCHRONO,	/* TCPMemoryPressuresChrono */
 	LINUX_MIB_TCPSACKDISCARD,		/* TCPSACKDiscard */
 	LINUX_MIB_TCPDSACKIGNOREDOLD,		/* TCPSACKIgnoredOld */
 	LINUX_MIB_TCPDSACKIGNOREDNOUNDO,	/* TCPSACKIgnoredNoUndo */
diff --git a/net/core/sock.c b/net/core/sock.c
index bef844127e0182091678b9d57f7ec85c5241748d..ad8a4bc841267a442a1da3c56ef1cf074f9825b9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2076,6 +2076,26 @@ int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 }
 EXPORT_SYMBOL(sock_cmsg_send);
 
+static void sk_enter_memory_pressure(struct sock *sk)
+{
+	if (!sk->sk_prot->enter_memory_pressure)
+		return;
+
+	sk->sk_prot->enter_memory_pressure(sk);
+}
+
+static void sk_leave_memory_pressure(struct sock *sk)
+{
+	if (sk->sk_prot->leave_memory_pressure) {
+		sk->sk_prot->leave_memory_pressure(sk);
+	} else {
+		unsigned long *memory_pressure = sk->sk_prot->memory_pressure;
+
+		if (memory_pressure && *memory_pressure)
+			*memory_pressure = 0;
+	}
+}
+
 /* On 32bit arches, an skb frag is limited to 2^15 */
 #define SKB_FRAG_PAGE_ORDER	get_order(32768)
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 405483a07efc7ac2efcfe86e285a7673547c9691..73a0399dc7a277178b0a432a067172131dce99ee 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -447,7 +447,7 @@ static void dn_destruct(struct sock *sk)
 	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
 }
 
-static int dn_memory_pressure;
+static unsigned long dn_memory_pressure;
 
 static void dn_enter_memory_pressure(struct sock *sk)
 {
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index fa44e752a9a3f8eb9957314149ae15e6df10465a..43eb6567b3a0a2add9a1d36019eae5b6d5caf657 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -250,6 +250,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPAbortOnLinger", LINUX_MIB_TCPABORTONLINGER),
 	SNMP_MIB_ITEM("TCPAbortFailed", LINUX_MIB_TCPABORTFAILED),
 	SNMP_MIB_ITEM("TCPMemoryPressures", LINUX_MIB_TCPMEMORYPRESSURES),
+	SNMP_MIB_ITEM("TCPMemoryPressuresChrono", LINUX_MIB_TCPMEMORYPRESSURESCHRONO),
 	SNMP_MIB_ITEM("TCPSACKDiscard", LINUX_MIB_TCPSACKDISCARD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredOld", LINUX_MIB_TCPDSACKIGNOREDOLD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredNoUndo", LINUX_MIB_TCPDSACKIGNOREDNOUNDO),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f7be94fc8431d30a6b8c5de62a70b529789f7873..00d1bf4092fdf852e54eccf8ec5b130ac9935704 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -320,18 +320,37 @@ struct tcp_splice_state {
  * All the __sk_mem_schedule() is of this nature: accounting
  * is strict, actions are advisory and have some latency.
  */
-int tcp_memory_pressure __read_mostly;
+unsigned long tcp_memory_pressure __read_mostly;
 EXPORT_SYMBOL(tcp_memory_pressure);
 
 void tcp_enter_memory_pressure(struct sock *sk)
 {
-	if (!tcp_memory_pressure) {
+	unsigned long val;
+
+	if (tcp_memory_pressure)
+		return;
+	val = jiffies;
+
+	if (!val)
+		val--;
+	if (!cmpxchg(&tcp_memory_pressure, 0, val))
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
-		tcp_memory_pressure = 1;
-	}
 }
 EXPORT_SYMBOL(tcp_enter_memory_pressure);
 
+void tcp_leave_memory_pressure(struct sock *sk)
+{
+	unsigned long val;
+
+	if (!tcp_memory_pressure)
+		return;
+	val = xchg(&tcp_memory_pressure, 0);
+	if (val)
+		NET_ADD_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURESCHRONO,
+			      jiffies_to_msecs(jiffies - val));
+}
+EXPORT_SYMBOL(tcp_leave_memory_pressure);
+
 /* Convert seconds to retransmits based on initial and max timeout */
 static u8 secs_to_retrans(int seconds, int timeout, int rto_max)
 {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 191b2f78b19d2c8d62c59cc046bd608687679619..d19933949373ca019fd06fa310a506efd29718cb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2387,6 +2387,7 @@ struct proto tcp_prot = {
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
+	.leave_memory_pressure	= tcp_leave_memory_pressure,
 	.stream_memory_free	= tcp_stream_memory_free,
 	.sockets_allocated	= &tcp_sockets_allocated,
 	.orphan_count		= &tcp_orphan_count,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 233edfabe1dbceaeb6cdd42a2bb379072aeee361..f6592790d9f93bf40f3e5432c945bca20b28ff34 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1909,6 +1909,7 @@ struct proto tcpv6_prot = {
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
+	.leave_memory_pressure	= tcp_leave_memory_pressure,
 	.stream_memory_free	= tcp_stream_memory_free,
 	.sockets_allocated	= &tcp_sockets_allocated,
 	.memory_allocated	= &tcp_memory_allocated,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0822046e4f3f5a1acd3f5382d915bf9004a25c1c..5f58dd03e3ace38b9c4babbe2d92f0a3f98a4b68 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -103,7 +103,7 @@ static int sctp_autobind(struct sock *sk);
 static void sctp_sock_migrate(struct sock *, struct sock *,
 			      struct sctp_association *, sctp_socket_type_t);
 
-static int sctp_memory_pressure;
+static unsigned long sctp_memory_pressure;
 static atomic_long_t sctp_memory_allocated;
 struct percpu_counter sctp_sockets_allocated;
 
