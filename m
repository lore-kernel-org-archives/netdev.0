From: Fan Du <fan.du@intel.com>
Subject: [PATCHv3 net-next 3/4] ipv4: shrink current mss for tcp PMTU blackhole detection
Date: Sat, 28 Feb 2015 11:23:04 +0800
Message-ID: <1425093785-27380-4-git-send-email-fan.du@intel.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com>
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46020 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbbB1D1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 22:27:54 -0500
In-Reply-To: <1425093785-27380-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reducing current tcp mss instead of search_low will make
more sense, as current tcp mss still got lost.

In addition, rename tcp_mtu_probing to tcp_blackhole_probe
to clearify confusion between tcp_mtu_probing and
tcp_mtu_probe.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/ipv4/tcp_timer.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 0732b78..3465175 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -99,7 +99,8 @@ static int tcp_orphan_retries(struct sock *sk, int alive)
 	return retries;
 }
 
-static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
+static void tcp_blackhole_probe(struct inet_connection_sock *icsk,
+				struct sock *sk)
 {
 	struct net *net = sock_net(sk);
 
@@ -113,7 +114,8 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 			struct tcp_sock *tp = tcp_sk(sk);
 			int mss;
 
-			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low) >> 1;
+			/* try mss smaller than current mss */
+			mss = tcp_current_mss(sk) >> 1;
 			mss = min(net->ipv4.sysctl_tcp_base_mss, mss);
 			mss = max(mss, 68 - tp->tcp_header_len);
 			icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
@@ -176,7 +178,7 @@ static int tcp_write_timeout(struct sock *sk)
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
 			/* Black hole detection */
-			tcp_mtu_probing(icsk, sk);
+			tcp_blackhole_probe(icsk, sk);
 
 			dst_negative_advice(sk);
 		}
-- 
1.7.1
