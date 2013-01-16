From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [Patch net-next 1/2] xfrm: replace rwlock on xfrm_state_afinfo
 with rcu
Date: Wed, 16 Jan 2013 22:57:48 +0900
Message-ID: <50F6B1DC.4030307@linux-ipv6.org>
References: <1358323506-19571-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42620 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751478Ab3APN5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 08:57:50 -0500
In-Reply-To: <1358323506-19571-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Similar to commit 418a99ac6ad487dc9c42e6b0e85f941af56330f2
> (Replace rwlock on xfrm_policy_afinfo with rcu), the rwlock
> on xfrm_state_afinfo can be replaced by RCU too.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/xfrm/xfrm_state.c |   33 ++++++++++++++++-----------------
>  1 files changed, 16 insertions(+), 17 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 3459692..f567716 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
:
> @@ -173,17 +173,16 @@ static struct xfrm_state_afinfo *xfrm_state_lock_afinfo(unsigned int family)
>  	struct xfrm_state_afinfo *afinfo;
>  	if (unlikely(family >= NPROTO))
>  		return NULL;
> -	write_lock_bh(&xfrm_state_afinfo_lock);
> +	spin_lock_bh(&xfrm_state_afinfo_lock);
>  	afinfo = xfrm_state_afinfo[family];
>  	if (unlikely(!afinfo))
> -		write_unlock_bh(&xfrm_state_afinfo_lock);
> +		spin_unlock_bh(&xfrm_state_afinfo_lock);
>  	return afinfo;
>  }
>  
>  static void xfrm_state_unlock_afinfo(struct xfrm_state_afinfo *afinfo)
> -	__releases(xfrm_state_afinfo_lock)
>  {
> -	write_unlock_bh(&xfrm_state_afinfo_lock);
> +	spin_unlock_bh(&xfrm_state_afinfo_lock);
>  }
>  
>  int xfrm_register_type(const struct xfrm_type *type, unsigned short family)

Why removing __releases() hint?

--yoshfuji
