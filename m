From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: HalfSipHash Acceptable Usage
Date: Mon, 19 Dec 2016 22:00:40 +0100
Message-ID: <CAHmME9p3w5O+onO9GDmM9E1egKE2FdY3htLkCfSW2P2Lw5qJfQ@mail.gmail.com>
References: <CAHmME9rPmH=wP_eHYopt8ZPG9TSN7bos3fGOuqKL2HjQW-2SWA@mail.gmail.com>
 <CAGiyFdduUNSGq24zfsk0ZU=hnOCmewAw8vw6XvDoS-3f+3UPKQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "Theodore Ts'o" <tytso@mit.edu>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	LKML <linux-kernel@vger.kernel.org>, Eric Biggers <ebiggers3@gmail.com>,
	"Daniel J . Bernstein" <djb@cr.yp.to>, David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@linux.intel.com>,
	George Spelvin <linux@sciencehorizons.net>, kernel-hardening@lists.openwall.com,
	Andy Lutomirski <luto@amacapital.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
	Vegard Nossum <vegard.nossum@gmail.com>, Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5708-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGiyFdduUNSGq24zfsk0ZU=hnOCmewAw8vw6XvDoS-3f+3UPKQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hi JP,

On Mon, Dec 19, 2016 at 9:49 PM, Jean-Philippe Aumasson
<jeanphilippe.aumasson@gmail.com> wrote:
>
> On Mon, Dec 19, 2016 at 6:32 PM Jason A. Donenfeld <Jason@zx2c4.com> wrot=
e:
>>
>> Hi JP,
>>
>> With the threads getting confusing, I've been urged to try and keep
>> the topics and threads more closely constrained. Here's where we're
>> at, and here's the current pressing security concern. It'd be helpful
>> to have a definitive statement on what you think is best, so we can
>> just build on top of that, instead of getting lost in the chorus of
>> opinions.
>>
>> 1) Anything that requires actual long-term security will use
>> SipHash2-4, with the 64-bit output and the 128-bit key. This includes
>> things like TCP sequence numbers. This seems pretty uncontroversial to
>> me. Seem okay to you?
>
>
>
> Right, since 2012 when we published SipHash many cryptanalysts attempted =
to
> break SipHash-2-4 with a 128-bit key, for various notions of "break", and
> nothing worth worrying was ever found. I'm totally confident that
> SipHash-2-4 will live up to its security promises.
>
> Don't use something weaker for things like TCP sequence numbers or RNGs. =
Use
> SipHash2-4 for those. That is the correct choice.
>
>>
>>
>> 2) People seem to want something competitive, performance-wise, with
>> jhash if it's going to replace jhash. The kernel community
>> instinctively pushes back on anything that could harm performance,
>> especially in networking and in critical data structures, so there
>> have been some calls for something faster than SipHash. So, questions
>> regarding this:
>>
>
> No free lunch I guess: either go with a cryptographically secure,
> time-proved keyed hash such as SipHash, or go with some simpler hash deem=
ed
> secure cos its designer can't break it :) #DontRollYourOwnCrypto
>
>> 2a) George thinks that HalfSipHash on 32-bit systems will have roughly
>> comparable speed as SipHash on 64-bit systems, so the idea would be to
>> use HalfSipHash on 32-bit systems' hash tables and SipHash on 64-bit
>> systems' hash tables. The big obvious question is: does HalfSipHash
>> have a sufficient security margin for hashtable usage and hashtable
>> attacks? I'm not wondering about the security margin for other usages,
>> but just of the hashtable usage. In your opinion, does HalfSipHash cut
>> it?
>
>
> HalfSipHash takes its core function from Chaskey and uses the same
> construction as SipHash, so it *should* be secure. Nonetheless it hasn't
> received the same amount of attention as 64-bit SipHash did. So I'm less
> confident about its security than about SipHash's, but it obviously inspi=
res
> a lot more confidence than non-crypto hashes.
>
> Too, HalfSipHash only has a 64-bit key, not a 128-bit key like SipHash, s=
o
> only use this as a mitigation for hash-flooding attacks, where the output=
 of
> the hash function is never directly shown to the caller. Do not use
> HalfSipHash for TCP sequence numbers or RNGs.
>
>
>>
>>
>> 2b) While I certainly wouldn't consider making the use case in
>> question (1) employ a weaker function, for this question (2), there
>> has been some discussion about using HalfSipHash1-3 (or SipHash1-3 on
>> 64-bit) instead of 2-4. So, the same question is therefore posed:
>> would using HalfSipHash1-3 give a sufficient security margin for
>> hashtable usage and hashtable attacks?
>
>
> My educated guess is that yes, it will, but that it may not withhold
> cryptanalysis as a pseudorandom function (PRF). For example I wouldn't be
> surprised if there were a "distinguishing attack" that detects non-random
> patterns in HalfSipHash-1-3's output. But most of the non-crypto hashes I=
've
> seen have obvious distinguishing attacks. So the upshot is that HSH will =
get
> you better security that AnyWeakHash even with 1 & 3 rounds.
>
> So, if you're willing to compromise on security, but still want something
> not completely unreasonable, you might be able to get away with using
> HalfSipHash1-3 as a replacement for jhash=E2=80=94in circumstances where =
the output
> of the hash function is kept secret=E2=80=94in order to mitigate hash-flo=
oding
> attacks.
>

Thanks for the detailed response. I will continue exactly how you've specif=
ied.

1. SipHash2-4 for TCP sequence numbers, syncookies, and RNG. IOW, the
things that MD5 is used for now.

2. HalfSipHash1-3 for hash tables where the output is not revealed,
for jhash replacements. On 64-bit this will alias to SipHash1-3.

3. I will write Documentation/siphash.txt detailing this.

4. I'll continue to discourage other kernel developers from rolling
their own crypto or departing from the tried&true in substantial ways.

Thanks again,
Jason
