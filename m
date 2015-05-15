From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 16:35:06 +0200
Message-ID: <20150515143506.GA5019@via.ecp.fr>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
 <1431401204-731380-6-git-send-email-tom@herbertland.com>
 <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
 <1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from artikodin.via.ecp.fr ([138.195.130.75]:56424 "EHLO
	artikodin.via.ecp.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbbEOOfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 10:35:12 -0400
Content-Disposition: inline
In-Reply-To: <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

2015-05-15, 05:48:07 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> First one in __skb_checksum_validate_complete() fixes the following
> (and other callers)
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/tcp_ipv4.o
>   CHECK   net/ipv4/tcp_ipv4.c
> include/linux/skbuff.h:3052:24: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3052:24:    expected restricted __sum16
> include/linux/skbuff.h:3052:24:    got int
> 
> Second is fixing gso_make_checksum() :
> 
>   CHECK   net/ipv4/gre_offload.c
> include/linux/skbuff.h:3360:14: warning: incorrect type in assignment (different base types)
> include/linux/skbuff.h:3360:14:    expected unsigned short [unsigned] [usertype] csum
> include/linux/skbuff.h:3360:14:    got restricted __sum16
> include/linux/skbuff.h:3365:16: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3365:16:    expected restricted __sum16
> include/linux/skbuff.h:3365:16:    got unsigned short [unsigned] [usertype] csum
> 
> 
> Fixes: 5a21232983aa7 ("net: Support for csum_bad in skbuff")
> Fixes: 7e2b10c1e52ca ("net: Support for multiple checksums with gso")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> CC: Tom Herbert <tom@herbertland.com>
> ---

That's very similar to what I submitted in February:
https://patchwork.ozlabs.org/patch/437332/

I have a patch to make __skb_checksum_validate_complete return a bool,
since that's all the callers care about (it also needs modifications
at some call sites, not included here).

After that, maybe we should also reverse the logic so that "validate"
functions return true when the csum is valid.



diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f83aa6568cbf..23dc1ccb28f0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3034,24 +3034,23 @@ static inline void skb_checksum_complete_unset(struct sk_buff *skb)
 /* Validate (init) checksum based on checksum complete.
  *
  * Return values:
- *   0: checksum is validated or try to in skb_checksum_complete. In the latter
- *	case the ip_summed will not be CHECKSUM_UNNECESSARY and the pseudo
- *	checksum is stored in skb->csum for use in __skb_checksum_complete
- *   non-zero: value of invalid checksum
- *
+ *   false: checksum is validated or try to in skb_checksum_complete. In the
+ *     latter case the ip_summed will not be CHECKSUM_UNNECESSARY and the
+ *     pseudo checksum is stored in skb->csum for use in __skb_checksum_complete
+ *   true: invalid checksum
  */
-static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
-						       bool complete,
-						       __wsum psum)
+static inline bool __skb_checksum_validate_complete(struct sk_buff *skb,
+						    bool complete,
+						    __wsum psum)
 {
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!csum_fold(csum_add(psum, skb->csum))) {
 			skb->csum_valid = 1;
-			return 0;
+			return false;
 		}
 	} else if (skb->csum_bad) {
 		/* ip_summed == CHECKSUM_NONE in this case */
-		return 1;
+		return true;
 	}
 
 	skb->csum = psum;
@@ -3061,10 +3060,10 @@ static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
 
 		csum = __skb_checksum_complete(skb);
 		skb->csum_valid = !csum;
-		return csum;
+		return !!csum;
 	}
 
-	return 0;
+	return false;
 }
 
 static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
@@ -3079,13 +3078,13 @@ static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
  * pseudo header.
  *
  * Return values:
- *   0: checksum is validated or try to in skb_checksum_complete
- *   non-zero: value of invalid checksum
+ *   false: checksum is validated or try to in skb_checksum_complete
+ *   true: invalid checksum
  */
 #define __skb_checksum_validate(skb, proto, complete,			\
 				zero_okay, check, compute_pseudo)	\
 ({									\
-	__sum16 __ret = 0;						\
+	bool __ret = false;						\
 	skb->csum_valid = 0;						\
 	if (__skb_checksum_validate_needed(skb, zero_okay, check))	\
 		__ret = __skb_checksum_validate_complete(skb,		\




-- 
Sabrina
