From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net 1/2] tcp: disable Fast Open on timeouts after handshake
Date: Wed, 18 Nov 2015 18:17:30 -0800
Message-ID: <1447899451-24584-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35951 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754580AbbKSCSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 21:18:08 -0500
Received: by pacdm15 with SMTP id dm15so63958606pac.3
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 18:18:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some middle-boxes black-hole the data after the Fast Open handshake
(https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf).
The exact reason is unknown. The work-around is to disable Fast Open
temporarily after multiple recurring timeouts with few or no data
delivered in the established state.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Christoph Paasch <cpaasch@apple.com>
---
 net/ipv4/tcp_timer.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index c9c716a..448603a 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -176,6 +176,18 @@ static int tcp_write_timeout(struct sock *sk)
 		syn_set = true;
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
+			/* Some middle-boxes may black-hole Fast Open _after_
+			 * the handshake. Therefore we conservatively disable
+			 * Fast Open on this path on recurring timeouts with
+			 * few or zero bytes acked after Fast Open.
+			 */
+			if (tp->syn_data_acked &&
+			    tp->bytes_acked <= tp->rx_opt.mss_clamp) {
+				tcp_fastopen_cache_set(sk, 0, NULL, true, 0);
+				if (icsk->icsk_retransmits == sysctl_tcp_retries1)
+					NET_INC_STATS_BH(sock_net(sk),
+							 LINUX_MIB_TCPFASTOPENACTIVEFAIL);
+			}
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
-- 
2.6.0.rc2.230.g3dd15c0
