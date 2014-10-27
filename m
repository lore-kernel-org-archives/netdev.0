From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Poor UDP throughput with virtual devices and UFO
Date: Mon, 27 Oct 2014 19:29:41 +0900
Message-ID: <1414405781.4492.38.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:47145 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaJ0KaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 06:30:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I recently noticed sending UDP packets ends up with very poor throughput when
using UFO and virtual devices.

Example configurations are:
- macvlan on vlan
- gre on bridge

With these configurations, the upper virtual devices (macvlan, gre) has the
UFO feature and the lower devices (vlan, bridge) don't have it. UFO packets
will be sent from the upper devices and fragmented on the lower devices.
So, they will be fragmented before entering qdisc.

Since skb_segment() doesn't increase sk_wmem_alloc, the send buffer of a UDP
socket looks almost always empty, and user space can send packets with no limit,
which causes massive drops on qdisc.

I wrote a patch to increase sk_wmem_alloc in skb_segment(), but I'm wondering
if we can do this change since it has been this way for years and only TCP
handles it so far (d6a4a1041176 "tcp: GSO should be TSQ friendly").

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
Average:          0      0.29      0.00      0.76      0.29      0.00     98.66
Average:          1      0.21      0.00      0.33      0.00      0.00     99.45
Average:          2      0.05      0.00      0.12      0.07      0.00     99.76
Average:          3      0.36      0.00     99.64      0.00      0.00      0.00

- After
# netperf -t UDP_STREAM ...
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   60.00      109593      0     957.20
212992           60.00      109593            957.20

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.18      0.00      8.38      0.02      0.00     91.43
Average:          0      0.17      0.00      3.60      0.00      0.00     96.23
Average:          1      0.13      0.00      6.60      0.00      0.00     93.27
Average:          2      0.23      0.00      5.76      0.07      0.00     93.94
Average:          3      0.17      0.00     17.57      0.00      0.00     82.26


The patch (based on net tree) for the test above:

----
Subject: [PATCH net] gso: Inherit sk_wmem_alloc

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/core/skbuff.c      |  6 +++++-
 net/ipv4/tcp_offload.c | 13 ++++---------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c16615b..29dc763 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3020,7 +3020,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 							    len, 0);
 			SKB_GSO_CB(nskb)->csum_start =
 			    skb_headroom(nskb) + doffset;
-			continue;
+			goto set_owner;
 		}
 
 		nskb_frag = skb_shinfo(nskb)->frags;
@@ -3092,6 +3092,10 @@ perform_csum_check:
 			SKB_GSO_CB(nskb)->csum_start =
 			    skb_headroom(nskb) + doffset;
 		}
+
+set_owner:
+		if (head_skb->sk)
+			skb_set_owner_w(nskb, head_skb->sk);
 	} while ((offset += len) < head_skb->len);
 
 	/* Some callers want to get the end of the list.
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 5b90f2f..93758a8 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -139,11 +139,8 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			th->check = gso_make_checksum(skb, ~th->check);
 
 		seq += mss;
-		if (copy_destructor) {
+		if (copy_destructor)
 			skb->destructor = gso_skb->destructor;
-			skb->sk = gso_skb->sk;
-			sum_truesize += skb->truesize;
-		}
 		skb = skb->next;
 		th = tcp_hdr(skb);
 
@@ -157,11 +154,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	 * is freed by GSO engine
 	 */
 	if (copy_destructor) {
-		swap(gso_skb->sk, skb->sk);
-		swap(gso_skb->destructor, skb->destructor);
-		sum_truesize += skb->truesize;
-		atomic_add(sum_truesize - gso_skb->truesize,
-			   &skb->sk->sk_wmem_alloc);
+		skb->destructor = gso_skb->destructor;
+		gso_skb->destructor = NULL;
+		atomic_sub(gso_skb->truesize, &skb->sk->sk_wmem_alloc);
 	}
 
 	delta = htonl(oldlen + (skb_tail_pointer(skb) -
-- 
1.8.1.2
