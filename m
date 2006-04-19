From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 6409] New: llc_rcv doesn't handle receives
 using nr_frags and frags[]
Date: Wed, 19 Apr 2006 15:37:49 -0700 (PDT)
Message-ID: <20060419.153749.92750588.davem@davemloft.net>
References: <20060419113806.29ba0d23.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@conectiva.com.br,
	jesse.brandeburg@intel.com, bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45731
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751302AbWDSWht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:37:49 -0400
To: akpm@osdl.org
In-Reply-To: <20060419113806.29ba0d23.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Wed, 19 Apr 2006 11:38:06 -0700

> Analysis:
> llc_rcv 
>   does a skb_clone inside skb_share_check
> llc_fixup_skb
> skb_trim
> __skb_trim
> ___pskb_trim(x,x,0) <-- realloc set to 0
> ___pskb_trim BUG on !realloc inside skb_cloned check

I'll fix it like this:

diff-tree 5185db09f46ed64d520d09db6e93852e44106628 (from 3672558c6180ca28a7aa46765702467a37e58fc5)
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Apr 19 15:37:13 2006 -0700

    [LLC]: Use pskb_trim_rcsum() in llc_fixup_skb().
    
    Kernel Bugzilla #6409
    
    If we use plain skb_trim(), that's wrong, because if
    the SKB is cloned, and it can be because we unshared
    it in the caller, we have to allow reallocation.  The
    pskb_trim*() family of routines is therefore the most
    appropriate here.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index 8f3addf..d62e0f9 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -118,7 +118,8 @@ static inline int llc_fixup_skb(struct s
 		u16 pdulen = eth_hdr(skb)->h_proto,
 		    data_size = ntohs(pdulen) - llc_len;
 
-		skb_trim(skb, data_size);
+		if (unlikely(pskb_trim_rcsum(skb, data_size)))
+			return 0;
 	}
 	return 1;
 }
