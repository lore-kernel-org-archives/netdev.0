From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/12] bpf: rewrite value
	tracking in verifier
Date: Tue, 4 Jul 2017 20:22:02 +0100
Message-ID: <5fa61129-fa82-1607-3363-dfad86aecf1e@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<5953B436.6030506@iogearbox.net>
	<788035e1-1974-b48e-3008-d294194a8b05@solarflare.com>
	<595413AA.40502@iogearbox.net>
	<20170628213701.32krfuipzngsmt4k@ast-mbp>
	<91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
	<ff1ef3ef-71ef-4c23-ede4-b8caeac561ee@fb.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Alexei Starovoitov
	<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <ff1ef3ef-71ef-4c23-ede4-b8caeac561ee-b10kYP2dOMg@public.gmane.org>
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

On 30/06/17 19:15, Alexei Starovoitov wrote:
> On 6/30/17 9:44 AM, Edward Cree wrote:
>> I haven't measured the test_progs ones, because I *still* haven't gotten
>>  around to actually setting up a BPF toolchain (it doesn't help that I'm
>>  building everything on a test server that gets reimaged every night to
>>  run our nightly tests...).
>
> then you're missing a lot of tests then...
> installing llvm is trivial. On x86 there are plenty of pre-built
> packages that you can apt-get or yum.
> Dave had to compile llvm and gcc from source on sparc, so volatile test
> server isn't really an excuse to miss all these tests ;)
> especially for such large verifier change.
>
After two days' wrestling with clang's build system, I'm finally able to
 run test_progs, and all its tests pass as of the full patch series.
Here are the processed insn counts:

Program         net-next  short  full
test_pkt_access       78     79    79
test_xdp             386    411   407
test_l4lb           6438   4154  4154
test_tcp_estats      435    436   435
test_bpf_obj_id        8      8     8
test_pkt_md_access    41     42    42

"short" is the first 3 patches plus the 'roll back ptr&const' patch I
 posted on Friday.  "full" is the full 12-patch series.  "Program" is
 the function in test_progs.c.
I don't know why test_l4lb has to process _fewer_ insns with my patches;
 if anything I'm worrying that I may be incorrectly pruning branches.
(I've spotted a possible bug in that I'm not looking at 'id' which,
 although it doesn't have to match, if two regs in the old state had the
 same id as each other, then those regs in the new state have to have
 the same id as each other too.)
Also interesting is that going from "short" to "full" only decreases the
 counts, suggesting that the ptr&const and full negative/positive
 tracking isn't (at least for these test cases) costly.

-Ed
