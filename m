From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to page frag allocators
Date: Tue, 29 Oct 2013 12:21:56 +1030
Message-ID: <87ppqoetdv.fsf@rustcorp.com.au>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52116 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756651Ab3J2B5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 21:57:12 -0400
In-Reply-To: <1383000258-1458-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Dalton <mwdalton@google.com> writes:
> The virtio_net driver's mergeable receive buffer allocator
> uses 4KB packet buffers. For MTU-sized traffic, SKB truesize
> is > 4KB but only ~1500 bytes of the buffer is used to store
> packet data, reducing the effective TCP window size
> substantially. This patch addresses the performance concerns
> with mergeable receive buffers by allocating MTU-sized packet
> buffers using page frag allocators. If more than MAX_SKB_FRAGS
> buffers are needed, the SKB frag_list is used.
>
> Signed-off-by: Michael Dalton <mwdalton@google.com>

Hi Michael,

        Nice work!  Just one comment.  Your patch highlights the
anachronistic name MAX_PACKET_LEN: it was from the original
implementation which only supported 1500 byte packets, and only used in
one place.

Please apply a first patch like this, then come up with a new constant
name (GOOD_PACKET_LEN?) for that value.  Because it's not the maximum
packet we can receive for mergable buffers.

Thanks,
Rusty.

Subject: virtio_net: remove anachronistic MAX_PACKET_LEN constant.
From: Rusty Russell <rusty@rustcorp.com.au>

The initial implementation of virtio_net only allowed ethernet-style
MTU packets; with more recent features this isn't true.  Move the
constant into the function where it's used.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 057ea13..dcbfccd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -35,8 +35,6 @@ static bool csum = true, gso = true;
 module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
 
-/* FIXME: MTU in config. */
-#define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
 
 #define VIRTNET_DRIVER_VERSION "1.0.0"
@@ -434,12 +432,13 @@ static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	int err;
+	const int len = ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN;
 
-	skb = __netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN, gfp);
+	skb = __netdev_alloc_skb_ip_align(vi->dev, len, gfp);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	skb_put(skb, MAX_PACKET_LEN);
+	skb_put(skb, len);
 
 	hdr = skb_vnet_hdr(skb);
 	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
