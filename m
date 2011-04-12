From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 32872] New: LLC PDU is dropped if skb is not
 linear
Date: Mon, 11 Apr 2011 18:56:50 -0700 (PDT)
Message-ID: <20110411.185650.193706505.davem@davemloft.net>
References: <bug-32872-10286@https.bugzilla.kernel.org/>
	<20110411164812.8f84f995.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vitalyb@telenet.dn.ua, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753756Ab1DLB53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 21:57:29 -0400
In-Reply-To: <20110411164812.8f84f995.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 11 Apr 2011 16:48:12 -0700

> --- linux-2.6.32.36/net/llc/llc_input.c.orig	2009-12-03 05:51:21.000000000 +0200
> +++ linux-2.6.32.36/net/llc/llc_input.c	2011-04-08 08:57:29.000000000 +0300
> @@ -105,6 +105,11 @@
>  	if (unlikely(!pskb_may_pull(skb, sizeof(*pdu))))
>  		return 0;
>  
> +	if (skb->data_len != 0){
> +	    if (unlikely(skb_linearize(skb)))
> +		return 0;
> +	}
> +
>  	pdu = (struct llc_pdu_un *)skb->data;
>  	if ((pdu->ctrl_1 & LLC_PDU_TYPE_MASK) == LLC_PDU_TYPE_U)
>  		llc_len = 1;
> 
> 
> 2.6.32 is a pretty old kernel - we'll need to verify if current kernels
> have the same problem.
> 
> Please don't send patches via bugzilla - it causes lots of problems
> with our usual patch management and review processes.  It's preferred
> that patches be sent via email as per Documentation/SubmittingPatches,
> and that they include a Signed-off-by:, as described in that file.

The skb_tail_pointer() check in llc_fixup_skb() is beyond wonky and
honestly the source of the problems here.

I'd suggest instead:

diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index 058f1e9..9032421 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -121,8 +121,7 @@ static inline int llc_fixup_skb(struct sk_buff *skb)
 		s32 data_size = ntohs(pdulen) - llc_len;
 
 		if (data_size < 0 ||
-		    ((skb_tail_pointer(skb) -
-		      (u8 *)pdu) - llc_len) < data_size)
+		    !pskb_may_pull(skb, data_size))
 			return 0;
 		if (unlikely(pskb_trim_rcsum(skb, data_size)))
 			return 0;
