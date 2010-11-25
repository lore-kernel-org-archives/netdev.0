From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] The new jhash implementation
Date: Thu, 25 Nov 2010 21:55:35 +0800
Message-ID: <AANLkTi=jqRY18Omv2Y2a1XjT-SH8W--wJ7A4y4PV1oT1@mail.gmail.com>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
 <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
 <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu> <1290692943.2858.303.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290692943.2858.303.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 25, 2010 at 9:49 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 25 novembre 2010 =E0 14:15 +0100, Jozsef Kadlecsik a =E9crit=
 :
>> The current jhash.h implements the lookup2() hash function by Bob Je=
nkins.
>> However, lookup2() is outdated as Bob wrote a new hash function call=
ed
>> lookup3(). The new hash function
>>
>> - mixes better than lookup2(): it passes the check that every input =
bit
>> =A0 changes every output bit 50% of the time, while lookup2() failed=
 it.
>> - performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% =
faster
>> =A0 than lookup2() depending on the key length.
>>
>> The patch replaces the lookup2() implementation of the 'jhash*'
>> functions with that of lookup3().
>>
>> You can read a longer comparison of the two and other hash functions=
 at
>> http://burtleburtle.net/bob/hash/doobs.html.
>>
>> Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
>> ---
>> =A0include/linux/jhash.h | =A0136 +++-------------------------------=
----------
>> =A0lib/Makefile =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
>> =A0lib/jhash.c =A0 =A0 =A0 =A0 =A0 | =A0153 ++++++++++++++++++++++++=
+++++++++++++++++++++++++
>> =A03 files changed, 162 insertions(+), 129 deletions(-)
>> =A0create mode 100644 lib/jhash.c
>>
> ...
>
> I agree jhash() should be not be inlined.
>
> I am not sure for other variants.
>
>> +u32 jhash(const void *key, u32 length, u32 initval)
>> +{
>> + =A0 =A0 u32 a, b, c;
>> + =A0 =A0 const u8 *k =3D key;
>> +
>> + =A0 =A0 /* Set up the internal state */
>> + =A0 =A0 a =3D b =3D c =3D JHASH_INITVAL + length + initval;
>> +
>> + =A0 =A0 /* All but the last block: affect some 32 bits of (a,b,c) =
*/
>> + =A0 =A0 while (length > 12) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 a +=3D k[0] + ((u32)k[1]<<8) + ((u32)k[2]<=
<16) + ((u32)k[3]<<24);
>
> disassembly code on x86_32 for the previous line :
>
> =A026: =A0 66 90 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xchg =A0 %ax,%ax
> =A028: =A0 0f b6 72 01 =A0 =A0 =A0 =A0 =A0 =A0 movzbl 0x1(%edx),%esi
> =A02c: =A0 0f b6 4a 02 =A0 =A0 =A0 =A0 =A0 =A0 movzbl 0x2(%edx),%ecx
> =A030: =A0 c1 e6 08 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shl =A0 =A0$0x8,%e=
si
> =A033: =A0 c1 e1 10 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shl =A0 =A0$0x10,%=
ecx
> =A036: =A0 8d 0c 0e =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lea =A0 =A0(%esi,%=
ecx,1),%ecx
> =A039: =A0 0f b6 32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0movzbl (%edx),%esi
> =A03c: =A0 8d 34 31 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lea =A0 =A0(%ecx,%=
esi,1),%esi
> =A03f: =A0 0f b6 4a 03 =A0 =A0 =A0 =A0 =A0 =A0 movzbl 0x3(%edx),%ecx
> =A043: =A0 c1 e1 18 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shl =A0 =A0$0x18,%=
ecx
> =A046: =A0 8d 0c 0e =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lea =A0 =A0(%esi,%=
ecx,1),%ecx
>
> or (CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy) :
>
> =A01b: =A0 0f b6 7b 01 =A0 =A0 =A0 =A0 =A0 =A0 movzbl 0x1(%ebx),%edi
> =A01f: =A0 c1 e7 08 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shl =A0 =A0$0x8,%e=
di
> =A022: =A0 89 7d f0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mov =A0 =A0%edi,-0=
x10(%ebp)
> =A025: =A0 0f b6 7b 02 =A0 =A0 =A0 =A0 =A0 =A0 movzbl 0x2(%ebx),%edi
> =A029: =A0 c1 e7 10 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shl =A0 =A0$0x10,%=
edi
> =A02c: =A0 03 7d f0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add =A0 =A0-0x10(%=
ebp),%edi
> =A02f: =A0 89 7d f0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mov =A0 =A0%edi,-0=
x10(%ebp)
> =A032: =A0 0f b6 3b =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0movzbl (%ebx),%edi
> =A035: =A0 03 7d f0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add =A0 =A0-0x10(%=
ebp),%edi
> =A038: =A0 89 7d f0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mov =A0 =A0%edi,-0=
x10(%ebp)
> =A03b: =A0 0f b6 7b 03 =A0 =A0 =A0 =A0 =A0 =A0 movzbl 0x3(%ebx),%edi
> =A03f: =A0 c1 e7 18 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shl =A0 =A0$0x18,%=
edi
> =A042: =A0 03 7d f0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add =A0 =A0-0x10(%=
ebp),%edi
>
>
> I suggest :
>
> #include <linux/unaligned/packed_struct.h>
> ...
> =A0 =A0 =A0 =A0a +=3D __get_unaligned_cpu32(k);
> =A0 =A0 =A0 =A0b +=3D __get_unaligned_cpu32(k+4);
> =A0 =A0 =A0 =A0c +=3D __get_unaligned_cpu32(k+8);
>
> Fits nicely in registers.
>

I think you mean get_unaligned_le32().

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
