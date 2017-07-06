From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v3 net-next 00/12] bpf: rewrite value tracking in verifier
Date: Thu, 6 Jul 2017 19:27:09 +0100
Message-ID: <54b95191-697d-6b15-ec39-438c85e08adc@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
 <5953B436.6030506@iogearbox.net>
 <788035e1-1974-b48e-3008-d294194a8b05@solarflare.com>
 <595413AA.40502@iogearbox.net> <20170628213701.32krfuipzngsmt4k@ast-mbp>
 <91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
 <ff1ef3ef-71ef-4c23-ede4-b8caeac561ee@fb.com>
 <5fa61129-fa82-1607-3363-dfad86aecf1e@solarflare.com>
 <595C1685.4060209@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <595C1685.4060209@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/07/17 23:28, Daniel Borkmann wrote:
> Have you tried with cilium's BPF code? The kernel selftests are quite small,
> so not really pushing processed insns too far. I can send you a BPF obj file
> if that's easier for testing.
Results from the next (in-progress) version of the patch series, with the
 'id' bugfix I mentioned in my other mail, and rebased onto an updated
 net-next (0e72582).  Numbers collected with:
# tc filter add dev lo egress bpf da obj /path/to/bpf_object.o sec $section verb 2>&1 | grep "processed" | awk -e 'BEGIN { N = 0; }' -e '{ N += $2; }' -e 'END { print N; }'

Program                net-next   short    full
bpf_lb_opt_-DLB_L3.o       4707    5872    6515
bpf_lb_opt_-DLB_L4.o       7662    8652    8976
bpf_lb_opt_-DUNKNOWN.o      727    2972    2960
bpf_lxc_opt_-DDROP_ALL.o  57725   85750   95412
bpf_lxc_opt_-DUNKNOWN.o   93676  134043  141706
bpf_netdev.o              14702   24665   24251
bpf_overlay.o              7303   10939   10999

Conclusion: the ptr&const and full-range min/max tracking make little
 difference (10% increase at most, sometimes a decrease); most of the
 increase comes from the basic "replace imm and aux_off/align with tnums"
 patch.
So based on what Alexei was saying earlier, it sounds like the answer for
 now is to up the limit (say to a round 128k), get this series merged,
 then start work on pruning optimisation so we can hopefully bring that
 limit back down again later.  Sound reasonable?

-Ed
