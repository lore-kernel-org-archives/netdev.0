From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 1/3] net: flow_dissector: avoid multiple calls
 in BPF
Date: Wed, 14 May 2014 13:05:37 -0700
Message-ID: <CAMEtUuxOC3krRcwcuUaMHwBOC_7pGckVFmpU0f_NsMs-5j586w@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1400093480-498-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:38784 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaENUFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 16:05:39 -0400
Received: by mail-we0-f179.google.com with SMTP id q59so56916wes.38
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 13:05:37 -0700 (PDT)
In-Reply-To: <1400093480-498-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 11:51 AM, Chema Gonzalez <chema@google.com> wrote:
> We want multiple calls to __skb_get_poff() in the same filter to only
> cause one invocation to the flow dissector. In order to reuse the result
> of the flow dissector invocation (skb_flow_dissect()), we add a flow_keys
> variable in the eBPF runner stack (__sk_run_filter() function), and pass
> it as an argument to __skb_get_poff(). __skb_get_poff() inits the variable
> the very first time it is called, and reuses the result in any further
> invocation.
>
> We also add handy function to init/check for inited flow_keys.
>
> Signed-off-by: Chema Gonzalez <chema@google.com>
> ---
>  include/linux/skbuff.h    |  4 +++-
>  net/core/filter.c         | 14 ++++++++++++--
>  net/core/flow_dissector.c | 28 ++++++++++++++++++++++------
>  3 files changed, 37 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 7a9beeb..858d7af 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3065,7 +3065,9 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
>
>  int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
>
> -u32 __skb_get_poff(const struct sk_buff *skb);
> +void __flow_keys_reset(struct flow_keys *flow);
> +bool __flow_keys_inited(struct flow_keys *flow);
> +u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *flow);
>
>  /**
>   * skb_head_is_locked - Determine if the skb->head is locked down
> diff --git a/net/core/filter.c b/net/core/filter.c
> index c442a0d..b71948b 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -66,6 +66,11 @@
>  #define CTX    regs[BPF_REG_CTX]
>  #define K      insn->imm
>
> +struct sk_run_filter_ctx {
> +       struct sk_buff *skb;
> +       struct flow_keys *flow;
> +};
> +
>  /* No hurry in this branch
>   *
>   * Exported for the bpf jit load helper.
> @@ -252,12 +257,15 @@ unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
>         };
>         void *ptr;
>         int off;
> +       struct flow_keys flow;
> +       struct sk_run_filter_ctx context = { ctx, &flow };
>
>  #define CONT    ({ insn++; goto select_insn; })
>  #define CONT_JMP ({ insn++; goto select_insn; })
>
> +       memset(&flow, 0, sizeof(flow));
>         FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
> -       ARG1 = (u64) (unsigned long) ctx;
> +       ARG1 = (u64) (unsigned long) &context;

I have a feeling that you didn't test this. Even basic "tcpdump port 22"
will be broken, let alone BPF testsuite. It also breaks seccomp, new JIT
and tracing filter patches I've posted yesterday.
sk_run_filter() is a generic interpreter that should be suitable for
sockets, seccomp, tracing, etc. Adding one use case specific data
structure to interpreter is not desirable.
Doing memset(&flow,0...) every invocation is not performance
friendly either. Majority of filters will suffer.

You can do the same without touching sk_run_filter().
For example, you can tweak sk_convert_filter() to pass
R10(frame pointer) as arg4 to helper functions
(__skb_get_pay_offset() and others)
then inside those functions cast 'arg4 - appropriate offset'
to struct flow_keys and use it.
BPF was extended from 16 spill/fill only slots to generic
stack space exactly for this type of use cases.
Key point: you can add pretty much any feature to classic BPF
by tweaking converter from classic to internal without changing
interpreter and causing trainwreck for non-socket use cases.

The idea itself I think is quite interesting. I'm only disliking its
implementation.

>         /* Register for user BPF programs need to be reset first. */
>         regs[BPF_REG_A] = 0;
> @@ -602,7 +610,9 @@ static unsigned int pkt_type_offset(void)
>
>  static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
>  {
> -       return __skb_get_poff((struct sk_buff *)(unsigned long) ctx);
> +       struct sk_run_filter_ctx *context = (struct sk_run_filter_ctx *)
> +                       (unsigned long) ctx;
> +       return __skb_get_poff(context->skb, context->flow);
>  }
>
>  static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 107ed12..4d431f0 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -270,21 +270,37 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
>  }
>  EXPORT_SYMBOL(__skb_tx_hash);
>
> +/* __flow_keys_reset() zeroes a flow_keys struct */
> +void __flow_keys_reset(struct flow_keys *flow)
> +{
> +       memset(flow, 0, sizeof(struct flow_keys));
> +}
> +
> +/* __flow_keys_inited() checks whether a flow_keys struct is init */
> +bool __flow_keys_inited(struct flow_keys *flow)
> +{
> +       struct flow_keys zero_flow;
> +
> +       __flow_keys_reset(&zero_flow);
> +       return memcmp(flow, &zero_flow, sizeof(struct flow_keys));
> +}
> +
>  /* __skb_get_poff() returns the offset to the payload as far as it could
>   * be dissected. The main user is currently BPF, so that we can dynamically
>   * truncate packets without needing to push actual payload to the user
>   * space and can analyze headers only, instead.
>   */
> -u32 __skb_get_poff(const struct sk_buff *skb)
> +u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *flow)
>  {
> -       struct flow_keys keys;
>         u32 poff = 0;
>
> -       if (!skb_flow_dissect(skb, &keys))
> -               return 0;
> +       /* check whether the flow dissector has already been run */
> +       if (!__flow_keys_inited(flow))
> +               if (!skb_flow_dissect(skb, flow))
> +                       return 0;
>
> -       poff += keys.thoff;
> -       switch (keys.ip_proto) {
> +       poff += flow->thoff;
> +       switch (flow->ip_proto) {
>         case IPPROTO_TCP: {
>                 const struct tcphdr *tcph;
>                 struct tcphdr _tcph;
> --
> 1.9.1.423.g4596e3a
>
