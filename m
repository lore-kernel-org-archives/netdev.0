From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] macsec: avoid heap overflow in skb_to_sgvec
Date: Mon, 24 Apr 2017 14:15:19 +0200
Message-ID: <CAHmME9ppLZdpqf2Q2rigVvydHEG=-X1whh-BHB3bYFS3J_XDGw@mail.gmail.com>
References: <20170421211448.16995-1-Jason@zx2c4.com> <063D6719AE5E284EB5DD2968C1650D6DCFFD9487@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "security@kernel.org" <security@kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFD9487@AcuExch.aculab.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2017 at 1:02 PM, David Laight <David.Laight@aculab.com> wrote:
> ...
>
> Shouldn't skb_to_sgvec() be checking the number of fragments against
> the size of the sg list?
> The callers would then all need auditing to allow for failure.

This has never been done before, since this is one of those operations
that simply _shouldn't fail_ this late in the driver's path. There's
an easy way to use a fixed size array of MAX_SKB_FRAGS+1, and then
just not specify FRAGLIST as a device feature. Then the function
succeeds every time, rather than dropping packets. Alternatively, if
the array is being allocated dynamically (kmalloc), a call to
skb_cow_data returns the number of fragments needed; since usually
people using scattergather are going to be modifying the skb anyway, I
believe this function should be being called anyway...

It would be possible to do as you suggest, though, by using sg_is_last
in skb_to_sgvec. In this case we'd need to change every call site of
skb_to_sgvec to ensure the return value is being checked as well as
making sure that the sglist is initialized with sg_init_table to
ensure the last frag is properly marked. I wouldn't be opposed to
this, though it is potentially error prone work.

In any case, this patch here follows the pattern of the entire rest of
the present-day kernel, so it ought to be merged as-is.
