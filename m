From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 13:53:10 +0100
Message-ID: <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214035927.30004-3-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Andi Kleen <ak@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161214035927.30004-3-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, Dec 14, 2016 at 10:51 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Jason A. Donenfeld
>> Sent: 14 December 2016 00:17
>> This gives a clear speed and security improvement. Rather than manually
>> filling MD5 buffers, we simply create a layout by a simple anonymous
>> struct, for which gcc generates rather efficient code.
> ...
>> +     const struct {
>> +             struct in6_addr saddr;
>> +             struct in6_addr daddr;
>> +             __be16 sport;
>> +             __be16 dport;
>> +     } __packed combined = {
>> +             .saddr = *(struct in6_addr *)saddr,
>> +             .daddr = *(struct in6_addr *)daddr,
>> +             .sport = sport,
>> +             .dport = dport
>> +     };
>
> You need to look at the effect of marking this (and the other)
> structures 'packed' on architectures like sparc64.

In all current uses of __packed in the code, I think the impact is
precisely zero, because all structures have members in descending
order of size, with each member being a perfect multiple of the one
below it. The __packed is therefore just there for safety, in case
somebody comes in and screws everything up by sticking a u8 in
between. In that case, it wouldn't be desirable to hash the structure
padding bits. In the worst case, I don't believe the impact would be
worse than a byte-by-byte memcpy, which is what the old code did. But
anyway, these structures are already naturally packed anyway, so the
present impact is nil.

Jason
