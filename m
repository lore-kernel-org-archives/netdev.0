From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
Subject: [PATCH v3] tcp: fix wrong checksum calculation on MTU probing
Date: Thu, 22 Sep 2016 15:52:04 -0300
Message-ID: <f920ce68-c4e9-7772-809c-01f7319fa78e@taghos.com.br>
References: <15e3bab9-f21e-9a55-a87e-e389f633f755@taghos.com.br>
 <20160920.225729.1715125475365382873.davem@davemloft.net>
 <2923a9bc-c433-7546-cd4a-9f834bd43181@taghos.com.br>
 <5ffc1020-a36f-75b4-ff25-4f58c243f803@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
        <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp815.redehostenvio.com.br ([187.84.239.29]:58209 "EHLO
        smtp815.redehostenvio.com.br" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S941142AbcIVSyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 14:54:00 -0400
Received: by smtp788.redehostenvio.com.br id hsgkl227hus8 for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 15:56:09 -0300 (envelope-from <douglascs@taghos.com.br>)
In-Reply-To: <5ffc1020-a36f-75b4-ff25-4f58c243f803@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With TCP MTU probing enabled and offload TX checksumming disabled,
tcp_mtu_probe() calculated the wrong checksum when a fragment being copied
into the probe's SKB had an odd length. This was caused by the direct use
of skb_copy_and_csum_bits() to calculate the checksum, as it pads the
fragment being copied, if needed. When this fragment was not the last, a
subsequent call used the previous checksum without considering this
padding.

The effect was a stale connection in one way, as even retransmissions
wouldn't solve the problem, because the checksum was never recalculated for
the full SKB length.

Signed-off-by: Douglas Caetano dos Santos <douglascs@taghos.com.br>
---
 net/ipv4/tcp_output.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f53d0cc..2d32952 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1966,12 +1966,14 @@ static int tcp_mtu_probe(struct sock *sk)
 	len = 0;
 	tcp_for_write_queue_from_safe(skb, next, sk) {
 		copy = min_t(int, skb->len, probe_size - len);
-		if (nskb->ip_summed)
+		if (nskb->ip_summed) {
 			skb_copy_bits(skb, 0, skb_put(nskb, copy), copy);
-		else
-			nskb->csum = skb_copy_and_csum_bits(skb, 0,
-							    skb_put(nskb, copy),
-							    copy, nskb->csum);
+		} else {
+			__wsum csum = skb_copy_and_csum_bits(skb, 0,
+							     skb_put(nskb, copy),
+							     copy, 0);
+			nskb->csum = csum_block_add(nskb->csum, csum, len);
+		}

 		if (skb->len <= copy) {
 			/* We've eaten all the data from this skb.
-- 
2.5.0
