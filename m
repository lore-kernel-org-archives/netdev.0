From: Y Song <ys114321@gmail.com>
Subject: Re: [iovisor-dev] [PATCH v3 net-next 00/12] bpf: rewrite value
 tracking in verifier
Date: Fri, 14 Jul 2017 13:03:26 -0700
Message-ID: <CAH3MdRUh-RHhntzvvwZwMuhqDd0O8kPyOqsFu5reJs8PU+Ss9w@mail.gmail.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        linux-kernel@vger.kernel.org, yhs@fb.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I did an experiment with one of our internal bpf programs.
The program has 1563 insns.

Without Edward's patch:
processed 13634 insns, stack depth 160

With Edward's patch:
processed 15807 insns, stack depth 160

So the number of processed insns regressed by roughly 16%.
Did anybody do any similar experiments to quantify the patch's
impact in verification performance (e.g., in terms of processed insns)?

On Tue, Jun 27, 2017 at 5:53 AM, Edward Cree via iovisor-dev
<iovisor-dev@lists.iovisor.org> wrote:
> This series simplifies alignment tracking, generalises bounds tracking and
>  fixes some bounds-tracking bugs in the BPF verifier.  Pointer arithmetic on
>  packet pointers, stack pointers, map value pointers and context pointers has
>  been unified, and bounds on these pointers are only checked when the pointer
>  is dereferenced.
> Operations on pointers which destroy all relation to the original pointer
>  (such as multiplies and shifts) are disallowed if !env->allow_ptr_leaks,
>  otherwise they convert the pointer to an unknown scalar and feed it to the
>  normal scalar arithmetic handling.
> Pointer types have been unified with the corresponding adjusted-pointer types
>  where those existed (e.g. PTR_TO_MAP_VALUE[_ADJ] or FRAME_PTR vs
>  PTR_TO_STACK); similarly, CONST_IMM and UNKNOWN_VALUE have been unified into
>  SCALAR_VALUE.
> Pointer types (except CONST_PTR_TO_MAP, PTR_TO_MAP_VALUE_OR_NULL and
>  PTR_TO_PACKET_END, which do not allow arithmetic) have a 'fixed offset' and
>  a 'variable offset'; the former is used when e.g. adding an immediate or a
>  known-constant register, as long as it does not overflow.  Otherwise the
>  latter is used, and any operation creating a new variable offset creates a
>  new 'id' (and, for PTR_TO_PACKET, clears the 'range').
> SCALAR_VALUEs use the 'variable offset' fields to track the range of possible
>  values; the 'fixed offset' should never be set on a scalar.
>
> As of patch 12/12, all tests of tools/testing/selftests/bpf/test_verifier
>  and tools/testing/selftests/bpf/test_align pass.
>
> v3: added a few more tests; removed RFC tags.
>
> v2: fixed nfp build, made test_align pass again and extended it with a few
>  new tests (though still need to add more).
>
> Edward Cree (12):
>   selftests/bpf: add test for mixed signed and unsigned bounds checks
>   bpf/verifier: rework value tracking
>   nfp: change bpf verifier hooks to match new verifier data structures
>   bpf/verifier: track signed and unsigned min/max values
>   bpf/verifier: more concise register state logs for constant var_off
>   selftests/bpf: change test_verifier expectations
>   selftests/bpf: rewrite test_align
>   selftests/bpf: add a test to test_align
>   selftests/bpf: add test for bogus operations on pointers
>   selftests/bpf: don't try to access past MAX_PACKET_OFF in
>     test_verifier
>   selftests/bpf: add tests for subtraction & negative numbers
>   selftests/bpf: variable offset negative tests
>
>  drivers/net/ethernet/netronome/nfp/bpf/verifier.c |   24 +-
>  include/linux/bpf.h                               |   34 +-
>  include/linux/bpf_verifier.h                      |   56 +-
>  include/linux/tnum.h                              |   81 +
>  kernel/bpf/Makefile                               |    2 +-
>  kernel/bpf/tnum.c                                 |  180 ++
>  kernel/bpf/verifier.c                             | 1943 ++++++++++++---------
>  tools/testing/selftests/bpf/test_align.c          |  462 ++++-
>  tools/testing/selftests/bpf/test_verifier.c       |  293 ++--
>  9 files changed, 2034 insertions(+), 1041 deletions(-)
>  create mode 100644 include/linux/tnum.h
>  create mode 100644 kernel/bpf/tnum.c
>
> _______________________________________________
> iovisor-dev mailing list
> iovisor-dev@lists.iovisor.org
> https://lists.iovisor.org/mailman/listinfo/iovisor-dev
