From: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Thu, 15 Dec 2016 23:00:37 +0000
Message-ID: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
References: <20161215203003.31989-2-Jason@zx2c4.com> <20161215224224.21447.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=94eb2c1a19e89ac3f70543ba6cd1
Cc: djb@cr.yp.to
To: George Spelvin <linux@sciencehorizons.net>, ak@linux.intel.com, davem@davemloft.net,
	David.Laight@aculab.com, ebiggers3@gmail.com, hannes@stressinduktion.org,
	Jason@zx2c4.com, kernel-hardening@lists.openwall.com,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
	torvalds@linux-foundation.org, tytso@mit.edu, vegard.nossum@gmail.com
Return-path: <kernel-hardening-return-5610-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215224224.21447.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

--94eb2c1a19e89ac3f70543ba6cd1
Content-Type: text/plain; charset=UTF-8

If a halved version of SipHash can bring significant performance boost
(with 32b words instead of 64b words) with an acceptable security level
(64-bit enough?) then we may design such a version.

Regarding output size, are 64 bits sufficient?
On Thu, 15 Dec 2016 at 23:42, George Spelvin <linux@sciencehorizons.net>
wrote:

> > While SipHash is extremely fast for a cryptographically secure function,
> > it is likely a tiny bit slower than the insecure jhash, and so
> replacements
> > will be evaluated on a case-by-case basis based on whether or not the
> > difference in speed is negligible and whether or not the current jhash
> usage
> > poses a real security risk.
>
> To quantify that, jhash is 27 instructions per 12 bytes of input, with a
> dependency path length of 13 instructions.  (24/12 in __jash_mix, plus
> 3/1 for adding the input to the state.) The final add + __jhash_final
> is 24 instructions with a path length of 15, which is close enough for
> this handwaving.  Call it 18n instructions and 8n cycles for 8n bytes.
>
> SipHash (on a 64-bit machine) is 14 instructions with a dependency path
> length of 4 *per round*.  Two rounds per 8 bytes, plus plus two adds
> and one cycle per input word, plus four rounds to finish makes 30n+46
> instructions and 9n+16 cycles for 8n bytes.
>
> So *if* you have a 64-bit 4-way superscalar machine, it's not that much
> slower once it gets going, but the four-round finalization is quite
> noticeable for short inputs.
>
> For typical kernel input lengths "within a factor of 2" is
> probably more accurate than "a tiny bit".
>
> You lose a factor of 2 if you machine is 2-way or non-superscalar,
> and a second factor of 2 if it's a 32-bit machine.
>
> I mention this because there are a lot of home routers and other netwoek
> appliances running Linux on 32-bit ARM and MIPS processors.  For those,
> it's a factor of *eight*, which is a lot more than "a tiny bit".
>
> The real killer is if you don't have enough registers; SipHash performs
> horribly on i386 because it uses more state than i386 has registers.
>
> (If i386 performance is desired, you might ask Jean-Philippe for some
> rotate constants for a 32-bit variant with 64 bits of key.  Note that
> SipHash's security proof requires that key length + input length is
> strictly less than the state size, so for a 4x32-bit variant, while
> you could stretch the key length a little, you'd have a hard limit at
> 95 bits.)
>
>
> A second point, the final XOR in SipHash is either a (very minor) design
> mistake, or an opportunity for optimization, depending on how you look
> at it.  Look at the end of the function:
>
> >+      SIPROUND;
> >+      SIPROUND;
> >+      return (v0 ^ v1) ^ (v2 ^ v3);
>
> Expanding that out, you get:
> +       v0 += v1; v1 = rol64(v1, 13); v1 ^= v0; v0 = rol64(v0, 32);
> +       v2 += v3; v3 = rol64(v3, 16); v3 ^= v2;
> +       v0 += v3; v3 = rol64(v3, 21); v3 ^= v0;
> +       v2 += v1; v1 = rol64(v1, 17); v1 ^= v2; v2 = rol64(v2, 32);
> +       return v0 ^ v1 ^ v2 ^ v3;
>
> Since the final XOR includes both v0 and v3, it's undoing the "v3 ^= v0"
> two lines earlier, so the value of v0 doesn't matter after its XOR into
> v1 on line one.
>
> The final SIPROUND and return can then be optimized to
>
> +       v0 += v1; v1 = rol64(v1, 13); v1 ^= v0;
> +       v2 += v3; v3 = rol64(v3, 16); v3 ^= v2;
> +       v3 = rol64(v3, 21);
> +       v2 += v1; v1 = rol64(v1, 17); v1 ^= v2; v2 = rol64(v2, 32);
> +       return v1 ^ v2 ^ v3;
>
> A 32-bit implementation could further tweak the 4 instructions of
>         v1 ^= v2; v2 = rol64(v2, 32); v1 ^= v2;
>
> gcc 6.2.1 -O3 compiles it to basically:
>         v1.low ^= v2.low;
>         v1.high ^= v2.high;
>         v1.low ^= v2.high;
>         v1.high ^= v2.low;
> but it could be written as:
>         v2.low ^= v2.high;
>         v1.low ^= v2.low;
>         v1.high ^= v2.low;
>
> Alternatively, if it's for private use only (key not shared with other
> systems), a slightly stronger variant would "return v1 ^ v3;".
> (The final swap of v2 is dead code, but a compiler can spot that easily.)
>

