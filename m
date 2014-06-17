From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: mips:allmodconfig build failure in 3.16-rc1 due to bpf_jit code
Date: Tue, 17 Jun 2014 12:38:25 -0700
Message-ID: <CAMEtUuz=us+=ejHaOf+Mq19hZoNJ=-faB9y4f4NC90=9E6Ck7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Markos Chandras <Markos.Chandras@imgtec.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux MIPS Mailing List <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2014 at 4:21 AM, Daniel Borkmann <dborkman@redhat.com> =
wrote:
> On 06/17/2014 01:09 PM, Markos Chandras wrote:
> ...
>>
>> Thanks for these instructions. I will try them myself once I find so=
me
>>
>> time since I don't think bpf_jit for MIPS has ever been tested with =
all
>> the opcodes.
>
>
> Sounds great! If you find some tests are missing, please feel free to
> submit them as well via netdev.
>
> Best,
>
> Daniel

Daniel,

thank you for taking care of it so quickly :)
from the BPF perspective the fix looks good:
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Markos,

please do run the testsuite.
Doing quick code review of mips jit, it looks like:

- your version of pkt_type_offset() will work for little endian only.
  (we've recently fixed it in net/core/filter.c)

- vlan tag handling is incorrect, since it's missing shifts.
  classic BPF standard for vlan_tag_present has to return 1 or 0
  and not just emit_and(r_A, r_s0, VLAN_TAG_PRESENT, ctx);

- pr_warn("%s: Unhandled opcode: 0x%02x\n", __FILE__,
  is way too heavy, since when jit is on, unprivileged user can spam lo=
g.

- /* sa is 5-bits long */
  BUG_ON(sa >=3D BIT(5));
is wrong too. Malicious user can cause kernel crash=E2=80=A6
Also shift A>>=3D33 was always allowed by classic BPF checker, so
JITs have to silently do C-equivalent version of such shift.

- /* Determine if immediate is within the 16-bit signed range */
static inline bool is_range16(s32 imm)
{
        if (imm >=3D SBIT(15) || imm < -SBIT(15))
                return true;
the function name and comment are doing the opposite of
actual code, which makes harder to follow.

- the rest looks pretty good!

Also you'll get a lot more mileage out of mips jit if you use eBPF
instruction set as a base for JITing. You wouldn't need to worry
about vlan, pkt_type and other classic extensions. You'll get all
extensions for free, plus seccomp, tracing, etc.

Thanks
Alexei
