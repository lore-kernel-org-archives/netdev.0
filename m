From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/8] net: bpf: add neq jump operations to bpf
 machine
Date: Mon, 31 Dec 2012 19:25:49 -0800
Message-ID: <1357010749.21409.8935.camel@edumazet-glaptop>
References: <cover.1356960070.git.dborkman@redhat.com>
	 <ce1ddcbf8c0effcfa561b224630e3645504a6ad4.1356960070.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:62975 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab3AADZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 22:25:52 -0500
Received: by mail-pb0-f51.google.com with SMTP id ro12so7299479pbb.10
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2012 19:25:52 -0800 (PST)
In-Reply-To: <ce1ddcbf8c0effcfa561b224630e3645504a6ad4.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-31 at 14:59 +0100, Daniel Borkmann wrote:
> This patch adds jump operations for neq (!=) that compare A
> with K resp. X in order to facilitate filter programming with
> conditional jumps, since currently only eq (==) is present in
> the BPF machine. For user-space filter programming / compilers,
> it might be good to also have this complementary operation.
> They don't need to be as ancillary, since they fit into the
> instruction encoding directly. Follow-up BPF JIT patches are
> welcomed.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/linux/filter.h      |  2 ++
>  include/uapi/linux/filter.h |  1 +
>  net/core/filter.c           | 14 ++++++++++++++
>  3 files changed, 17 insertions(+)
> 
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 36630bc..256c01f 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -105,6 +105,8 @@ enum {
>  	BPF_S_JMP_JA,
>  	BPF_S_JMP_JEQ_K,
>  	BPF_S_JMP_JEQ_X,
> +	BPF_S_JMP_JNEQ_K,
> +	BPF_S_JMP_JNEQ_X,
>  	BPF_S_JMP_JGE_K,
>  	BPF_S_JMP_JGE_X,
>  	BPF_S_JMP_JGT_K,
> diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
> index 3ebcc2e..d909a6f 100644
> --- a/include/uapi/linux/filter.h
> +++ b/include/uapi/linux/filter.h
> @@ -80,6 +80,7 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>  #define         BPF_JSET        0x40
>  #define         BPF_JLT         0x50
>  #define         BPF_JLE         0x60
> +#define         BPF_JNEQ        0x70
>  
>  #define BPF_SRC(code)   ((code) & 0x08)
>  #define         BPF_K           0x00
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 2122eba..b360fb3 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -228,6 +228,9 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
>  		case BPF_S_JMP_JEQ_K:
>  			fentry += (A == K) ? fentry->jt : fentry->jf;
>  			continue;
> +		case BPF_S_JMP_JNEQ_K:
> +			fentry += (A != K) ? fentry->jt : fentry->jf;
> +			continue;
>  		case BPF_S_JMP_JSET_K:
>  			fentry += (A & K) ? fentry->jt : fentry->jf;
>  			continue;

This makes no sense at all to me, it seems kernel bloat.

The JNE instruction already exists.

You only have to take the JEQ (jt,jf) and swap the jt/jf targets.
