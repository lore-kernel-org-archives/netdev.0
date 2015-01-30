From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: dctcp: loosen requirement to assert ECT(0) during 3WHS
Date: Fri, 30 Jan 2015 20:45:20 +0100
Message-ID: <1422647120-27252-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Glenn Judd <glenn.judd@morganstanley.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43044 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752077AbbA3Tpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 14:45:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One deployment requirement of DCTCP is to be able to run
in a DC setting along with TCP traffic. As Glenn Judd's
NSDI'15 paper "Attaining the Promise and Avoiding the Pitfalls
of TCP in the Datacenter" [1] (tba) explains, one way to
solve this on switch side is to split DCTCP and TCP traffic
in two queues per switch port based on the DSCP: one queue
soley intended for DCTCP traffic and one for non-DCTCP traffic.

For the DCTCP queue, there's the marking threshold K as
explained in commit e3118e8359bb ("net: tcp: add DCTCP congestion
control algorithm") for RED marking ECT(0) packets with CE.
For the non-DCTCP queue, there's f.e. a classic tail drop queue.
As already explained in e3118e8359bb, running DCTCP at scale
when not marking SYN/SYN-ACK packets with ECT(0) has severe
consequences as for non-ECT(0) packets, traversing the RED
marking DCTCP queue will result in a severe reduction of
connection probability.

This is due to the DCTCP queue being dominated by ECT(0) traffic
and switches handle non-ECT traffic in the RED marking queue
after passing K as drops, where K is usually a low watermark
in order to leave enough tailroom for bursts. Splitting DCTCP
traffic among several queues (ECN and non-ECN queue) is being
considered a terrible idea in the network community as it
splits single flows across multiple network paths.

Therefore, commit e3118e8359bb implements this on Linux as
ECT(0) marked traffic, as we argue that marking all packets
of a DCTCP flow is the only viable solution and also doesn't
speak against the draft.

However, recently, a DCTCP implementation for FreeBSD hit also
their mainline kernel [2]. In order to let them play well
together with Linux' DCTCP, we would need to loosen the
requirement that ECT(0) has to be asserted during the 3WHS as
not implemented in FreeBSD. This simplifies the ECN test and
lets DCTCP work together with FreeBSD.

Joint work with Daniel Borkmann.

  [1] https://www.usenix.org/conference/nsdi15/technical-sessions/presentation/judd
  [2] https://github.com/freebsd/freebsd/commit/8ad879445281027858a7fa706d13e458095b595f

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Glenn Judd <glenn.judd@morganstanley.com>
---
 net/ipv4/tcp_input.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 71fb37c..9ec9115 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5870,10 +5870,9 @@ static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
  * TCP ECN negotiation.
  *
  * Exception: tcp_ca wants ECN. This is required for DCTCP
- * congestion control; it requires setting ECT on all packets,
- * including SYN. We inverse the test in this case: If our
- * local socket wants ECN, but peer only set ece/cwr (but not
- * ECT in IP header) its probably a non-DCTCP aware sender.
+ * congestion control: Linux DCTCP asserts ECT on all packets,
+ * including SYN, which is most optimal solution; however,
+ * others, such as FreeBSD do not.
  */
 static void tcp_ecn_create_request(struct request_sock *req,
 				   const struct sk_buff *skb,
@@ -5883,18 +5882,15 @@ static void tcp_ecn_create_request(struct request_sock *req,
 	const struct tcphdr *th = tcp_hdr(skb);
 	const struct net *net = sock_net(listen_sk);
 	bool th_ecn = th->ece && th->cwr;
-	bool ect, need_ecn, ecn_ok;
+	bool ect, ecn_ok;
 
 	if (!th_ecn)
 		return;
 
 	ect = !INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield);
-	need_ecn = tcp_ca_needs_ecn(listen_sk);
 	ecn_ok = net->ipv4.sysctl_tcp_ecn || dst_feature(dst, RTAX_FEATURE_ECN);
 
-	if (!ect && !need_ecn && ecn_ok)
-		inet_rsk(req)->ecn_ok = 1;
-	else if (ect && need_ecn)
+	if ((!ect && ecn_ok) || tcp_ca_needs_ecn(listen_sk))
 		inet_rsk(req)->ecn_ok = 1;
 }
 
-- 
2.0.5
