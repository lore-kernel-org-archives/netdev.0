From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] tcp: add tcp_syncookies mode to allow unconditionally generation of syncookies
Date: Fri, 26 Jul 2013 17:43:23 +0200
Message-ID: <20130726154323.GA12067@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, fw@strlen.de, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41428 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756379Ab3GZPnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 11:43:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From the documentation update:
| If you want to test which effects syncookies have to your
| network connections you can set this knob to 2 to enable
| unconditionally generation of syncookies.

Original idea and first implementation by Eric Dumazet.

Cc: Florian Westphal <fw@strlen.de>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt | 4 ++++
 net/ipv4/tcp_ipv4.c                    | 5 +++--
 net/ipv6/tcp_ipv6.c                    | 3 ++-
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 53cea9b..36be26b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -440,6 +440,10 @@ tcp_syncookies - BOOLEAN
 	SYN flood warnings in logs not being really flooded, your server
 	is seriously misconfigured.
 
+	If you want to test which effects syncookies have to your
+	network connections you can set this knob to 2 to enable
+	unconditionally generation of syncookies.
+
 tcp_fastopen - INTEGER
 	Enable TCP Fast Open feature (draft-ietf-tcpm-fastopen) to send data
 	in the opening SYN packet. To use this feature, the client application
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2a5d5c4..280efe5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -890,7 +890,7 @@ bool tcp_syn_flood_action(struct sock *sk,
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);
 
 	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
-	if (!lopt->synflood_warned) {
+	if (!lopt->synflood_warned && sysctl_tcp_syncookies != 2) {
 		lopt->synflood_warned = 1;
 		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
 			proto, ntohs(tcp_hdr(skb)->dest), msg);
@@ -1462,7 +1462,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * limitations, they conserve resources and peer is
 	 * evidently real one.
 	 */
-	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+	if ((sysctl_tcp_syncookies == 2 ||
+	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
 		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
 		if (!want_cookie)
 			goto drop;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b792e87..38c196c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -963,7 +963,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (!ipv6_unicast_destination(skb))
 		goto drop;
 
-	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+	if ((sysctl_tcp_syncookies == 2 ||
+	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
 		want_cookie = tcp_syn_flood_action(sk, skb, "TCPv6");
 		if (!want_cookie)
 			goto drop;
-- 
1.8.3.1
