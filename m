From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
Subject: [PATCH] tcp: fix wrong checksum calculation on MTU probing
Date: Mon, 19 Sep 2016 18:16:28 -0300
Message-ID: <15e3bab9-f21e-9a55-a87e-e389f633f755@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp799.redehostenvio.com.br ([187.84.239.13]:41394 "EHLO
        smtp799.redehostenvio.com.br" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753126AbcISV1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:27:40 -0400
Received: by smtp788.redehostenvio.com.br id hs1cda27hush for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 18:18:55 -0300 (envelope-from <douglascs@taghos.com.br>)
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
  net/ipv4/tcp_output.c | 10 ++++++----
  1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f53d0cc..767135e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1968,10 +1968,12 @@ static int tcp_mtu_probe(struct sock *sk)
          copy = min_t(int, skb->len, probe_size - len);
          if (nskb->ip_summed)
              skb_copy_bits(skb, 0, skb_put(nskb, copy), copy);
-        else
-            nskb->csum = skb_copy_and_csum_bits(skb, 0,
-                                skb_put(nskb, copy),
-                                copy, nskb->csum);
+        else {
+            __wsum csum = skb_copy_and_csum_bits(skb, 0,
+                                 skb_put(nskb, copy),
+                                 copy, 0);
+            nskb->csum = csum_block_add(nskb->csum, csum, len);
+        }

          if (skb->len <= copy) {
              /* We've eaten all the data from this skb.
-- 
2.5.0
