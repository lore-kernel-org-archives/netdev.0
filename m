From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: mips:allmodconfig build failure in 3.16-rc1 due to bpf_jit code
Date: Wed, 18 Jun 2014 09:28:26 +0100
Message-ID: <53A14DAA.3070207@imgtec.com>
References: <CAMEtUuz=us+=ejHaOf+Mq19hZoNJ=-faB9y4f4NC90=9E6Ck7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guenter Roeck <linux@roeck-us.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux MIPS Mailing List <linux-mips@linux-mips.org>,
        Ralf Baechle <ralf@linux-mips.org>,
        "Network Development" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <ast@plumgrid.com>,
        Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <CAMEtUuz=us+=ejHaOf+Mq19hZoNJ=-faB9y4f4NC90=9E6Ck7g@mail.gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 06/17/2014 08:38 PM, Alexei Starovoitov wrote:
> On Tue, Jun 17, 2014 at 4:21 AM, Daniel Borkmann <dborkman@redhat.com=
> wrote:
>> On 06/17/2014 01:09 PM, Markos Chandras wrote:
>> ...
>>>
>>> Thanks for these instructions. I will try them myself once I find s=
ome
>>>
>>> time since I don't think bpf_jit for MIPS has ever been tested with=
 all
>>> the opcodes.
>>
>>
>> Sounds great! If you find some tests are missing, please feel free t=
o
>> submit them as well via netdev.
>>
>> Best,
>>
>> Daniel
>=20
> Daniel,
>=20
> thank you for taking care of it so quickly :)
> from the BPF perspective the fix looks good:
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>=20
> Markos,
>=20
> please do run the testsuite.
> Doing quick code review of mips jit, it looks like:
>=20
> - your version of pkt_type_offset() will work for little endian only.
>   (we've recently fixed it in net/core/filter.c)
>=20
> - vlan tag handling is incorrect, since it's missing shifts.
>   classic BPF standard for vlan_tag_present has to return 1 or 0
>   and not just emit_and(r_A, r_s0, VLAN_TAG_PRESENT, ctx);
>=20
> - pr_warn("%s: Unhandled opcode: 0x%02x\n", __FILE__,
>   is way too heavy, since when jit is on, unprivileged user can spam =
log.
>=20
> - /* sa is 5-bits long */
>   BUG_ON(sa >=3D BIT(5));
> is wrong too. Malicious user can cause kernel crash=E2=80=A6
> Also shift A>>=3D33 was always allowed by classic BPF checker, so
> JITs have to silently do C-equivalent version of such shift.
>=20
> - /* Determine if immediate is within the 16-bit signed range */
> static inline bool is_range16(s32 imm)
> {
>         if (imm >=3D SBIT(15) || imm < -SBIT(15))
>                 return true;
> the function name and comment are doing the opposite of
> actual code, which makes harder to follow.
>=20
> - the rest looks pretty good!
>=20
> Also you'll get a lot more mileage out of mips jit if you use eBPF
> instruction set as a base for JITing. You wouldn't need to worry
> about vlan, pkt_type and other classic extensions. You'll get all
> extensions for free, plus seccomp, tracing, etc.
>=20
> Thanks
> Alexei
>=20
Hi Alexei,

Thanks a lot for the feedback. I have already identified a few problems
which I have already fixed. I would like to move to eBPF but I can't
promise I can do it soon, so i think it's best to make sure that classi=
c
BPF works fine for 3.16 and then I will make my plans for eBPF.

--=20
markos
