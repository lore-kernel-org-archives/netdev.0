From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [PATCH 2/4] UDP memory accounting and limitation(take 5): accounting
 unit and variable
Date: Fri, 12 Oct 2007 21:07:10 +0900
Message-ID: <470F636E.1010509@hitachi.com>
References: <470F61D4.6040808@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <hideo.aoki.tk@hitachi.com>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?ISO-2022-JP?B?IhskQkBETFobKEJAUmVkSGF0Ig==?= <haoki@redhat.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:58003 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbXJLMHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:07:15 -0400
Received: from mlsv15.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 1DD8C37AE6
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 21:07:14 +0900 (JST)
In-Reply-To: <470F61D4.6040808@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces global variable for UDP memory accounting.
The unit is page.


signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>

Index: 2.6.23-udp_limit/include/net/sock.h
===================================================================
--- 2.6.23-udp_limit.orig/include/net/sock.h
+++ 2.6.23-udp_limit/include/net/sock.h
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
Index: 2.6.23-udp_limit/include/net/udp.h
===================================================================
--- 2.6.23-udp_limit.orig/include/net/udp.h
+++ 2.6.23-udp_limit/include/net/udp.h
@@ -65,6 +65,8 @@ extern rwlock_t udp_hash_lock;
 
 extern struct proto udp_prot;
 
+extern atomic_t udp_memory_allocated;
+
 struct sk_buff;
 
 /*
Index: 2.6.23-udp_limit/net/ipv4/proc.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/proc.c
+++ 2.6.23-udp_limit/net/ipv4/proc.c
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
Index: 2.6.23-udp_limit/net/ipv4/udp.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/udp.c
+++ 2.6.23-udp_limit/net/ipv4/udp.c
@@ -113,6 +113,8 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
 
+atomic_t udp_memory_allocated;
+
 static int udp_port_rover;
 
 static inline int __udp_lib_lport_inuse(__u16 num, struct hlist_head udptable[])