--94eb2c1a19e89ac3f70543ba6cd1
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

If a halved version of SipHash can bring significant performance boost (wit=
h 32b words instead of 64b words) with an acceptable security level (64-bit=
 enough?) then we may design such a version.<br><br>Regarding output size, =
are 64 bits sufficient?<br><div class=3D"gmail_quote"><div dir=3D"ltr">On T=
hu, 15 Dec 2016 at 23:42, George Spelvin &lt;<a href=3D"mailto:linux@scienc=
ehorizons.net">linux@sciencehorizons.net</a>&gt; wrote:<br></div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex">&gt; While SipHash is extremely fast for a cryptograph=
ically secure function,<br class=3D"gmail_msg">
&gt; it is likely a tiny bit slower than the insecure jhash, and so replace=
ments<br class=3D"gmail_msg">
&gt; will be evaluated on a case-by-case basis based on whether or not the<=
br class=3D"gmail_msg">
&gt; difference in speed is negligible and whether or not the current jhash=
 usage<br class=3D"gmail_msg">
&gt; poses a real security risk.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
To quantify that, jhash is 27 instructions per 12 bytes of input, with a<br=
 class=3D"gmail_msg">
dependency path length of 13 instructions.=C2=A0 (24/12 in __jash_mix, plus=
<br class=3D"gmail_msg">
3/1 for adding the input to the state.) The final add + __jhash_final<br cl=
ass=3D"gmail_msg">
is 24 instructions with a path length of 15, which is close enough for<br c=
lass=3D"gmail_msg">
this handwaving.=C2=A0 Call it 18n instructions and 8n cycles for 8n bytes.=
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
SipHash (on a 64-bit machine) is 14 instructions with a dependency path<br =
class=3D"gmail_msg">
length of 4 *per round*.=C2=A0 Two rounds per 8 bytes, plus plus two adds<b=
r class=3D"gmail_msg">
and one cycle per input word, plus four rounds to finish makes 30n+46<br cl=
ass=3D"gmail_msg">
instructions and 9n+16 cycles for 8n bytes.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
So *if* you have a 64-bit 4-way superscalar machine, it&#39;s not that much=
<br class=3D"gmail_msg">
slower once it gets going, but the four-round finalization is quite<br clas=
s=3D"gmail_msg">
noticeable for short inputs.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
For typical kernel input lengths &quot;within a factor of 2&quot; is<br cla=
ss=3D"gmail_msg">
probably more accurate than &quot;a tiny bit&quot;.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
You lose a factor of 2 if you machine is 2-way or non-superscalar,<br class=
=3D"gmail_msg">
and a second factor of 2 if it&#39;s a 32-bit machine.<br class=3D"gmail_ms=
g">
<br class=3D"gmail_msg">
I mention this because there are a lot of home routers and other netwoek<br=
 class=3D"gmail_msg">
