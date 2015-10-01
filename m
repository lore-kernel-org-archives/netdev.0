From: David Miller <davem@davemloft.net>
Subject: Re: skbuff: Fix checksum start check in skb_postpull_rcsum
Date: Thu, 01 Oct 2015 08:15:43 -0700 (PDT)
Message-ID: <20151001.081543.1685933972558161717.davem@davemloft.net>
References: <1443698177.3401.1.camel@gmail.com>
	<20151001112134.GA26657@gondor.apana.org.au>
	<20151001113407.GA26772@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: umgwanakikbuti@gmail.com, netdev@vger.kernel.org,
	pshelar@nicira.com, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151001113407.GA26772@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 1 Oct 2015 19:34:07 +0800

> In skb_postpull_rcsum the skb has already been pulled so we should
> be testing whether the checksum start offset is non-negative rather
> than how it compares to the length that we have pulled.
> 
> Fixes: 6ae459bdaaee ("skbuff: Fix skb checksum flag on skb pull")
> Reported-by: Mike Galbraith <umgwanakikbuti@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2b0a30a..4398411 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2708,7 +2708,7 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
>  	if (skb->ip_summed == CHECKSUM_COMPLETE)
>  		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
>  	else if (skb->ip_summed == CHECKSUM_PARTIAL &&
> -		 skb_checksum_start_offset(skb) <= len)
> +		 skb_checksum_start_offset(skb) < 0)
>  		skb->ip_summed = CHECKSUM_NONE;
>  }
>  

A patch with this and more should be in the 'net' tree already.

====================
commit 31b33dfb0a144469dd805514c9e63f4993729a48
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Mon Sep 28 17:24:25 2015 -0700

    skbuff: Fix skb checksum partial check.
    
    Earlier patch 6ae459bda tried to detect void ckecksum partial
    skb by comparing pull length to checksum offset. But it does
    not work for all cases since checksum-offset depends on
    updates to skb->data.
    
    Following patch fixes it by validating checksum start offset
    after skb-data pointer is updated. Negative value of checksum
    offset start means there is no need to checksum.
    
    Fixes: 6ae459bda ("skbuff: Fix skb checksum flag on skb pull")
    Reported-by: Andrew Vagin <avagin@odin.com>
    Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2b0a30a..4398411 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2708,7 +2708,7 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 	else if (skb->ip_summed == CHECKSUM_PARTIAL &&
-		 skb_checksum_start_offset(skb) <= len)
+		 skb_checksum_start_offset(skb) < 0)
 		skb->ip_summed = CHECKSUM_NONE;
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index dad4dd3..fab4599 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2958,11 +2958,12 @@ EXPORT_SYMBOL_GPL(skb_append_pagefrags);
  */
 unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
 {
+	unsigned char *data = skb->data;
+
 	BUG_ON(len > skb->len);
-	skb->len -= len;
-	BUG_ON(skb->len < skb->data_len);
-	skb_postpull_rcsum(skb, skb->data, len);
-	return skb->data += len;
+	__skb_pull(skb, len);
+	skb_postpull_rcsum(skb, data, len);
+	return skb->data;
 }
 EXPORT_SYMBOL_GPL(skb_pull_rcsum);
 
