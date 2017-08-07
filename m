From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 00/12] bpf: rewrite value tracking in verifier
Date: Mon, 7 Aug 2017 15:21:32 +0100
Message-ID: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series simplifies alignment tracking, generalises bounds tracking and
 fixes some bounds-tracking bugs in the BPF verifier.  Pointer arithmetic on
 packet pointers, stack pointers, map value pointers and context pointers has
 been unified, and bounds on these pointers are only checked when the pointer
 is dereferenced.
Operations on pointers which destroy all relation to the original pointer
 (such as multiplies and shifts) are disallowed if !env->allow_ptr_leaks,
 otherwise they convert the pointer to an unknown scalar and feed it to the
 normal scalar arithmetic handling.
Pointer types have been unified with the corresponding adjusted-pointer types
 where those existed (e.g. PTR_TO_MAP_VALUE[_ADJ] or FRAME_PTR vs
 PTR_TO_STACK); similarly, CONST_IMM and UNKNOWN_VALUE have been unified into
 SCALAR_VALUE.
Pointer types (except CONST_PTR_TO_MAP, PTR_TO_MAP_VALUE_OR_NULL and
 PTR_TO_PACKET_END, which do not allow arithmetic) have a 'fixed offset' and
 a 'variable offset'; the former is used when e.g. adding an immediate or a
 known-constant register, as long as it does not overflow.  Otherwise the
 latter is used, and any operation creating a new variable offset creates a
 new 'id' (and, for PTR_TO_PACKET, clears the 'range').
SCALAR_VALUEs use the 'variable offset' fields to track the range of possible
 values; the 'fixed offset' should never be set on a scalar.

All tests of tools/testing/selftests/bpf/test_{verifier,align,progs} pass.

v5: folded the nfp fix into patch #1; don't modify src_reg when coercing it
 to 32 bits.

v4: removed some changes which were submitted separately to 'net'; altered
 some of the conditional-jump bounds handling in rebasing it on Daniel's
 changes.  Upped the complexity limit to 128k insns.

v3: added a few more tests; removed RFC tags.

v2: fixed nfp build, made test_align pass again and extended it with a few
 new tests (though still need to add more).

Edward Cree (12):
  bpf/verifier: rework value tracking
  bpf/verifier: track signed and unsigned min/max values
  bpf/verifier: more concise register state logs for constant var_off
  selftests/bpf: change test_verifier expectations
  selftests/bpf: rewrite test_align
  selftests/bpf: add a test to test_align
  selftests/bpf: add test for bogus operations on pointers
  selftests/bpf: don't try to access past MAX_PACKET_OFF in
    test_verifier
  selftests/bpf: add tests for subtraction & negative numbers
  selftests/bpf: variable offset negative tests
  Documentation: describe the new eBPF verifier value tracking behaviour
  bpf/verifier: increase complexity limit to 128k

 Documentation/networking/filter.txt               |  122 +-
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c |   24 +-
 include/linux/bpf.h                               |   34 +-
 include/linux/bpf_verifier.h                      |   55 +-
 include/linux/tnum.h                              |   81 +
 kernel/bpf/Makefile                               |    2 +-
 kernel/bpf/tnum.c                                 |  180 ++
 kernel/bpf/verifier.c                             | 2149 ++++++++++++---------
 tools/testing/selftests/bpf/test_align.c          |  462 ++++-
 tools/testing/selftests/bpf/test_verifier.c       |  389 ++--
 10 files changed, 2217 insertions(+), 1281 deletions(-)
 create mode 100644 include/linux/tnum.h
 create mode 100644 kernel/bpf/tnum.c
