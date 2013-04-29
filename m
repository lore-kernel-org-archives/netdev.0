From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: Add MIB counters for checksum errors
Date: Mon, 29 Apr 2013 11:39:56 -0700
Message-ID: <1367260796.8964.331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f179.google.com ([209.85.210.179]:60666 "EHLO
	mail-ia0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195Ab3D2Sj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:39:59 -0400
Received: by mail-ia0-f179.google.com with SMTP id p22so5820750iad.24
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 11:39:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add MIB counters for checksum errors in IP layer,
and TCP/UDP/ICMP layers, to help diagnose problems.

$ nstat -a | grep  Csum
IcmpInCsumErrors                72                 0.0
TcpInCsumErrors                 382                0.0
UdpInCsumErrors                 463221             0.0
Icmp6InCsumErrors               75                 0.0
Udp6InCsumErrors                173442             0.0
IpExtInCsumErrors               10884              0.0

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/snmp.h |    5 +++++
 net/ipv4/icmp.c           |    4 +++-
 net/ipv4/ip_input.c       |    4 +++-
 net/ipv4/proc.c           |   10 +++++++---
 net/ipv4/tcp_input.c      |    1 +
 net/ipv4/tcp_ipv4.c       |   14 ++++++++++----
 net/ipv4/tcp_output.c     |    3 ++-
 net/ipv4/udp.c            |   11 +++++++++--
 net/ipv6/icmp.c           |    4 +++-
 net/ipv6/proc.c           |    4 ++++
 net/ipv6/tcp_ipv6.c       |   19 ++++++++++---------
 net/ipv6/udp.c            |   21 +++++++++++++++------
 12 files changed, 72 insertions(+), 28 deletions(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index fefdec91..df2e8b4 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -50,6 +50,7 @@ enum
 	IPSTATS_MIB_OUTMCASTOCTETS,		/* OutMcastOctets */
 	IPSTATS_MIB_INBCASTOCTETS,		/* InBcastOctets */
 	IPSTATS_MIB_OUTBCASTOCTETS,		/* OutBcastOctets */
+	IPSTATS_MIB_CSUMERRORS,			/* InCsumErrors */
 	__IPSTATS_MIB_MAX
 };
 
@@ -87,6 +88,7 @@ enum
 	ICMP_MIB_OUTTIMESTAMPREPS,		/* OutTimestampReps */
 	ICMP_MIB_OUTADDRMASKS,			/* OutAddrMasks */
 	ICMP_MIB_OUTADDRMASKREPS,		/* OutAddrMaskReps */
+	ICMP_MIB_CSUMERRORS,			/* InCsumErrors */
 	__ICMP_MIB_MAX
 };
 
@@ -103,6 +105,7 @@ enum
 	ICMP6_MIB_INERRORS,			/* InErrors */
 	ICMP6_MIB_OUTMSGS,			/* OutMsgs */
 	ICMP6_MIB_OUTERRORS,			/* OutErrors */
+	ICMP6_MIB_CSUMERRORS,			/* InCsumErrors */
 	__ICMP6_MIB_MAX
 };
 
@@ -130,6 +133,7 @@ enum
 	TCP_MIB_RETRANSSEGS,			/* RetransSegs */
 	TCP_MIB_INERRS,				/* InErrs */
 	TCP_MIB_OUTRSTS,			/* OutRsts */
+	TCP_MIB_CSUMERRORS,			/* InCsumErrors */
 	__TCP_MIB_MAX
 };
 
@@ -147,6 +151,7 @@ enum
 	UDP_MIB_OUTDATAGRAMS,			/* OutDatagrams */
 	UDP_MIB_RCVBUFERRORS,			/* RcvbufErrors */
 	UDP_MIB_SNDBUFERRORS,			/* SndbufErrors */
+	UDP_MIB_CSUMERRORS,			/* InCsumErrors */
 	__UDP_MIB_MAX
 };
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 3ac5dff..76e10b4 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -881,7 +881,7 @@ int icmp_rcv(struct sk_buff *skb)
 	case CHECKSUM_NONE:
 		skb->csum = 0;
 		if (__skb_checksum_complete(skb))
-			goto error;
+			goto csum_error;
 	}
 
 	if (!pskb_pull(skb, sizeof(*icmph)))
@@ -929,6 +929,8 @@ int icmp_rcv(struct sk_buff *skb)
 drop:
 	kfree_skb(skb);
 	return 0;
+csum_error:
+	ICMP_INC_STATS_BH(net, ICMP_MIB_CSUMERRORS);
 error:
 	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 	goto drop;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 2bdf802..3da817b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -419,7 +419,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	iph = ip_hdr(skb);
 
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
-		goto inhdr_error;
+		goto csum_error;
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
@@ -446,6 +446,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);
 
