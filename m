From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 -next] net: tcp: add mib counters to track zero window transitions
Date: Tue, 25 Feb 2014 14:34:32 +0100
Message-ID: <1393335272-12914-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54787 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352AbaBYNid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 08:38:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three counters are added:
- one to track when we went from non-zero to zero window
- one to track the reverse
- one counter incremented when we want to announce zero window,
  but can't because we would shrink current window.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
Changes in v2:
 - use NET_INC_STATS, not _BH; can be called from both bh and process context (pointed out by Hannes)
 - rename LINUX_MIB_TCPWANTZEROWINDOW to LINUX_MIB_TCPWANTZEROWINDOWADV for consistency

 include/uapi/linux/snmp.h |  3 +++
 net/ipv4/proc.c           |  3 +++
 net/ipv4/tcp_output.c     | 12 +++++++++++-
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index bbaba22..8d64a7e 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -259,6 +259,9 @@ enum
 	LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
 	LINUX_MIB_BUSYPOLLRXPACKETS,		/* BusyPollRxPackets */
 	LINUX_MIB_TCPAUTOCORKING,		/* TCPAutoCorking */
+	LINUX_MIB_TCPFROMZEROWINDOWADV,		/* TCPFromZeroWindowAdv */
+	LINUX_MIB_TCPTOZEROWINDOWADV,		/* TCPToZeroWindowAdv */
+	LINUX_MIB_TCPWANTZEROWINDOWADV,		/* TCPWantZeroWindowAdv */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index a6c8a80..99d2e9b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -280,6 +280,9 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
 	SNMP_MIB_ITEM("BusyPollRxPackets", LINUX_MIB_BUSYPOLLRXPACKETS),
 	SNMP_MIB_ITEM("TCPAutoCorking", LINUX_MIB_TCPAUTOCORKING),
+	SNMP_MIB_ITEM("TCPFromZeroWindowAdv", LINUX_MIB_TCPFROMZEROWINDOWADV),
+	SNMP_MIB_ITEM("TCPToZeroWindowAdv", LINUX_MIB_TCPTOZEROWINDOWADV),
+	SNMP_MIB_ITEM("TCPWantZeroWindowAdv", LINUX_MIB_TCPWANTZEROWINDOWADV),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 21e8a9f..c5eadec 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -269,6 +269,7 @@ EXPORT_SYMBOL(tcp_select_initial_window);
 static u16 tcp_select_window(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	u32 old_win = tp->rcv_wnd;
 	u32 cur_win = tcp_receive_window(tp);
 	u32 new_win = __tcp_select_window(sk);
 
@@ -281,6 +282,9 @@ static u16 tcp_select_window(struct sock *sk)
 		 *
 		 * Relax Will Robinson.
 		 */
+		if (new_win == 0)
+			NET_INC_STATS(sock_net(sk),
+				      LINUX_MIB_TCPWANTZEROWINDOWADV);
 		new_win = ALIGN(cur_win, 1 << tp->rx_opt.rcv_wscale);
 	}
 	tp->rcv_wnd = new_win;
@@ -298,8 +302,14 @@ static u16 tcp_select_window(struct sock *sk)
 	new_win >>= tp->rx_opt.rcv_wscale;
 
 	/* If we advertise zero window, disable fast path. */
-	if (new_win == 0)
+	if (new_win == 0) {
 		tp->pred_flags = 0;
+		if (old_win)
+			NET_INC_STATS(sock_net(sk),
+				      LINUX_MIB_TCPTOZEROWINDOWADV);
+	} else if (old_win == 0) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPFROMZEROWINDOWADV);
+	}
 
 	return new_win;
 }
-- 
1.8.1.5
