From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net v2] sctp: linearize early if it's not GSO
Date: Thu, 18 Aug 2016 14:58:35 -0300
Message-ID: <c333cd2ab2c828577251c6f75a3cc5e5f3683eb8.1471542789.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54458 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754418AbcHSBSd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:18:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because otherwise when crc computation is still needed it's way more
expensive than on a linear buffer to the point that it affects
performance.

It's so expensive that netperf test gives a perf output as below:

Overhead  Command         Shared Object       Symbol
  18,62%  netserver       [kernel.vmlinux]    [k] crc32_generic_shift
   2,57%  netserver       [kernel.vmlinux]    [k] __pskb_pull_tail
   1,94%  netserver       [kernel.vmlinux]    [k] fib_table_lookup
   1,90%  netserver       [kernel.vmlinux]    [k] copy_user_enhanced_fast_string
   1,66%  swapper         [kernel.vmlinux]    [k] intel_idle
   1,63%  netserver       [kernel.vmlinux]    [k] _raw_spin_lock
   1,59%  netserver       [sctp]              [k] sctp_packet_transmit
   1,55%  netserver       [kernel.vmlinux]    [k] memcpy_erms
   1,42%  netserver       [sctp]              [k] sctp_rcv

# netperf -H 192.168.10.1 -l 10 -t SCTP_STREAM -cC -- -m 12000
SCTP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

212992 212992  12000    10.00      3016.42   2.88     3.78     1.874   2.462

After patch:
Overhead  Command         Shared Object      Symbol
   2,75%  netserver       [kernel.vmlinux]   [k] memcpy_erms
   2,63%  netserver       [kernel.vmlinux]   [k] copy_user_enhanced_fast_string
   2,39%  netserver       [kernel.vmlinux]   [k] fib_table_lookup
   2,04%  netserver       [kernel.vmlinux]   [k] __pskb_pull_tail
   1,91%  netserver       [kernel.vmlinux]   [k] _raw_spin_lock
   1,91%  netserver       [sctp]             [k] sctp_packet_transmit
   1,72%  netserver       [mlx4_en]          [k] mlx4_en_process_rx_cq
   1,68%  netserver       [sctp]             [k] sctp_rcv

# netperf -H 192.168.10.1 -l 10 -t SCTP_STREAM -cC -- -m 12000
SCTP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

212992 212992  12000    10.00      3681.77   3.83     3.46     2.045   1.849

Fixes: 3acb50c18d8d ("sctp: delay as much as possible skb_linearize")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
v1->v2:
 - Fixed changelog referencing other kernel, spotted by Daniel Borkmann.

Please consider this for stable, as v4.7 is affected. Thanks!

 net/sctp/input.c   | 11 +++++++----
 net/sctp/inqueue.c | 13 -------------
 2 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index c182db7d691ff44a52923fb36c9170e49c141c04..69444d32ecda6cd1a4924911172feba89c5ae976 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -119,7 +119,13 @@ int sctp_rcv(struct sk_buff *skb)
 		       skb_transport_offset(skb))
 		goto discard_it;
 
-	if (!pskb_may_pull(skb, sizeof(struct sctphdr)))
+	/* If the packet is fragmented and we need to do crc checking,
+	 * it's better to just linearize it otherwise crc computing
+	 * takes longer.
+	 */
+	if ((!(skb_shinfo(skb)->gso_type & SKB_GSO_SCTP) &&
+	     skb_linearize(skb)) ||
+	    !pskb_may_pull(skb, sizeof(struct sctphdr)))
 		goto discard_it;
 
 	/* Pull up the IP header. */
@@ -1177,9 +1183,6 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 	if ((skb_shinfo(skb)->gso_type & SKB_GSO_SCTP) == SKB_GSO_SCTP)
 		return NULL;
 
-	if (skb_linearize(skb))
-		return NULL;
-
 	ch = (sctp_chunkhdr_t *) skb->data;
 
 	/* The code below will attempt to walk the chunk and extract
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index c30ddb0f31907f57c5ce85b00dbe04260ca1cb2e..6437aa97cfd79f14c633499c2b131389204c435b 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -170,19 +170,6 @@ next_chunk:
 
 		chunk = list_entry(entry, struct sctp_chunk, list);
 
-		/* Linearize if it's not GSO */
-		if ((skb_shinfo(chunk->skb)->gso_type & SKB_GSO_SCTP) != SKB_GSO_SCTP &&
-		    skb_is_nonlinear(chunk->skb)) {
-			if (skb_linearize(chunk->skb)) {
-				__SCTP_INC_STATS(dev_net(chunk->skb->dev), SCTP_MIB_IN_PKT_DISCARDS);
-				sctp_chunk_free(chunk);
-				goto next_chunk;
-			}
-
-			/* Update sctp_hdr as it probably changed */
-			chunk->sctp_hdr = sctp_hdr(chunk->skb);
-		}
-
 		if ((skb_shinfo(chunk->skb)->gso_type & SKB_GSO_SCTP) == SKB_GSO_SCTP) {
 			/* GSO-marked skbs but without frags, handle
 			 * them normally
-- 
2.7.4
