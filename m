From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] tcp: Remove some spurious dropped packet profile hits from the passive connection accept path
Date: Thu, 20 Nov 2014 10:58:29 -0800 (PST)
Message-ID: <20141120185829.986CB290095D@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:19486 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755125AbaKTS6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 13:58:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

When a system is the passive accepter of many connections, for example
when the target of a netperf TCP_CC or TCP_CRR test, or as say a web
server, the discard of the skb containing the TCP SYN being processed
for the LISTEN endpoint should be a consume_skb() rather than a kfree_skb()
to avoid cluttering a dropped packet profile.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

perf top -a -g -e skb:kfree_sk output from a system which is the target
of a netperf TCP_CC test

before:

-  100.00%   100.00%  [kernel]  [k] kfree_skb
   - kfree_skb
      + 68.68% sk_stream_kill_queues
      + 31.32% tcp_rcv_state_process           

after:

-  100.00%   100.00%  [kernel]            [k] kfree_skb
   - kfree_skb
        99.89% sk_stream_kill_queues


Presumably, the consume_skb() versus kfree_skb() could be made conditional
on there actually being data in the TCP SYN segment, but the odds of there
actually being data seemed low enough to not warrant it.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d91436b..999b0a4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5624,8 +5624,12 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			 * against this problem. So, we drop the data
 			 * in the interest of security over speed unless
 			 * it's still in use.
+			 *
+			 * 99 times out of 10, there won't actually be any
+			 * data and so we aren't really dropping anything.
+			 * So, we consume_skb() rather than kfree_skb().
 			 */
-			kfree_skb(skb);
+			consume_skb(skb);
 			return 0;
 		}
 		goto discard;