+csum_error:
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_CSUMERRORS);
 inhdr_error:
 	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
 drop:
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 6da51d5..2a5bf86 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -125,6 +125,7 @@ static const struct snmp_mib snmp4_ipextstats_list[] = {
 	SNMP_MIB_ITEM("OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_ITEM("InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
 	SNMP_MIB_ITEM("OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
+	SNMP_MIB_ITEM("InCsumErrors", IPSTATS_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -162,6 +163,7 @@ static const struct snmp_mib snmp4_tcp_list[] = {
 	SNMP_MIB_ITEM("RetransSegs", TCP_MIB_RETRANSSEGS),
 	SNMP_MIB_ITEM("InErrs", TCP_MIB_INERRS),
 	SNMP_MIB_ITEM("OutRsts", TCP_MIB_OUTRSTS),
+	SNMP_MIB_ITEM("InCsumErrors", TCP_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -172,6 +174,7 @@ static const struct snmp_mib snmp4_udp_list[] = {
 	SNMP_MIB_ITEM("OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_ITEM("RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("SndbufErrors", UDP_MIB_SNDBUFERRORS),
+	SNMP_MIB_ITEM("InCsumErrors", UDP_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -322,15 +325,16 @@ static void icmp_put(struct seq_file *seq)
 	struct net *net = seq->private;
 	atomic_long_t *ptr = net->mib.icmpmsg_statistics->mibs;
 
-	seq_puts(seq, "\nIcmp: InMsgs InErrors");
+	seq_puts(seq, "\nIcmp: InMsgs InErrors InCsumErrors");
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " In%s", icmpmibmap[i].name);
 	seq_printf(seq, " OutMsgs OutErrors");
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
-	seq_printf(seq, "\nIcmp: %lu %lu",
+	seq_printf(seq, "\nIcmp: %lu %lu %lu",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INMSGS),
-		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INERRORS));
+		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INERRORS),
+		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_CSUMERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			   atomic_long_read(ptr + icmpmibmap[i].index));
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index aafd052..08bbe60 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5273,6 +5273,7 @@ step5:
 	return 0;
 
 csum_error:
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 
 discard:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2278669..8ea9751 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1866,6 +1866,7 @@ discard:
 	return 0;
 
 csum_err:
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 	goto discard;
 }
@@ -1985,7 +1986,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	 * provided case of th->doff==0 is eliminated.
 	 * So, we defer the checks. */
 	if (!skb_csum_unnecessary(skb) && tcp_v4_checksum_init(skb))
-		goto bad_packet;
+		goto csum_error;
 
 	th = tcp_hdr(skb);
 	iph = ip_hdr(skb);
@@ -2051,6 +2052,8 @@ no_tcp_socket:
 		goto discard_it;
 
 	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
+csum_error:
+		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
@@ -2072,10 +2075,13 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
-		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
+	if (skb->len < (th->doff << 2)) {
 		inet_twsk_put(inet_twsk(sk));
-		goto discard_it;
+		goto bad_packet;
+	}
+	if (tcp_checksum_complete(skb)) {
+		inet_twsk_put(inet_twsk(sk));
+		goto csum_error;
 	}
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b735c23..536d409 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -80,8 +80,9 @@ static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
 
 	tp->packets_out += tcp_skb_pcount(skb);
 	if (!prior_packets || icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
-	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)
+	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
 		tcp_rearm_rto(sk);
+	}
 }
 
 /* SND.NXT, if window was not shrunk.
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2722db0..3159d16 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1131,6 +1131,8 @@ static unsigned int first_packet_length(struct sock *sk)
 	spin_lock_bh(&rcvq->lock);
 	while ((skb = skb_peek(rcvq)) != NULL &&
 		udp_lib_checksum_complete(skb)) {
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS,
+				 IS_UDPLITE(sk));
 		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
 				 IS_UDPLITE(sk));
 		atomic_inc(&sk->sk_drops);
@@ -1286,8 +1288,10 @@ out:
 
 csum_copy_err:
 	slow = lock_sock_fast(sk);
-	if (!skb_kill_datagram(sk, skb, flags))
+	if (!skb_kill_datagram(sk, skb, flags)) {
+		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	}
 	unlock_sock_fast(sk, slow);
 
 	if (noblock)
@@ -1513,7 +1517,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (rcu_access_pointer(sk->sk_filter) &&
 	    udp_lib_checksum_complete(skb))
-		goto drop;
+		goto csum_error;
 
 
 	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
@@ -1533,6 +1537,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	return rc;
 
+csum_error:
+	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 drop:
 	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	atomic_inc(&sk->sk_drops);
@@ -1749,6 +1755,7 @@ csum_error:
 		       proto == IPPROTO_UDPLITE ? "Lite" : "",
 		       &saddr, ntohs(uh->source), &daddr, ntohs(uh->dest),
 		       ulen);
+	UDP_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
 drop:
 	UDP_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 2a53a79..b4ff0a4 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -699,7 +699,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		if (__skb_checksum_complete(skb)) {
 			LIMIT_NETDEBUG(KERN_DEBUG "ICMPv6 checksum failed [%pI6 > %pI6]\n",
 				       saddr, daddr);
-			goto discard_it;
+			goto csum_error;
 		}
 	}
 
@@ -785,6 +785,8 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	kfree_skb(skb);
 	return 0;
 
+csum_error:
+	ICMP6_INC_STATS_BH(dev_net(dev), idev, ICMP6_MIB_CSUMERRORS);
 discard_it:
 	ICMP6_INC_STATS_BH(dev_net(dev), idev, ICMP6_MIB_INERRORS);
 drop_no_count:
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index bbbe53a..115cc58 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -90,6 +90,7 @@ static const struct snmp_mib snmp6_ipstats_list[] = {
 	SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
+	SNMP_MIB_ITEM("InCsumErrors", IPSTATS_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -99,6 +100,7 @@ static const struct snmp_mib snmp6_icmp6_list[] = {
 	SNMP_MIB_ITEM("Icmp6InErrors", ICMP6_MIB_INERRORS),
 	SNMP_MIB_ITEM("Icmp6OutMsgs", ICMP6_MIB_OUTMSGS),
 	SNMP_MIB_ITEM("Icmp6OutErrors", ICMP6_MIB_OUTERRORS),
+	SNMP_MIB_ITEM("Icmp6InCsumErrors", ICMP6_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -129,6 +131,7 @@ static const struct snmp_mib snmp6_udp6_list[] = {
 	SNMP_MIB_ITEM("Udp6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_ITEM("Udp6RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("Udp6SndbufErrors", UDP_MIB_SNDBUFERRORS),
+	SNMP_MIB_ITEM("Udp6InCsumErrors", UDP_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -139,6 +142,7 @@ static const struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_ITEM("UdpLite6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_ITEM("UdpLite6RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("UdpLite6SndbufErrors", UDP_MIB_SNDBUFERRORS),
+	SNMP_MIB_ITEM("UdpLite6InCsumErrors", UDP_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e51bd1a..7116706 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1405,6 +1405,7 @@ discard:
 	kfree_skb(skb);
 	return 0;
 csum_err:
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 	goto discard;
 
@@ -1466,7 +1467,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 		goto discard_it;
 
 	if (!skb_csum_unnecessary(skb) && tcp_v6_checksum_init(skb))
-		goto bad_packet;
+		goto csum_error;
 
 	th = tcp_hdr(skb);
 	hdr = ipv6_hdr(skb);
@@ -1530,6 +1531,8 @@ no_tcp_socket:
 		goto discard_it;
 
 	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
+csum_error:
+		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
@@ -1537,11 +1540,6 @@ bad_packet:
 	}
 
 discard_it:
-
-	/*
-	 *	Discard frame
-	 */
-
 	kfree_skb(skb);
 	return 0;
 
@@ -1555,10 +1553,13 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
-		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
+	if (skb->len < (th->doff<<2)) {
 		inet_twsk_put(inet_twsk(sk));
-		goto discard_it;
+		goto bad_packet;
+	}
+	if (tcp_checksum_complete(skb)) {
+		inet_twsk_put(inet_twsk(sk));
+		goto csum_error;
 	}
 
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index da6019b..d4defdd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -483,12 +483,17 @@ out:
 csum_copy_err:
 	slow = lock_sock_fast(sk);
 	if (!skb_kill_datagram(sk, skb, flags)) {
-		if (is_udp4)
+		if (is_udp4) {
+			UDP_INC_STATS_USER(sock_net(sk),
+					UDP_MIB_CSUMERRORS, is_udplite);
 			UDP_INC_STATS_USER(sock_net(sk),
 					UDP_MIB_INERRORS, is_udplite);
-		else
+		} else {
+			UDP6_INC_STATS_USER(sock_net(sk),
+					UDP_MIB_CSUMERRORS, is_udplite);
 			UDP6_INC_STATS_USER(sock_net(sk),
 					UDP_MIB_INERRORS, is_udplite);
+		}
 	}
 	unlock_sock_fast(sk, slow);
 
@@ -637,7 +642,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (rcu_access_pointer(sk->sk_filter)) {
 		if (udp_lib_checksum_complete(skb))
-			goto drop;
+			goto csum_error;
 	}
 
 	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
@@ -656,6 +661,8 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_unlock_sock(sk);
 
 	return rc;
+csum_error:
+	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 drop:
 	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	atomic_inc(&sk->sk_drops);
@@ -817,7 +824,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	}
 
 	if (udp6_csum_init(skb, uh, proto))
-		goto discard;
+		goto csum_error;
 
 	/*
 	 *	Multicast receive code
@@ -850,7 +857,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		goto discard;
 
 	if (udp_lib_checksum_complete(skb))
-		goto discard;
+		goto csum_error;
 
 	UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
@@ -867,7 +874,9 @@ short_packet:
 		       skb->len,
 		       daddr,
 		       ntohs(uh->dest));
-
+	goto discard;
+csum_error:
+	UDP6_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
 discard:
 	UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
