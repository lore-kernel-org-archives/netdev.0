From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [RFC PATCH 0/2] mac80211: use crypto shash for AES cmac
Date: Sat, 4 Feb 2017 14:44:15 +0000
Message-ID: <CAKv+Gu_tn+wc=19_ZZELSXxVknqswFrM1+b2KJCHYBgvFbjo3A@mail.gmail.com>
References: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
 <20170203214707.GA14147@jouni.qca.qualcomm.com> <CAKv+Gu9zp+vptF2mHP5MW=x_K5m7WQgMxNNSD5hn93aT_-99xA@mail.gmail.com>
 <20170204113514.GA4350@jouni.qca.qualcomm.com> <CAKv+Gu9p_yng=_=sri8VtRpBCpvL-r1iZ=YgEqNhuQf55p1xBA@mail.gmail.com>
 <20170204143913.GA24691@jouni.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Malinen, Jouni" <jouni@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34585 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdBDOoR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 09:44:17 -0500
Received: by mail-io0-f178.google.com with SMTP id l66so38046117ioi.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 06:44:16 -0800 (PST)
In-Reply-To: <20170204143913.GA24691@jouni.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 February 2017 at 14:39, Malinen, Jouni <jouni@qca.qualcomm.com> wrote:
> On Sat, Feb 04, 2017 at 02:24:36PM +0000, Ard Biesheuvel wrote:
>> There is another issue I spotted: the skcipher you allocate may be of
>> the async variant, which may return from skcipher_encrypt() with
>> -EINPROGRESS as soon as it has queued the request. Since you don't
>> deal with that result, you should allocate a sync cipher explicitly:
>
>> diff --git a/net/mac80211/fils_aead.c b/net/mac80211/fils_aead.c
>> -       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, 0);
>> +       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);
>
>> -       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, 0);
>> +       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);
>
> Thanks! Can you send this as a full contribution or do you want me to
> do that?

Please go ahead if you don't mind doing it

> I did run this through all the FILS test cases with
> mac80211_hwsim.
>

Well, even async ciphers can act synchronously: the SIMD based async
ciphers will only enqueue the request for deferred processing when
called in interrupt context (on most architectures) but if you happen
to run on a platform that has a h/w accelerator for ctr(aes), you are
quite likely to see failures here.

>> Thanks for the instructions and thanks for testing. If I manage to run
>> this locally, I will follow up with an alternative patch #1 tha here
>> switches FILS to use cmac(aes) as well (which looks reasonably
>> feasible now that I understand the code)
>
> If you have any issues in getting the hwsim test setup working, please
> let me know. I'm trying to make it easy for anyone to run those tests in
> hopes of improving quality of Linux WLAN contributions and what gets
> applied into cfg80211 or mac80211 (or hostap.git for that matter). In
> particular the latest step-by-step guide I added for the VM version (*)
> was hoping to show how that can be done in 15 minutes from scratch..
>
>
> (*) http://w1.fi/cgit/hostap/plain/tests/hwsim/vm/example-vm-setup.txt
>

I will take a look on Monday
