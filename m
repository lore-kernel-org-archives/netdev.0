From: Joonwoo Park <joonwpark81@gmail.com>
Subject: Re: [PATCH] llc: dont trust payload size on test cmd
Date: Tue, 26 Feb 2008 16:01:56 +0900
Message-ID: <20080226070156.GB24954@ehus.geninetworks.com>
References: <20080225161439.GZ84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net,
	David Miller <davem@davemloft.net>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Jim Westfall <jwestfall@surrealistic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:25589 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbYBZHB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 02:01:57 -0500
Received: by wr-out-0506.google.com with SMTP id c48so3042265wra.23
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 23:01:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080225161439.GZ84358@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 08:14:39AM -0800, Jim Westfall wrote:
> Hi
> 
> In testing its not safe to trust the payload length we are given in a
> received llc test command header.  Instead we should calculate this 
> ourselves or run the risk of an skb_over_panic() if the received length in 
> the header is > then the actual payload size.

Shouldn't it be discarded?

> 
> Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>
> 
> diff -urp linux-2.6.24.2.org/include/net/llc_pdu.h linux-2.6.24.2/include/net/llc_pdu.h
> --- linux-2.6.24.2.org/include/net/llc_pdu.h	2008-02-10 21:51:11.000000000 -0800
> +++ linux-2.6.24.2/include/net/llc_pdu.h	2008-02-24 10:23:02.000000000 -0800
> @@ -348,7 +348,7 @@ static inline void llc_pdu_init_as_test_
>  		struct llc_pdu_un *ev_pdu = llc_pdu_un_hdr(ev_skb);
>  		int dsize;
>  
> -		dsize = ntohs(eth_hdr(ev_skb)->h_proto) - 3;
> +		dsize = (ev_skb->tail - (u8 *)ev_pdu) - 3;

In addition, dsize can be a minus. (with & without your patch)

>  		memcpy(((u8 *)pdu) + 3, ((u8 *)ev_pdu) + 3, dsize);
>  		skb_put(skb, dsize);
>  	}
> 
> ----- End forwarded message -----


[PATCH] LLC: discard malfromed llc packet

Discard llc packet which has invalid data size.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/llc/llc_input.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index c40c9b2..6ef80fe 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -117,9 +117,12 @@ static inline int llc_fixup_skb(struct sk_buff *skb)
 	skb_pull(skb, llc_len);
 	if (skb->protocol == htons(ETH_P_802_2)) {
 		__be16 pdulen = eth_hdr(skb)->h_proto;
-		u16 data_size = ntohs(pdulen) - llc_len;
+		s32 data_size = ntohs(pdulen) - llc_len;
 
-		if (unlikely(pskb_trim_rcsum(skb, data_size)))
+		if (data_size < 0
+		    || ((skb->tail - (u8 *)pdu) - llc_len) < data_size)
+			return 0;
+		if (unlikely(pskb_trim_rcsum(skb, (unsigned int)data_size)))
 			return 0;
 	}
 	return 1;
-- 
1.5.4

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
