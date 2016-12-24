From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC PATCH 4.10 1/6] crypto/sha256: Refactor the API so it can be
 used without shash
Date: Sat, 24 Dec 2016 09:57:53 -0800
Message-ID: <CALCETrVbT_1=cdU1+a-+KbhoFqeT3XvbHjY0s_U7C5JVgiPx_Q@mail.gmail.com>
References: <cover.1482545792.git.luto@kernel.org> <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
 <CAKv+Gu-UCqwchgbhg8VN4s=Yxk=PkjXG46NZo=8P4wAQtJ2TXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAKv+Gu-UCqwchgbhg8VN4s=Yxk=PkjXG46NZo=8P4wAQtJ2TXw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 24, 2016 at 2:33 AM, Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
> Hi Andy,
>
> On 24 December 2016 at 02:22, Andy Lutomirski <luto@kernel.org> wrote:
>> There are some pieecs of kernel code that want to compute SHA256
>> directly without going through the crypto core.  Adjust the exported
>> API to decouple it from the crypto core.
>>
>
> There are a bunch of things happening at the same time in this patch,
> i.e., unnecessary renames of functions with static linkage, return
> type changes to the base prototypes (int (*)(...) to void (*)(...))
> and the change for the base functions to take a struct sha256_state
> ctx rather than a shash_desc. I suppose you are mainly after the
> latter, so could we please drop the other changes?
>
> For the name clashes, could we simply use the crypto_ prefix for the
> globally visible functions rather than using names that are already in
> use? (and having to go around clean up the conflicts)
> As for the return type changes, the base functions intentionally
> return int to allow tail calls from the functions exposed by the
> crypto API (whose prototypes cannot be changed). Unlikely to matter in
> the grand scheme of things (especially now that the base layer
> consists of static inline functions primarily), but it is equally
> pointless to go around and change them to return void IMO.
>
> So what remains is the struct shash_desc to struct sha256_state
> change, which makes sense given that you are after a sha256_digest()
> function that does not require the crypto API. But it seems your use
> case does not rely on incremental hashing, and so there is no reason
> for the state to be exposed outside of the implementation, and we
> could simply expose a crypto_sha256_digest() routine from the
> sha256_generic.c implementation instead.

I actually do use incremental hashing later on.   BPF currently
vmallocs() a big temporary buffer just so it can fill it and hash it.
I change it to hash as it goes.

I painted the bike shed the other way because I thought that crypto_
names should indicate that they're the versions compatible with the
crypto API, but I take your point about churn.  Part of the reason I
didn't want to use crypto_sha256_update is because that function is
currently like this:

int crypto_sha256_update(struct shash_desc *desc, const u8 *data,
                          unsigned int len)

and I wanted to avoid churn.  The sha256_update() functions scattered
all over were static, so I didn't worry about them.

I'm going to give this another try as a split-up series that tries to
avoid making any changes beyond simple function renames to the
drivers.

>
> Also, I strongly feel that crypto and other security related patches
> should be tested before being posted, even if they are only RFC,
> especially when they are posted by high profile kernel devs like
> yourself. (Your code incorrectly calls crypto_sha2_final() in a couple
> of places, resulting in the finalization being performed twice, once
> with the accelerated block transform and again with the generic
> transform)
>

I tested it, albeit poorly.  I wanted feedback on the API (thanks!)
and I figured I could more carefully check the implementation once the
API survives a bit of review.  Since it looks like I have to rework
this, I'd need to re-test anyway.

>> I suspect this will very slightly speed up the SHA256 shash operations
>> as well by reducing the amount of indirection involved.
>>
>
> I think you have a valid point when it comes to the complexity of the
> crypto API in general. But the struct sha256_state is embedded in the
> shash_desc rather than referred to via a pointer, so the level of
> indirection does not appear to change. And given how 99.9% of the
> SHA256 execution time is spent in the block transform routine anyway,
> I expect the performance delta to be in the noise tbh.

s/very slightly/negligibly?  There's an extra speedup from avoiding a
variable-length stack allocation, but that probably doesn't matter
much either.

>
> Finally, another thing to keep in mind is that the base layers of
> SHA-1, SHA-256 and SHA-512 are intentionally structured in the same
> way. If there is a need for a digest() entry point, I'd prefer to add
> them for all flavours.

I want to get sha256 right first.  Once it's in good shape, making the
same changes to the other variants should be easy.

>
> Whether this still belongs under crypto or under lib/sha256.c as a
> library function (allowing archs to override it) is open for debate.
> If hashing BPF programs becomes a hot spot, we probably have bigger
> problems.
>
> Regards,
> Ard.
>
> P.S. I do take your point regarding the arch_sha256_block_transform()
> proposed in your follow up email, but there are some details (SIMD,
> availability of the instructions etc) that would make it only suitable
> for the generic implementation anyway, and the base layer was already
> a huge improvement compared to the open coded implementations of the
> SHA boilerplate.

Agreed, and my model may not be quite right.  It might have to be
something like:

if (arch_begin_sha256(len)) {
  ... do it with arch helpers...
  arch_end_sha256();
} else {
  ... do it generically ...
}

>> -       return sha256_base_finish(desc, out);
>> +       return crypto_sha2_final(desc, out);
>
> This is wrong: your crypto_sha2_final also calls sha256_base_do_finalize()

Ugh, right.  I clearly need to organize this change better to avoid
this kind of mistake.
