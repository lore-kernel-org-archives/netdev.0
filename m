From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 2/5] bpf/verifier: rework
	value tracking
Date: Thu, 8 Jun 2017 20:38:29 +0100
Message-ID: <9b7aaa39-aacf-6f41-6adf-fc9317c447aa@solarflare.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<cef78266-62ec-8ef7-a512-cc111ba9c22a@solarflare.com>
	<20170608023239.lsqijtfcg5fadpai@ast-mbp>
	<81a661cc-a37c-336b-c10f-1fd4b301ca54@solarflare.com>
	<20170608164553.y2jvdbmsqqdc7cqt@ast-mbp.dhcp.thefacebook.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20170608164553.y2jvdbmsqqdc7cqt-+o4/htvd0TCa6kscz5V53/3mLCh9rsb+VpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/06/17 17:45, Alexei Starovoitov wrote:
> On Thu, Jun 08, 2017 at 03:53:36PM +0100, Edward Cree wrote:
>>>>  
>>>> -	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
>>>> +	} else if (reg->type == PTR_TO_STACK) {
>>>> +		/* stack accesses must be at a fixed offset, so that we can
>>>> +		 * determine what type of data were returned.
>>>> +		 */
>>>> +		if (reg->align.mask) {
>>>> +			char tn_buf[48];
>>>> +
>>>> +			tn_strn(tn_buf, sizeof(tn_buf), reg->align);
>>>> +			verbose("variable stack access align=%s off=%d size=%d",
>>>> +				tn_buf, off, size);
>>>> +			return -EACCES;
>>> hmm. why this restriction?
>>> I thought one of key points of the diff that ptr+var tracking logic
>>> will now apply not only to map_value, but to stack_ptr as well?
>> As the comment above it says, we need to determine what was returned:
>>  was it STACK_MISC or STACK_SPILL, and if the latter, what kind of pointer
>>  was spilled there?  See check_stack_read(), which I should probably
>>  mention in the comment.
> this piece of code is not only spill/fill, but normal ldx/stx stack access.
> Consider the frequent pattern that many folks tried to do:
> bpf_prog()
> {
>   char buf[64];
>   int len;
>
>   bpf_probe_read(&len, sizeof(len), kernel_ptr_to_filename_len);
>   bpf_probe_read(buf, sizeof(buf), kernel_ptr_to_filename);
>   buf[len & (sizeof(buf) - 1)] = 0;
> ...
>
> currently above is not supported, but when 'buf' is a pointer to map value
> it works fine. Allocating extra bpf map just to do such workaround
> isn't nice and since this patch generalized map_value_adj with ptr_to_stack
> we can support above code too.
> We can check that all bytes of stack for this variable access were
> initialized already.
> In the example above it will happen by bpf_probe_read (in the verifier code):
>         for (i = 0; i < meta.access_size; i++) {
>                 err = check_mem_access(env, meta.regno, i, BPF_B, BPF_WRITE, -1);
> so at the time of
>   buf[len & ..] = 0
> we can check that 'stx' is within the range of inited stack and allow it.
Yes, we could check every byte of the stack within the range [buf, buf+63]
 is a STACK_MISC and if so allow it.  But since this is not supported by the
 existing code (so it's not a regression), I'd prefer to leave that for a
 future patch - this one is quite big enough already ;-)
>>>> +	if (!err && size < BPF_REG_SIZE && value_regno >= 0 && t == BPF_READ &&
>>>> +	    state->regs[value_regno].type == SCALAR_VALUE) {
>>>> +		/* b/h/w load zero-extends, mark upper bits as known 0 */
>>>> +		state->regs[value_regno].align.value &= (1ULL << (size * 8)) - 1;
>>>> +		state->regs[value_regno].align.mask &= (1ULL << (size * 8)) - 1;
>>> probably another helper from tnum.h is needed.
>> I could rewrite as
>>  reg->align = tn_and(reg->align, tn_const((1ULL << (size * 8)) - 1))
> yep. that's perfect.
In the end I settled on adding a helper
    struct tnum tnum_cast(struct tnum a, u8 size);
 since I have a bunch of other places that cast things to 32 bits.
> I see. May be print verifier state in such warn_ons and make error
> more human readable?
Good idea, I'll do that.
>>>> +	case PTR_TO_MAP_VALUE_OR_NULL:
>>> does this new state comparison logic helps? Do you have any numbers before/after in the number of insns it had to process for the tests in selftests ?
>> I don't have the numbers, no (I'll try to collect them).  This rewrite was
> Thanks. The main concern is that right now some complex programs
> that cilium is using are close to the verifier complexity limit and these
> big changes to amount of info recognized by the verifier can cause pruning
> to be ineffective, so we need to test on big programs.
> I think Daniel will be happy to test your next rev of the patches.
> I'll test them as well.
> At least 'insn_processed' from C code in tools/testing/selftests/bpf/
> is a good estimate of how these changes affect pruning.
It looks like the only place this gets recorded is as "processed %d insns"
 in the log_buf.  Is there a convenient way to get at this, or am I going
 to have to make bpf_verify_program grovel through the log sscanf()ing for
 a matching line?

-Ed
