From: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Subject: Re: HalfSipHash Acceptable Usage
Date: Mon, 19 Dec 2016 20:49:21 +0000
Message-ID: <CAGiyFdduUNSGq24zfsk0ZU=hnOCmewAw8vw6XvDoS-3f+3UPKQ@mail.gmail.com>
References: <CAHmME9rPmH=wP_eHYopt8ZPG9TSN7bos3fGOuqKL2HjQW-2SWA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a11401e848308690544090e36
Cc: "Theodore Ts'o" <tytso@mit.edu>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	LKML <linux-kernel@vger.kernel.org>, Eric Biggers <ebiggers3@gmail.com>,
	"Daniel J . Bernstein" <djb@cr.yp.to>, David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@linux.intel.com>,
	George Spelvin <linux@sciencehorizons.net>, kernel-hardening@lists.openwall.com,
	Andy Lutomirski <luto@amacapital.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
	Vegard Nossum <vegard.nossum@gmail.com>, Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5707-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9rPmH=wP_eHYopt8ZPG9TSN7bos3fGOuqKL2HjQW-2SWA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

--001a11401e848308690544090e36
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 19, 2016 at 6:32 PM Jason A. Donenfeld <Jason@zx2c4.com> wrote:

> Hi JP,
>
> With the threads getting confusing, I've been urged to try and keep
> the topics and threads more closely constrained. Here's where we're
> at, and here's the current pressing security concern. It'd be helpful
> to have a definitive statement on what you think is best, so we can
> just build on top of that, instead of getting lost in the chorus of
> opinions.
>
> 1) Anything that requires actual long-term security will use
> SipHash2-4, with the 64-bit output and the 128-bit key. This includes
> things like TCP sequence numbers. This seems pretty uncontroversial to
> me. Seem okay to you?
>


Right, since 2012 when we published SipHash many cryptanalysts attempted to
break SipHash-2-4 with a 128-bit key, for various notions of "break", and
nothing worth worrying was ever found. I'm totally confident that
SipHash-2-4 will live up to its security promises.

Don't use something weaker for things like TCP sequence numbers or RNGs.
Use SipHash2-4 for those. That is the correct choice.


>
> 2) People seem to want something competitive, performance-wise, with
> jhash if it's going to replace jhash. The kernel community
> instinctively pushes back on anything that could harm performance,
> especially in networking and in critical data structures, so there
> have been some calls for something faster than SipHash. So, questions
> regarding this:
>
>
No free lunch I guess: either go with a cryptographically secure,
time-proved keyed hash such as SipHash, or go with some simpler hash deemed
secure cos its designer can't break it :) #DontRollYourOwnCrypto

2a) George thinks that HalfSipHash on 32-bit systems will have roughly
> comparable speed as SipHash on 64-bit systems, so the idea would be to
> use HalfSipHash on 32-bit systems' hash tables and SipHash on 64-bit
> systems' hash tables. The big obvious question is: does HalfSipHash
> have a sufficient security margin for hashtable usage and hashtable
> attacks? I'm not wondering about the security margin for other usages,
> but just of the hashtable usage. In your opinion, does HalfSipHash cut
> it?
>

HalfSipHash takes its core function from Chaskey and uses the same
construction as SipHash, so it *should* be secure. Nonetheless it hasn't
received the same amount of attention as 64-bit SipHash did. So I'm less
confident about its security than about SipHash's, but it obviously
inspires a lot more confidence than non-crypto hashes.

Too, HalfSipHash only has a 64-bit key, not a 128-bit key like SipHash, so
only use this as a mitigation for hash-flooding attacks, where the output
of the hash function is never directly shown to the caller. Do not use
HalfSipHash for TCP sequence numbers or RNGs.



>
> 2b) While I certainly wouldn't consider making the use case in
> question (1) employ a weaker function, for this question (2), there
> has been some discussion about using HalfSipHash1-3 (or SipHash1-3 on
> 64-bit) instead of 2-4. So, the same question is therefore posed:
> would using HalfSipHash1-3 give a sufficient security margin for
> hashtable usage and hashtable attacks?
>

