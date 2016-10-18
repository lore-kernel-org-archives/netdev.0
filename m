From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH 2/2] mac80211: aes_ccm: cache AEAD request structures
 per CPU
Date: Tue, 18 Oct 2016 15:18:26 +0100
Message-ID: <CAKv+Gu8aE4AfewHeMDf2RQfJtSsrp6Fb1A_ygFsqEwpyP6hDjQ@mail.gmail.com>
References: <1476799713-16188-1-git-send-email-ard.biesheuvel@linaro.org>
 <1476799713-16188-3-git-send-email-ard.biesheuvel@linaro.org> <1476800194.6425.35.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
        Jouni Malinen <j@w1.fi>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476800194.6425.35.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18 October 2016 at 15:16, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Tue, 2016-10-18 at 15:08 +0100, Ard Biesheuvel wrote:
>>
>> +     aead_req = *this_cpu_ptr(ccmp->reqs);
>> +     if (!aead_req) {
>> +             aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
>> +             if (!aead_req)
>> +                     return -ENOMEM;
>> +             *this_cpu_ptr(ccmp->reqs) = aead_req;
>> +             aead_request_set_tfm(aead_req, ccmp->tfm);
>> +     }
>
> Hmm. Is it really worth having a per-CPU variable for each possible
> key? You could have a large number of those (typically three when
> you're a client on an AP, and 1 + 1 for each client when you're the
> AP).
>
> Would it be so bad to have to set the TFM every time (if that's even
> possible), and just have a single per-CPU cache?
>

That would be preferred, yes. The only snag here is that
crypto_alloc_aead() is not guaranteed to return the same algo every
time, which means the request size is not guaranteed to be the same
either. This is a rare corner case, of course, but it needs to be
dealt with regardless
