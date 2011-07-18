From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] Add error check to hex2bin().
Date: Mon, 18 Jul 2011 21:57:00 +0300
Message-ID: <CAHp75VcXNQKej_n4cOB8-gYDSL8MuGrv=Fs8=zdEKGp53DCtSA@mail.gmail.com>
References: <1310977597-9666-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<201107182041.EHB78622.VOFSHFMOOFtLJQ@I-love.SAKURA.ne.jp>
	<1310991796.3903.6.camel@smile>
	<201107182148.AGD21306.FOLtJVMSOOFQHF@I-love.SAKURA.ne.jp>
	<1311012230.3193.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-security-module@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311012230.3193.35.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2011 at 9:03 PM, Mimi Zohar <zohar@linux.vnet.ibm.com> =
wrote:
> On Mon, 2011-07-18 at 21:48 +0900, Tetsuo Handa wrote:
>> Currently, security/keys/ is the only user of hex2bin().
>> Should I keep hex2bin() unmodified in case of bad input?
>> If so, I'd like to make it as hex2bin_safe().
>
>> ----------------------------------------
>> [PATCH] Add error check to hex2bin().
>>
>> Since converting 2 hexadecimal letters into a byte with error checks=
 is
>> commonly used, we can replace multiple hex_to_bin() calls with singl=
e hex2bin()
>> call by changing hex2bin() to do error checks.
>>
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I=3Dlove.SAKURA.ne.jp>
>> ---
>> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
>> index 953352a..186e9fc 100644
>> --- a/include/linux/kernel.h
>> +++ b/include/linux/kernel.h
>> @@ -374,7 +374,7 @@ static inline char *pack_hex_byte(char *buf, u8 =
byte)
>> =C2=A0}
>>
>> =C2=A0extern int hex_to_bin(char ch);
>> -extern void hex2bin(u8 *dst, const char *src, size_t count);
>> +extern bool hex2bin(u8 *dst, const char *src, size_t count);
>>
>> =C2=A0/*
>> =C2=A0 * General tracing related utility functions - trace_printk(),
>> diff --git a/lib/hexdump.c b/lib/hexdump.c
>> index f5fe6ba..1524002 100644
>> --- a/lib/hexdump.c
>> +++ b/lib/hexdump.c
>> @@ -38,14 +38,22 @@ EXPORT_SYMBOL(hex_to_bin);
>> =C2=A0 * @dst: binary result
>> =C2=A0 * @src: ascii hexadecimal string
>> =C2=A0 * @count: result length
>> + *
>> + * Returns true on success, false in case of bad input.
>> =C2=A0 */
>> -void hex2bin(u8 *dst, const char *src, size_t count)
>> +bool hex2bin(u8 *dst, const char *src, size_t count)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 while (count--) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *dst =3D hex_to_bin(*src=
++) << 4;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *dst +=3D hex_to_bin(*sr=
c++);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dst++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int c =3D hex_to_bin(*sr=
c++);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int d;
>
> Missing blank line here.
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (c < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return false;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 d =3D hex_to_bin(*src++)=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (d < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return false;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *dst++ =3D (c << 4) | d;
>> =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 return true;
>> =C2=A0}
>> =C2=A0EXPORT_SYMBOL(hex2bin);
>
> We probably don't need to define a separate 'safe' function.
There is an opponent on any  approach. Although, small and fast error
route could be good.

>
> Instead of changing the existing code to short circuit out and return=
 a
> value, does only adding the return value work? =C2=A0Something like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool ret =3D true;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int c, d;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (count--) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c =3D hex_to_b=
in(*src++);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0d =3D hex_to_b=
in(*src++);
Here is a performance issue, yeah. The user prefers to know about an
error as soon as possible.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*dst++ =3D (c =
<< 4) | d;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (c < 0 || d=
 < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0ret =3D false;
The ret value is redundant, and here you continue to fill the result
array by something arbitrary (might be wrong data).

> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>
> thanks,
>
> Mimi
>
>> In message "Re: [PATCH] net: can: remove custom hex_to_bin()",
>> Andy Shevchenko wrote:
>> > On Mon, 2011-07-18 at 20:41 +0900, Tetsuo Handa wrote:
>> > > Andy Shevchenko wrote:
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0, dlc_pos++; i < cf.ca=
n_dlc; i++) {
>> > > > -
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp =3D asc=
2nibble(sl->rbuff[dlc_pos++]);
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (tmp > 0=
x0F)
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp =3D hex=
_to_bin(sl->rbuff[dlc_pos++]);
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (tmp < 0=
)
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 return;
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cf.dat=
a[i] =3D (tmp << 4);
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp =3D asc=
2nibble(sl->rbuff[dlc_pos++]);
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (tmp > 0=
x0F)
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp =3D hex=
_to_bin(sl->rbuff[dlc_pos++]);
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (tmp < 0=
)
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 return;
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cf.dat=
a[i] |=3D tmp;
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > >
>> > > What about changing
>> > >
>> > > =C2=A0 void hex2bin(u8 *dst, const char *src, size_t count)
>> > >
>> > > to
>> > >
>> > > =C2=A0 bool hex2bin(u8 *dst, const char *src, size_t count)
>> > >
>> > > in order to do error checks like
>> > >
>> > > bool hex2bin_with_validation(u8 *dst, const char *src, size_t co=
unt)
>> > > {
>> > > =C2=A0 while (count--) {
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int c =3D hex_to_bin(*src++);
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int d;
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (c < 0)
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 r=
eturn false;
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 d =3D hex_to_bin(*src++)
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (d < 0)
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 r=
eturn false;
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *dst++ =3D (c << 4) | d;
>> > > =C2=A0 }
>> > > =C2=A0 return true;
>> > > }
>> > >
>> > > and use hex2bin() rather than hex_to_bin()?
>> > Perhaps, good idea. Could you submit a patch?
>> >
>> > --
>> > Andy Shevchenko <andriy.shevchenko@linux.intel.com>
>> > Intel Finland Oy
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-secu=
rity-module" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.h=
tml
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>



--=20
With Best Regards,
Andy Shevchenko
