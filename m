From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 14:16:24 +0100
Message-ID: <1e502c6b-cda3-c46d-2535-fcfb58f443a9@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Andi Kleen <ak@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        David Laight <David.Laight@aculab.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.12.2016 13:53, Jason A. Donenfeld wrote:
> Hi David,
> 
> On Wed, Dec 14, 2016 at 10:51 AM, David Laight <David.Laight@aculab.com> wrote:
>> From: Jason A. Donenfeld
>>> Sent: 14 December 2016 00:17
>>> This gives a clear speed and security improvement. Rather than manually
>>> filling MD5 buffers, we simply create a layout by a simple anonymous
>>> struct, for which gcc generates rather efficient code.
>> ...
>>> +     const struct {
>>> +             struct in6_addr saddr;
>>> +             struct in6_addr daddr;
>>> +             __be16 sport;
>>> +             __be16 dport;
>>> +     } __packed combined = {
>>> +             .saddr = *(struct in6_addr *)saddr,
>>> +             .daddr = *(struct in6_addr *)daddr,
>>> +             .sport = sport,
>>> +             .dport = dport
>>> +     };
>>
>> You need to look at the effect of marking this (and the other)
>> structures 'packed' on architectures like sparc64.
> 
> In all current uses of __packed in the code, I think the impact is
> precisely zero, because all structures have members in descending
> order of size, with each member being a perfect multiple of the one
> below it. The __packed is therefore just there for safety, in case
> somebody comes in and screws everything up by sticking a u8 in
> between. In that case, it wouldn't be desirable to hash the structure
> padding bits. In the worst case, I don't believe the impact would be
> worse than a byte-by-byte memcpy, which is what the old code did. But
> anyway, these structures are already naturally packed anyway, so the
> present impact is nil.

__packed not only removes all padding of the struct but also changes the
alignment assumptions for the whole struct itself. The rule, the struct
is aligned by its maximum alignment of a member is no longer true. That
said, the code accessing this struct will change (not on archs that can
deal efficiently with unaligned access, but on others).

A proper test for not introducing padding is to use something with
BUILD_BUG_ON. Also gcc also clears the padding of the struct, so padding
shouldn't be that bad in there (it is better than byte access on mips).

Btw. I think gcc7 gets support for store merging optimization.

Bye,
Hannes
