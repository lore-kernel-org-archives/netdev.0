From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V3 net-next 1/5] tcp: TCP experimental option for SMC - definitions
Date: Wed, 22 Jul 2015 10:59:48 +0200
Message-ID: <1437555592-16506-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <20150715.212837.233151628267116088.davem@davemloft.net>
 <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:35197 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186AbbGVJAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 05:00:03 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 22 Jul 2015 10:00:00 +0100
In-Reply-To: <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The SMC-R protocol defines dynamic discovery of peers. This is done by
implementing experimental TCP options as defined in RFC6994. The TCP code
needs to be extended to support RFC6994.

Setting the TCP experimental option for SMC-R [2] will be triggered from
kernel exploiters like the new SMC-R socket family by setting a new
flag "syn_smc" on struct tcp_sock of the connecting and the listening
socket. If the client peer is SMC-R capable, flag syn_smc is kept on the
connecting socket after the 3-way TCP handshake, otherwise it is reset.
If the server peer is SMC-R capable, the new connected TCP socket has
the new flag set, otherwise not.

Code snippet client:
  tcp_sk(sock->sk)->syn_smc = 1;
  rc = kernel_connect(sock, addr, alen, flags);
  if (tcp_sk(sock->sk)->syn_smc) {
          /* switch to smc for this connection */

Code snippet server:
  tcp_sk(sock->sk)->syn_smc = 1;
  rc = kernel_listen(sock, backlog);
  rc = kernel_accept(sock, &newsock, 0);
  if (tcp_sk(newsock->sk)->syn_smc) {
          /* switch to smc for this connection */

References:
[1] Shared Use of TCP Experimental Options RFC 6994:
    https://tools.ietf.org/rfc/rfc6994.txt
[2] IANA ExID SMCR:
    http://www.iana.org/assignments/tcp-parameters/tcp-parameters.xhtml#tcp-exids

This patch has already been posted in June 2013, but Dave Miller has
postponed applying till the user of the new flags, ie. the entire SMC-R
protocol stack is implemented.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 include/linux/tcp.h     | 6 ++++--
 include/net/inet_sock.h | 3 ++-
 include/net/tcp.h       | 8 ++++++++
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 48c3696..488a875 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -87,7 +87,8 @@ struct tcp_options_received {
 		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
 		dsack : 1,	/* D-SACK is scheduled			*/
 		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
-		sack_ok : 4,	/* SACK seen on SYN packet		*/
+		sack_ok : 3,	/* SACK seen on SYN packet		*/
+		smc_ok : 1,	/* SMC seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
 	u8	num_sacks;	/* Number of SACK blocks		*/
@@ -207,7 +208,8 @@ struct tcp_sock {
 		syn_fastopen_exp:1,/* SYN includes Fast Open exp. option */
 		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
 		save_syn:1,	/* Save headers of SYN packet */
-		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
+		is_cwnd_limited:1,/* forward progress limited by snd_cwnd? */
+		syn_smc:1;	/* SYN includes SMC			*/
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 47eb67b..18d8d3f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -91,7 +91,8 @@ struct inet_request_sock {
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
 				acked	   : 1,
-				no_srccheck: 1;
+				no_srccheck: 1,
+				smc_ok     : 1;
 	kmemcheck_bitfield_end(flags);
 	u32                     ir_mark;
 	union {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 364426a..e4584ed 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -46,6 +46,7 @@
 
 #include <linux/seq_file.h>
 #include <linux/memcontrol.h>
+#include <linux/unaligned/access_ok.h>
 
 extern struct inet_hashinfo tcp_hashinfo;
 
@@ -185,6 +186,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
  */
 #define TCPOPT_FASTOPEN_MAGIC	0xF989
+#define TCPOPT_SMC_MAGIC	0xE2D4C3D9
 
 /*
  *     TCP option lengths
@@ -197,6 +199,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_MD5SIG         18
 #define TCPOLEN_FASTOPEN_BASE  2
 #define TCPOLEN_EXP_FASTOPEN_BASE  4
+#define TCPOLEN_EXP_SMC_BASE   6
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -207,6 +210,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_EXP_SMC_BASE_ALIGNED    8
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -1762,4 +1766,8 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
 	skb->truesize = 2;
 }
 
+#if IS_ENABLED(CONFIG_AFSMC)
+extern struct static_key tcp_have_smc;
+#endif
+
 #endif	/* _TCP_H */
-- 
2.3.8
