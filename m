From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] net/esp4: Fix invalid esph pointer crash
Date: Wed, 3 May 2017 09:02:28 +0200
Message-ID: <20170503070228.GK2649@secunet.com>
References: <20170430133438.31962-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50294 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751014AbdECHCc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 03:02:32 -0400
Content-Disposition: inline
In-Reply-To: <20170430133438.31962-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 30, 2017 at 04:34:38PM +0300, ilant@mellanox.com wrote:
> From: Ilan Tayari <ilant@mellanox.com>
> 
> Both esp_output and esp_xmit take a pointer to the ESP header
> and place it in esp_info struct prior to calling esp_output_head.
> 
> Inside esp_output_head, the call to esp_output_udp_encap
> makes sure to update the pointer if it gets invalid.
> However, if esp_output_head itself calls skb_cow_data, the
> pointer is not updated and stays invalid, causing a crash
> after esp_output_head returns.
> 
> Update the pointer if it becomes invalid in esp_output_head
> 
> Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>
> ---
>  net/ipv4/esp4.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
> index 7f2caf71212b..65cc02bd82bc 100644
> --- a/net/ipv4/esp4.c
> +++ b/net/ipv4/esp4.c
> @@ -317,6 +317,7 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
>  	if (nfrags < 0)
>  		goto out;
>  	tail = skb_tail_pointer(trailer);
> +	esp->esph = ip_esp_hdr(skb);

This is not quite right for udpencap. It fixes the crash,
but introduces a bug that we already have in v4.11.

On udpencap the esp header has an offset to skb_transport_header,
the problem was discussed last week here:

https://lkml.org/lkml/2017/4/25/937

I plan to fix this with the patch below:

Subject: [PATCH RFC] esp4: Fix udpencap for local TCP packets.

Locally generated TCP packets are usually cloned, so we
do skb_cow_data() on this packets. After that we need to
reload the pointer to the esp header. On udpencap this
header has an offset to skb_transport_header, so take this
offset into account.

Fixes: 67d349ed603 ("net/esp4: Fix invalid esph pointer crash")
Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Reported-by: Don Bowman <db@donbowman.ca>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 65cc02b..93322f8 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -248,6 +248,7 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	u8 *tail;
 	u8 *vaddr;
 	int nfrags;
+	int esph_offset;
 	struct page *page;
 	struct sk_buff *trailer;
 	int tailen = esp->tailen;
@@ -313,11 +314,13 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	}
 
 cow:
+	esph_offset = (unsigned char *)esp->esph - skb_transport_header(skb);
+
 	nfrags = skb_cow_data(skb, tailen, &trailer);
 	if (nfrags < 0)
 		goto out;
 	tail = skb_tail_pointer(trailer);
-	esp->esph = ip_esp_hdr(skb);
+	esp->esph = (struct ip_esp_hdr *)(skb_transport_header(skb) + esph_offset);
 
 skip_cow:
 	esp_output_fill_trailer(tail, esp->tfclen, esp->plen, esp->proto);
-- 
2.7.4
