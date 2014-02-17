From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: tcp: add mib counters to track zero window transitions
Date: Mon, 17 Feb 2014 22:57:48 +0100
Message-ID: <1392674268-26005-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50815 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752864AbaBQWBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 17:01:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three counters are added:
- one to track when we went from non-zero to zero window
- one to track the reverse
- one counter incremented when we want to announce zero window.

The latter is added because it can show cases where we want to close the
window but can't because we would shrink window.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Eric, is this what you had in mind?

 I re-ran my 'slow-sender-with-reader-that-does-not-drain-socket'
 scenario and, as expected, only TCPWANTZEROWINDOW increases.

 Thanks,
 Florian

 include/uapi/linux/snmp.h |  3 +++
 net/ipv4/proc.c           |  3 +++
 net/ipv4/tcp_output.c     | 13 ++++++++++++-
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index bbaba22..6404eed 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -259,6 +259,9 @@ enum
 	LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
 	LINUX_MIB_BUSYPOLLRXPACKETS,		/* BusyPollRxPackets */
 	LINUX_MIB_TCPAUTOCORKING,		/* TCPAutoCorking */
+	LINUX_MIB_TCPFROMZEROWINDOWADV,		/* TCPFromZeroWindowAdv */
+	LINUX_MIB_TCPTOZEROWINDOWADV,		/* TCPToZeroWindowAdv */
+	LINUX_MIB_TCPWANTZEROWINDOW,		/* TCPWantZeroWindow */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index a6c8a80..542d414 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -280,6 +280,9 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
 	SNMP_MIB_ITEM("BusyPollRxPackets", LINUX_MIB_BUSYPOLLRXPACKETS),
 	SNMP_MIB_ITEM("TCPAutoCorking", LINUX_MIB_TCPAUTOCORKING),
+	SNMP_MIB_ITEM("TCPFromZeroWindowAdv", LINUX_MIB_TCPFROMZEROWINDOWADV),
+	SNMP_MIB_ITEM("TCPToZeroWindowAdv", LINUX_MIB_TCPTOZEROWINDOWADV),
+	SNMP_MIB_ITEM("TCPWantZeroWindow", LINUX_MIB_TCPWANTZEROWINDOW),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 48414fc..e8d6f14 100644
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
+			NET_INC_STATS_BH(sock_net(sk),
+					 LINUX_MIB_TCPWANTZEROWINDOW);
 		new_win = ALIGN(cur_win, 1 << tp->rx_opt.rcv_wscale);
 	}
 	tp->rcv_wnd = new_win;
@@ -298,8 +302,15 @@ static u16 tcp_select_window(struct sock *sk)
 	new_win >>= tp->rx_opt.rcv_wscale;
 
 	/* If we advertise zero window, disable fast path. */
-	if (new_win == 0)
+	if (new_win == 0) {
 		tp->pred_flags = 0;
+		if (old_win)
+			NET_INC_STATS_BH(sock_net(sk),
+					 LINUX_MIB_TCPTOZEROWINDOWADV);
+	} else if (old_win == 0) {
+		NET_INC_STATS_BH(sock_net(sk),
+				 LINUX_MIB_TCPFROMZEROWINDOWADV);
+	}
 
 	return new_win;
 }
-- 
1.8.1.5
