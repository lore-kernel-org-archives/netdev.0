From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 2/3] UDP memory usage accounting: accounting unit and
 variable
Date: Fri, 28 Sep 2007 22:40:02 +0900
Message-ID: <46FD0432.8040100@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?ISO-2022-JP?B?IhskQkBEGyhC?=
	 =?ISO-2022-JP?B?GyRCTFobKEJAUmVkSGF0Ig==?= <haoki@redhat.com>,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:59403 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbXI1NkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 09:40:10 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 1FECE37C8B
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 22:40:09 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces global variable for UDP memory accounting.
The unit is page.


signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>

Index: 2.6.23-rc3-udp_limit/include/net/sock.h
===================================================================
--- 2.6.23-rc3-udp_limit.orig/include/net/sock.h
+++ 2.6.23-rc3-udp_limit/include/net/sock.h
@@ -723,6 +723,13 @@ static inline int sk_stream_wmem_schedul
 	       sk_stream_mem_schedule(sk, size, 0);
 }
 
+#define SK_DATAGRAM_MEM_QUANTUM ((int)PAGE_SIZE)
+
+static inline int sk_datagram_pages(int amt)
+{
+	return DIV_ROUND_UP(amt, SK_DATAGRAM_MEM_QUANTUM);
+}
+
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
Index: 2.6.23-rc3-udp_limit/include/net/udp.h
===================================================================
--- 2.6.23-rc3-udp_limit.orig/include/net/udp.h
+++ 2.6.23-rc3-udp_limit/include/net/udp.h
@@ -65,6 +65,8 @@ extern rwlock_t udp_hash_lock;
 
 extern struct proto udp_prot;
 
+extern atomic_t udp_memory_allocated;
+
 struct sk_buff;
 
 /*
Index: 2.6.23-rc3-udp_limit/net/ipv4/proc.c
===================================================================
--- 2.6.23-rc3-udp_limit.orig/net/ipv4/proc.c
+++ 2.6.23-rc3-udp_limit/net/ipv4/proc.c
@@ -66,7 +66,8 @@ static int sockstat_seq_show(struct seq_
 		   fold_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
-	seq_printf(seq, "UDP: inuse %d\n", fold_prot_inuse(&udp_prot));
+	seq_printf(seq, "UDP: inuse %d mem %d\n", fold_prot_inuse(&udp_prot),
+		   atomic_read(&udp_memory_allocated));
 	seq_printf(seq, "UDPLITE: inuse %d\n", fold_prot_inuse(&udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n", fold_prot_inuse(&raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n", ip_frag_nqueues,
Index: 2.6.23-rc3-udp_limit/net/ipv4/udp.c
===================================================================
--- 2.6.23-rc3-udp_limit.orig/net/ipv4/udp.c
+++ 2.6.23-rc3-udp_limit/net/ipv4/udp.c
@@ -113,6 +113,10 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
 
+atomic_t udp_memory_allocated;
+
+EXPORT_SYMBOL(udp_memory_allocated);
+
 static int udp_port_rover;
 
 static inline int __udp_lib_lport_inuse(__u16 num, struct hlist_head udptable[])

