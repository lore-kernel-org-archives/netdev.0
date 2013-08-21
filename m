From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] net: tcp_probe: add IPv6 support
Date: Wed, 21 Aug 2013 19:48:00 +0200
Message-ID: <1377107280-31091-4-git-send-email-dborkman@redhat.com>
References: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752289Ab3HURsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 13:48:08 -0400
In-Reply-To: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tcp_probe currently only supports analysis of IPv4 connections.
Therefore, it would be nice to have IPv6 supported as well. Since we
have the recently added %pISpc specifier that is IPv4/IPv6 generic,
build related sockaddress structures from the flow information and
pass this to our format string. Tested with SSH and HTTP sessions
on IPv4 and IPv6.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp_probe.c |   54 ++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index a2392f4..301a3ef 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -54,8 +54,11 @@ static const char procname[] = "tcpprobe";
 
 struct tcp_log {
 	ktime_t tstamp;
-	__be32	saddr, daddr;
-	__be16	sport, dport;
+	union {
+		struct sockaddr		raw;
+		struct sockaddr_in	v4;
+		struct sockaddr_in6	v6;
+	}	src, dst;
 	u16	length;
 	u32	snd_nxt;
 	u32	snd_una;
@@ -87,6 +90,30 @@ static inline int tcp_probe_avail(void)
 	return bufsize - tcp_probe_used() - 1;
 }
 
+#define tcp_probe_copy_fl_to_si4(inet, si4, mem)		\
+	do {							\
+		si4.sin_family = AF_INET;			\
+		si4.sin_port = inet->inet_##mem##port;		\
+		si4.sin_addr.s_addr = inet->inet_##mem##addr;	\
+	} while (0)						\
+
+#if IS_ENABLED(CONFIG_IPV6)
+#define tcp_probe_copy_fl_to_si6(inet, si6, mem)		\
+	do {							\
+		struct ipv6_pinfo *pi6 = inet->pinet6;		\
+		si6.sin6_family = AF_INET6;			\
+		si6.sin6_port = inet->inet_##mem##port;		\
+		si6.sin6_addr = pi6->mem##addr;			\
+		si6.sin6_flowinfo = 0; /* No need here. */	\
+		si6.sin6_scope_id = 0;	/* No need here. */	\
+	} while (0)
+#else
+#define tcp_probe_copy_fl_to_si6(fl, si6, mem)			\
+	do {							\
+		memset(&si6, 0, sizeof(si6));			\
+	} while (0)
+#endif
+
 /*
  * Hook inserted to be called before each receive packet.
  * Note: arguments must match tcp_rcv_established()!
@@ -108,10 +135,19 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			struct tcp_log *p = tcp_probe.log + tcp_probe.head;
 
 			p->tstamp = ktime_get();
-			p->saddr = inet->inet_saddr;
-			p->sport = inet->inet_sport;
-			p->daddr = inet->inet_daddr;
-			p->dport = inet->inet_dport;
+			switch (sk->sk_family) {
+			case AF_INET:
+				tcp_probe_copy_fl_to_si4(inet, p->src.v4, s);
+				tcp_probe_copy_fl_to_si4(inet, p->dst.v4, d);
+				break;
+			case AF_INET6:
+				tcp_probe_copy_fl_to_si6(inet, p->src.v6, s);
+				tcp_probe_copy_fl_to_si6(inet, p->dst.v6, d);
+				break;
+			default:
+				BUG();
+			}
+
 			p->length = skb->len;
 			p->snd_nxt = tp->snd_nxt;
 			p->snd_una = tp->snd_una;
@@ -159,12 +195,10 @@ static int tcpprobe_sprint(char *tbuf, int n)
 		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
 
 	return scnprintf(tbuf, n,
-			"%lu.%09lu %pI4:%u %pI4:%u %d %#x %#x %u %u %u %u %u\n",
+			"%lu.%09lu %pISpc %pISpc %d %#x %#x %u %u %u %u %u\n",
 			(unsigned long) tv.tv_sec,
 			(unsigned long) tv.tv_nsec,
-			&p->saddr, ntohs(p->sport),
-			&p->daddr, ntohs(p->dport),
-			p->length, p->snd_nxt, p->snd_una,
+			&p->src, &p->dst, p->length, p->snd_nxt, p->snd_una,
 			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt, p->rcv_wnd);
 }
 
-- 
1.7.1
