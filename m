From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Mon, 17 Oct 2016 18:21:14 +0100
Message-ID: <CAKv+Gu-25OvTSbyE06Ln8N+HsqNyV1T6oOudK2tyAAOmmXXqgA@mail.gmail.com>
References: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org>
 <1476689310.19992.1.camel@sipsolutions.net> <CAKv+Gu_P-6sHW3t7tp1N+3v9ZGqWcQrzMZkASY5g=QR76KN4wg@mail.gmail.com>
 <CALCETrUWW2A1XK7BzcajTcBzg58SDUCTE35Hj1vmbywTLCe2vQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUWW2A1XK7BzcajTcBzg58SDUCTE35Hj1vmbywTLCe2vQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 October 2016 at 18:08, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Oct 17, 2016 at 12:37 AM, Ard Biesheuvel
> <ard.biesheuvel@linaro.org> wrote:
>> On 17 October 2016 at 08:28, Johannes Berg <johannes@sipsolutions.net> wrote:
>>> On Sat, 2016-10-15 at 18:16 +0100, Ard Biesheuvel wrote:
>>>> The CCM code goes out of its way to perform the CTR encryption of the
>>>> MAC using the subordinate CTR driver. To this end, it tweaks the
>>>> input and output scatterlists so the aead_req 'odata' and/or
>>>> 'auth_tag' fields [which may live on the stack] are prepended to the
>>>> CTR payload. This involves calling sg_set_buf() on addresses which
>>>> are not direct mapped, which is not supported.
>>>
>>>> Since the calculation of the MAC keystream involves a single call
>>>> into the cipher, to which we have a handle already given that the
>>>> CBC-MAC calculation uses it as well, just calculate the MAC keystream
>>>> directly, and record it in the aead_req private context so we can
>>>> apply it to the MAC in cypto_ccm_auth_mac(). This greatly simplifies
>>>> the scatterlist manipulation, and no longer requires scatterlists to
>>>> refer to buffers that may live on the stack.
>>>
>>> No objection from me, Herbert?
>>>
>>> I'm getting a bit nervous though - I'd rather have any fix first so
>>> people get things working again - so maybe I'll apply your other patch
>>> and mine first, and then we can replace yours by this later.
>>>
>>
>> Could we get a statement first whether it is supported to allocate
>> aead_req (and other crypto req structures) on the stack? If not, then
>> we have our work cut out for us. But if it is, I'd rather we didn't
>> apply the kzalloc/kfree patch, since it is just a workaround for the
>> broken generic CCM driver, for which a fix is already available.
>
> I'm not a crypto person, but I don't see why not.  There's even a
> helper called SKCIPHER_REQUEST_ON_STACK. :)  The only problem I know
> of is pointing a scatterlist at the stack, which is bad for much the
> same reason as doing real DMA from the stack.

Excellent point!

So the CCM code was an easy fix, although the RFC4309 part is still broken:

It does

"""
scatterwalk_map_and_copy(iv + 16, req->src, 0, req->assoclen - 8, 0);
...
sg_set_buf(rctx->src, iv + 16, req->assoclen - 8);
sg = scatterwalk_ffwd(rctx->src + 1, req->src, req->assoclen);
"""

which essentially just hides the last 8 bytes of associated data from
the inner CCM transform. So we'd need to rewrite this part to create a
new scatterlist that omits those 8 bytes instead of just replacing the
first sg entry and point it to another buffer entirely (and copy the
data into it)

The GCM code is much more complicated, and does not easily allow the
offending sg_set_buf() calls to be turned into something that only
involves direct mapped memory references. I haven't looked at anything
else.

Annoyingly, all this complication with scatterlists etc is for doing
asynchronous crypto via DMA capable crypto accelerators, and the
networking code (ipsec as well as mac80211, afaik) only allow
synchronous in the first place, given that they execute in softirq
context.
