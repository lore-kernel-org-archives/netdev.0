From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [BUG-FIX][PATCH] tcp: Fix IPv6 fallout from 'Port redirection support
 for TCP'
Date: Sat, 18 Oct 2008 12:09:10 +0200
Message-ID: <200810181209.10355@nessa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:36959 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892AbYJRKJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 06:09:12 -0400
Received: from nessa.odu ([89.132.101.55])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTPSA id <0K8X00KL0IU3ND50@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 18 Oct 2008 12:08:27 +0200 (CEST)
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Gerrit's patch fixes DCCP, but I think that there are other code paths
in IPv6 TCP where the new loc_port field should be used.

Could you please consider applying the patch to net-2.6?

Cheers,
Krisztian

- 8< -
tcp: Fix IPv6 fallout from 'Port redirection support for TCP'

'tcp: Port redirection support for TCP' (a3116ac5c) added a new member
to inet_request_sock() which inet_csk_clone() makes use of but failed
to add proper initialization to the IPv6 syncookie code and missed a
couple of places where the new member should be used instead of
inet_sk(sk)->sport.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---
 net/ipv6/syncookies.c |    1 +
 net/ipv6/tcp_ipv6.c   |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index ec394cf..676c80b 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -204,6 +204,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	req->mss = mss;
 	ireq->rmt_port = th->source;
+	ireq->loc_port = th->dest;
 	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
 	if (ipv6_opt_accepted(sk, skb) ||
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e5310c9..b6b356b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -476,7 +476,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 	fl.fl6_flowlabel = 0;
 	fl.oif = treq->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-	fl.fl_ip_sport = inet_sk(sk)->sport;
+	fl.fl_ip_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
 
 	opt = np->opt;
@@ -1309,7 +1309,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-		fl.fl_ip_sport = inet_sk(sk)->sport;
+		fl.fl_ip_sport = inet_rsk(req)->loc_port;
 		security_req_classify_flow(req, &fl);
 
 		if (ip6_dst_lookup(sk, &dst, &fl))
@@ -1865,7 +1865,7 @@ static void get_openreq6(struct seq_file *seq,
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3],
-		   ntohs(inet_sk(sk)->sport),
+		   ntohs(inet_rsk(req)->loc_port),
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3],
 		   ntohs(inet_rsk(req)->rmt_port),
-- 
1.5.4.4
