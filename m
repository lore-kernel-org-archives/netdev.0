From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tcp: Add SNMP counter for DEFER_ACCEPT
Date: Fri, 19 Mar 2010 16:37:18 +0100
Message-ID: <1269013038.3048.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:33873 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab0CSPhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 11:37:23 -0400
Received: by bwz1 with SMTP id 1so143520bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 08:37:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its currently hard to diagnose when ACK frames are dropped because an
application set TCP_DEFER_ACCEPT on its listening socket.

See http://bugzilla.kernel.org/show_bug.cgi?id=15507

This patch adds a SNMP value, named TCPDeferAcceptDrop

netstat -s | grep TCPDeferAcceptDrop
    TCPDeferAcceptDrop: 0

This counter is incremented every time we drop a pure ACK frame received
by a socket in SYN_RECV state because its SYNACK retrans count is lower
than defer_accept value.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/snmp.h     |    1 +
 net/ipv4/proc.c          |    1 +
 net/ipv4/tcp_minisocks.c |    1 +
 3 files changed, 3 insertions(+)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 4435d10..d2a9aa3 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -227,6 +227,7 @@ enum
 	LINUX_MIB_SACKSHIFTFALLBACK,
 	LINUX_MIB_TCPBACKLOGDROP,
 	LINUX_MIB_TCPMINTTLDROP, /* RFC 5082 */
+	LINUX_MIB_TCPDEFERACCEPTDROP,
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 4f1f337..3dc9914 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -251,6 +251,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPSackShiftFallback", LINUX_MIB_SACKSHIFTFALLBACK),
 	SNMP_MIB_ITEM("TCPBacklogDrop", LINUX_MIB_TCPBACKLOGDROP),
 	SNMP_MIB_ITEM("TCPMinTTLDrop", LINUX_MIB_TCPMINTTLDROP),
+	SNMP_MIB_ITEM("TCPDeferAcceptDrop", LINUX_MIB_TCPDEFERACCEPTDROP),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4199bc6..32f9627 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -671,6 +671,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
 	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
 		inet_rsk(req)->acked = 1;
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDEFERACCEPTDROP);
 		return NULL;
 	}
 


