From: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 08:08:57 +0000
Message-ID: <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161216034618.28276.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=94eb2c1a19e8a264470543c215c0
Cc: djb@cr.yp.to
To: George Spelvin <linux@sciencehorizons.net>, ak@linux.intel.com, davem@davemloft.net,
	David.Laight@aculab.com, ebiggers3@gmail.com, hannes@stressinduktion.org,
	Jason@zx2c4.com, kernel-hardening@lists.openwall.com,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
	torvalds@linux-foundation.org, tytso@mit.edu, vegard.nossum@gmail.com
Return-path: <kernel-hardening-return-5627-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161216034618.28276.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

--94eb2c1a19e8a264470543c215c0
Content-Type: text/plain; charset=UTF-8

Here's a tentative HalfSipHash:
https://github.com/veorq/SipHash/blob/halfsiphash/halfsiphash.c

Haven't computed the cycle count nor measured its speed.

On Fri, Dec 16, 2016 at 4:46 AM George Spelvin <linux@sciencehorizons.net>
wrote:

> Jean-Philippe Aumasson wrote:
> > If a halved version of SipHash can bring significant performance boost
> > (with 32b words instead of 64b words) with an acceptable security level
> > (64-bit enough?) then we may design such a version.
>
> It would be fairly significant, a 2x speed benefit on a lot of 32-bit
> machines.
>
> First is the fact that a 64-bit SipHash round on a generic 32-bit machine
> requires not twice as many instructions, but more than three.
>
> Consider the core SipHash quarter-round operation:
>         a += b;
>         b = rotate_left(b, k)
>         b ^= a
>
> The add and xor are equivalent between 32- and 64-bit rounds; twice the
> instructions do twice the work.  (There's a dependency via the carry
> bit between the two halves of the add, but it ends up not being on the
> critical path even in a superscalar implementation.)
>
> The problem is the rotates.  Although some particularly nice code is
> possible on 32-bit ARM due to its support for shift-and-xor operations,
> on a generic 32-bit CPU the rotate grows to 6 instructions with a 2-cycle
> dependency chain (more in practice because barrel shifters are large and
> even quad-issue CPUs can't do 4 shifts per cycle):
>
>         temp_lo = b_lo >> (32-k)
>         temp_hi = b_hi >> (32-k)
>         b_lo <<= k
>         b_hi <<= k
>         b_lo ^= temp_hi
>         b_hi ^= temp_lo
>
> The resultant instruction counts and (assuming wide issue)
> latencies are:
>
>         64-bit SipHash  "Half" SipHash
>         Inst.   Latency Inst.   Latency
>          10      3        3      2      Quarter round
>          40      6       12      4      Full round
>          80     12       24      8      Two rounds
>          82     13       26      9      Mix in one word
>          82     13       52     18      Mix in 64 bits
>         166     26       61     18      Four round finalization + final XOR
>         248     39      113     36      Hash 64 bits
>         330     52      165     54      Hash 128 bits
>         412     65      217     72      Hash 192 bits
>
> While the ideal latencies are actually better for the 64-bit algorithm,
> that requires an unrealistic 6+-wide superscalar implementation that's
> more than twice as wide as the 64-bit code requires (which is already
> optimized for quad-issue).  For a 1- or 2-wide processor, the instruction
> counts dominate, and not only does the 64-bit algorithm take 60% more
> time to mix in the same number of bytes, but the finalization rounds
> bring the ratio to 2:1 for small inputs.
>
> (And I haven't included the possible savings if the input size is an odd
> number of 32-bit words, such as networking applications which include
> the source/dest port numbers.)
>
>
> Notes on particular processors:
> - x86 can do a 64-bit rotate in 3 instructions and 2 cycles using
>   the SHLD/SHRD instructions instead:
>         movl    %b_hi, %temp
>         shldl   $k, %b_lo, %b_hi
>         shldl   $k, %temp, %b_lo
>   ... but as I mentioned the problem is registers.  SipHash needs 8 32-bit
>   words plus at least one temporary, and 32-bit x86 has only 7 available.
>   (And compilers can rarely manage to keep more than 6 of them busy.)
> - 64-bit SipHash is particularly efficient on 32-bit ARM due to its
>   support for shift-and-op instructions.  The 64-bit shift and following
>   xor can be done in 4 instructions.  So the only benefit is from the
>   reduced finalization.
> - Double-width adds cost a little more on CPUs like MIPS and RISC-V without
>   condition codes.
> - Certain particularly crappy uClinux processors with slow shifts
>   (68000, anyone?) really suffer from extra shifts.
>
> One *weakly* requested feature: It might simplify some programming
> interfaces if we could use the same key for multiple hash tables with a
> 1-word "tweak" (e.g. pointer to the hash table, so it could be assumed
> non-zero if that helped) to make distinct functions.  That would let us
> more safely use a global key for multiple small hash tables without the
> need to add code to generate and store key material for each place that
> an unkeyed hash is replaced.
>

--94eb2c1a19e8a264470543c215c0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Here&#39;s a tentative HalfSipHash:=C2=A0<a href=3D"https:=
//github.com/veorq/SipHash/blob/halfsiphash/halfsiphash.c">https://github.c=
om/veorq/SipHash/blob/halfsiphash/halfsiphash.c</a><div><br></div><div>Have=
n&#39;t computed the cycle count nor measured its speed.</div></div><br><di=
v class=3D"gmail_quote"><div dir=3D"ltr">On Fri, Dec 16, 2016 at 4:46 AM Ge=
orge Spelvin &lt;<a href=3D"mailto:linux@sciencehorizons.net">linux@science=
horizons.net</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Jean-Ph=
ilippe Aumasson wrote:<br class=3D"gmail_msg">
&gt; If a halved version of SipHash can bring significant performance boost=
<br class=3D"gmail_msg">
&gt; (with 32b words instead of 64b words) with an acceptable security leve=
l<br class=3D"gmail_msg">
&gt; (64-bit enough?) then we may design such a version.<br class=3D"gmail_=
msg">
<br class=3D"gmail_msg">
It would be fairly significant, a 2x speed benefit on a lot of 32-bit<br cl=
ass=3D"gmail_msg">
machines.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
First is the fact that a 64-bit SipHash round on a generic 32-bit machine<b=
r class=3D"gmail_msg">
requires not twice as many instructions, but more than three.<br class=3D"g=
mail_msg">
<br class=3D"gmail_msg">
Consider the core SipHash quarter-round operation:<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 a +=3D b;<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 b =3D rotate_left(b, k)<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 b ^=3D a<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
The add and xor are equivalent between 32- and 64-bit rounds; twice the<br =
class=3D"gmail_msg">
instructions do twice the work.=C2=A0 (There&#39;s a dependency via the car=
ry<br class=3D"gmail_msg">
bit between the two halves of the add, but it ends up not being on the<br c=
lass=3D"gmail_msg">
critical path even in a superscalar implementation.)<br class=3D"gmail_msg"=
>
<br class=3D"gmail_msg">
The problem is the rotates.=C2=A0 Although some particularly nice code is<b=
r class=3D"gmail_msg">
possible on 32-bit ARM due to its support for shift-and-xor operations,<br =
class=3D"gmail_msg">
on a generic 32-bit CPU the rotate grows to 6 instructions with a 2-cycle<b=
r class=3D"gmail_msg">
dependency chain (more in practice because barrel shifters are large and<br=
 class=3D"gmail_msg">
even quad-issue CPUs can&#39;t do 4 shifts per cycle):<br class=3D"gmail_ms=
g">
<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 temp_lo =3D b_lo &gt;&gt; (32-k)<br class=3D"gm=
ail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 temp_hi =3D b_hi &gt;&gt; (32-k)<br class=3D"gm=
ail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 b_lo &lt;&lt;=3D k<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 b_hi &lt;&lt;=3D k<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 b_lo ^=3D temp_hi<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 b_hi ^=3D temp_lo<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
The resultant instruction counts and (assuming wide issue)<br class=3D"gmai=
l_msg">
latencies are:<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 64-bit SipHash=C2=A0 &quot;Half&quot; SipHash<b=
r class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Inst.=C2=A0 =C2=A0Latency Inst.=C2=A0 =C2=A0Lat=
ency<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A010=C2=A0 =C2=A0 =C2=A0 3=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 3=C2=A0 =C2=A0 =C2=A0 2=C2=A0 =C2=A0 =C2=A0 Quarter round<br cla=
ss=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A040=C2=A0 =C2=A0 =C2=A0 6=C2=A0 =C2=A0 =C2=
=A0 =C2=A012=C2=A0 =C2=A0 =C2=A0 4=C2=A0 =C2=A0 =C2=A0 Full round<br class=
=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A080=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=
=A0 =C2=A024=C2=A0 =C2=A0 =C2=A0 8=C2=A0 =C2=A0 =C2=A0 Two rounds<br class=
=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A082=C2=A0 =C2=A0 =C2=A013=C2=A0 =C2=A0 =C2=
=A0 =C2=A026=C2=A0 =C2=A0 =C2=A0 9=C2=A0 =C2=A0 =C2=A0 Mix in one word<br c=
lass=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A082=C2=A0 =C2=A0 =C2=A013=C2=A0 =C2=A0 =C2=
=A0 =C2=A052=C2=A0 =C2=A0 =C2=A018=C2=A0 =C2=A0 =C2=A0 Mix in 64 bits<br cl=
ass=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 166=C2=A0 =C2=A0 =C2=A026=C2=A0 =C2=A0 =C2=A0 =
=C2=A061=C2=A0 =C2=A0 =C2=A018=C2=A0 =C2=A0 =C2=A0 Four round finalization =
+ final XOR<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 248=C2=A0 =C2=A0 =C2=A039=C2=A0 =C2=A0 =C2=A0 1=
13=C2=A0 =C2=A0 =C2=A036=C2=A0 =C2=A0 =C2=A0 Hash 64 bits<br class=3D"gmail=
_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 330=C2=A0 =C2=A0 =C2=A052=C2=A0 =C2=A0 =C2=A0 1=
65=C2=A0 =C2=A0 =C2=A054=C2=A0 =C2=A0 =C2=A0 Hash 128 bits<br class=3D"gmai=
l_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 412=C2=A0 =C2=A0 =C2=A065=C2=A0 =C2=A0 =C2=A0 2=
17=C2=A0 =C2=A0 =C2=A072=C2=A0 =C2=A0 =C2=A0 Hash 192 bits<br class=3D"gmai=
l_msg">
<br class=3D"gmail_msg">
While the ideal latencies are actually better for the 64-bit algorithm,<br =
class=3D"gmail_msg">
that requires an unrealistic 6+-wide superscalar implementation that&#39;s<=
br class=3D"gmail_msg">
more than twice as wide as the 64-bit code requires (which is already<br cl=
ass=3D"gmail_msg">
optimized for quad-issue).=C2=A0 For a 1- or 2-wide processor, the instruct=
ion<br class=3D"gmail_msg">
counts dominate, and not only does the 64-bit algorithm take 60% more<br cl=
ass=3D"gmail_msg">
time to mix in the same number of bytes, but the finalization rounds<br cla=
ss=3D"gmail_msg">
bring the ratio to 2:1 for small inputs.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
(And I haven&#39;t included the possible savings if the input size is an od=
d<br class=3D"gmail_msg">
number of 32-bit words, such as networking applications which include<br cl=
ass=3D"gmail_msg">
the source/dest port numbers.)<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Notes on particular processors:<br class=3D"gmail_msg">
- x86 can do a 64-bit rotate in 3 instructions and 2 cycles using<br class=
=3D"gmail_msg">
=C2=A0 the SHLD/SHRD instructions instead:<br class=3D"gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 movl=C2=A0 =C2=A0 %b_hi, %temp<br class=3D"gmai=
l_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 shldl=C2=A0 =C2=A0$k, %b_lo, %b_hi<br class=3D"=
gmail_msg">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 shldl=C2=A0 =C2=A0$k, %temp, %b_lo<br class=3D"=
gmail_msg">
=C2=A0 ... but as I mentioned the problem is registers.=C2=A0 SipHash needs=
 8 32-bit<br class=3D"gmail_msg">
=C2=A0 words plus at least one temporary, and 32-bit x86 has only 7 availab=
le.<br class=3D"gmail_msg">
=C2=A0 (And compilers can rarely manage to keep more than 6 of them busy.)<=
br class=3D"gmail_msg">
- 64-bit SipHash is particularly efficient on 32-bit ARM due to its<br clas=
s=3D"gmail_msg">
=C2=A0 support for shift-and-op instructions.=C2=A0 The 64-bit shift and fo=
llowing<br class=3D"gmail_msg">
=C2=A0 xor can be done in 4 instructions.=C2=A0 So the only benefit is from=
 the<br class=3D"gmail_msg">
=C2=A0 reduced finalization.<br class=3D"gmail_msg">
- Double-width adds cost a little more on CPUs like MIPS and RISC-V without=
<br class=3D"gmail_msg">
=C2=A0 condition codes.<br class=3D"gmail_msg">
- Certain particularly crappy uClinux processors with slow shifts<br class=
=3D"gmail_msg">
=C2=A0 (68000, anyone?) really suffer from extra shifts.<br class=3D"gmail_=
msg">
<br class=3D"gmail_msg">
One *weakly* requested feature: It might simplify some programming<br class=
=3D"gmail_msg">
interfaces if we could use the same key for multiple hash tables with a<br =
class=3D"gmail_msg">
1-word &quot;tweak&quot; (e.g. pointer to the hash table, so it could be as=
sumed<br class=3D"gmail_msg">
non-zero if that helped) to make distinct functions.=C2=A0 That would let u=
s<br class=3D"gmail_msg">
more safely use a global key for multiple small hash tables without the<br =
class=3D"gmail_msg">
need to add code to generate and store key material for each place that<br =
class=3D"gmail_msg">
an unkeyed hash is replaced.<br class=3D"gmail_msg">
</blockquote></div>

--94eb2c1a19e8a264470543c215c0--
