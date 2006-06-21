From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] Export accept queue len of a TCP listening socket via
	/proc/net/tcp{6}
Date: Wed, 21 Jun 2006 16:56:47 -0700
Message-ID: <1150934207.2868.24.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:26823 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932734AbWFUX5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 19:57:38 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5LNvbM3030297
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 19:57:37 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5LNvbNI277936
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 19:57:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5LNvbmC030455
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 19:57:37 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While debugging a TCP server hang issue, we noticed that currently there is 
no way for a user to find the acceptq backlog value for a TCP listen socket.

All the standard networking utilities that display socket info like netstat,
ss and /proc/net/tcp have 2 fields called rx_queue and tx_queue. I think these
fields do not mean much for listening sockets and they are always zero. So why
not use one of these fields(rx_queue) to export the accept queue len for listening
sockets?
The attached patch implements this, but it only works with /proc/net/tcp and
/proc/net/tcp6.

In order to support this with netstat/ss that use netlink mechanism to
get the socket info, i think we need to extend tcp_info to add this field.
Can this be done in a backward compatible way?

Anyway, i think it is useful to have this value exported via /proc.

Thanks
Sridhar


Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 25ecc6e..4c6ef47 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1726,7 +1726,8 @@ static void get_tcp4_sock(struct sock *s
 	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
 			"%08X %5d %8d %lu %d %p %u %u %u %u %d",
 		i, src, srcp, dest, destp, sp->sk_state,
-		tp->write_seq - tp->snd_una, tp->rcv_nxt - tp->copied_seq,
+		tp->write_seq - tp->snd_una,
+		(sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
 		timer_active,
 		jiffies_to_clock_t(timer_expires - jiffies),
 		icsk->icsk_retransmits,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a50eb30..b36d5b2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1469,7 +1469,8 @@ static void get_tcp6_sock(struct seq_fil
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
 		   sp->sk_state, 
-		   tp->write_seq-tp->snd_una, tp->rcv_nxt-tp->copied_seq,
+		   tp->write_seq-tp->snd_una,
+		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
 		   timer_active,
 		   jiffies_to_clock_t(timer_expires - jiffies),
 		   icsk->icsk_retransmits,


