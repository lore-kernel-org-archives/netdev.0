From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 4/4] bpf/verifier: document liveness analysis
Date: Tue, 22 Aug 2017 08:42:42 -0700
Message-ID: <36605f53-479d-a32d-ed2e-721c13f0080a@fb.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
 <60838927-7286-60c9-ad69-3b97350a05a4@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Edward Cree <ecree@solarflare.com>, <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44546 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933001AbdHVPnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 11:43:06 -0400
In-Reply-To: <60838927-7286-60c9-ad69-3b97350a05a4@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/17 6:27 AM, Edward Cree wrote:
> The liveness tracking algorithm is quite subtle; add comments to explain it.
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
>  include/linux/bpf_verifier.h | 13 +++++++++++++
>  kernel/bpf/verifier.c        | 28 +++++++++++++++++++++++++++-
>  2 files changed, 40 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
> index d8f131a..b8d200f 100644
> --- a/include/linux/bpf_verifier.h
> +++ b/include/linux/bpf_verifier.h
> @@ -21,6 +21,19 @@
>   */
>  #define BPF_MAX_VAR_SIZ	INT_MAX
>
> +/* Liveness marks, used for registers and spilled-regs (in stack slots).
> + * Read marks propagate upwards until they find a write mark; they record that
> + * "one of this state's descendants read this reg" (and therefore the reg is
> + * relevant for states_equal() checks).
> + * Write marks collect downwards and do not propagate; they record that "the
> + * straight-line code that reached this state (from its parent) wrote this reg"
> + * (and therefore that reads propagated from this state or its descendants
> + * should not propagate to its parent).
> + * A state with a write mark can receive read marks; it just won't propagate
> + * them to its parent, since the write mark is a property, not of the state,
> + * but of the link between it and its parent.  See mark_reg_read() and
> + * mark_stack_slot_read() in kernel/bpf/verifier.c.
> + */

+1

>  enum bpf_reg_liveness {
>  	REG_LIVE_NONE = 0, /* reg hasn't been read or written this branch */
>  	REG_LIVE_READ, /* reg was read, so we're sensitive to initial value */
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 711bdbd..5fc350e 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -3417,6 +3417,12 @@ static bool states_equal(struct bpf_verifier_env *env,
>  	return ret;
>  }
>
> +/* A write screens off any subsequent reads; but write marks come from the
> + * straight-line code between a state and its parent.  When we arrive at a
> + * jump target (in the first iteration of the propagate_liveness() loop),
> + * we didn't arrive by the straight-line code, so read marks in state must
> + * propagate to parent regardless of state's write marks.
> + */

+1

>  static bool do_propagate_liveness(const struct bpf_verifier_state *state,
>  				  struct bpf_verifier_state *parent)
>  {
> @@ -3457,6 +3463,15 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
>  	return touched;
>  }
>
> +/* "parent" is "a state from which we reach the current state", but initially
> + * it is not the state->parent (i.e. "the state whose straight-line code leads
> + * to the current state"), instead it is the state that happened to arrive at
> + * a (prunable) equivalent of the current state.  See comment above
> + * do_propagate_liveness() for consequences of this.
> + * This function is just a more efficient way of calling mark_reg_read() or
> + * mark_stack_slot_read() on each reg in "parent" that is read in "state", so
> + * long as parent != state->parent.
> + */

i'm confused with 'so long as parent != state->parent' which implies
looping and multiple iterations, whereas 'parent != state->parent'
condition is true only for the first iteration of
'while (do_propagate_liveness(state, parent))' loop.
right ?

>  static void propagate_liveness(const struct bpf_verifier_state *state,
>  			       struct bpf_verifier_state *parent)
>  {
> @@ -3485,6 +3500,12 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
>  			/* reached equivalent register/stack state,
>  			 * prune the search.
>  			 * Registers read by the continuation are read by us.
> +			 * If we have any write marks in env->cur_state, they
> +			 * will prevent corresponding reads in the continuation
> +			 * from reaching our parent (an explored_state).  Our
> +			 * own state will get the read marks recorded, but
> +			 * they'll be immediately forgotten as we're pruning
> +			 * this state and will pop a new one.
>  			 */

+1

>  			propagate_liveness(&sl->state, &env->cur_state);
>  			return 1;
> @@ -3508,7 +3529,12 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
>  	env->explored_states[insn_idx] = new_sl;
>  	/* connect new state to parentage chain */
>  	env->cur_state.parent = &new_sl->state;
> -	/* clear liveness marks in current state */
> +	/* clear write marks in current state: the writes we did are not writes
> +	 * our child did, so they don't screen off its reads from us.
> +	 * (There are no read marks in current state, because reads always mark
> +	 * their parent and current state never has children yet.  Only
> +	 * explored_states can get read marks.)
> +	 */

+1

>  	for (i = 0; i < BPF_REG_FP; i++)
>  		env->cur_state.regs[i].live = REG_LIVE_NONE;
>  	for (i = 0; i < MAX_BPF_STACK / BPF_REG_SIZE; i++)
>