My educated guess is that yes, it will, but that it may not withhold
cryptanalysis as a pseudorandom function (PRF). For example I wouldn't be
surprised if there were a "distinguishing attack" that detects non-random
patterns in HalfSipHash-1-3's output. But most of the non-crypto hashes
I've seen have obvious distinguishing attacks. So the upshot is that HSH
will get you better security that AnyWeakHash even with 1 & 3 rounds.

So, if you're willing to compromise on security, but still want something
not completely unreasonable, you might be able to get away with using
HalfSipHash1-3 as a replacement for jhash=E2=80=94in circumstances where th=
e output
of the hash function is kept secret=E2=80=94in order to mitigate hash-flood=
ing
attacks.



>
> My plan is essentially to implement things according to your security
> recommendation. The thread started with me pushing a heavy duty
> security solution -- SipHash2-4 -- for _everything_. I've received
> understandable push back on that notion for certain use cases. So now
> I'm trying to discover what the most acceptable compromise is. Your
> answers on (2a) and (2b) will direct that compromise.
>
> Thanks again,
> Jason


>

--001a11401e848308690544090e36
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote"><div dir=3D"ltr">On Mon, De=
c 19, 2016 at 6:32 PM Jason A. Donenfeld &lt;<a href=3D"mailto:Jason@zx2c4.=
com">Jason@zx2c4.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quo=
te" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204=
);padding-left:1ex">Hi JP,<br class=3D"gmail_msg"><br class=3D"gmail_msg">W=
ith the threads getting confusing, I&#39;ve been urged to try and keep<br c=
lass=3D"gmail_msg">the topics and threads more closely constrained. Here&#3=
9;s where we&#39;re<br class=3D"gmail_msg">at, and here&#39;s the current p=
ressing security concern. It&#39;d be helpful<br class=3D"gmail_msg">to hav=
e a definitive statement on what you think is best, so we can<br class=3D"g=
mail_msg">just build on top of that, instead of getting lost in the chorus =
of<br class=3D"gmail_msg">opinions.<br class=3D"gmail_msg"><br class=3D"gma=
il_msg">1) Anything that requires actual long-term security will use<br cla=
ss=3D"gmail_msg">SipHash2-4, with the 64-bit output and the 128-bit key. Th=
is includes<br class=3D"gmail_msg">things like TCP sequence numbers. This s=
eems pretty uncontroversial to<br class=3D"gmail_msg">me. Seem okay to you?=
<br class=3D"gmail_msg"></blockquote><br><br>Right, since 2012 when we publ=
ished SipHash many cryptanalysts attempted to break SipHash-2-4 with a 128-=
bit key, for various notions of &quot;break&quot;, and nothing worth worryi=
ng was ever found. I&#39;m totally confident that SipHash-2-4 will live up =
to its security promises.<span class=3D"inbox-inbox-Apple-converted-space">=
=C2=A0</span><br><br>Don&#39;t use something weaker for things like TCP seq=
uence numbers or RNGs. Use SipHash2-4 for those. That is the correct choice=
.<div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px=
 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><br cla=
ss=3D"gmail_msg">2) People seem to want something competitive, performance-=
wise, with<br class=3D"gmail_msg">jhash if it&#39;s going to replace jhash.=
 The kernel community<br class=3D"gmail_msg">instinctively pushes back on a=
nything that could harm performance,<br class=3D"gmail_msg">especially in n=
etworking and in critical data structures, so there<br class=3D"gmail_msg">=
have been some calls for something faster than SipHash. So, questions<br cl=
ass=3D"gmail_msg">regarding this:<br class=3D"gmail_msg"><br class=3D"gmail=
_msg"></blockquote><div><br></div>No free lunch I guess: either go with a c=
ryptographically secure, time-proved keyed hash such as SipHash, or go with=
 some simpler hash deemed secure cos its designer can&#39;t break it :) #Do=
