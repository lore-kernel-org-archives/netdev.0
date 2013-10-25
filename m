From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv4: fix DO and PROBE pmtu mode regarding local fragmentation with UFO/CORK
Date: Fri, 25 Oct 2013 21:40:03 +0200
Message-ID: <20131025194003.GG15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57634 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab3JYTkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 15:40:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UFO as well as UDP_CORK do not respect IP_PMTUDISC_DO and
IP_PMTUDISC_PROBE well enough.

UFO enabled packet delivery just appends all frags to the cork and hands
it over to the network card. So we just deliver non-DF udp fragments
(DF-flag may get overwritten by hardware or virtual UFO enabled
interface).

UDP_CORK does enqueue the data until the cork is disengaged. At this
point it sets the correct IP_DF and local_df flags and hands it over to
ip_fragment which in this case will generate an icmp error which gets
appended to the error socket queue. This is not reflected in the syscall
error (of course, if UFO is enabled this also won't happen).

Improve this by checking the pmtudisc flags before appending data to the
socket and if we still can fit all data in one packet when IP_PMTUDISC_DO
or IP_PMTUDISC_PROBE is set, only then proceed.

Maybe, we can relax some other checks around ip_fragment. This needs
more research.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_output.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8fbac7d..27dc1b3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -810,7 +810,7 @@ static int __ip_append_data(struct sock *sk,
 	int copy;
 	int err;
 	int offset = 0;
-	unsigned int maxfraglen, fragheaderlen;
+	unsigned int maxfraglen, fragheaderlen, maxmsgsize;
 	int csummode = CHECKSUM_NONE;
 	struct rtable *rt = (struct rtable *)cork->dst;
 
@@ -823,8 +823,10 @@ static int __ip_append_data(struct sock *sk,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
+	maxmsgsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
+		     maxfraglen : 0xFFFF;
 
-	if (cork->length + length > 0xFFFF - fragheaderlen) {
+	if (cork->length + length > maxmsgsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
 			       mtu-exthdrlen);
 		return -EMSGSIZE;
@@ -1122,7 +1124,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 	int mtu;
 	int len;
 	int err;
-	unsigned int maxfraglen, fragheaderlen, fraggap;
+	unsigned int maxfraglen, fragheaderlen, fraggap, maxmsgsize;
 
 	if (inet->hdrincl)
 		return -EPERM;
@@ -1146,8 +1148,10 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
+	maxmsgsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
+		     maxfraglen : 0xFFFF;
 
-	if (cork->length + size > 0xFFFF - fragheaderlen) {
+	if (cork->length + size > maxmsgsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport, mtu);
 		return -EMSGSIZE;
 	}
-- 
1.8.3.1
