From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add pacing_rate information into tcp_info
Date: Thu, 13 Feb 2014 14:27:40 -0800
Message-ID: <1392330460.1752.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:55530 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbaBMW1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:27:43 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so10719665pdb.38
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 14:27:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add two new fields to struct tcp_info, to report sk_pacing_rate
and sk_max_pacing_rate to monitoring applications, as ss from iproute2.

User exported fields are 64bit, even if kernel is currently using 32bit
fields.

lpaa5:~# ss -i 
..
	 skmem:(r0,rb357120,t0,tb2097152,f1584,w1980880,o0,bl0) ts sack cubic
wscale:6,6 rto:400 rtt:0.875/0.75 mss:1448 cwnd:1 ssthresh:12 send
13.2Mbps pacing_rate 3336.2Mbps unacked:15 retrans:1/5448 lost:15
rcv_space:29200

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/tcp.h |    3 +++
 net/ipv4/tcp.c           |    5 +++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 377f1e59411d..3b9718328d8b 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -186,6 +186,9 @@ struct tcp_info {
 	__u32	tcpi_rcv_space;
 
 	__u32	tcpi_total_retrans;
+
+	__u64	tcpi_pacing_rate;
+	__u64	tcpi_max_pacing_rate;
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9f3a2db9109e..bed379c7abcd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2794,6 +2794,11 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 	info->tcpi_rcv_space = tp->rcvq_space.space;
 
 	info->tcpi_total_retrans = tp->total_retrans;
+
+	info->tcpi_pacing_rate = sk->sk_pacing_rate != ~0U ?
+					sk->sk_pacing_rate : ~0ULL;
+	info->tcpi_max_pacing_rate = sk->sk_max_pacing_rate != ~0U ?
+					sk->sk_max_pacing_rate : ~0ULL;
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
