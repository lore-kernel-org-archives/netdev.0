From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] tcp_cubic: add SNMP counters to track how
 effective is Hystart
Date: Thu, 04 Dec 2014 16:13:23 -0800
Message-ID: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:40126 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbaLEANZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 19:13:25 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so16170557iec.8
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 16:13:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When deploying FQ pacing, one thing we noticed is that CUBIC Hystart
triggers too soon.

Having SNMP counters to have an idea of how often the various Hystart
methods trigger is useful prior to any modifications.

This patch adds SNMP counters tracking, how many time "ack train" or
"Delay" based Hystart triggers, and cumulative sum of cwnd at the time
Hystart decided to end SS (Slow Start)

myhost:~# nstat -a | grep Hystart
TcpExtTCPHystartTrainDetect     9                  0.0
TcpExtTCPHystartTrainCwnd       20650              0.0
TcpExtTCPHystartDelayDetect     10                 0.0
TcpExtTCPHystartDelayCwnd       360                0.0

->
 Train detection was triggered 9 times, and average cwnd was
 20650/9=2294,
 Delay detection was triggered 10 times and average cwnd was 36

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/snmp.h |    4 ++++
 net/ipv4/proc.c           |    4 ++++
 net/ipv4/tcp_cubic.c      |   31 ++++++++++++++++++++++---------
 3 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 30f541b32895..b22224100011 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -266,6 +266,10 @@ enum
 	LINUX_MIB_TCPWANTZEROWINDOWADV,		/* TCPWantZeroWindowAdv */
 	LINUX_MIB_TCPSYNRETRANS,		/* TCPSynRetrans */
 	LINUX_MIB_TCPORIGDATASENT,		/* TCPOrigDataSent */
+	LINUX_MIB_TCPHYSTARTTRAINDETECT,	/* TCPHystartTrainDetect */
+	LINUX_MIB_TCPHYSTARTTRAINCWND,		/* TCPHystartTrainCwnd */
+	LINUX_MIB_TCPHYSTARTDELAYDETECT,	/* TCPHystartDelayDetect */
+	LINUX_MIB_TCPHYSTARTDELAYCWND,		/* TCPHystartDelayCwnd */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 6513ade8d6dc..8f9cd200ce20 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -288,6 +288,10 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPWantZeroWindowAdv", LINUX_MIB_TCPWANTZEROWINDOWADV),
 	SNMP_MIB_ITEM("TCPSynRetrans", LINUX_MIB_TCPSYNRETRANS),
 	SNMP_MIB_ITEM("TCPOrigDataSent", LINUX_MIB_TCPORIGDATASENT),
+	SNMP_MIB_ITEM("TCPHystartTrainDetect", LINUX_MIB_TCPHYSTARTTRAINDETECT),
+	SNMP_MIB_ITEM("TCPHystartTrainCwnd", LINUX_MIB_TCPHYSTARTTRAINCWND),
+	SNMP_MIB_ITEM("TCPHystartDelayDetect", LINUX_MIB_TCPHYSTARTDELAYDETECT),
+	SNMP_MIB_ITEM("TCPHystartDelayCwnd", LINUX_MIB_TCPHYSTARTDELAYCWND),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 20de0118c98e..c1d07c7ed03d 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -363,16 +363,28 @@ static void hystart_update(struct sock *sk, u32 delay)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
 
-	if (!(ca->found & hystart_detect)) {
+	if (ca->found & hystart_detect)
+		return;
+
+	if (hystart_detect & HYSTART_ACK_TRAIN) {
 		u32 now = bictcp_clock();
 
 		/* first detection parameter - ack-train detection */
 		if ((s32)(now - ca->last_ack) <= hystart_ack_delta) {
 			ca->last_ack = now;
-			if ((s32)(now - ca->round_start) > ca->delay_min >> 4)
+			if ((s32)(now - ca->round_start) > ca->delay_min >> 4) {
 				ca->found |= HYSTART_ACK_TRAIN;
+				NET_INC_STATS_BH(sock_net(sk),
+						 LINUX_MIB_TCPHYSTARTTRAINDETECT);
+				NET_ADD_STATS_BH(sock_net(sk),
+						 LINUX_MIB_TCPHYSTARTTRAINCWND,
+						 tp->snd_cwnd);
+				tp->snd_ssthresh = tp->snd_cwnd;
+			}
 		}
+	}
 
+	if (hystart_detect & HYSTART_DELAY) {
 		/* obtain the minimum delay of more than sampling packets */
 		if (ca->sample_cnt < HYSTART_MIN_SAMPLES) {
 			if (ca->curr_rtt == 0 || ca->curr_rtt > delay)
@@ -381,15 +393,16 @@ static void hystart_update(struct sock *sk, u32 delay)
 			ca->sample_cnt++;
 		} else {
 			if (ca->curr_rtt > ca->delay_min +
-			    HYSTART_DELAY_THRESH(ca->delay_min>>4))
+			    HYSTART_DELAY_THRESH(ca->delay_min>>4)) {
 				ca->found |= HYSTART_DELAY;
+				NET_INC_STATS_BH(sock_net(sk),
+						 LINUX_MIB_TCPHYSTARTDELAYDETECT);
+				NET_ADD_STATS_BH(sock_net(sk),
+						 LINUX_MIB_TCPHYSTARTDELAYCWND,
+						 tp->snd_cwnd);
+				tp->snd_ssthresh = tp->snd_cwnd;
+			}
 		}
-		/*
-		 * Either one of two conditions are met,
-		 * we exit from slow start immediately.
-		 */
-		if (ca->found & hystart_detect)
-			tp->snd_ssthresh = tp->snd_cwnd;
 	}
 }
 
