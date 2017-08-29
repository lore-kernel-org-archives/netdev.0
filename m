From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] neigh: increase queue_len_bytes to match
 wmem_default
Date: Tue, 29 Aug 2017 15:16:01 -0700
Message-ID: <1504044961.11498.100.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
         <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
         <1503718844.11498.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170825.211905.920493778125075310.davem@davemloft.net>
         <1503751671.11498.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <deb227c9-728a-bd98-f282-1478d71353a8@gmail.com>
         <353aa37f-c62b-f5af-8c89-f67af6509497@gmail.com>
         <1504029689.11498.79.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35714 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH2WQE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:16:04 -0400
Received: by mail-pf0-f193.google.com with SMTP id g13so3135579pfm.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 15:16:03 -0700 (PDT)
In-Reply-To: <1504029689.11498.79.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Florian reported UDP xmit drops that could be root caused to the
too small neigh limit.

Current limit is 64 KB, meaning that even a single UDP socket would hit
it, since its default sk_sndbuf comes from net.core.wmem_default
(~212992 bytes on 64bit arches).

Once ARP/ND resolution is in progress, we should allow a little more
packets to be queued, at least for one producer.

Once neigh arp_queue is filled, a rogue socket should hit its sk_sndbuf
limit and either block in sendmsg() or return -EAGAIN.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |    7 +++++--
 include/net/sock.h                     |   10 ++++++++++
 net/core/sock.c                        |   10 ----------
 net/decnet/dn_neigh.c                  |    2 +-
 net/ipv4/arp.c                         |    2 +-
 net/ipv4/tcp_input.c                   |    2 +-
 net/ipv6/ndisc.c                       |    2 +-
 7 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 6b0bc0f715346a097a6df46e2ba2771359abcd23..b3345d0fe0a67e477a6754848e7fc7be144322d5 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -109,7 +109,10 @@ neigh/default/unres_qlen_bytes - INTEGER
 	queued for each	unresolved address by other network layers.
 	(added in linux 3.3)
 	Setting negative value is meaningless and will return error.
-	Default: 65536 Bytes(64KB)
+	Default: SK_WMEM_MAX, (same as net.core.wmem_default).
+		Exact value depends on architecture and kernel options,
+		but should be enough to allow queuing 256 packets
+		of medium size.
 
 neigh/default/unres_qlen - INTEGER
 	The maximum number of packets which may be queued for each
@@ -119,7 +122,7 @@ neigh/default/unres_qlen - INTEGER
 	unexpected packet loss. The current default value is calculated
 	according to default value of unres_qlen_bytes and true size of
 	packet.
-	Default: 31
+	Default: 101
 
 mtu_expires - INTEGER
 	Time, in seconds, that cached PMTU information is kept.
diff --git a/include/net/sock.h b/include/net/sock.h
index 1c2912d433e81b10f3fdc87bcfcbb091570edc03..03a362568357acc7278a318423dd3873103f90ca 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2368,6 +2368,16 @@ bool sk_net_capable(const struct sock *sk, int cap);
 
 void sk_get_meminfo(const struct sock *sk, u32 *meminfo);
 
+/* Take into consideration the size of the struct sk_buff overhead in the
+ * determination of these values, since that is non-constant across
+ * platforms.  This makes socket queueing behavior and performance
+ * not depend upon such differences.
+ */
+#define _SK_MEM_PACKETS		256
+#define _SK_MEM_OVERHEAD	SKB_TRUESIZE(256)
+#define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
+#define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
+
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index dfdd14cac775e9bfcee0085ee32ffcd0ab28b67b..9b7b6bbb2a23e7652a1f34a305f29d49de00bc8c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -307,16 +307,6 @@ static struct lock_class_key af_wlock_keys[AF_MAX];
 static struct lock_class_key af_elock_keys[AF_MAX];
 static struct lock_class_key af_kern_callback_keys[AF_MAX];
 
-/* Take into consideration the size of the struct sk_buff overhead in the
- * determination of these values, since that is non-constant across
- * platforms.  This makes socket queueing behavior and performance
- * not depend upon such differences.
- */
-#define _SK_MEM_PACKETS		256
-#define _SK_MEM_OVERHEAD	SKB_TRUESIZE(256)
-#define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
-#define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
-
 /* Run time adjustable parameters. */
 __u32 sysctl_wmem_max __read_mostly = SK_WMEM_MAX;
 EXPORT_SYMBOL(sysctl_wmem_max);
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 21dedf6fd0f76dec22b2b3685beb89cfefea7ded..22bf0b95d6edc3c27ef3a99d27cb70a1551e3e0e 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -94,7 +94,7 @@ struct neigh_table dn_neigh_table = {
 			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
 			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
 			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
-			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64*1024,
+			[NEIGH_VAR_QUEUE_LEN_BYTES] = SK_WMEM_MAX,
 			[NEIGH_VAR_PROXY_QLEN] = 0,
 			[NEIGH_VAR_ANYCAST_DELAY] = 0,
 			[NEIGH_VAR_PROXY_DELAY] = 0,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 8b52179ddc6e54eabf6d3c2ed0132083228680bb..7c45b8896709815c5dde5972fd57cb5c3bcb2648 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -171,7 +171,7 @@ struct neigh_table arp_tbl = {
 			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
 			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
 			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
-			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
+			[NEIGH_VAR_QUEUE_LEN_BYTES] = SK_WMEM_MAX,
 			[NEIGH_VAR_PROXY_QLEN] = 64,
 			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
 			[NEIGH_VAR_PROXY_DELAY]	= (8 * HZ) / 10,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 568ccfd6dd371d88136ffabe5cfcc36f099786b6..7616cd76f6f6a62f395da897baef2c66c0098193 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6086,9 +6086,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct net *net = sock_net(sk);
 	struct sock *fastopen_sk = NULL;
-	struct dst_entry *dst = NULL;
 	struct request_sock *req;
 	bool want_cookie = false;
+	struct dst_entry *dst;
 	struct flowi fl;
 
 	/* TW buckets are converted to open requests without
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 5e338eb89509b1df6ebd060f8bd19fcb4b86fe05..266a530414d7be4f1e7be922e465bbab46f7cbac 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -127,7 +127,7 @@ struct neigh_table nd_tbl = {
 			[NEIGH_VAR_BASE_REACHABLE_TIME] = ND_REACHABLE_TIME,
 			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
 			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
-			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
+			[NEIGH_VAR_QUEUE_LEN_BYTES] = SK_WMEM_MAX,
 			[NEIGH_VAR_PROXY_QLEN] = 64,
 			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
 			[NEIGH_VAR_PROXY_DELAY] = (8 * HZ) / 10,
