From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 2/5] udp: accounting unit and variable
Date: Thu, 15 Nov 2007 16:49:50 -0500
Message-ID: <473CBEFE.7020205@redhat.com>
References: <473CBDAD.1010708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752980AbXKOV4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 16:56:42 -0500
In-Reply-To: <473CBDAD.1010708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces global variable for UDP memory accounting.
The unit is page.

signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/sock.h |    8 ++++++++
 include/net/udp.h  |    2 ++
 net/ipv4/proc.c    |    3 ++-
 net/ipv4/udp.c     |    2 ++
 4 files changed, 14 insertions(+), 1 deletion(-)

diff -pruN net-2.6-udp-p1/include/net/sock.h net-2.6-udp-p2/include/net/sock.h
--- net-2.6-udp-p1/include/net/sock.h	2007-11-15 12:42:04.000000000 -0500
+++ net-2.6-udp-p2/include/net/sock.h	2007-11-15 14:44:13.000000000 -0500
@@ -778,6 +778,14 @@ static inline int sk_stream_wmem_schedul
 	       sk_stream_mem_schedule(sk, size, 0);
 }

+#define SK_DATAGRAM_MEM_QUANTUM ((unsigned int)PAGE_SIZE)
+
+static inline int sk_datagram_pages(int amt)
+{
+	/* Cast to unsigned as an optimization, since amt is always positive. */
+	return DIV_ROUND_UP((unsigned int)amt, SK_DATAGRAM_MEM_QUANTUM);
+}
+
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
diff -pruN net-2.6-udp-p1/include/net/udp.h net-2.6-udp-p2/include/net/udp.h
--- net-2.6-udp-p1/include/net/udp.h	2007-11-14 10:49:05.000000000 -0500
+++ net-2.6-udp-p2/include/net/udp.h	2007-11-15 14:44:13.000000000 -0500
@@ -65,6 +65,8 @@ extern rwlock_t udp_hash_lock;

 extern struct proto udp_prot;

+extern atomic_t udp_memory_allocated;
+
 struct sk_buff;

 /*
diff -pruN net-2.6-udp-p1/net/ipv4/proc.c net-2.6-udp-p2/net/ipv4/proc.c
--- net-2.6-udp-p1/net/ipv4/proc.c	2007-11-14 10:49:07.000000000 -0500
+++ net-2.6-udp-p2/net/ipv4/proc.c	2007-11-15 14:44:13.000000000 -0500
@@ -56,7 +56,8 @@ static int sockstat_seq_show(struct seq_
 		   sock_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
-	seq_printf(seq, "UDP: inuse %d\n", sock_prot_inuse(&udp_prot));
+	seq_printf(seq, "UDP: inuse %d mem %d\n", sock_prot_inuse(&udp_prot),
+		   atomic_read(&udp_memory_allocated));
 	seq_printf(seq, "UDPLITE: inuse %d\n", sock_prot_inuse(&udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n", sock_prot_inuse(&raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
diff -pruN net-2.6-udp-p1/net/ipv4/udp.c net-2.6-udp-p2/net/ipv4/udp.c
--- net-2.6-udp-p1/net/ipv4/udp.c	2007-11-14 10:49:07.000000000 -0500
+++ net-2.6-udp-p2/net/ipv4/udp.c	2007-11-15 14:44:13.000000000 -0500
@@ -114,6 +114,8 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);

+atomic_t udp_memory_allocated;
+
 static inline int __udp_lib_lport_inuse(__u16 num,
 					const struct hlist_head udptable[])
 {
-- 
Hitachi Computer Products (America) Inc.