ntRollYourOwnCrypto<div><br></div><blockquote class=3D"gmail_quote" style=
=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding=
-left:1ex">2a) George thinks that HalfSipHash on 32-bit systems will have r=
oughly<br class=3D"gmail_msg">comparable speed as SipHash on 64-bit systems=
, so the idea would be to<br class=3D"gmail_msg">use HalfSipHash on 32-bit =
systems&#39; hash tables and SipHash on 64-bit<br class=3D"gmail_msg">syste=
ms&#39; hash tables. The big obvious question is: does HalfSipHash<br class=
=3D"gmail_msg">have a sufficient security margin for hashtable usage and ha=
shtable<br class=3D"gmail_msg">attacks? I&#39;m not wondering about the sec=
urity margin for other usages,<br class=3D"gmail_msg">but just of the hasht=
able usage. In your opinion, does HalfSipHash cut<br class=3D"gmail_msg">it=
?<br class=3D"gmail_msg"></blockquote><div><br></div>HalfSipHash takes its =
core function from Chaskey and uses the same construction as SipHash, so it=
 *should* be secure. Nonetheless it hasn&#39;t received the same amount of =
attention as 64-bit SipHash did. So I&#39;m less confident about its securi=
ty than about SipHash&#39;s, but it obviously inspires a lot more confidenc=
e than non-crypto hashes.<span class=3D"inbox-inbox-Apple-converted-space">=
=C2=A0</span><br><br>Too, HalfSipHash only has a 64-bit key, not a 128-bit =
key like SipHash, so only use this as a mitigation for hash-flooding attack=
s, where the output of the hash function is never directly shown to the cal=
ler. Do not use HalfSipHash for TCP sequence numbers or RNGs.<div><br></div=
><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px=
 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><br cla=
ss=3D"gmail_msg">2b) While I certainly wouldn&#39;t consider making the use=
 case in<br class=3D"gmail_msg">question (1) employ a weaker function, for =
this question (2), there<br class=3D"gmail_msg">has been some discussion ab=
out using HalfSipHash1-3 (or SipHash1-3 on<br class=3D"gmail_msg">64-bit) i=
nstead of 2-4. So, the same question is therefore posed:<br class=3D"gmail_=
msg">would using HalfSipHash1-3 give a sufficient security margin for<br cl=
ass=3D"gmail_msg">hashtable usage and hashtable attacks?<br class=3D"gmail_=
msg"></blockquote><div><br></div><div><div>My educated guess is that yes, i=
t will, but that it may not withhold cryptanalysis as a pseudorandom functi=
on (PRF). For example I wouldn&#39;t be surprised if there were a &quot;dis=
tinguishing attack&quot; that detects non-random patterns in HalfSipHash-1-=
3&#39;s output. But most of the non-crypto hashes I&#39;ve seen have obviou=
s distinguishing attacks. So the upshot is that HSH will get you better sec=
urity that AnyWeakHash even with 1 &amp; 3 rounds.=C2=A0</div><div><br></di=
v><div>So, if you&#39;re willing to compromise on security, but still want =
something not completely unreasonable, you might be able to get away with u=
sing HalfSipHash1-3 as a replacement for jhash=E2=80=94in circumstances whe=
re the output of the hash function is kept secret=E2=80=94in order to mitig=
ate hash-flooding attacks.</div></div><div><br></div><div>=C2=A0</div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:=
1px solid rgb(204,204,204);padding-left:1ex"><br class=3D"gmail_msg">My pla=
n is essentially to implement things according to your security<br class=3D=
"gmail_msg">recommendation. The thread started with me pushing a heavy duty=
<br class=3D"gmail_msg">security solution -- SipHash2-4 -- for _everything_=
. I&#39;ve received<br class=3D"gmail_msg">understandable push back on that=
 notion for certain use cases. So now<br class=3D"gmail_msg">I&#39;m trying=
 to discover what the most acceptable compromise is. Your<br class=3D"gmail=
_msg">answers on (2a) and (2b) will direct that compromise.<br class=3D"gma=
il_msg"><br class=3D"gmail_msg">Thanks again,<br class=3D"gmail_msg">Jason<=
/blockquote></div><div class=3D"gmail_quote"><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
><br class=3D"gmail_msg">
</blockquote></div></div>

--001a11401e848308690544090e36--
