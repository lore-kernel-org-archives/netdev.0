From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 net-next 0/4] Introduce The SipHash PRF
Date: Sun, 8 Jan 2017 13:41:46 +0100
Message-ID: <CAHmME9rsff+tKAiM3PZ+21YDHM53qZzLMV79+KgFBk8bO-1yTQ@mail.gmail.com>
References: <20170107144057.15432-1-Jason@zx2c4.com> <20170107195422.GA8327@zzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:39723 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967128AbdAHMlu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 07:41:50 -0500
In-Reply-To: <20170107195422.GA8327@zzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for round two. I'll address these. Comments are inline below.

On Sat, Jan 7, 2017 at 8:54 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> Hi Jason, thanks for doing this!  Yes, I had gotten a little lost in the earlier
> discussions about the 'random' driver and other potential users of SipHash.  I
> agree with the approach to just introduce the two uses in net/ to start with,
> and introduce more users later.  The changes from v1 to v2 look good too.

Indeed the initial patchset was _insane_ and the discussion became
sprawling and impossible. Everybody suggested I do baby steps, so
voila, there's this more manageable patchset now.

> Now that the HalfSipHash patch is Cc'ed to me too I do have one other small
> suggestion which is that this:
>
>         #if BITS_PER_LONG == 64
>         typedef siphash_key_t hsiphash_key_t;
>         #define HSIPHASH_ALIGNMENT SIPHASH_ALIGNMENT
>         #else
>         typedef struct {
>                 u32 key[2];
>         } hsiphash_key_t;
>         #define HSIPHASH_ALIGNMENT __alignof__(u32)
>         #endif
>
> could cause confusion if someone accidentally uses 'siphash_key_t' instead of
> 'hsiphash_key_t', as their code would compile fine on a 64-bit platform but
> would fail to compile on a 32-bit platform.  I think there should just always be
> a hsiphash_key_t struct defined, and it can use unsigned long (no need for an
> #ifdef):
>
>         #define HSIPHASH_ALIGNMENT __alignof__(unsigned long)
>         typedef struct {
>                 unsigned long key[2];
>         } hsiphash_key_t;

Good idea. Will adjust. That makes things a lot simpler.

> There's also a small error in Documentation/siphash.txt: hsiphash() is shown as
> taking siphash_key_t instead of hsiphash_key_t.

Arg, nice catch, fixing.

> The uses in net look good too.  Something to watch out for is accidentally
> defining the structs in a way that leaves internal padding bytes, which could
> theoretically take on any value and cause the same input to produce different
> hashes.  But AFAICS, in the proposed patch all the structs are laid out
> properly, so that won't happen.

Indeed that's something closely examined. In fact, originally, just to
be careful, I was using __packed, but David pointed out that using
__packed makes gcc resort to byte-by-byte assignment, even if the
alignment would otherwise be natural. So, instead I just made sure to
list the members in descending order of size, and made sure to use
offsetendof instead of sizeof. I'll be sure to document this
precaution in the Documentation/siphash.txt file for the next version,
alongside a simple example.

> 'net_secret' could also be marked as __read_mostly, like the keys in
> syncookies.c, I suppose; it may not matter much.

Good point. Fixing.

New version coming your way soon.

Thanks again,
Jason
