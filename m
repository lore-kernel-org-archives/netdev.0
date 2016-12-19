From: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Mon, 19 Dec 2016 20:18:07 +0000
Message-ID: <CAGiyFdepunSduudt5ZWYaDN2inU_56TQn3dZcPibOXE+-JJXig@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6DB0242669@AcuExch.aculab.com> <20161219181040.25441.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=f403045ec68ed4e1590544089e52
Cc: ak@linux.intel.com, davem@davemloft.net, djb@cr.yp.to, ebiggers3@gmail.com,
	hannes@stressinduktion.org, Jason@zx2c4.com,
	kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, luto@amacapital.net, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, tytso@mit.edu, vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>, David.Laight@aculab.com, tom@herbertland.com
Return-path: <kernel-hardening-return-5706-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161219181040.25441.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

--f403045ec68ed4e1590544089e52
Content-Type: text/plain; charset=UTF-8

FTR, I agree that SipHash may benefit from security/performance
optimizations (there's always optimizations), but I'm note sure that it's
the right time/place to discuss it. Cryptanalysis is hard, and any major
change should be backed by a rigorous security analysis and/or security
proof. For example, the redundancy in the initial state prevents trivial
weaknesses that would occur if four key words were used (something I've
seen proposed in this thread).

In the paper at http://aumasson.jp/siphash/siphash.pdf we explain rationale
behind most of our design choices. The cryptanalysis paper at
https://eprint.iacr.org/2014/722.pdf analyzes differences propagations and
presents attacks on reduced versions of SipHash.


On Mon, Dec 19, 2016 at 7:10 PM George Spelvin <linux@sciencehorizons.net>
wrote:

> David Laight wrote:
> > From: George Spelvin
> ...
> >> uint32_t
> >> hsiphash24(char const *in, size_t len, uint32_t const key[2])
> >> {
> >>      uint32_t c = key[0];
> >>      uint32_t d = key[1];
> >>      uint32_t a =     0x6c796765 ^ 0x736f6d65;
> >>      uint32_t b = d ^ 0x74656462 ^ 0x646f7261;
>
> > I've not looked closely, but is that (in some sense) duplicating
> > the key length?
> > So you could set a = key[2] and b = key[3] and still have an
> > working hash - albeit not exactly the one specified.
>
> That's tempting, but not necessarily effective.  (A similar unsuccesful
> idea can be found in discussions of "DES with independent round keys".
> Or see the design discussion of Salsa20 and the constants in its input.)
>
> You can increase the key size, but that might not increase the *security*
> any.
>
> The big issue is that there are a *lot* of square root attack in
> cryptanalysis.  Because SipHash's state is twice the size of the key,
> such an attack will have the same complexity as key exhaustion and need
> not be considered.  To make a stronger security claim, you need to start
> working through them all and show that they don't apply.
>
> For SipHash in particular, an important property is asymmetry of the
> internal state.  That's what duplicating the key with XORs guarantees.
> If the two halves of the state end up identical, the mixing is much
> weaker.
>
> Now the probability of ending up in a "mirror state" is the square
> root of the state size (1 in 2^64 for HalfSipHash's 128-bit state),
> which is the same probability as guessing a key, so it's not a
> problem that has to be considered when making a 64-bit security claim.
>
> But if you want a higher security level, you have to think about
> what can happen.
>
> That said, I have been thinking very hard about
>
>         a = c ^ 0x48536970;     /* 'HSip' */
>         d = key[2];
>
> By guaranteeing that a and c are different, we get the desired
> asymmetry, and the XOR of b and d is determined by the first word of
> the message anyway, so this isn't weakening anything.
>
> 96 bits is far beyond the reach of any brute-force attack, and if a
> more sophisticated 64-bit attack exists, it's at least out of the reach
> of the script kiddies, and will almost certainly have a non-negligible
> constant factor and more limits in when it can be applied.
>
> > Is it worth using the 32bit hash for IP addresses on 64bit systems that
> > can't do misaligned accessed?
>
> Not a good idea.  To hash 64 bits of input:
>
> * Full SipHash has to do two loads, a shift, an or, and two rounds of
> mixing.
> * HalfSipHash has to do a load, two rounds, another load, and two more
> rounds.
>
> In other words, in addition to being less secure, it's half the speed.
>
> Also, what systems are you thinking about?  x86, ARMv8, PowerPC, and
> S390 (and ia64, if anyone cares) all handle unaligned loads.  MIPS has
> efficient support.  Alpha and HPPA are for retrocomputing fans, not
> people who care about performance.
>
> So you're down to SPARC.  Which conveniently has the same maintainer as
> the networking code, so I figure DaveM can take care of that himself. :-)
>

--f403045ec68ed4e1590544089e52
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">FTR, I agree that SipHash may benefit from security/perfor=
mance optimizations (there&#39;s always optimizations), but I&#39;m note su=
re that it&#39;s the right time/place to discuss it. Cryptanalysis is hard,=
 and any major change should be backed by a rigorous security analysis and/=
or security proof. For example, the redundancy in the initial state prevent=
s trivial weaknesses that would occur if four key words were used (somethin=
g I&#39;ve seen proposed in this thread).<div><div><br></div><div>In the pa=
per at <a href=3D"http://aumasson.jp/siphash/siphash.pdf">http://aumasson.j=
p/siphash/siphash.pdf</a>=C2=A0we explain rationale behind most of our desi=
gn choices. The cryptanalysis paper at <a href=3D"https://eprint.iacr.org/2=
014/722.pdf">https://eprint.iacr.org/2014/722.pdf</a>=C2=A0analyzes differe=
nces propagations and presents attacks on reduced versions of SipHash.</div=
><div><div><br></div></div></div></div><br><div class=3D"gmail_quote"><div =
dir=3D"ltr">On Mon, Dec 19, 2016 at 7:10 PM George Spelvin &lt;<a href=3D"m=
ailto:linux@sciencehorizons.net">linux@sciencehorizons.net</a>&gt; wrote:<b=
r></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex">David Laight wrote:<br class=3D"gmai=
l_msg">
&gt; From: George Spelvin<br class=3D"gmail_msg">
...<br class=3D"gmail_msg">
&gt;&gt; uint32_t<br class=3D"gmail_msg">
&gt;&gt; hsiphash24(char const *in, size_t len, uint32_t const key[2])<br c=
lass=3D"gmail_msg">
&gt;&gt; {<br class=3D"gmail_msg">
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 uint32_t c =3D key[0];<br class=3D"gmail_msg">
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 uint32_t d =3D key[1];<br class=3D"gmail_msg">
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 uint32_t a =3D=C2=A0 =C2=A0 =C2=A00x6c796765 ^=
 0x736f6d65;<br class=3D"gmail_msg">
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 uint32_t b =3D d ^ 0x74656462 ^ 0x646f7261;<br=
 class=3D"gmail_msg">
<br class=3D"gmail_msg">
&gt; I&#39;ve not looked closely, but is that (in some sense) duplicating<b=
r class=3D"gmail_msg">
&gt; the key length?<br class=3D"gmail_msg">
&gt; So you could set a =3D key[2] and b =3D key[3] and still have an<br cl=
ass=3D"gmail_msg">
&gt; working hash - albeit not exactly the one specified.<br class=3D"gmail=
_msg">
<br class=3D"gmail_msg">
That&#39;s tempting, but not necessarily effective.=C2=A0 (A similar unsucc=
esful<br class=3D"gmail_msg">
idea can be found in discussions of &quot;DES with independent round keys&q=
uot;.<br class=3D"gmail_msg">
Or see the design discussion of Salsa20 and the constants in its input.)<br=
 class=3D"gmail_msg">
<br class=3D"gmail_msg">
You can increase the key size, but that might not increase the *security*<b=
r class=3D"gmail_msg">
any.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
The big issue is that there are a *lot* of square root attack in<br class=
=3D"gmail_msg">
cryptanalysis.=C2=A0 Because SipHash&#39;s state is twice the size of the k=
ey,<br class=3D"gmail_msg">
such an attack will have the same complexity as key exhaustion and need<br =
class=3D"gmail_msg">
not be considered.=C2=A0 To make a stronger security claim, you need to sta=
rt<br class=3D"gmail_msg">
working through them all and show that they don&#39;t apply.<br class=3D"gm=
ail_msg">
<br class=3D"gmail_msg">
For SipHash in particular, an important property is asymmetry of the<br cla=
ss=3D"gmail_msg">
internal state.=C2=A0 That&#39;s what duplicating the key with XORs guarant=
ees.<br class=3D"gmail_msg">
If the two halves of the state end up identical, the mixing is much<br clas=
s=3D"gmail_msg">
weaker.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Now the probability of ending up in a &quot;mirror state&quot; is the squar=
e<br class=3D"gmail_msg">
root of the state size (1 in 2^64 for HalfSipHash&#39;s 128-bit state),<br =
class=3D"gmail_msg">
which is the same probability as guessing a key, so it&#39;s not a<br class=
=3D"gmail_msg">
problem that has to be considered when making a 64-bit security claim.<br c=
lass=3D"gmail_msg">
<br class=3D"gmail_msg">
But if you want a higher security level, you have to think about<br class=
=3D"gmail_msg">
what can happen.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
That said, I have been thinking very hard about<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 a =3D c ^ 0x48536970;=C2=A0 =C2=A0 =C2=A0/* &#3=
9;HSip&#39; */<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 d =3D key[2];<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
By guaranteeing that a and c are different, we get the desired<br class=3D"=
gmail_msg">
asymmetry, and the XOR of b and d is determined by the first word of<br cla=
ss=3D"gmail_msg">
the message anyway, so this isn&#39;t weakening anything.<br class=3D"gmail=
_msg">
<br class=3D"gmail_msg">
96 bits is far beyond the reach of any brute-force attack, and if a<br clas=
s=3D"gmail_msg">
more sophisticated 64-bit attack exists, it&#39;s at least out of the reach=
<br class=3D"gmail_msg">
of the script kiddies, and will almost certainly have a non-negligible<br c=
lass=3D"gmail_msg">
constant factor and more limits in when it can be applied.<br class=3D"gmai=
l_msg">
<br class=3D"gmail_msg">
&gt; Is it worth using the 32bit hash for IP addresses on 64bit systems tha=
t<br class=3D"gmail_msg">
&gt; can&#39;t do misaligned accessed?<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Not a good idea.=C2=A0 To hash 64 bits of input:<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
* Full SipHash has to do two loads, a shift, an or, and two rounds of mixin=
g.<br class=3D"gmail_msg">
* HalfSipHash has to do a load, two rounds, another load, and two more roun=
ds.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
In other words, in addition to being less secure, it&#39;s half the speed.<=
br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Also, what systems are you thinking about?=C2=A0 x86, ARMv8, PowerPC, and<b=
r class=3D"gmail_msg">
S390 (and ia64, if anyone cares) all handle unaligned loads.=C2=A0 MIPS has=
<br class=3D"gmail_msg">
efficient support.=C2=A0 Alpha and HPPA are for retrocomputing fans, not<br=
 class=3D"gmail_msg">
people who care about performance.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
So you&#39;re down to SPARC.=C2=A0 Which conveniently has the same maintain=
er as<br class=3D"gmail_msg">
the networking code, so I figure DaveM can take care of that himself. :-)<b=
r class=3D"gmail_msg">
</blockquote></div>

--f403045ec68ed4e1590544089e52--
