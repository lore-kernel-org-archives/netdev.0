From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2 net-next 0/4] Introduce The SipHash PRF
Date: Sat, 7 Jan 2017 11:54:22 -0800
Message-ID: <20170107195422.GA8327@zzz>
References: <20170107144057.15432-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeanphilippe.aumasson@gmail.com,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170107144057.15432-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 07, 2017 at 03:40:53PM +0100, Jason A. Donenfeld wrote:
> This patch series introduces SipHash into the kernel. SipHash is a
> cryptographically secure PRF, which serves a variety of functions, and is
> introduced in patch #1. The following patch #2 introduces HalfSipHash,
> an optimization suitable for hash tables only. Finally, the last two patches
> in this series show two usages of the introduced siphash function family.
> It is expected that after this initial introductin, other usages will follow.
...
> The use of SipHash is not limited to the networking subsystem -- indeed I
> would like to use it in other places too in the kernel. But after discussing
> with a few on this list and at Linus' suggestion, the initial import of these
> functions is coming through the networking tree. After these are merged, it
> will then be easier to expand use elsewhere.
> 
> Changes v1->v2:
>   - len in the macro is now (len).
>   - siphash_key_t is now a struct, so that passing by reference is more
>     obvious and clear. This required changing all the call sites.
>   - Rather than calling le32_to_cpu(data[0]), where data is a u64, we now
>     do the safer thing and call le32_to_cpup((const __le32 *)data).
>   - The alignment in the tests is now more explicit.
>   - Sparse no longer complains, after fixing up a few endian casts.
>   - White space fixups.
>   - Word wrapping fixes.
>   - The valid suggestions from checkpatch.

Hi Jason, thanks for doing this!  Yes, I had gotten a little lost in the earlier
discussions about the 'random' driver and other potential users of SipHash.  I
agree with the approach to just introduce the two uses in net/ to start with,
and introduce more users later.  The changes from v1 to v2 look good too.

Now that the HalfSipHash patch is Cc'ed to me too I do have one other small
suggestion which is that this:

	#if BITS_PER_LONG == 64
	typedef siphash_key_t hsiphash_key_t;
	#define HSIPHASH_ALIGNMENT SIPHASH_ALIGNMENT
	#else
	typedef struct {
		u32 key[2];
	} hsiphash_key_t;
	#define HSIPHASH_ALIGNMENT __alignof__(u32)
	#endif

could cause confusion if someone accidentally uses 'siphash_key_t' instead of
'hsiphash_key_t', as their code would compile fine on a 64-bit platform but
would fail to compile on a 32-bit platform.  I think there should just always be
a hsiphash_key_t struct defined, and it can use unsigned long (no need for an
#ifdef):

	#define HSIPHASH_ALIGNMENT __alignof__(unsigned long)
	typedef struct {
		unsigned long key[2];
	} hsiphash_key_t;

There's also a small error in Documentation/siphash.txt: hsiphash() is shown as
taking siphash_key_t instead of hsiphash_key_t.

The uses in net look good too.  Something to watch out for is accidentally
defining the structs in a way that leaves internal padding bytes, which could
theoretically take on any value and cause the same input to produce different
hashes.  But AFAICS, in the proposed patch all the structs are laid out
properly, so that won't happen.

'net_secret' could also be marked as __read_mostly, like the keys in
syncookies.c, I suppose; it may not matter much.

Thanks!

Eric
