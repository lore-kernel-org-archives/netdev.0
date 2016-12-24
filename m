From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC PATCH 4.10 1/6] crypto/sha256: Refactor the API so it can be
 used without shash
Date: Fri, 23 Dec 2016 18:26:37 -0800
Message-ID: <CALCETrW8JFtmByxMnSQkP04JZH7V-zEcN+sJaBPNodyKcspvNw@mail.gmail.com>
References: <cover.1482545792.git.luto@kernel.org> <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
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
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 23, 2016 at 6:22 PM, Andy Lutomirski <luto@kernel.org> wrote:
> There are some pieecs of kernel code that want to compute SHA256
> directly without going through the crypto core.  Adjust the exported
> API to decouple it from the crypto core.
>
> I suspect this will very slightly speed up the SHA256 shash operations
> as well by reducing the amount of indirection involved.
>

I should also mention: there's a nice potential cleanup that's
possible on top of this.  Currently, most of the accelerated SHA256
implementations just swap out the block function.  Another approach to
enabling this would be to restructure sha256_update along the lines
of:

sha256_block_fn_t fn = arch_sha256_block_fn(len);
sha256_base_do_update(sctx, data, len, arch_sha256_block_fn(len));

The idea being that arch code can decide whether to use an accelerated
block function based on context (x86, for example, can't always use
xmm regs) and length (on x86, using the accelerated versions for short
digests is very slow due to the state save/restore that happens) and
then the core code can just use it.

This would allow a lot of the boilerplate that this patch was forced
to modify to be deleted outright.

--Andy
