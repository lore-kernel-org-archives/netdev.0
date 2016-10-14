From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 09:41:08 +0100
Message-ID: <CAKv+Gu_v+4D_7EvRkrSrStheuP1L-oPh=o7Ub+NU7-wgLYks4w@mail.gmail.com>
References: <20161010150358.GA514@swordfish> <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net> <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net> <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
 <1476366354.4904.31.camel@sipsolutions.net> <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
 <1476429916.4382.12.camel@sipsolutions.net> <1476433699.31114.6.camel@sipsolutions.net>
 <CAKv+Gu8hTy8U7FcA58P1YWt2rHU09xP9v1UU0KcnD4uuaK8How@mail.gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34245 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbcJNIlK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 04:41:10 -0400
Received: by mail-io0-f172.google.com with SMTP id r30so113983098ioi.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 01:41:09 -0700 (PDT)
In-Reply-To: <CAKv+Gu8hTy8U7FcA58P1YWt2rHU09xP9v1UU0KcnD4uuaK8How@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 October 2016 at 09:39, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> On 14 October 2016 at 09:28, Johannes Berg <johannes@sipsolutions.net> wrote:
>>
>>>    1. revert that patch (doing so would need some major adjustments now,
>>>       since it's pretty old and a number of new things were added in the
>>>       meantime)
>>
>> This it will have to be, I guess.
>>
>>>    2. allocate a per-CPU buffer for all the things that we put on the
>>>       stack and use in SG lists, those are:
>>>        * CCM/GCM: AAD (32B), B_0/J_0 (16B)
>>>        * GMAC: AAD (20B), zero (16B)
>>>        * (not sure why CMAC isn't using this API, but it would be like GMAC)
>>
>> This doesn't work - I tried to move the mac80211 buffers, but because
>> we also put the struct aead_request on the stack, and crypto_ccm has
>> the "odata" in there, and we can't separate the odata from that struct,
>> we'd have to also put that into a per-CPU buffer, but it's very big -
>> 456 bytes for CCM, didn't measure the others but I'd expect them to be
>> larger, if different.
>>
>> I don't think we can allocate half a kb for each CPU just to be able to
>> possibly use the acceleration here. We can't even make that conditional
>> on not having hardware crypto in the wifi NIC because drivers are
>> always allowed to pass undecrypted frames, regardless of whether or not
>> HW crypto was attempted, so we don't know upfront if we'll have to
>> decrypt anything in software...
>>
>> Given that, I think we have had a bug in here basically since Ard's
>> patch, we never should've put these structs on the stack. Herbert, you
>> also touched this later and converted the API usage, did you see the
>> way the stack is used here and think it should be OK, or did you simply
>> not realize that?
>>
>> Ard, are you able to help out working on a revert of your patch? That
>> would require also reverting a number of other patches (various fixes,
>> API adjustments, etc. to the AEAD usage), but the more complicated part
>> is that in the meantime Jouni introduced GCMP and CCMP-256, both of
>> which we of course need to retain.
>>
>
> I am missing some context here, but could you explain what exactly is
> the problem here?
>
> Look at this code
>
> """
> struct scatterlist sg[3];
>
> char aead_req_data[sizeof(struct aead_request) +
>     crypto_aead_reqsize(tfm)]
>     __aligned(__alignof__(struct aead_request));
> struct aead_request *aead_req = (void *) aead_req_data;
>
> memset(aead_req, 0, sizeof(aead_req_data));
>
> sg_init_table(sg, 3);
> sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
> sg_set_buf(&sg[1], data, data_len);
> sg_set_buf(&sg[2], mic, mic_len);
>
> aead_request_set_tfm(aead_req, tfm);
> aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
> aead_request_set_ad(aead_req, sg[0].length);
> """
>
> I assume the stack buffer itself is not the problem here, but aad,
> which is allocated on the stack one frame up.
> Do we really need to revert the whole patch to fix that?

Ah never mind, this is about 'odata'. Apologies, should have read first
