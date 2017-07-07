From: Daniel Borkmann via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/12] bpf: rewrite value
	tracking in verifier
Date: Fri, 07 Jul 2017 11:14:27 +0200
Message-ID: <595F50F3.2030008@iogearbox.net>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<5953B436.6030506@iogearbox.net>
	<788035e1-1974-b48e-3008-d294194a8b05@solarflare.com>
	<595413AA.40502@iogearbox.net>
	<20170628213701.32krfuipzngsmt4k@ast-mbp>
	<91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
	<ff1ef3ef-71ef-4c23-ede4-b8caeac561ee@fb.com>
	<5fa61129-fa82-1607-3363-dfad86aecf1e@solarflare.com>
	<595C1685.4060209@iogearbox.net>
	<54b95191-697d-6b15-ec39-438c85e08adc@solarflare.com>
Reply-To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <54b95191-697d-6b15-ec39-438c85e08adc-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 07/06/2017 08:27 PM, Edward Cree wrote:
> On 04/07/17 23:28, Daniel Borkmann wrote:
>> Have you tried with cilium's BPF code? The kernel selftests are quite small,
>> so not really pushing processed insns too far. I can send you a BPF obj file
>> if that's easier for testing.
> Results from the next (in-progress) version of the patch series, with the
>   'id' bugfix I mentioned in my other mail, and rebased onto an updated
>   net-next (0e72582).  Numbers collected with:
> # tc filter add dev lo egress bpf da obj /path/to/bpf_object.o sec $section verb 2>&1 | grep "processed" | awk -e 'BEGIN { N = 0; }' -e '{ N += $2; }' -e 'END { print N; }'
>
> Program                net-next   short    full
> bpf_lb_opt_-DLB_L3.o       4707    5872    6515
> bpf_lb_opt_-DLB_L4.o       7662    8652    8976
> bpf_lb_opt_-DUNKNOWN.o      727    2972    2960
> bpf_lxc_opt_-DDROP_ALL.o  57725   85750   95412
> bpf_lxc_opt_-DUNKNOWN.o   93676  134043  141706
> bpf_netdev.o              14702   24665   24251
> bpf_overlay.o              7303   10939   10999
>
> Conclusion: the ptr&const and full-range min/max tracking make little
>   difference (10% increase at most, sometimes a decrease); most of the
>   increase comes from the basic "replace imm and aux_off/align with tnums"
>   patch.

Okay, thanks for the analysis, Edward.

> So based on what Alexei was saying earlier, it sounds like the answer for
>   now is to up the limit (say to a round 128k), get this series merged,
>   then start work on pruning optimisation so we can hopefully bring that
>   limit back down again later.  Sound reasonable?

But this means the bpf_lxc_* cases increase quite significantly,
arguably one of them is pretty close already, but the other one not
so much, meaning while 142k would shoot over the 128k target quite a
bit, the 95k is quite close to the point that it wouldn't take much,
say, few different optimizations from compiler, to hit the limit as
well eventually, something like 156k for the time being would seem a
more adequate raise perhaps that needs to be evaluated carefully
given the situation.
