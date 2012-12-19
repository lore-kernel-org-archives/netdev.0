From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH] fix IP_ECN_set_ce
Date: Wed, 19 Dec 2012 10:11:59 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1212191001530.1620@ja.ssi.bg>
References: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1274773181-1355904720=:1620"
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:40571 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884Ab2LSIKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 03:10:47 -0500
In-Reply-To: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1274773181-1355904720=:1620
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Wed, 19 Dec 2012, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. ECN uses the two least significant (right-most) bits of the DiffServ
> field in the IPv4, so it should be in iph->tos, not in (iph->tos+1)
> 
> 2. When setting CE, we should check if ECN Capable Transport supports,
> both 10 and 01 mean ECN Capable Transport, so only check 10 is not enough
>     00: Non ECN-Capable Transport — Non-ECT
>     10: ECN Capable Transport — ECT(0)
>     01: ECN Capable Transport — ECT(1)
>     11: Congestion Encountered — CE
> 
> 3. Remove the misunderstand comment
> 
> 4. fix the checksum computation
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  include/net/inet_ecn.h |   22 ++++------------------
>  1 file changed, 4 insertions(+), 18 deletions(-)
> 
> diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
> index aab7375..545a683 100644
> --- a/include/net/inet_ecn.h
> +++ b/include/net/inet_ecn.h
> @@ -73,27 +73,13 @@ static inline void INET_ECN_dontxmit(struct sock *sk)
>  
>  static inline int IP_ECN_set_ce(struct iphdr *iph)
>  {
> -	u32 check = (__force u32)iph->check;
> -	u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
> -
> -	/*
> -	 * After the last operation we have (in binary):
> -	 * INET_ECN_NOT_ECT => 01
> -	 * INET_ECN_ECT_1   => 10
> -	 * INET_ECN_ECT_0   => 11
> -	 * INET_ECN_CE      => 00
> -	 */

	I think, the above comment explains how an
increment (iph->tos + 1) serves the purpose to check
for ECT_1 and ECT_0, there is no such thing as
addressing the next byte from header. It is just an
optimized logic that avoids complex INET_ECN_is_XXX
checks.

> -	if (!(ecn & 2))
> +	u32 ecn = iph->tos & INET_ECN_MASK;
> +
> +	if (INET_ECN_is_ce(ecn) || INET_ECN_is_not_ect(ecn))
>  		return !ecn;

	May be return INET_ECN_is_ce(ecn) ?

>  
> -	/*
> -	 * The following gives us:
> -	 * INET_ECN_ECT_1 => check += htons(0xFFFD)
> -	 * INET_ECN_ECT_0 => check += htons(0xFFFE)
> -	 */
> -	check += (__force u16)htons(0xFFFB) + (__force u16)htons(ecn);
> +	csum_replace2(&iph->check, iph->tos, iph->tos|INET_ECN_CE);
>  
> -	iph->check = (__force __sum16)(check + (check>=0xFFFF));
>  	iph->tos |= INET_ECN_CE;
>  	return 1;
>  }
> -- 
> 1.7.10.4

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1274773181-1355904720=:1620--
