From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 2/3] ipv4: Use binary search to choose tcp PMTU probe_size
Date: Fri, 13 Feb 2015 16:16:44 +0800
Message-ID: <1423815405-32644-3-git-send-email-fan.du@intel.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
Cc: netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7254 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbbBMIVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2015 03:21:23 -0500
In-Reply-To: <1423815405-32644-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current probe_size is chosen by doubling mss_cache,
the initial mss base is 512 Bytes, as a result the
converged probe_size will only be 1024 Bytes, there
is still big gap between 1024 and common 1500 bytes
of mtu.

Use binary search to choose probe_size in a fine
granularity manner, an optimal mss will be found
to boost performance as its maxmium.

Test env:
Docker instance with vxlan encapuslation(82599EB)
iperf -c 10.0.0.24  -t 60

before this patch:
1.26 Gbits/sec

After this patch: increase 26%
1.59 Gbits/sec

Signed-off-by: Fan Du <fan.du@intel.com>
---
 include/net/inet_connection_sock.h |    3 +++
 net/ipv4/tcp_input.c               |    5 ++++-
 net/ipv4/tcp_output.c              |   12 +++++++++---
 net/ipv4/tcp_timer.c               |    2 +-
 4 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 5976bde..3d0932e 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -124,6 +124,9 @@ struct inet_connection_sock {
 		int		  search_high;
 		int		  search_low;
 
+		int		  search_high_sav;
+		int		  search_low_sav;
+
 		/* Information on the current probe. */
 		int		  probe_size;
 	} icsk_mtup;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8fdd27b..20b28e9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2613,7 +2613,10 @@ static void tcp_mtup_probe_success(struct sock *sk)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 	tp->snd_ssthresh = tcp_current_ssthresh(sk);
 
-	icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
+	if (icsk->icsk_mtup.search_low == icsk->icsk_mtup.probe_size)
+		icsk->icsk_mtup.search_low = icsk->icsk_mtup.search_high;
+	else
+		icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
 	icsk->icsk_mtup.probe_size = 0;
 	tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 }
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a2a796c..0a60deb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1349,10 +1349,13 @@ void tcp_mtup_init(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct net *net = sock_net(sk);
 
-	icsk->icsk_mtup.enabled = net->ipv4.sysctl_tcp_mtu_probing > 1;
+	icsk->icsk_mtup.enabled = net->ipv4.sysctl_tcp_mtu_probing;
 	icsk->icsk_mtup.search_high = tp->rx_opt.mss_clamp + sizeof(struct tcphdr) +
 			       icsk->icsk_af_ops->net_header_len;
 	icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, net->ipv4.sysctl_tcp_base_mss);
+
+	icsk->icsk_mtup.search_high_sav = icsk->icsk_mtup.search_high;
+	icsk->icsk_mtup.search_low_sav = icsk->icsk_mtup.search_low;
 	icsk->icsk_mtup.probe_size = 0;
 }
 EXPORT_SYMBOL(tcp_mtup_init);
@@ -1854,9 +1857,12 @@ static int tcp_mtu_probe(struct sock *sk)
 	    tp->rx_opt.num_sacks || tp->rx_opt.dsack)
 		return -1;
 
-	/* Very simple search strategy: just double the MSS. */
+	/* Use binary search for probe_size bewteen tcp_mss_base
+	 * and current mss_clamp.
+	 */
 	mss_now = tcp_current_mss(sk);
-	probe_size = 2 * tp->mss_cache;
+
+	probe_size = (icsk->icsk_mtup.search_high + icsk->icsk_mtup.search_low) >> 1;
 	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
 		/* TODO: set timer for probe_converge_event */
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 0732b78..9d1cfe0 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -113,7 +113,7 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 			struct tcp_sock *tp = tcp_sk(sk);
 			int mss;
 
-			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low) >> 1;
+			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low);
 			mss = min(net->ipv4.sysctl_tcp_base_mss, mss);
 			mss = max(mss, 68 - tp->tcp_header_len);
 			icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
-- 
1.7.1
