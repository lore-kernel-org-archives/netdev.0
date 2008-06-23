From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp: /proc/net/tcp rto,ato values not scaled properly (v2)
Date: Mon, 23 Jun 2008 11:16:00 -0700
Message-ID: <20080623111600.2324b7ff@extreme>
References: <20080620115603.5c494cab@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36621 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762290AbYFWSQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 14:16:03 -0400
In-Reply-To: <20080620115603.5c494cab@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found another case where we are sending information to userspace
in the wrong HZ scale.  This should have been fixed back in 2.5 :-(

This means an ABI change but as it stands there is no way for an application
like ss to get the right value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Fixed printf format warnings in earlier patch

--- a/net/ipv4/tcp_ipv4.c	2008-06-23 10:54:19.000000000 -0700
+++ b/net/ipv4/tcp_ipv4.c	2008-06-23 11:03:43.000000000 -0700
@@ -2189,7 +2189,7 @@ static void get_tcp4_sock(struct sock *s
 	}
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %u %u %u %u %d%n",
+			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		sk->sk_state == TCP_LISTEN ? sk->sk_ack_backlog :
@@ -2201,8 +2201,8 @@ static void get_tcp4_sock(struct sock *s
 		icsk->icsk_probes_out,
 		sock_i_ino(sk),
 		atomic_read(&sk->sk_refcnt), sk,
-		icsk->icsk_rto,
-		icsk->icsk_ack.ato,
+		jiffies_to_clock_t(icsk->icsk_rto),
+		jiffies_to_clock_t(icsk->icsk_ack.ato),
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		tp->snd_cwnd,
 		tp->snd_ssthresh >= 0xFFFF ? -1 : tp->snd_ssthresh,
--- a/net/ipv6/tcp_ipv6.c	2008-06-23 10:54:19.000000000 -0700
+++ b/net/ipv6/tcp_ipv6.c	2008-06-23 11:04:25.000000000 -0700
@@ -1946,7 +1946,7 @@ static void get_tcp6_sock(struct seq_fil
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %u %u %u %u %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -1962,8 +1962,8 @@ static void get_tcp6_sock(struct seq_fil
 		   icsk->icsk_probes_out,
 		   sock_i_ino(sp),
 		   atomic_read(&sp->sk_refcnt), sp,
-		   icsk->icsk_rto,
-		   icsk->icsk_ack.ato,
+		   jiffies_to_clock_t(icsk->icsk_rto),
+		   jiffies_to_clock_t(icsk->icsk_ack.ato),
 		   (icsk->icsk_ack.quick << 1 ) | icsk->icsk_ack.pingpong,
 		   tp->snd_cwnd, tp->snd_ssthresh>=0xFFFF?-1:tp->snd_ssthresh
 		   );
