From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/12] bpf: rewrite value
	tracking in verifier
Date: Fri, 30 Jun 2017 17:44:03 +0100
Message-ID: <91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<5953B436.6030506@iogearbox.net>
	<788035e1-1974-b48e-3008-d294194a8b05@solarflare.com>
	<595413AA.40502@iogearbox.net>
	<20170628213701.32krfuipzngsmt4k@ast-mbp>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann
	<daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20170628213701.32krfuipzngsmt4k@ast-mbp>
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

On 28/06/17 22:37, Alexei Starovoitov wrote:
> Increasing the limit is must have, since pruning suffered so much.
> Going from 53k to 76k is pretty substantial.
> What is the % increase for tests in selftests/ ?
When I tried to measure the test_verifier tests, they changed hardly at
 all, only a couple of percent iirc.  But that's with (a) only the
 accepted progs get measured, since rejected don't print the #insns line
 - and most of the tests in test_verifier are rejected; and (b) those
 test progs are pretty small, usually with only a couple of jumps and
 not much chance for pruning to occur.  So it's really not a great test
 case for pruning effectiveness.
I haven't measured the test_progs ones, because I *still* haven't gotten
 around to actually setting up a BPF toolchain (it doesn't help that I'm
 building everything on a test server that gets reimaged every night to
 run our nightly tests...).
> I think we need to pin point exactly the reason.
> Saying we just track more data is not enough.
> We've tried v2 set on our load balancer and also saw ~20% increase.
> I don't remember the absolute numbers.
> These jumps don't make me comfortable with these extra tracking.
> Can you try to roll back ptr&const and full negative/positive tracking
> and see whether it gets back to what we had before?
The ptr&const bit shouldn't be relevant unless your programs are actually
 doing that (i.e. ops on pointers other than +/-), which seems surprising.
 But if you really are, then it's not too hard to roll it back - just
 need to change how adjust_reg_min_max_vals() deals with EACCES.
For a version without full negative/positive tracking, just take the first
 3 patches; some of the selftests will fail but hopefully your progs will
 still be accepted.  If not, we can try jbacik's patch (off-list response
 to v2).  I will followup this email with a patch to apply on top of the
 first 3 that does that and rolls back ptr&const.
> If tnum is causing it that would be reasonable trade off to make,
> but if it's full neg/pos tracking that has no use today other than
> (the whole thing is cleaner) I would rather drop it then.
Well, the full neg/pos tracking was a result of needing to fix the bug I
 found with patch #1, and not wanting to confuse myself with the min/max
 range while doing my signed/unsigned tracking.  But if we can make it
 work with jbacik's approach of 'remember whether our current bounds came
 from a signed or an unsigned compare', then we can drop or delay the
 full neg/pos tracking unless/until pruning is sorted out.

-Ed
