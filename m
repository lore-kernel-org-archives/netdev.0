From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 02/12] bpf/verifier: rework
 value tracking
Date: Fri, 7 Jul 2017 14:48:27 +0100
Message-ID: <abd3c014-f33a-6e86-aead-be38697a2cec@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
	<E65DE75F-FC5F-41BC-9F7B-C03D324D8C6F@gmail.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Nadav Amit <nadav.amit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <E65DE75F-FC5F-41BC-9F7B-C03D324D8C6F-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On 06/07/17 22:21, Nadav Amit wrote:
> I find it a bit surprising that such huge changes that can affect security
> and robustness are performed in one patch.
In the first version of the series, this was two patches, with "feed
 pointer-to-unknown-scalar casts into scalar ALU path" split out from the rest;
 but that just caused a lot of code movement and confusing diffs, hence why I
 folded it into the same patch.
As for the rest of it, I'm not sure it can be split up: I'm changing the
 definition and semantics of a core data structure (struct bpf_reg_state)
 and I don't see any reasonable intermediate steps that would even compile.
For instance, replacing reg->imm (with its two meanings of 'known value' or
 'number of leading zero bits') with reg->var_off necessitates replacing all
 the arithmetic-handling code (e.g. evaluate_reg_imm_alu()).  But then
 var_off also replaces reg->aux_align[_off], so all the alignment-checking
 code has to change as well.  And changing what register state we track
 means that the pruning code (states_equal()) has to change too.
As it is, this patch leaves some selftests failing and it takes _another_
 big patch (4/12 "track signed and unsigned min/max values") to get them
 all to pass again.
> Personally, I cannot comprehend
> all of these changes. In addition, I think that it is valuable to describe
> in detail the bugs that the patch solves and when they were introduced.
Mostly this patch series isn't about fixing bugs (except those which were
 exposed when the changes caused some selftests to fail).  Instead, it's a
 combination of refactoring and unifying so that (for instance) the rules
 for pointer arithmetic and alignment checking are as similar as possible
 for all pointer types rather than having special-case rules for each type.
This allows many (correct) programs which the verifier will currently
 reject, and makes the overall description of the verifier's rules much
 shorter and simpler.  I have written a documentation patch explaining
 these rules, which the next version of the patch series will include.

The diff _is_ hard to read, I accept that; I think `diff` was too eager to
 interpolate and match single lines like '{' from completely unrelated
 functions.  It might be easier to just try applying the patch to a tree
 and then reading the result, rather than trying to interpret the diff.
> I can bring up some concerns regarding inconsistencies in offset checks and
> size, not spilling SCALAR and my wish not to limit packet size. However,
> when the patch is that big, I think it is useless.
Please, do describe these concerns; what inconsistencies do you see?
The not spilling scalars, and the limit to packet size, are retained
 from the existing code (is_spillable_regtype() and MAX_PACKET_OFF).
The latter is also needed for correctness in computing reg->range;
 if 'pkt_ptr + offset' could conceivably overflow, then the result
 could be < pkt_end without being a valid pointer into the packet.
We thus rely on the assumption that the packet pointer will never be
 within MAX_PACKET_OFF of the top of the address space.  (This
 assumption is, again, carried over from the existing verifier.)

-Ed
