From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 1/2] bpf: don't enable preemption twice in smap_do_verdict
Date: Thu, 17 Aug 2017 09:03:25 -0700
Message-ID: <5995BE4D.10503@gmail.com>
References: <cover.1502983087.git.daniel@iogearbox.net> <d90eed71c2a723edd75f19fb1b921fec74d8a514.1502983087.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34111 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbdHQQDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 12:03:34 -0400
Received: by mail-pg0-f65.google.com with SMTP id y192so10548771pgd.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 09:03:34 -0700 (PDT)
In-Reply-To: <d90eed71c2a723edd75f19fb1b921fec74d8a514.1502983087.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 08:22 AM, Daniel Borkmann wrote:
> In smap_do_verdict(), the fall-through branch leads to call
> preempt_enable() twice for the SK_REDIRECT, which creates an
> imbalance. Only enable it for all remaining cases again.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Reported-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  kernel/bpf/sockmap.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
> index f7e5e6c..39de541 100644
> --- a/kernel/bpf/sockmap.c
> +++ b/kernel/bpf/sockmap.c
> @@ -135,7 +135,8 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
>  	/* Fall through and free skb otherwise */
>  	case SK_DROP:
>  	default:
> -		preempt_enable();
> +		if (rc != SK_REDIRECT)
> +			preempt_enable();
>  		kfree_skb(skb);
>  	}
>  }
> 

Yep looks good, nice catch Alexei. Thanks! I'll add a selftests entry
in test_maps to catch this fall through case. Looks like we don't hit
this case during selftests at the moment.

Acked-by: John Fastabend <john.fastabend@gmail.com>
