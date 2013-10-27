From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2] ipv4: fix DO and PROBE pmtu mode regarding local fragmentation with UFO/CORK
Date: Sun, 27 Oct 2013 17:29:11 +0100
Message-ID: <20131027162911.GA4714@order.stressinduktion.org>
References: <20131025194003.GG15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60282 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab3J0Q3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 12:29:12 -0400
Content-Disposition: inline
In-Reply-To: <20131025194003.GG15744@order.stressinduktion.org>
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

We use (mtu-fragheaderlen) to check for the maximum length because we
ensure not to generate a fragment and non-fragmented data does not need
to have its length aligned on 64 bit boundaries. Also the passed in
ip_options are already aligned correctly.

Maybe, we can relax some other checks around ip_fragment. This needs
more research.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2:
 Switch from maxfraglen to mtu for length check as outlined in the commit
 message.

 net/ipv4/ip_output.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8fbac7d..51be64e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -810,7 +810,7 @@ static int __ip_append_data(struct sock *sk,
 	int copy;
 	int err;
 	int offset = 0;
-	unsigned int maxfraglen, fragheaderlen;
+	unsigned int maxfraglen, fragheaderlen, maxnonfragsize;
 	int csummode = CHECKSUM_NONE;
 	struct rtable *rt = (struct rtable *)cork->dst;
 
@@ -823,8 +823,10 @@ static int __ip_append_data(struct sock *sk,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
+	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
+			 mtu : 0xFFFF;
 
-	if (cork->length + length > 0xFFFF - fragheaderlen) {
+	if (cork->length + length > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
 			       mtu-exthdrlen);
 		return -EMSGSIZE;
@@ -1122,7 +1124,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 	int mtu;
 	int len;
 	int err;
-	unsigned int maxfraglen, fragheaderlen, fraggap;
+	unsigned int maxfraglen, fragheaderlen, fraggap, maxnonfragsize;
 
 	if (inet->hdrincl)
 		return -EPERM;
@@ -1146,8 +1148,10 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
+	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
+			 mtu : 0xFFFF;
 
-	if (cork->length + size > 0xFFFF - fragheaderlen) {
+	if (cork->length + size > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport, mtu);
 		return -EMSGSIZE;
 	}
-- 
1.8.3.1
