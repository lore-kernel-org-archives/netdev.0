From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: reduce verifier memory consumption
Date: Tue, 31 Oct 2017 18:12:39 -0700
Message-ID: <aa50bc18-0353-8e02-8434-82116984d900@fb.com>
References: <20171030215147.579702-1-ast@fb.com>
 <d8d1710d-cb03-af74-db6d-9e19b4a342b5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Edward Cree <ecree@solarflare.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37942 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752175AbdKABNF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:13:05 -0400
In-Reply-To: <d8d1710d-cb03-af74-db6d-9e19b4a342b5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/17 5:37 AM, Edward Cree wrote:
> On 30/10/17 21:51, Alexei Starovoitov wrote:
>> the verifier got progressively smarter over time and size of its internal
>> state grew as well. Time to reduce the memory consumption.
>>
>> Before:
>> sizeof(struct bpf_verifier_state) = 6520
>> After:
>> sizeof(struct bpf_verifier_state) = 896
> Nice!
>
>> It's done by observing that majority of BPF programs use little to
>> no stack whereas verifier kept all of 512 stack slots ready always.
>> Instead dynamically reallocate struct verifier state when stack
>> access is detected.
>> Besides memory savings such approach gives few % runtime perf
>> improvement as well and small reduction in number of processed insns:
>                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> This worries me.  Not that improving pruning performance is a bad thing,
>  but I don't see anything in this patch that should affect it, which
>  suggests maybe a bug has been introduced that prunes too much?

that indeed turned out to be a missed case when poping a state
with smaller stack than the current one.

>> +static void copy_verifier_state(struct bpf_verifier_state *dst,
>> +				const struct bpf_verifier_state *src)
>> +{
>> +	int stack = dst->allocated_stack;
>> +
>> +	if (stack < src->allocated_stack) {
>> +		WARN_ON_ONCE(stack < src->allocated_stack);
> Why not just
>     if (WARN_ON_ONCE(stack < src->allocated_stack)) {
> ?

done.

>> +		/* internal bug, make state invalid to reject the program */
>> +		memset(dst, 0, sizeof(*dst));
>> +		return;
> Any reason this function couldn't return int instead?

I didn't do it, since it adds additional error checks to the code that
should never be taken, but I guess it makes the verifier a tiny bit
more robust in case of fatal errors, so done.

>> +	}
>> +	memcpy(dst, src, offsetof(struct bpf_verifier_state,
>> +				  stack[src->allocated_stack / BPF_REG_SIZE]));
>> +	dst->allocated_stack = stack;
>> +}
>
> Then again, I'm not entirely sure I like the idea of an array[0] at the
>  end of the struct anyway (which is what makes this copy_verifier_state()
>  necessary).  I'd be happier with a *array member pointing to a separate
>  allocation;

I coded it up. It turned out to be a bit more complex than current
version, but the argument about keeping state pointer the same is
solid, so done.

> though that would still need separate copying in
>  is_state_visited().

yes

> I also worry about a stale *parent somewhere
>  pointing to the old state; I don't _think_ that can happen, but I'm not

'parent' can point to wrong thing since liveness was introduced,
so this doesn't change it. With stack[0] and *stack approach,
both need to copy parent. Specifically for that I had a comment
next to realloc_verifier_state() and kept the comment in
the new version.

>  as sure of that as I'd like to be.  Using a *array instead would mean
>  that &state doesn't change when we grow it.
> Also, why kzalloc() a new state (in realloc_verifier_state()) rather than
>  krealloc()ing the existing one and memset()ing the extra space?  That way
>  you wouldn't need to then copy across all the old data.

because krealloc() unconditionally copies the data whereas we can make
it smarter by not copying always.

>
>>  static int pop_stack(struct bpf_verifier_env *env, int *prev_insn_idx)
>>  {
>> -	struct bpf_verifier_stack_elem *elem;
>> +	struct bpf_verifier_state *cur = env->cur_state;
>> +	struct bpf_verifier_stack_elem *elem, *head = env->head;
>>  	int insn_idx;
>>
>>  	if (env->head == NULL)
>>  		return -1;
>>
>> -	memcpy(&env->cur_state, &env->head->st, sizeof(env->cur_state));
>> -	insn_idx = env->head->insn_idx;
>> +	if (cur && cur->allocated_stack < head->st.allocated_stack) {
>> +		cur = realloc_verifier_state(cur, head->st.allocated_stack);
>> +		if (!cur)
>> +			return -ENOMEM;
> I don't think this does what you want.  Calling code in do_check() will
>  get insn_idx = -ENOMEM, see that it's < 0, and break out of the loop.
>  Prog will then be accepted without further checking.

yeah. it was on my todo list to fix before submitting, but then slipped
my mind. Fixed now.

v2 is coming.
