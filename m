From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: udp: break from the lookup when hitting the maximum score value
Date: Fri, 23 Oct 2009 19:36:15 +0300
Message-ID: <200910231936.16022.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Aud4K8HTayLserr"
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:5727 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752672AbZJWQgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:36:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_Aud4K8HTayLserr
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit

Before udp hashes were converted to rcu in
	udp: introduce struct udp_table and multiple spinlocks
	645ca708f936b2fbeb79e52d7823e3eb2c0905f8
we stopped searching in list upon hitting the maximum score value (which is 
9).

This got removed in the conversion to rcu.
I'm not sure whether this was intentional or it just slipped by.

As far as I understand it this does not interfere with the lockless rcu: there 
is another score check the result will have to pass and if it doesn't have a 
score of 9 (which will be the value of badness) we'll just restart the lookup.

Even if the node was deleted from the chain and reclaimed at a later time, if 
at the second score test we have value 9 again, we can still return with this 
result.

Am I missing something?

-- 
Lucian

--Boundary-00=_Aud4K8HTayLserr
Content-Type: text/plain;
  charset="utf-8";
  name="score-9.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="score-9.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d0d436d..69464b9 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -294,6 +294,11 @@ begin:
 	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
 		score = compute_score(sk, net, saddr, hnum, sport,
 				      daddr, dport, dif);
+		if (score == 9) {
+			result = sk;
+			badness = score;
+			goto skip_end_of_nulls_check;
+		}
 		if (score > badness) {
 			result = sk;
 			badness = score;
@@ -307,6 +312,7 @@ begin:
 	if (get_nulls_value(node) != hash)
 		goto begin;
 
+skip_end_of_nulls_check:
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;

--Boundary-00=_Aud4K8HTayLserr--
