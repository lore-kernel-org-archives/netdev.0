From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [iproute2][PATCH] tc: mirred target: do not report
 non-existing devices
Date: Thu, 30 Aug 2012 08:01:54 -0700
Message-ID: <1346338914.2586.14.camel@edumazet-glaptop>
References: <1346338277-8395-1-git-send-email-danken@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Dan Kenigsberg <danken@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63834 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab2H3PCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 11:02:10 -0400
Received: by pbbrr13 with SMTP id rr13so3274227pbb.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 08:02:09 -0700 (PDT)
In-Reply-To: <1346338277-8395-1-git-send-email-danken@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-30 at 17:51 +0300, Dan Kenigsberg wrote:
> Currently, if a mirred target device is removed, `tc filter show`
> does not reveal the fact. Instead, it replaces the original name of the
> device with the default output of ll_map:ll_idx_n2a().
> 
> This is unfortunate, since one cannot differ between this case and a valid
> mirroring target device named 'if17'.
> 
> It seems that the original code meant to report an error message in this
> case, but it does not, since ll_index_to_name() never returns 0. I would
> not like to bail out in case of an error, since the user would still be
> interested to know what are the other details of the action.
> 
> Signed-off-by: Dan Kenigsberg <danken@redhat.com>
> ---
>  lib/ll_map.c  |   13 +++++++++++++
>  tc/m_mirred.c |   10 ++++------
>  2 files changed, 17 insertions(+), 6 deletions(-)
> 
> diff --git a/lib/ll_map.c b/lib/ll_map.c
> index 1ca781e..8ceef41 100644
> --- a/lib/ll_map.c
> +++ b/lib/ll_map.c
> @@ -108,6 +108,19 @@ const char *ll_idx_n2a(unsigned idx, char *buf)
>  	return buf;
>  }
>  
> +char *ll_index_exists(unsigned idx)
> +{
> +	const struct ll_cache *im;
> +
> +	if (idx == 0)
> +		return 0;
> +
> +	for (im = idxhead(idx); im; im = im->idx_next)
> +		if (im->index == idx)
> +			return 1;
> +
> +	return 0;
> +}
>  

I am curious to know what compiler accepted this.

return type should be a "int", not a "char *"

>  const char *ll_index_to_name(unsigned idx)
>  {
> diff --git a/tc/m_mirred.c b/tc/m_mirred.c
> index 0d771bc..eba1240 100644
> --- a/tc/m_mirred.c
> +++ b/tc/m_mirred.c
> @@ -268,13 +268,11 @@ print_mirred(struct action_util *au,FILE * f, struct rtattr *arg)
>  	ll_init_map(&rth);
>  	*/
>  
> +	dev = ll_index_to_name(p->ifindex);
>  
> -	if ((dev = ll_index_to_name(p->ifindex)) == 0) {
> -		fprintf(stderr, "Cannot find device %d\n", p->ifindex);
> -		return -1;
> -	}
> -
> -	fprintf(f, "mirred (%s to device %s) %s", mirred_n2a(p->eaction), dev,action_n2a(p->action, b1, sizeof (b1)));
> +	fprintf(f, "mirred (%s to %sdevice %s) %s", mirred_n2a(p->eaction),
> +                ll_index_exists(p->ifindex) ? "" : "missing-",
> +                dev, action_n2a(p->action, b1, sizeof (b1)));
>  
>  	fprintf(f, "\n ");
>  	fprintf(f, "\tindex %d ref %d bind %d",p->index,p->refcnt,p->bindcnt);

How this can compile without triggering a warning, as the
ll_index_exists() is not in an include file ?
