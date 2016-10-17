From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Mon, 17 Oct 2016 08:37:45 +0100
Message-ID: <CAKv+Gu_P-6sHW3t7tp1N+3v9ZGqWcQrzMZkASY5g=QR76KN4wg@mail.gmail.com>
References: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org> <1476689310.19992.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33264 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757558AbcJQHjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 03:39:05 -0400
Received: by mail-io0-f181.google.com with SMTP id q192so179820889iod.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 00:37:46 -0700 (PDT)
In-Reply-To: <1476689310.19992.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 October 2016 at 08:28, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Sat, 2016-10-15 at 18:16 +0100, Ard Biesheuvel wrote:
>> The CCM code goes out of its way to perform the CTR encryption of the
>> MAC using the subordinate CTR driver. To this end, it tweaks the
>> input and output scatterlists so the aead_req 'odata' and/or
>> 'auth_tag' fields [which may live on the stack] are prepended to the
>> CTR payload. This involves calling sg_set_buf() on addresses which
>> are not direct mapped, which is not supported.
>
>> Since the calculation of the MAC keystream involves a single call
>> into the cipher, to which we have a handle already given that the
>> CBC-MAC calculation uses it as well, just calculate the MAC keystream
>> directly, and record it in the aead_req private context so we can
>> apply it to the MAC in cypto_ccm_auth_mac(). This greatly simplifies
>> the scatterlist manipulation, and no longer requires scatterlists to
>> refer to buffers that may live on the stack.
>
> No objection from me, Herbert?
>
> I'm getting a bit nervous though - I'd rather have any fix first so
> people get things working again - so maybe I'll apply your other patch
> and mine first, and then we can replace yours by this later.
>

Could we get a statement first whether it is supported to allocate
aead_req (and other crypto req structures) on the stack? If not, then
we have our work cut out for us. But if it is, I'd rather we didn't
apply the kzalloc/kfree patch, since it is just a workaround for the
broken generic CCM driver, for which a fix is already available.

Also, regarding your __percpu patch: those are located in the vmalloc
area as well, at least on arm64, and likely other architectures too.
