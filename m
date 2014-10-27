From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_segment() should preserve backpressure
Date: Mon, 27 Oct 2014 10:30:51 -0700
Message-ID: <1414431051.16231.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414405781.4492.38.camel@ubuntu-vm-makita>
	 <1414422089.16231.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414424388.16231.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36347 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbaJ0RbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 13:31:04 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so2319084pad.17
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 10:31:03 -0700 (PDT)
In-Reply-To: <1414424388.16231.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

This patch generalizes commit d6a4a1041176 ("tcp: GSO should be TSQ
friendly") to protocols using skb_set_owner_w()

TCP uses its own destructor (tcp_wfree) and needs a more complex scheme
as explained in commit 6ff50cd55545 ("tcp: gso: do not generate out of
order packets")

This allows UDP sockets using UFO to get proper backpressure,
thus avoiding qdisc drops and excessive cpu usage.

Here are performance test results (macvlan on vlan):

- Before
# netperf -t UDP_STREAM ...
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   60.00      144096 1224195    1258.56
212992           60.00          51              0.45

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.23      0.00     25.26      0.08      0.00     74.43

- After
# netperf -t UDP_STREAM ...
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   60.00      109593      0     957.20
212992           60.00      109593            957.20

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.18      0.00      8.38      0.02      0.00     91.43

[edumazet] Rewrote patch and changelog.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c16615bfb61edd2a1dae9ef7935a3153d78dc4df..e48e5c02e877d9a9389ea54f0e015ba041d3f2a7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3099,6 +3099,16 @@ perform_csum_check:
 	 * (see validate_xmit_skb_list() for example)
 	 */
 	segs->prev = tail;
+
+	/* Following permits correct backpressure, for protocols
+	 * using skb_set_owner_w().
+	 * Idea is to tranfert ownership from head_skb to last segment.
+	 */
+	if (head_skb->destructor == sock_wfree) {
+		swap(tail->truesize, head_skb->truesize);
+		swap(tail->destructor, head_skb->destructor);
+		swap(tail->sk, head_skb->sk);
+	}
 	return segs;
 
 err:
