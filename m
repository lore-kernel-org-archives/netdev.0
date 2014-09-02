From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: export pkt_type_offset() helper
Date: Tue, 2 Sep 2014 15:59:27 -0700
Message-ID: <20140902225926.GA14635@its-macbook-pro.plumgrid.com>
References: <1409688238-3152-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:58829 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbaIBW70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 18:59:26 -0400
Received: by mail-pd0-f176.google.com with SMTP id w10so273038pde.35
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 15:59:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1409688238-3152-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2014 at 12:03:58AM +0400, Denis Kirjanov wrote:
> Currently we have 2 pkt_type_offset functions doing
> the same thing and spread across the architecture files.
> Let's use the generic helper routine.

that would be good cleanup.
Please tag your subject as '[PATCH net-next]...'

> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> Cc: Markos Chandras <markos.chandras@imgtec.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> ---
>  arch/mips/net/bpf_jit.c      | 21 ---------------------
>  arch/s390/net/bpf_jit_comp.c | 38 ++++----------------------------------
>  include/linux/filter.h       |  7 +++++++
>  net/core/filter.c            |  7 +------
>  4 files changed, 12 insertions(+), 61 deletions(-)
> 
> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
> -#define PKT_TYPE_MAX 0xe0
> -static int pkt_type_offset;
...
> -}
> -device_initcall(bpf_pkt_type_offset_init);

may be make sense to optimize common case via initcall() as well
instead of dropping it for s390?

> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index a5227ab..97e0549 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -424,6 +424,13 @@ static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
>  	return bpf_internal_load_pointer_neg_helper(skb, k, size);
>  }
>  
> +#ifdef __BIG_ENDIAN_BITFIELD
> +#define PKT_TYPE_MAX	(7 << 5)
> +#else
> +#define PKT_TYPE_MAX    7
> +#endif

these defines don't need to move. keep them in filter.c
