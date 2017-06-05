From: Y Song via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: More BPF verifier questions
Date: Mon, 5 Jun 2017 00:06:41 -0700
Message-ID: <CAH3MdRUasw4PL-Fq3tEbO=ByKGdCh4vLSF7EYZxtaDY0O24-Pg@mail.gmail.com>
References: <24a519bc-d403-f429-5d72-2a1d31edfbe7@solarflare.com>
Reply-To: Y Song <ys114321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <24a519bc-d403-f429-5d72-2a1d31edfbe7-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On Fri, Jun 2, 2017 at 7:42 AM, Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org> wrote:
> A couple of the tests in tools/testing/selftests/bpf/test_verifier.c seem to be bogus: Test "multiple registers share map_lookup_elem bad reg type" is supposed to
>  error with "R3 invalid mem access 'inv'", but from my reading of it, R3 gets
>  loaded with a map_value_or_null, that later gets null-checked (both directly
>  and - through R0 - indirectly), and finally stored through.  I don't see
>  what's supposed to make R3 become a bad pointer.

You are right. In this case,
r0 = bpf_map_lookup
r2 = r0
r3 = r0
r4 = r0
r5 = r0
if (r0 != 0)  <=== condition 1
  r1 = 1
if (r0 != 0)
  r1 = 2
if (r3 != 0)
  *r3 = 0
...

If (r0 != 0) if false, the current verifier marks r2/r3/r4/r5 as unknown value.
I guess here what you did to have precise value 0 helps and make verifier
complaint go away correctly.

> Test "helper access to variable memory: stack, bitwise AND + JMP, correct
>  bounds" is listed as expected to pass, but it passes zero in the 'size'
>  argument, an ARG_CONST_SIZE, to bpf_probe_read; I believe this should fail
>  (and with my WIP patch it does).

Probably a typo or mis-statement. "size" is not passed in with "zero", but
with an unknown value. Hence, it probably should fail.

      BPF_MOV64_IMM(BPF_REG_2, 16),
      BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
      BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
      BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 64),
      BPF_MOV64_IMM(BPF_REG_4, 0),
      BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
      BPF_MOV64_IMM(BPF_REG_3, 0),
      BPF_EMIT_CALL(BPF_FUNC_probe_read),


In kernel/bpf/verifier.c,

  } else if (arg_type == ARG_CONST_SIZE ||
       arg_type == ARG_CONST_SIZE_OR_ZERO) {
    expected_type = CONST_IMM;
    /* One exception. Allow UNKNOWN_VALUE registers when the
     * boundaries are known and don't cause unsafe memory accesses
     */
    if (type != UNKNOWN_VALUE && type != expected_type)
      goto err_type;

Maybe somebody can provide some historical context for this relaxation.
