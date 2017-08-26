From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP sockets oddities
Date: Sat, 26 Aug 2017 05:47:51 -0700
Message-ID: <1503751671.11498.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
         <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
         <1503718844.11498.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170825.211905.920493778125075310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, pabeni@redhat.com,
        willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33551 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752356AbdHZMry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 08:47:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id c28so913246pfe.0
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 05:47:53 -0700 (PDT)
In-Reply-To: <20170825.211905.920493778125075310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 21:19 -0700, David Miller wrote:

> Agreed, but the ARP resolution queue really needs to scale it's backlog
> to the physical technology it is attached to.
Yes, last time (in 2011) we increased the old limit of 3 packets :/

We probably should match sysctl_wmem_max so that a single socket
provider would hit its sk_sndbuf limit

Something like :

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 6b0bc0f715346a097a6df46e2ba2771359abcd23..7777dceb78107c0019fb39d5b69be1959005b78e 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -109,7 +109,8 @@ neigh/default/unres_qlen_bytes - INTEGER
 	queued for each	unresolved address by other network layers.
 	(added in linux 3.3)
 	Setting negative value is meaningless and will return error.
-	Default: 65536 Bytes(64KB)
+	Default: SK_WMEM_MAX, enough to store 256 packets of medium size
+		 (less than 256 bytes per packet)
 
 neigh/default/unres_qlen - INTEGER
 	The maximum number of packets which may be queued for each
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
