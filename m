From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp: add TCPWinProbe SNMP counter
Date: Wed,  6 May 2015 05:52:14 -0700
Message-ID: <1430916734-5051-3-git-send-email-edumazet@google.com>
References: <1430916734-5051-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:33027 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbEFMwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 08:52:40 -0400
Received: by ierx19 with SMTP id x19so1054890ier.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 05:52:39 -0700 (PDT)
In-Reply-To: <1430916734-5051-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Diagnosing problems related to Window Probes has been hard because
we lacked a counter.

TCPWinProbe counts the number of ACK packets a sender has to transmit
at regular intervals to make sure a reverse ACK packet opening back
a zero window had not been lost.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/snmp.h | 1 +
 net/ipv4/proc.c           | 1 +
 net/ipv4/tcp_output.c     | 1 +
 3 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 6a6fb747c78d..05a1b92dc7d8 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -276,6 +276,7 @@ enum
 	LINUX_MIB_TCPACKSKIPPEDFINWAIT2,	/* TCPACKSkippedFinWait2 */
 	LINUX_MIB_TCPACKSKIPPEDTIMEWAIT,	/* TCPACKSkippedTimeWait */
 	LINUX_MIB_TCPACKSKIPPEDCHALLENGE,	/* TCPACKSkippedChallenge */
+	LINUX_MIB_TCPWINPROBE,			/* TCPWinProbe */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index e1f3b911dd1e..0ce5c7797d01 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -298,6 +298,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPACKSkippedFinWait2", LINUX_MIB_TCPACKSKIPPEDFINWAIT2),
 	SNMP_MIB_ITEM("TCPACKSkippedTimeWait", LINUX_MIB_TCPACKSKIPPEDTIMEWAIT),
 	SNMP_MIB_ITEM("TCPACKSkippedChallenge", LINUX_MIB_TCPACKSKIPPEDCHALLENGE),
+	SNMP_MIB_ITEM("TCPWinProbe", LINUX_MIB_TCPWINPROBE),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b76c719e1979..18a9a44c8761 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3400,6 +3400,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	 */
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPHDR_ACK);
 	skb_mstamp_get(&skb->skb_mstamp);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPWINPROBE);
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
 
-- 
2.2.0.rc0.207.ga3a616c
