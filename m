From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 3/4] ipv4: Use probe_size to check write queue data length
Date: Tue, 10 Mar 2015 17:16:25 +0800
Message-ID: <1425978986-8512-4-git-send-email-fan.du@intel.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38648 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbbCJJV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 05:21:28 -0400
In-Reply-To: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building a probe segment, only 'probe_size' of bytes
is needed, so check write queue data length with probe_size
instead of size_needed.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/ipv4/tcp_output.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 79977d1..89d3f84 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1872,7 +1872,6 @@ static int tcp_mtu_probe(struct sock *sk)
 	struct net *net = sock_net(sk);
 	int len;
 	int probe_size;
-	int size_needed;
 	int copy;
 	int mss_now;
 	int interval;
@@ -1895,7 +1894,6 @@ static int tcp_mtu_probe(struct sock *sk)
 	mss_now = tcp_current_mss(sk);
 	probe_size = tcp_mtu_to_mss(sk, (icsk->icsk_mtup.search_high +
 				    icsk->icsk_mtup.search_low) >> 1);
-	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
 	interval = icsk->icsk_mtup.search_high - icsk->icsk_mtup.search_low;
 	/* When misfortune happens, we are reprobing actively,
 	 * and then reprobe timer has expired. We stick with current
@@ -1911,12 +1909,12 @@ static int tcp_mtu_probe(struct sock *sk)
 	}
 
 	/* Have enough data in the send queue to probe? */
-	if (tp->write_seq - tp->snd_nxt < size_needed)
+	if (tp->write_seq - tp->snd_nxt < probe_size)
 		return -1;
 
-	if (tp->snd_wnd < size_needed)
+	if (tp->snd_wnd < probe_size)
 		return -1;
-	if (after(tp->snd_nxt + size_needed, tcp_wnd_end(tp)))
+	if (after(tp->snd_nxt + probe_size, tcp_wnd_end(tp)))
 		return 0;
 
 	/* Do we need to wait to drain cwnd? With none in flight, don't stall */
-- 
1.7.1