appliances running Linux on 32-bit ARM and MIPS processors.=C2=A0 For those=
,<br class=3D"gmail_msg">
it&#39;s a factor of *eight*, which is a lot more than &quot;a tiny bit&quo=
t;.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
The real killer is if you don&#39;t have enough registers; SipHash performs=
<br class=3D"gmail_msg">
horribly on i386 because it uses more state than i386 has registers.<br cla=
ss=3D"gmail_msg">
<br class=3D"gmail_msg">
(If i386 performance is desired, you might ask Jean-Philippe for some<br cl=
ass=3D"gmail_msg">
rotate constants for a 32-bit variant with 64 bits of key.=C2=A0 Note that<=
br class=3D"gmail_msg">
SipHash&#39;s security proof requires that key length + input length is<br =
class=3D"gmail_msg">
strictly less than the state size, so for a 4x32-bit variant, while<br clas=
s=3D"gmail_msg">
you could stretch the key length a little, you&#39;d have a hard limit at<b=
r class=3D"gmail_msg">
95 bits.)<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
A second point, the final XOR in SipHash is either a (very minor) design<br=
 class=3D"gmail_msg">
mistake, or an opportunity for optimization, depending on how you look<br c=
lass=3D"gmail_msg">
at it.=C2=A0 Look at the end of the function:<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
&gt;+=C2=A0 =C2=A0 =C2=A0 SIPROUND;<br class=3D"gmail_msg">
&gt;+=C2=A0 =C2=A0 =C2=A0 SIPROUND;<br class=3D"gmail_msg">
&gt;+=C2=A0 =C2=A0 =C2=A0 return (v0 ^ v1) ^ (v2 ^ v3);<br class=3D"gmail_m=
sg">
<br class=3D"gmail_msg">
Expanding that out, you get:<br class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v0 +=3D v1; v1 =3D rol64(v1, 13); v1 ^=3D v0; v=
0 =3D rol64(v0, 32);<br class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v2 +=3D v3; v3 =3D rol64(v3, 16); v3 ^=3D v2;<b=
r class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v0 +=3D v3; v3 =3D rol64(v3, 21); v3 ^=3D v0;<b=
r class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v2 +=3D v1; v1 =3D rol64(v1, 17); v1 ^=3D v2; v=
2 =3D rol64(v2, 32);<br class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return v0 ^ v1 ^ v2 ^ v3;<br class=3D"gmail_msg=
">
<br class=3D"gmail_msg">
Since the final XOR includes both v0 and v3, it&#39;s undoing the &quot;v3 =
^=3D v0&quot;<br class=3D"gmail_msg">
two lines earlier, so the value of v0 doesn&#39;t matter after its XOR into=
<br class=3D"gmail_msg">
v1 on line one.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
The final SIPROUND and return can then be optimized to<br class=3D"gmail_ms=
g">
<br class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v0 +=3D v1; v1 =3D rol64(v1, 13); v1 ^=3D v0;<b=
r class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v2 +=3D v3; v3 =3D rol64(v3, 16); v3 ^=3D v2;<b=
r class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v3 =3D rol64(v3, 21);<br class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0v2 +=3D v1; v1 =3D rol64(v1, 17); v1 ^=3D v2; v=
2 =3D rol64(v2, 32);<br class=3D"gmail_msg">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return v1 ^ v2 ^ v3;<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
A 32-bit implementation could further tweak the 4 instructions of<br class=
=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v1 ^=3D v2; v2 =3D rol64(v2, 32); v1 ^=3D v2;<b=
r class=3D"gmail_msg">
<br class=3D"gmail_msg">
gcc 6.2.1 -O3 compiles it to basically:<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v1.low ^=3D v2.low;<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v1.high ^=3D v2.high;<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v1.low ^=3D v2.high;<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v1.high ^=3D v2.low;<br class=3D"gmail_msg">
but it could be written as:<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v2.low ^=3D v2.high;<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v1.low ^=3D v2.low;<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 v1.high ^=3D v2.low;<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Alternatively, if it&#39;s for private use only (key not shared with other<=
br class=3D"gmail_msg">
systems), a slightly stronger variant would &quot;return v1 ^ v3;&quot;.<br=
 class=3D"gmail_msg">
(The final swap of v2 is dead code, but a compiler can spot that easily.)<b=
r class=3D"gmail_msg">
</blockquote></div>

--94eb2c1a19e89ac3f70543ba6cd1--
