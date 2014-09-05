From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] bpf: fix a false positive kmemcheck warning
Date: Fri, 05 Sep 2014 18:20:24 +0200
Message-ID: <5409E2C8.2080200@redhat.com>
References: <alpine.LRH.2.02.1409051157440.5269@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbaIEQUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 12:20:35 -0400
In-Reply-To: <alpine.LRH.2.02.1409051157440.5269@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mikulas,

On 09/05/2014 06:01 PM, Mikulas Patocka wrote:
> This patch fixes false positive kmemcheck warning in bpf.
>
> When we try to write the variable len, the compiler generates a code that
> reads the 32-bit word, modifies the bits belonging to "len" and writes the
> 32-bit word back. The reading of the word results in kmemcheck warning due
> to reading uninitialized memory. This patch fixes it by avoiding using bit
> fields when kmemcheck is enabled.
>
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

You need to submit this patch to netdev (Cc'ed).

> ---
>   include/linux/filter.h |    5 +++++
>   1 file changed, 5 insertions(+)
>
> Index: linux-2.6/include/linux/filter.h
> ===================================================================
> --- linux-2.6.orig/include/linux/filter.h	2014-09-04 23:04:26.000000000 +0200
> +++ linux-2.6/include/linux/filter.h	2014-09-04 23:43:05.000000000 +0200
> @@ -325,8 +325,13 @@ struct sock;
>   struct seccomp_data;
>
>   struct bpf_prog {
> +#ifdef CONFIG_KMEMCHECK
> +	bool			jited;
> +	u32			len;
> +#else
>   	u32			jited:1,	/* Is our filter JIT'ed? */
>   				len:31;		/* Number of filter blocks */
> +#endif
>   	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
>   	unsigned int		(*bpf_func)(const struct sk_buff *skb,
>   					    const struct bpf_insn *filter);

I don't really like this if-def. If you really want to fix it, can't
you just use :

   kmemcheck_bitfield_begin(bpf_anc_data)
   ...
   kmemcheck_bitfield_end(bpf_anc_data)

et al infrastructure as container (in case in future we will add some more
bit flags, since len doesn't really need all 31 bit universe)?

Note, there are currently some patches pending in patchwork that also fill
the u32 hole thus the extra bool would introduce a new hole after that.

Therefore, I think above would be better.

Thanks,
Daniel
