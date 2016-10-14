From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 10:35:56 +0100
Message-ID: <CAKv+Gu_p7neD-ttCBBA6p7VSkQt8mvfhS9cdcLftdkXNtAAFnQ@mail.gmail.com>
References: <20161010150358.GA514@swordfish> <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net> <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net> <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
 <1476366354.4904.31.camel@sipsolutions.net> <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
 <1476429916.4382.12.camel@sipsolutions.net> <1476433699.31114.6.camel@sipsolutions.net>
 <CAKv+Gu8hTy8U7FcA58P1YWt2rHU09xP9v1UU0KcnD4uuaK8How@mail.gmail.com>
 <CAKv+Gu_v+4D_7EvRkrSrStheuP1L-oPh=o7Ub+NU7-wgLYks4w@mail.gmail.com>
 <1476434561.31114.7.camel@sipsolutions.net> <CAKv+Gu896xme5sd5i8hs7tA=Xt=qQKCiAx7fQg1ZECn50NttbQ@mail.gmail.com>
 <1476435303.31114.14.camel@sipsolutions.net> <CAKv+Gu9KObA61fEYxr1FFj_3SKNS2RUbqZo01yfnm9Bf0AncwA@mail.gmail.com>
 <1476436248.31114.21.camel@sipsolutions.net> <CAKv+Gu-Y6wuMGuRgrHRGCvAM9qZjvufs=7VWL8hAUKFSF=tZWg@mail.gmail.com>
 <1476437149.31114.27.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476437149.31114.27.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14 October 2016 at 10:25, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Fri, 2016-10-14 at 10:21 +0100, Ard Biesheuvel wrote:
>
>> It is annotated with a TODO, though :-)
>>
>> 38320c70d282b (Herbert Xu               2008-01-28 19:35:05
>> -0800  41)
>>  * TODO: Use spare space in skb for this where possible.
>
> I saw that, but I don't think generally there will be spare space for
> it - the stuff there is likely far too big. Anyway ... same problem
> that we have.
>
> I'm not inclined to allocate ~500 bytes temporarily for every frame
> either though.
>
> Maybe we could try to manage it in mac80211, we'd "only" need 5 AEAD
> structs (which are today on the stack) in parallel for each key (4 TX,
> 1 RX), but in a typical case of having 3 keys that's already 7.5K worth
> of memory that we almost never use. Again, with more complexity, we
> could know that the TX will not be used if the driver does the TX, but
> the single RX one we'd need unconditionally... decisions decisions...
>

So why is the performance hit acceptable for ESP but not for WPA? We
could easily implement the same thing, i.e., kmalloc(GFP_ATOMIC)/kfree
the aead_req struct rather than allocate it on the stack
