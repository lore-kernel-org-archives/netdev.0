From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] pktgen: fix packet generation
Date: Mon, 11 May 2015 15:19:48 -0700
Message-ID: <1431382788-6051-1-git-send-email-ast@plumgrid.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36780 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbEKWT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:19:57 -0400
Received: by pdea3 with SMTP id a3so158342956pde.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:19:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_gen->last_ok was not set properly, so after the first burst
pktgen instead of allocating new packet, will reuse old one, advance
eth_type_trans further, which would mean the stack will be seeing very
short bogus packets.

Fixes: 62f64aed622b ("pktgen: introduce xmit_mode '<start_xmit|netif_receive>'")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
This bug slipped through due to all code refactoring and can be seen
after clean reboot. If taps, rps or tx mode was used at least once,
the bug will be hidden.

Note to users: if you don't see ip_rcv() in your perf profile, it means
you were hitting this.
As commit log of 62f64aed622b is saying, the baseline perf profile
should look like:
   37.69%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
   25.81%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
    7.22%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
    5.68%  kpktgend_0   [pktgen]          [k] pktgen_thread_worker

Jesper, that explains why you were seeing hot:
atomic_long_inc(&skb->dev->rx_dropped);

Only my V1 version was correct in this regard. V2 and above had this
latent bug. Sorry about that.

 net/core/pktgen.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8f2687da058e..62f979984a23 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1189,6 +1189,16 @@ static ssize_t pktgen_if_write(struct file *file,
 				return -ENOTSUPP;
 
 			pkt_dev->xmit_mode = M_NETIF_RECEIVE;
+
+			/* make sure new packet is allocated every time
+			 * pktgen_xmit() is called
+			 */
+			pkt_dev->last_ok = 1;
+
+			/* override clone_skb if user passed default value
+			 * at module loading time
+			 */
+			pkt_dev->clone_skb = 0;
 		} else {
 			sprintf(pg_result,
 				"xmit_mode -:%s:- unknown\nAvailable modes: %s",
@@ -3415,7 +3425,6 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 				/* get out of the loop and wait
 				 * until skb is consumed
 				 */
-				pkt_dev->last_ok = 1;
 				break;
 			}
 			/* skb was 'freed' by stack, so clean few
-- 
1.7.9.5
