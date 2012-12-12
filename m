From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: return -EINVAL if BPF_S_ANC* operation is
 not supported
Date: Wed, 12 Dec 2012 04:22:44 -0800
Message-ID: <1355314964.9139.173.camel@edumazet-glaptop>
References: <1355304701-22228-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ani Sinha <ani@aristanetworks.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:43750 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab2LLMWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 07:22:47 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so524576pbc.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 04:22:47 -0800 (PST)
In-Reply-To: <1355304701-22228-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-12 at 10:31 +0100, Daniel Borkmann wrote:
> Currently, we return -EINVAL for malicious or wrong BPF filters.
> However, this is not done for BPF_S_ANC* operations, which makes it
> more difficult to detect if it's actually supported or not by the
> BPF machine. Therefore, we should also return -EINVAL if K is within
> the SKF_AD_OFF universe and the ancillary operation did not match.
> 
> Cc: Ani Sinha <ani@aristanetworks.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/core/filter.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index c23543c..de9bed4 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -531,7 +531,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K,
>  		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
>  	};
> -	int pc;
> +	int pc, anc_found;
>  
>  	if (flen == 0 || flen > BPF_MAXINSNS)
>  		return -EINVAL;
> @@ -592,8 +592,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  		case BPF_S_LD_W_ABS:
>  		case BPF_S_LD_H_ABS:
>  		case BPF_S_LD_B_ABS:
> +			anc_found = 0;
>  #define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
>  				code = BPF_S_ANC_##CODE;	\
> +				anc_found = 1;			\
>  				break
>  			switch (ftest->k) {
>  			ANCILLARY(PROTOCOL);
> @@ -610,6 +612,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  			ANCILLARY(VLAN_TAG);
>  			ANCILLARY(VLAN_TAG_PRESENT);
>  			}
> +
> +			/* ancillary operation unkown or unsupported */
> +			if (anc_found == 0 && ftest->k >= SKF_AD_OFF)
> +				return -EINVAL;
>  		}
>  		ftest->code = code;
>  	}

Several points :

1) This might break a userland filter that was previously working, by
returning 0 when load_pointer() returns NULL.

Specifying an offset bigger than skb->len is not _invalid_, it only
makes a filter returns 0, because load_pointer() returns NULL.

2) This wont help applications running on old kernels where your patch
wont be applied, as already mentioned yesterday.

3) Misses a "Reported-by" tag

4) anc_found is a boolean


To be truly portable, userland should not rely on kernel doing a full
validation of ancillaries. 
