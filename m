From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] GRO: fix merging a paged skb after non-paged skbs
Date: Mon, 24 Jan 2011 18:47:52 +0100
Message-ID: <20110124184752.1d0947dd@delilah>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882Ab1AXRsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 12:48:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose that several linear skbs of the same flow were received by GRO. They
were thus merged into one skb with a frag_list. Then a new skb of the same flow
arrives, but it is a paged skb with data starting in its frags[].

Before adding the skb to the frag_list skb_gro_receive() will of course adjust
the skb to throw away the headers. It correctly modifies the page_offset and
size of the frag, but it leaves incorrect information in the skb:
 ->data_len is not decreased at all.
 ->len is decreased only by headlen, as if no change were done to the frag.
Later in a receiving process this causes skb_copy_datagram_iovec() to return
-EFAULT and this is seen in userspace as the result of the recv() syscall.

In practice the bug can be reproduced with the sfc driver. By default the
driver uses an adaptive scheme when it switches between using
napi_gro_receive() (with skbs) and napi_gro_frags() (with pages). The bug is
reproduced when under rx load with enough successful GRO merging the driver
decides to switch from the former to the latter.

Manual control is also possible, so reproducing this is easy with netcat:
 - on machine1 (with sfc): nc -l 12345 > /dev/null
 - on machine2: nc machine1 12345 < /dev/zero
 - on machine1:
   echo 1 > /sys/module/sfc/parameters/rx_alloc_method  # use skbs
   echo 2 > /sys/module/sfc/parameters/rx_alloc_method  # use pages
 - See that nc has quit suddenly.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d31bb36..c231f5b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2746,7 +2746,7 @@ merge:
 	if (offset > headlen) {
 		skbinfo->frags[0].page_offset += offset - headlen;
 		skbinfo->frags[0].size -= offset - headlen;
-		offset = headlen;
+		skb->data_len -= offset - headlen;
 	}
 
 	__skb_pull(skb, offset);
-- 
1.7.1

