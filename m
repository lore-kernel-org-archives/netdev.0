From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 2/5] bpf/verifier: rework
	value tracking
Date: Thu, 8 Jun 2017 09:45:55 -0700
Message-ID: <20170608164553.y2jvdbmsqqdc7cqt@ast-mbp.dhcp.thefacebook.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<cef78266-62ec-8ef7-a512-cc111ba9c22a@solarflare.com>
	<20170608023239.lsqijtfcg5fadpai@ast-mbp>
	<81a661cc-a37c-336b-c10f-1fd4b301ca54@solarflare.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <81a661cc-a37c-336b-c10f-1fd4b301ca54-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On Thu, Jun 08, 2017 at 03:53:36PM +0100, Edward Cree wrote:
> >>  
> >> -	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
> >> +	} else if (reg->type == PTR_TO_STACK) {
> >> +		/* stack accesses must be at a fixed offset, so that we can
> >> +		 * determine what type of data were returned.
> >> +		 */
> >> +		if (reg->align.mask) {
> >> +			char tn_buf[48];
> >> +
> >> +			tn_strn(tn_buf, sizeof(tn_buf), reg->align);
> >> +			verbose("variable stack access align=%s off=%d size=%d",
> >> +				tn_buf, off, size);
> >> +			return -EACCES;
> > hmm. why this restriction?
> > I thought one of key points of the diff that ptr+var tracking logic
> > will now apply not only to map_value, but to stack_ptr as well?
> As the comment above it says, we need to determine what was returned:
>  was it STACK_MISC or STACK_SPILL, and if the latter, what kind of pointer
>  was spilled there?  See check_stack_read(), which I should probably
>  mention in the comment.

this piece of code is not only spill/fill, but normal ldx/stx stack access.
Consider the frequent pattern that many folks tried to do:
bpf_prog()
{
  char buf[64];
  int len;

  bpf_probe_read(&len, sizeof(len), kernel_ptr_to_filename_len);
  bpf_probe_read(buf, sizeof(buf), kernel_ptr_to_filename);
  buf[len & (sizeof(buf) - 1)] = 0;
...

currently above is not supported, but when 'buf' is a pointer to map value
it works fine. Allocating extra bpf map just to do such workaround
isn't nice and since this patch generalized map_value_adj with ptr_to_stack
we can support above code too.
We can check that all bytes of stack for this variable access were
initialized already.
In the example above it will happen by bpf_probe_read (in the verifier code):
        for (i = 0; i < meta.access_size; i++) {
                err = check_mem_access(env, meta.regno, i, BPF_B, BPF_WRITE, -1);
so at the time of
  buf[len & ..] = 0
we can check that 'stx' is within the range of inited stack and allow it.

> >> +	if (!err && size < BPF_REG_SIZE && value_regno >= 0 && t == BPF_READ &&
> >> +	    state->regs[value_regno].type == SCALAR_VALUE) {
> >> +		/* b/h/w load zero-extends, mark upper bits as known 0 */
> >> +		state->regs[value_regno].align.value &= (1ULL << (size * 8)) - 1;
> >> +		state->regs[value_regno].align.mask &= (1ULL << (size * 8)) - 1;
> > probably another helper from tnum.h is needed.
> I could rewrite as
>  reg->align = tn_and(reg->align, tn_const((1ULL << (size * 8)) - 1))

yep. that's perfect.

> >> +	/* Got here implies adding two SCALAR_VALUEs */
> >> +	if (WARN_ON_ONCE(ptr_reg)) {
> >> +		verbose("verifier internal error\n");
> >> +		return -EINVAL;
> > ...
> >> +	if (WARN_ON(!src_reg)) {
> >> +		verbose("verifier internal error\n");
> >> +		return -EINVAL;
> >>  	}
> > i'm lost with these bits.
> > Can you add a comment in what circumstances this can be hit
> > and what would be the consequences?
> It should be impossible to hit either of these cases.  If we let the
>  first through, we'd probably do invalid pointer arithmetic (e.g. we
>  could multiply a pointer by two and think we'd just multiplied the
>  variable offset).  As for the latter, we access through that pointer
>  so if it were NULL we would promptly oops.

I see. May be print verifier state in such warn_ons and make error
more human readable?

> >> +	case PTR_TO_MAP_VALUE_OR_NULL:
> > does this new state comparison logic helps? Do you have any numbers before/after in the number of insns it had to process for the tests in selftests ?
> I don't have the numbers, no (I'll try to collect them).  This rewrite was

Thanks. The main concern is that right now some complex programs
that cilium is using are close to the verifier complexity limit and these
big changes to amount of info recognized by the verifier can cause pruning
to be ineffective, so we need to test on big programs.
I think Daniel will be happy to test your next rev of the patches.
I'll test them as well.
At least 'insn_processed' from C code in tools/testing/selftests/bpf/
is a good estimate of how these changes affect pruning.

btw, I'm working on bpf_call support and also refactoring verifier
quite a bit, but my stuff is far from ready and I'll wait for
your rewrite to land first.
One of the things I'm working on is trying to get rid of state pruning
heuristics and use register+stack liveness information instead.
It's all experimental so far.
