From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: =?UTF-8?B?5Zue5aSN77yaIFJlOiBbUEFUQ0ggbGludXgtbmV4dF0gbmV0L2Q=?=
 =?UTF-8?B?Y2NwL3RpbWVyLmM6IHVzZSAndTY0JyBpbnN0ZWFkIG9mICdzNjQnIHRvIGF2b2k=?=
 =?UTF-8?B?ZCBjb21waWxlcidzIHdhcm5pbmc=?=
Date: Fri, 23 May 2014 09:43:35 +0800
Message-ID: <537EA7C7.8040708@gmail.com>
References: <263613432.57393.1400803091663.JavaMail.root@bj-mail03.pku.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gerrit@erg.abdn.ac.uk, gxt@mprc.pku.edu.cn, dccp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?B?566h6Zuq5rab?= <gxt@pku.edu.cn>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <263613432.57393.1400803091663.JavaMail.root@bj-mail03.pku.edu.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2014 07:58 AM, =E7=AE=A1=E9=9B=AA=E6=B6=9B wrote:
>=20
> ----- David Miller <davem@davemloft.net> =E5=86=99=E9=81=93=EF=BC=9A
>> From: Chen Gang <gang.chen.5i5j@gmail.com>
>> Date: Wed, 21 May 2014 08:19:34 +0800
>>
>>> 'dccp_timestamp_seed' is initialized once by ktime_get_real() in
>>> dccp_timestamping_init(). It is always less than ktime_get_real()
>>> in dccp_timestamp().
>>>
>>> Then, ktime_us_delta() in dccp_timestamp() will always return posit=
ive
>>> number. So can use manual type cast to let compiler and do_div() kn=
ow
>>> about it to avoid warning.
>>>
>>> The related warning (with allmodconfig under unicore32):
>>>
>>>     CC [M]  net/dccp/timer.o
>>>   net/dccp/timer.c: In function =E2=80=98dccp_timestamp=E2=80=99:
>>>   net/dccp/timer.c:285: warning: comparison of distinct pointer typ=
es lacks a cast
>>>
>>>
>>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>>
>> Applied to net-next, thanks.
>>

Thank you for your work.

>> But that type check in include/asm-generic/div64.h is bogus, it shou=
ld
>> be checking sizeof(X) =3D=3D 8 rather than the type thing, it just w=
ants to
>> make sure that the value is 64-bit regardless of it's signedness.
>>
>> The arch local implementations do not do this, and that's why very f=
ew
>> other people notice this warning.
>=20
> Arch-dependent codes implement it with unsigned long long type.
> And, every warning should not be ignored.
>=20

Yeah, we have to let do_div() no touch (especially for 32-bit machine,
which the highest bit is checked). The related code in
"include/asm-generic/div64.h":

 23 #if BITS_PER_LONG =3D=3D 64
 24
 25 # define do_div(n,base) ({                                      \
 26         uint32_t __base =3D (base);                               \
 27         uint32_t __rem;                                         \
 28         __rem =3D ((uint64_t)(n)) % __base;                       \
 29         (n) =3D ((uint64_t)(n)) / __base;                         \
 30         __rem;                                                  \
 31  })
 32
 33 #elif BITS_PER_LONG =3D=3D 32
 34
 35 extern uint32_t __div64_32(uint64_t *dividend, uint32_t divisor);
 36
 37 /* The unnecessary pointer compare is there
 38  * to check for type safety (n must be 64bit)
 39  */
 40 # define do_div(n,base) ({                              \
 41         uint32_t __base =3D (base);                       \
 42         uint32_t __rem;                                 \
 43         (void)(((typeof((n)) *)0) =3D=3D ((uint64_t *)0));  \
 44         if (likely(((n) >> 32) =3D=3D 0)) {                 \
 45                 __rem =3D (uint32_t)(n) % __base;         \
 46                 (n) =3D (uint32_t)(n) / __base;           \
 47         } else                                          \
 48                 __rem =3D __div64_32(&(n), __base);       \
 49         __rem;                                          \
 50  })


And for division operation, architectures are signed/unsigned
sensitive, e.g. div_u64() and div_s64(), they are different.


Thanks.
--=20
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
