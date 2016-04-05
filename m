From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH V2 1/2] net: socket: return EADDRNOTAVAIL when source address becomes nonlocal
Date: Tue,  5 Apr 2016 22:19:45 +0800
Message-ID: <1459865986-18271-2-git-send-email-zlpnobody@163.com>
References: <1459865986-18271-1-git-send-email-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <liping.zhang@spreadtrum.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:55540 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758342AbcDEOUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 10:20:34 -0400
In-Reply-To: <1459865986-18271-1-git-send-email-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

A socket can use bind(directly) or connect(indirectly) to bind to a local
ip address, and later if the network becomes down, that cause the source
address becomes nonlocal, then send() call will fail and return EINVAL.
But this error code is confusing, acctually we did not pass any invalid
arguments. Furthermore, send() maybe return ok at first, it now returns
fail just because of a temporary network problem, i.e. when the network
recovery, send() call will become ok. Return EADDRNOTAVAIL instead of
EINVAL in such situation is better.

Take the ping utility for example, we can use -I option to specify the
source address (e.g ping -I 10.19.145.26 117.135.169.41), when network
becomes down, error message will be printed out as follows:
    64 bytes from  (117.135.169.41): icmp_seq=9 ttl=54 time=46.7 ms
    ping: sendmsg: Invalid argument
    ping: sendmsg: Invalid argument

Apply this patch, error message will become:
    64 bytes from  (117.135.169.41): icmp_seq=5 ttl=54 time=47.5 ms
    ping: sendmsg: Cannot assign requested address
    ping: sendmsg: Cannot assign requested address

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
---
 net/ipv4/route.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c6229..857f7b3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2149,11 +2149,13 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 
 	rcu_read_lock();
 	if (fl4->saddr) {
-		rth = ERR_PTR(-EINVAL);
+		rth = ERR_PTR(-EADDRNOTAVAIL);
 		if (ipv4_is_multicast(fl4->saddr) ||
 		    ipv4_is_lbcast(fl4->saddr) ||
-		    ipv4_is_zeronet(fl4->saddr))
+		    ipv4_is_zeronet(fl4->saddr)) {
+			rth = ERR_PTR(-EINVAL);
 			goto out;
+		}
 
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
-- 
1.7.9.5
