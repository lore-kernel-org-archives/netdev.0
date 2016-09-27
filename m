From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next] tcp: Change txhash on every SYN and RTO retransmit
Date: Tue, 27 Sep 2016 09:06:29 -0700
Message-ID: <20160927160629.1174360-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57599 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751519AbcI0QHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:07:05 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8RFx4X7014012
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 09:07:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 25qc90qtxy-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 09:07:04 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 59ef3e1c84cc11e6b1600002c95209d8-7d6f5a50 for <netdev@vger.kernel.org>;        Tue,
 27 Sep 2016 09:06:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code changes txhash (flowlables) on every retransmitted
SYN/ACK, but only after the 2nd retransmitted SYN and only after
tcp_retries1 RTO retransmits.

With this patch:
1) txhash is changed with every SYN retransmist
2) adds the option for the txhash to be changed before tcp_retries1
   RTO retransmits. A new sysctl tcp_rto_txhash_prob represents the
   probability that txhash will be changed. The default value is 0
   which maintains previous behavior and a value of 100 will always
   change it.

Tested with packetdrill tests

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/net/tcp.h          |  1 +
 net/ipv4/sysctl_net_ipv4.c | 10 ++++++++++
 net/ipv4/tcp_input.c       |  2 ++
 net/ipv4/tcp_timer.c       |  7 +++++++
 4 files changed, 20 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f83b7f2..406d474 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -271,6 +271,7 @@ extern int sysctl_tcp_autocorking;
 extern int sysctl_tcp_invalid_ratelimit;
 extern int sysctl_tcp_pacing_ss_ratio;
 extern int sysctl_tcp_pacing_ca_ratio;
+extern int sysctl_tcp_rto_txhash_prob;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1cb67de..0b185a1 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -28,6 +28,7 @@
 static int zero;
 static int one = 1;
 static int four = 4;
+static int hundred = 100;
 static int thousand = 1000;
 static int gso_max_segs = GSO_MAX_SEGS;
 static int tcp_retr1_max = 255;
@@ -624,6 +625,15 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_ms_jiffies,
 	},
 	{
+		.procname	= "tcp_rto_txhash_prob",
+		.data		= &sysctl_tcp_rto_txhash_prob,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &hundred,
+	},
+	{
 		.procname	= "icmp_msgs_per_sec",
 		.data		= &sysctl_icmp_msgs_per_sec,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8c6ad2d..2fea29d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -101,6 +101,8 @@ int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_early_retrans __read_mostly = 3;
 int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 
+int sysctl_tcp_rto_txhash_prob __read_mostly = 100;
+
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
 #define FLAG_DATA_ACKED		0x04 /* This ACK acknowledged new data.		*/
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index f712b41..0df8c5f 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -192,6 +192,8 @@ static int tcp_write_timeout(struct sock *sk)
 			if (tp->syn_data && icsk->icsk_retransmits == 1)
 				NET_INC_STATS(sock_net(sk),
 					      LINUX_MIB_TCPFASTOPENACTIVEFAIL);
+		} else if (!tp->syn_data && !tp->syn_fastopen) {
+			sk_rethink_txhash(sk);
 		}
 		retry_until = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_syn_retries;
 		syn_set = true;
@@ -213,6 +215,11 @@ static int tcp_write_timeout(struct sock *sk)
 			tcp_mtu_probing(icsk, sk);
 
 			dst_negative_advice(sk);
+		} else if (sk->sk_txhash && sysctl_tcp_rto_txhash_prob > 0) {
+			u32 v = prandom_u32() % 100;
+
+			if (v < sysctl_tcp_rto_txhash_prob)
+				sk_set_txhash(sk);
 		}
 
 		retry_until = net->ipv4.sysctl_tcp_retries2;
-- 
2.9.3
