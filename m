From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [RFC PATCH net-next 0/5] bpf: rewrite value tracking
	in verifier
Date: Wed, 7 Jun 2017 15:55:57 +0100
Message-ID: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
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

Patch 2/5 is rather on the big side, but since it changes the contents and
 semantics of a fairly central data structure, I'm not really sure how to go
 about splitting it up further without producing broken intermediate states.

With the changes in patch 5/5, all tools/testing/selftests/bpf/test_verifier
 tests pass.

Edward Cree (5):
  selftests/bpf: add test for mixed signed and unsigned bounds checks
  bpf/verifier: rework value tracking
  bpf/verifier: feed pointer-to-unknown-scalar casts into scalar ALU
    path
  bpf/verifier: track signed and unsigned min/max values
  selftests/bpf: change test_verifier expectations

 include/linux/bpf.h                         |   34 +-
 include/linux/bpf_verifier.h                |   56 +-
 include/linux/tnum.h                        |   58 +
 kernel/bpf/Makefile                         |    2 +-
 kernel/bpf/tnum.c                           |  163 +++
 kernel/bpf/verifier.c                       | 1852 ++++++++++++++++-----------
 tools/testing/selftests/bpf/test_verifier.c |  248 ++--
 7 files changed, 1482 insertions(+), 931 deletions(-)
 create mode 100644 include/linux/tnum.h
 create mode 100644 kernel/bpf/tnum.c
