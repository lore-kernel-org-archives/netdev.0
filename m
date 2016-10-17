From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 10:30:58 +0100
Message-ID: <CAKv+Gu_ZH9hO_xbVfOfk90CxFJ6ZTz3PKWB1v23LRVzpBrb=oQ@mail.gmail.com>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
 <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com> <1476696226.19992.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38091 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757991AbcJQJa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 05:30:59 -0400
Received: by mail-it0-f43.google.com with SMTP id 66so2764700itl.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 02:30:59 -0700 (PDT)
In-Reply-To: <1476696226.19992.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 October 2016 at 10:23, Johannes Berg <johannes@sipsolutions.net> wrote:
>
>> Apologies for going back and forth on this, but it appears there may
>> be another way to deal with this.
>>
>> First of all, we only need this handling for the authenticated data,
>
> Are you sure b_0/j_0 aren't needed? We pass those
> to aead_request_set_crypt(), and I wasn't sure what that really did
> internally, perhaps like the internal data.
>

They are the IV[], which is a fixed length parameter of the algorithm.
In contrast, the AAD[] could be of arbitrary length (from the POV of
the crypto API) so it uses scatterlists.

> Testing with that on the stack does seem to work, in fact.
>
> Surely we need zero for GMAC though, since we also put that into the sg
> list. Thus for GMAC we definitely need 20+16 bytes, and since I round
> up to a cacheline (at least on SMP) it doesn't really matter that we
> could get 36 instead of the 48 I have now.
>
>> and only for CCM and GCM, not CMAC (which does not use scatterlists
>> at all, it simply calls the AES cipher directly)
>
> I didn't modify CMAC, I think, only GMAC, which also uses scatterlists.
>

Ah ok, I misread the patch.

>> So that leaves a fixed 20 bytes for GCM and fixed 32 bytes for CCM,
>
> and 36 for GMAC :)

Yes. But as I replied, setting the req size is not supported atm,
although it is reasonable to demand a way to allocate additional data
in the request specifically for this issue. So let's proceed with the
aead_request_alloc/free patch, but I would like to propose something
on the API side to address this particular issue
