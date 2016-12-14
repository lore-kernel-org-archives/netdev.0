From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 21:27:07 +0100
Message-ID: <ba55e62d-d4e6-97ed-614e-98c33a74347b@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
 <20161214.125612.1361254098267633173.davem@davemloft.net>
 <CAHmME9pz4XudfeqhKBwFNDmp7AYuNwbnevMqB3e6ScPDnUnq9g@mail.gmail.com>
 <0e708ba2-6a4e-013e-597a-62ab32cc240b@stressinduktion.org>
 <CAHmME9rp2oSCo0eu92jKm00S0eJHz65bJKXRpeS7=_EV6zZNYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Andi Kleen <ak@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9rp2oSCo0eu92jKm00S0eJHz65bJKXRpeS7=_EV6zZNYw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Jason,

On 14.12.2016 20:38, Jason A. Donenfeld wrote:
> On Wed, Dec 14, 2016 at 8:22 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> I don't think this helps. Did you test it? I don't see reason why
>> padding could be left out between `d' and `end' because of the flexible
>> array member?
> 
> Because the type u8 doesn't require any alignment requirements, it can
> nestle right up there cozy with the u16:
> 
> zx2c4@thinkpad ~ $ cat a.c
> #include <stdint.h>
> #include <stdio.h>
> #include <stddef.h>
> int main()
> {
>        struct {
>                uint64_t a;
>                uint32_t b;
>                uint32_t c;
>                uint16_t d;
>                char x[];
>        } a;
>        printf("%zu\n", sizeof(a));
>        printf("%zu\n", offsetof(typeof(a), x));
>        return 0;
> }
> zx2c4@thinkpad ~ $ gcc a.c
> zx2c4@thinkpad ~ $ ./a.out
> 24
> 18

Sorry, I misread the patch. You are using offsetof. In this case remove
the char x[] and just use offsetofend because it is misleading
otherwise. Should work like that though.

What I don't really understand is that the addition of this complexity
actually reduces the performance, as you have to take the "if (left)"
branch during hashing and causes you to make a load_unaligned_zeropad.

Bye,
Hannes
