From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: pmtudisc setting not respected with UFO/CORK
Date: Mon, 16 Dec 2013 12:36:44 +0100
Message-ID: <20131216113644.GB2215@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58759 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195Ab3LPLgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 06:36:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sockets marked with IPV6_PMTUDISC_PROBE (or later IPV6_PMTUDISC_INTERFACE)
don't respect this setting when the outgoing interface supports UFO.

We had the same problem in IPv4, which was fixed in commit
daba287b299ec7a2c61ae3a714920e90e8396ad5 ("ipv4: fix DO and PROBE pmtu
mode regarding local fragmentation with UFO/CORK").

Also IPV6_DONTFRAG mode did not care about already corked data, thus
it may generate a fragmented frame even if this socket option was
specified. It also did not care about the length of the ipv6 header and
possible options.

In the error path allow the user to receive the pmtu notifications via
both, rxpmtu method or error queue. The user may opted in for both,
so deliver the notification to both error handlers (the handlers check
if the error needs to be enqueued).

Also report back consistent pmtu values when sending on an already
cork-appended socket.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9a311cc..4060902 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1196,11 +1196,35 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	fragheaderlen = sizeof(struct ipv6hdr) + rt->rt6i_nfheader_len +
 			(opt ? opt->opt_nflen : 0);
-	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen -
+		     sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
-		if (cork->length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
-			ipv6_local_error(sk, EMSGSIZE, fl6, mtu-exthdrlen);
+		unsigned int maxnonfragsize, headersize;
+
+		headersize = sizeof(struct ipv6hdr) +
+			     (opt ? opt->tot_len : 0) +
+			     (dst_allfrag(&rt->dst) ?
+			      sizeof(struct frag_hdr) : 0) +
+			     rt->rt6i_nfheader_len;
+
+		maxnonfragsize = (np->pmtudisc >= IPV6_PMTUDISC_DO) ?
+				 mtu : sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
+
+		/* dontfrag active */
+		if ((cork->length + length > mtu - headersize) && dontfrag &&
+		    (sk->sk_protocol == IPPROTO_UDP ||
+		     sk->sk_protocol == IPPROTO_RAW)) {
+			ipv6_local_rxpmtu(sk, fl6, mtu - headersize +
+						   sizeof(struct ipv6hdr));
+			goto emsgsize;
+		}
+
+		if (cork->length + length > maxnonfragsize - headersize) {
+emsgsize:
+			ipv6_local_error(sk, EMSGSIZE, fl6,
+					 mtu - headersize +
+					 sizeof(struct ipv6hdr));
 			return -EMSGSIZE;
 		}
 	}
@@ -1225,12 +1249,6 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	 * --yoshfuji
 	 */
 
-	if ((length > mtu) && dontfrag && (sk->sk_protocol == IPPROTO_UDP ||
-					   sk->sk_protocol == IPPROTO_RAW)) {
-		ipv6_local_rxpmtu(sk, fl6, mtu-exthdrlen);
-		return -EMSGSIZE;
-	}
-
 	skb = skb_peek_tail(&sk->sk_write_queue);
 	cork->length += length;
 	if (((length > mtu) ||
-- 
1.8.3.1
