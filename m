From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 8 Oct 2013 15:16:48 +0200
Message-ID: <CAKv+Gu-VZTnPGB8YN__vWySceDHEtcBZmgjbEWRzy2HL_eGM2g@mail.gmail.com>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	<1381233152.13359.10.camel@jlt4.sipsolutions.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B737B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Patch Tracking <patches@linaro.org>,
	John Linville <linville@tuxdriver.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:56009 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab3JHNQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 09:16:50 -0400
Received: by mail-lb0-f182.google.com with SMTP id c11so6730924lbj.41
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 06:16:48 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B737B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 October 2013 15:01, David Laight <David.Laight@aculab.com> wrote:
>> Hmm, thanks I guess. I'll need to review this in more detail, but I have
>> a question first:
>>
>> > +   /* allocate the variable sized aead_request on the stack */
>> > +   int l = DIV_ROUND_UP(crypto_aead_reqsize(tfm),
>> > +                        sizeof(struct aead_request));
>> > +   struct aead_request req[1 + l];
>>
>> This looks a bit odd, why round up first and then add one? Why even
>> bother using a struct array rather than some local struct like
>
> Is it even a good idea to be allocating variable sized items
> on the kernel stack?
>
> There has to be enough stack available for the maximum number
> of entries - so there is little point in dynamically sizing it.
>

The result of crypto_aead_reqsize() has nothing to do with the input
or output data, it is a property of the particular implementation of
ccm(aes) that is being used. In the generic case (ccm.c),
it always returns the size of this struct

struct crypto_ccm_req_priv_ctx {
        u8 odata[16];
        u8 idata[16];
        u8 auth_tag[16];
        u32 ilen;
        u32 flags;
        struct scatterlist src[2];
        struct scatterlist dst[2];
        struct ablkcipher_request abreq;
};

while the particular implementation that I am working on for ARM64
always has size 0. Note that this is data that would otherwise be
allocated on the stack, but in the case of aead, which supports an
asynchronous interface (which this code does not use btw), the data is
attached to the end of the aead_request struct instead.

The alternative is to allocate it dynamically using GFP_ATOMIC and
free it at the end of the function, but in this particular case I
don't think that makes much sense tbh

-- 
Ard.
