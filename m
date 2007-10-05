From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 2/4] UDP memory usage accounting (take 4): accounting
 unit and variable
Date: Sat, 06 Oct 2007 00:01:07 +0900
Message-ID: <470651B3.6060001@hitachi.com>
References: <47065139.5030402@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:38280 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756154AbXJEPBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 11:01:11 -0400
Received: from mlsv12.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id F422833CC7
	for <netdev@vger.kernel.org>; Sat,  6 Oct 2007 00:01:10 +0900 (JST)
In-Reply-To: <47065139.5030402@hitachi.com>
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

