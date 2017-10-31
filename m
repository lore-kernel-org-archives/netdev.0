From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] bpf: reduce verifier memory consumption
Date: Tue, 31 Oct 2017 12:37:14 +0000
Message-ID: <d8d1710d-cb03-af74-db6d-9e19b4a342b5@solarflare.com>
References: <20171030215147.579702-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:37024 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753051AbdJaMhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 08:37:22 -0400
In-Reply-To: <20171030215147.579702-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/10/17 21:51, Alexei Starovoitov wrote:
> the verifier got progressively smarter over time and size of its internal
> state grew as well. Time to reduce the memory consumption.
> 
> Before:
> sizeof(struct bpf_verifier_state) = 6520
> After:
> sizeof(struct bpf_verifier_state) = 896
Nice!

> It's done by observing that majority of BPF programs use little to
> no stack whereas verifier kept all of 512 stack slots ready always.
> Instead dynamically reallocate struct verifier state when stack
> access is detected.
> Besides memory savings such approach gives few % runtime perf
> improvement as well and small reduction in number of processed insns:
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This worries me.  Not that improving pruning performance is a bad thing,
 but I don't see anything in this patch that should affect it, which
 suggests maybe a bug has been introduced that prunes too much?

> +static void copy_verifier_state(struct bpf_verifier_state *dst,
> +				const struct bpf_verifier_state *src)
> +{
> +	int stack = dst->allocated_stack;
> +
> +	if (stack < src->allocated_stack) {
> +		WARN_ON_ONCE(stack < src->allocated_stack);
Why not just
    if (WARN_ON_ONCE(stack < src->allocated_stack)) {
?

> +		/* internal bug, make state invalid to reject the program */
> +		memset(dst, 0, sizeof(*dst));
> +		return;
Any reason this function couldn't return int instead?

> +	}
> +	memcpy(dst, src, offsetof(struct bpf_verifier_state,
> +				  stack[src->allocated_stack / BPF_REG_SIZE]));
> +	dst->allocated_stack = stack;
> +}

Then again, I'm not entirely sure I like the idea of an array[0] at the
 end of the struct anyway (which is what makes this copy_verifier_state()
 necessary).  I'd be happier with a *array member pointing to a separate
 allocation; though that would still need separate copying in
 is_state_visited().  I also worry about a stale *parent somewhere
 pointing to the old state; I don't _think_ that can happen, but I'm not
 as sure of that as I'd like to be.  Using a *array instead would mean
 that &state doesn't change when we grow it.
Also, why kzalloc() a new state (in realloc_verifier_state()) rather than
 krealloc()ing the existing one and memset()ing the extra space?  That way
 you wouldn't need to then copy across all the old data.

>  static int pop_stack(struct bpf_verifier_env *env, int *prev_insn_idx)
>  {
> -	struct bpf_verifier_stack_elem *elem;
> +	struct bpf_verifier_state *cur = env->cur_state;
> +	struct bpf_verifier_stack_elem *elem, *head = env->head;
>  	int insn_idx;
>  
>  	if (env->head == NULL)
>  		return -1;
>  
> -	memcpy(&env->cur_state, &env->head->st, sizeof(env->cur_state));
> -	insn_idx = env->head->insn_idx;
> +	if (cur && cur->allocated_stack < head->st.allocated_stack) {
> +		cur = realloc_verifier_state(cur, head->st.allocated_stack);
> +		if (!cur)
> +			return -ENOMEM;
I don't think this does what you want.  Calling code in do_check() will
 get insn_idx = -ENOMEM, see that it's < 0, and break out of the loop.
 Prog will then be accepted without further checking.

-Ed
