From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] bpf/verifier: when pruning a
 branch, ignore its write marks
Date: Tue, 22 Aug 2017 11:25:18 -0700
Message-ID: <7744ae71-cb68-4341-313b-aeebf87806fb@fb.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
	<d1a5b78a-8f5c-50d9-08a2-eb7c4829a478@solarflare.com>
	<0ba423e6-8629-37b1-b772-0734f1fb5489@fb.com>
	<97f3da2d-abb0-ba1f-07ca-ea426f30c7fb@solarflare.com>
	<9a8076d1-a88b-b0e8-3c47-969a022feb60@solarflare.com>
Reply-To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei
	Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann
	<daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <9a8076d1-a88b-b0e8-3c47-969a022feb60-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 8/22/17 11:03 AM, Edward Cree wrote:
> On 22/08/17 16:50, Edward Cree wrote:
>> On 22/08/17 16:24, Alexei Starovoitov wrote:
>>> Do you have a test case for this by any chance?
>> I think something like
>>     if (cond)
>>         r0=0;
>>     if (cond)
>>         r0=0;
>>     return r0;
>> might tickle the bug, but I'm not sure.
> It turns out that (cond) has to be constructed not to alter our knowledge
>  of whatever register we're testing, but apart from that, this works.
>     {
>         "liveness pruning and write screening",
>         .insns = {
>             /* Get an unknown value */
>             BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 0),
>             /* branch conditions teach us nothing about R2 */
>             BPF_JMP_IMM(BPF_JGE, BPF_REG_2, 0, 1),
>             BPF_MOV64_IMM(BPF_REG_0, 0),
>             BPF_JMP_IMM(BPF_JGE, BPF_REG_2, 0, 1),
>             BPF_MOV64_IMM(BPF_REG_0, 0),
>             BPF_EXIT_INSN(),
>         },
>         .errstr = "R0 !read_ok",
>         .result = REJECT,
>         .prog_type = BPF_PROG_TYPE_LWT_IN,
>     },
> This test fails on net-next, but passes with my patch.
> I'll include it in the next spin of the series.

nice. thanks for the test!
