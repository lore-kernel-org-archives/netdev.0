From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv4: consistent reporting of pmtu data in case of corking
Date: Thu, 19 Dec 2013 02:13:36 +0100
Message-ID: <20131219011336.GB14429@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38035 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab3LSBNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 20:13:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We report different pmtu values back on the first write and on further
writes on an corked socket.

Also don't include the dst.header_len (respectively exthdrlen) as this
should already be dealt with by the interface mtu of the outgoing
(virtual) interface and policy of that interface should dictate if
fragmentation should happen.

Instead reduce the pmtu data by IP options as we do for IPv6. Make the
same changes for ip_append_data, where we did not care about options or
dst.header_len at all.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_output.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 9124027..df18461 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -828,7 +828,7 @@ static int __ip_append_data(struct sock *sk,
 
 	if (cork->length + length > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
-			       mtu-exthdrlen);
+			       mtu - (opt ? opt->optlen : 0));
 		return -EMSGSIZE;
 	}
 
@@ -1151,7 +1151,8 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 			 mtu : 0xFFFF;
 
 	if (cork->length + size > maxnonfragsize - fragheaderlen) {
-		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport, mtu);
+		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
+			       mtu - (opt ? opt->optlen : 0));
 		return -EMSGSIZE;
 	}
 
-- 
1.8.3.1
