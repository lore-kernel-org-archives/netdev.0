From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Sun, 18 May 2008 19:53:58 +0200
Message-ID: <48306D36.6040706@firstfloor.org>
References: <87abirytxj.fsf@basil.nowhere.org> <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org> <20080516121239.GA9627@gondor.apana.org.au> <482DB568.1040704@firstfloor.org> <20080517010136.GA15102@gondor.apana.org.au> <482EBAA8.3040506@firstfloor.org> <a24804730805171254i2a37da61mb47280db7b330ed5@mail.gmail.com> <20080517130535.02d45372@infradead.org> <4830014F.9040800@firstfloor.org> <20080518112657.GK16496@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Theodore Tso <tytso@mit.edu>, Andi Kleen <andi@firstfloor.org>,
	Arjan van de Ven <arjan@infradead.org>,
	Chris Peterson <cpeterso@cpeterso.com>,
	Herbert Xu <herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35814 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbYERRyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 13:54:07 -0400
In-Reply-To: <20080518112657.GK16496@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> See why the qualifying statements is so important?  If you really
> believe that there isn't enough entropy after installing a
> distribution, THEN YOU SHOULDN'T BE GENERATING SSH HOST KEYS.  The
> problem is that the server scenario with no keyboard case is a really
> nasty one.

It's made worse by not feeding in the network interrupts.

I never quite understood the rationale behind that one either:
if you worry about someone else controlling the timing of these events,
why do you not worry about timings on the local system. e.g.
it's not that hard to predict with similar accuracy when a hard disk
interrupt happened when a local process read something from disk. Or
when the  keyboard/USB interrupt happened when you process keyboard input.

On the other hand if only the low bits of the time stamp counter
are used it should be still random enough in all cases because
real systems don't behave predictable down to ns levels.

> 
>> See also the distinction between "user controlled visible cryptography"
>> and "background cryptography" I introduced in a earlier mail on that
>> topic. gpg can only get away with it because they rely on a high level
>> of user education (so requiring banging on keys is ok), but that's
>> not really an option for your normal "everyday background crypto",
>> including longer term keys.
> 
> No, this distinction is a specious one, I think.  It's really more a
> level of paranoia.  

If people don't realize cryptography is used they can't really
have any paranoia. And you can only get away with paranoia requiring
significant user action (like banging on keys) if they realize that.

> People tend to be much more paranoid about their
> own personal keys, 

In this case I would say it's more the program authors because the users
don't really have any choice.

> That says
> something about how much they care about security right there. 

It's more a question on how practical security is. If security
gets too complicated nobody will use it.

[classical example of that is to force users to use unrememberable
"strong" passwords -- result is that they are just written down on
postit notes and pinned to monitors. Same effect here]

>> Instead I think just both urandom and random should try to rely
>> on TPMs and other hardware rngs and always get high quality bit noise.
> 
> Sure, if you can get access to a TPM or a hardware rng, that's
> *always* a better choice. 

Yes definitely, but the trouble is /dev/random does not use it by
default. So even if you have a working hardware RNG there's no
improvement on what comes out of /dev/u?random

 But the reason for /dev/random and
> /dev/urandom's existence is that hardware manufacturers have either
> not included a real hardware RNG, or made it impossible to get to it.
> (I *still* haven't figured out how to access my TPM on my Lenovo
> laptops.  Anyone who can send me turn-key instructions, let me know
> off-line.)  Intel used to provide a true hardware RNG in their
> chipsets a few years ago (props to them), but then stopped after one
> generation (boo, hiss).

Yes, but we don't use it either by default. So even if you have
such a chipset your /dev/random output isn't improved in any ways.

> If there is a way that we can at least seed /dev/random from the TPM
> (without needing any magic enabling keys, etc.) once at boot time, and
> then rely on what we can get from the environment, maybe we can do it
> in the kernel without needing to move all of the TPM access/contention
> control logic from userspace into the kernel.

Jeff's patch looked like a good start. I'll try to come up with
a complete patch series that auto feeds. The only system I have with a
TPM is a T61, let's see if trousers works on that.

There's also a couple of other problems here I believe, in particular
some of the kernel subsystems who get random numbers for their purpose
get it too early before there's any chance of seeing.

Also for a lot of kernel purposes (like the networking hash tables) it's
really wasteful to use the  precious entropy pool entropy.  It should
rather just seed some cryptographic PRNG once and then use output
from that for kernel purposes (or alternatively at least not
remove entropy credit from the random pool)

-Andi

