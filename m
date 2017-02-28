From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 16:28:35 -0500
Message-ID: <CAF=yD-+7syCYSdFT7eNfWsoUK34ybxwQntiX=RQBF89rDzTiZQ@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
 <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
 <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com> <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35668 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751882AbdB1Vjx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:39:53 -0500
In-Reply-To: <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> I can see this working if you have a special type of skb that
>>> indicates that the data might be concurrently written and have all the
>>> normal skb APIs (including, especially, anything that clones it) make
>>> a copy first.
>>
>> Support for cloned skbs is required for TCP, both at tcp_transmit_skb
>> and segmentation offload. Patch 4 especially adds reference counting
>> of shared pages across clones and other sk_buff operations like
>> pskb_expand_head. This still allows for deep copy (skb_copy_ubufs)
>> on clones in specific datapaths like the above.
>
> Does this mean that a user program that does a zerocopy send can cause
> a retransmitted segment to contain different data than the original
> segment? If so, is that okay?

That is possible, indeed. The bytestream at the receiver is then
likely undefined. Though integrity of the tcp receive stack should
not be affected. A valid question is whether the stack should protect
against such users. The pattern is reminiscent of evasion attacks. In
the limited case, privileged users already can generate this data
pattern, of course.
