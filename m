From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 20:35:44 +0100
Message-ID: <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214184605.24006-1-Jason@zx2c4.com>
 <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        David Laight <David.Laight@aculab.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tom,

On Wed, Dec 14, 2016 at 8:18 PM, Tom Herbert <tom@herbertland.com> wrote:
> "super fast" is relative. My quick test shows that this faster than
> Toeplitz (good, but not exactly hard to achieve), but is about 4x
> slower than jhash.

Fast relative to other cryptographically secure PRFs.

>> SipHash isn't just some new trendy hash function. It's been around for a
>> while, and there really isn't anything that comes remotely close to
>> being useful in the way SipHash is. With that said, why do we need this?
> I don't think we need advertising nor a lesson on hashing. It would be
> much more useful if you just point us to the paper on siphash (which I
> assume I http://cr.yp.to/siphash/siphash-20120918.pdf ?).

Ugh. Sorry. It definitely wasn't my intention to give an uninvited
lesson or an annoying advert. For the former, I didn't want to make
any expectations about fields of knowledge, because I honest have no
idea. For the latter, I wrote that sentence to indicate that siphash
isn't just some newfangled hipster function, but something useful and
well established. I didn't mean it as a form of advertising. My
apologies if I've offended your sensibilities.

That cr.yp.to link is fine, or https://131002.net/siphash/siphash.pdf I believe.

> Key rotation is important anyway, without any key rotation even if the
> key is compromised in siphash by some external means we would have an
> insecure hash until the system reboots.

I'm a bit surprised to read this. I've never designed a system to be
secure even in the event of remote arbitrary kernel memory disclosure,
and I wasn't aware this was generally considered an architectural
requirement or Linux.

In any case, if you want this, I suppose you can have it with siphash too.

> Maybe so, but we need to do due diligence before considering adopting
> siphash as the primary hashing in the network stack. Consider that we
> may very well perform a hash over L4 tuples on _every_ packet. We've
> done a good job at limiting this to be at most one hash per packet,
> but nevertheless the performance of the hash function must be take
> into account.

I agree with you. It seems like each case is going to needed to be
measured on a case by case basis. In this series I make the first use
of siphash in the secure sequence generation and get_random_int/long,
where siphash replaces md5, so there's a pretty clear performance in.
But for the jhash replacements indeed things are going to need to be
individually evaluated.

> 1) My quick test shows siphash is about four times more expensive than
> jhash. On my test system, computing a hash over IPv4 tuple (two 32 bit
> addresses and 2 16 bit source ports) is 6.9 nsecs in Jenkins hash, 33
> nsecs with siphash. Given that we have eliminated most of the packet
> header hashes this might be tolerable, but still should be looking at
> ways to optimize.
> 2) I like moving to use u64 (quad words) in the hash, this is an
> improvement over Jenkins which is based on 32 bit words. If we put
> this in the kernel we probably want to have several variants of
> siphash for specific sizes (e.g. siphash1, siphash2, siphash2,
> siphashn for hash over one, two, three, or n sixty four bit words).

I think your suggestion for (2) will contribute to further
optimizations for (1). In v2, I had another patch in there adding
siphash_1word, siphash_2words, etc, like jhash, but I implemented it
by taking u32 variables and then just concatenating these into a
buffer and passing them to the main siphash function. I removed it
from v3 because I thought that these kind of missed the whole point.
In particular:

a) siphash24_1word, siphash24_2words, siphash24_3words, etc should
take u64, not u32, since that's what siphash operates on natively
b) Rather than concatenating them in a buffer, I should write
specializations of the siphash24 function _especially_ for these size
inputs to avoid the copy and to reduce the book keeping.

I'll add these functions to v4 implemented like that.

Thanks for the useful feedback and benchmarks!

Jason
