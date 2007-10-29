From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 2/5] accounting unit and variable
Date: Mon, 29 Oct 2007 17:23:10 -0400
Message-ID: <47264F3E.3080306@redhat.com>
References: <47264E2D.4080109@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020209030905000406030303"
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56865 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbXJ2V1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:27:12 -0400
In-Reply-To: <47264E2D.4080109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020209030905000406030303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch introduces global variable for UDP memory accounting.
The unit is page.

--
Hideo Aoki
Hitachi Computer Products (America) Inc.

--------------020209030905000406030303
Content-Type: text/x-patch;
 name="udp_memory_account_common.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_memory_account_common.patch"


Signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Signed-off-by: Hideo Aoki <haoki@redhat.com>

 include/net/sock.h |    7 +++++++
 include/net/udp.h  |    2 ++
 net/ipv4/proc.c    |    3 ++-
 net/ipv4/udp.c     |    2 ++
 4 files changed, 13 insertions(+), 1 deletion(-)

diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p1/include/net/sock.h linux-2.6.24-rc1-mem003-ipv4-dev-p2/include/net/sock.h
--- linux-2.6.24-rc1-mem003-ipv4-dev-p1/include/net/sock.h	2007-10-24 11:34:32.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p2/include/net/sock.h	2007-10-24 11:47:51.000000000 -0400
@@ -727,6 +727,13 @@ static inline int sk_stream_wmem_schedul
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
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p1/include/net/udp.h linux-2.6.24-rc1-mem003-ipv4-dev-p2/include/net/udp.h
--- linux-2.6.24-rc1-mem003-ipv4-dev-p1/include/net/udp.h	2007-10-10 11:49:42.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p2/include/net/udp.h	2007-10-24 11:47:51.000000000 -0400
@@ -65,6 +65,8 @@ extern rwlock_t udp_hash_lock;
 
 extern struct proto udp_prot;
 
+extern atomic_t udp_memory_allocated;
+
 struct sk_buff;
 
 /*
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p1/net/ipv4/proc.c linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/proc.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p1/net/ipv4/proc.c	2007-10-24 11:34:34.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/proc.c	2007-10-24 11:47:51.000000000 -0400
@@ -67,7 +67,8 @@ static int sockstat_seq_show(struct seq_
 		   fold_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
-	seq_printf(seq, "UDP: inuse %d\n", fold_prot_inuse(&udp_prot));
+	seq_printf(seq, "UDP: inuse %d mem %d\n", fold_prot_inuse(&udp_prot),
+		   atomic_read(&udp_memory_allocated));
 	seq_printf(seq, "UDPLITE: inuse %d\n", fold_prot_inuse(&udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n", fold_prot_inuse(&raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p1/net/ipv4/udp.c linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/udp.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p1/net/ipv4/udp.c	2007-10-24 11:34:35.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/udp.c	2007-10-24 12:27:37.000000000 -0400
@@ -114,6 +114,8 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
 
+atomic_t udp_memory_allocated;
+
 static inline int __udp_lib_lport_inuse(__u16 num,
 					const struct hlist_head udptable[])
 {

--------------020209030905000406030303--
