From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: Re: af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT)
Date: Sun, 5 Apr 2015 10:35:07 +0200
Message-ID: <5520F3BB.7070400@fokus.fraunhofer.de>
References: <551D1F86.8050200@fokus.fraunhofer.de> <CANfWibMogTn8QSdMAci2RUeE2ROVJ92LjUDhs3nHb7NctwKiVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Xin Zhou <xinzhou.sjtu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay42-dus.antispameurope.com ([94.100.134.242]:45321 "EHLO
	mx-relay42-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbbDEIfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2015 04:35:12 -0400
In-Reply-To: <CANfWibMogTn8QSdMAci2RUeE2ROVJ92LjUDhs3nHb7NctwKiVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

IMHO, the unlikely() makes perfect sense in the blocking case while in 
the non-blocking case it depends on the scenario:
What's more likely, user space writing faster than the device can handle 
or vice versa ?
The reason I removed the unlikely() is that I thought the situation is 
rather balanced in the non-blocking case.

Let's see, if we assume that in the non-blocking case we go through 
select()/poll()/epoll() first, it is likely() that we can write, at 
least, one frame, while we would break after the first unsuccessful skb 
alloc.

Hence, if we can only write one frames, the chance are fifty:fifty => no 
likely()/unlikely().
If we assume we can typically write more than one frame, we probably 
should put the unlikely() back.

What do you think ?

Cheers,

Mathias

On 04/05/2015 09:13 AM, Xin Zhou wrote:
> Hi Mathias,
>
> Just for a general discussion, could removing the unlikely has 
> performance impact on some applications or platforms?
>
> -        if (unlikely(skb == NULL))
> +        if (skb == NULL) {
> +                    /* we assume the socket was initially writeable 
> ... */
> +                        if (likely(len_sum > 0))
> +                            err = len_sum;
> +                    else
> +                            err = -ENOBUFS;
>              goto out_status;
> -
> +                }
>
> Looking through the code in the do {} while loop of API tpacket_snd(),
> the code is highly optimized with branch predictions.
>
> Is it possible the original intention is to pass noblock=0, and use 
> "unlikely"?
>
> Thanks for discussion,
> Jeff
>
>
> On Thu, Apr 2, 2015 at 3:52 AM, Mathias Kretschmer 
> <mathias.kretschmer@fokus.fraunhofer.de 
> <mailto:mathias.kretschmer@fokus.fraunhofer.de>> wrote:
>
>     Dear all,
>
>     we have encountered a problem where the send(MSG_DONTWAIT) call on
>     a TX_RING is not fully non-blocking in cases where the device's
>     sndBuf is full (i.e. we are trying to write faster than the device
>     can handle).
>
>     This is on a WLAN radio (so it's not that hard to achieve :).
>
>     Comparing the TX_RING send() handler to the regular send()
>     handler, the difference seems to be in the sock_alloc_send_skb()
>     call where, the regular handler passes a (flags & MSG_DONTWAIT),
>     while the TX_RING handler always passes a 0 (block).
>
>     The attached patch changes this behavior by
>
>     a) also passing (flags & MSG_DONTWAIT)
>     b) adjusting the return code so that -ENOBUFS is returned if no
>     frame could be sent or to return the number of bytes sent, if
>     frame(s) could be sent within this call.
>
>     The proposed modification works fine for us and has been tested
>     extensively with WLAN and Ethernet device.
>
>     Feel free to apply this patch if you agree with this solution.
>     Of course, we're also open to other solutions / proposals / ideas.
>
>     Cheers,
>
>     Mathias
>
>     -- 
>     Dr. Mathias Kretschmer, Head of Competence Center
>     Fraunhofer FOKUS Network Research
>     A Schloss Birlinghoven, 53754 Sankt Augustin, Germany
>     T +49-2241-14-3466 <tel:%2B49-2241-14-3466>, F +49-2241-14-1050
>     <tel:%2B49-2241-14-1050>
>     E mathias.kretschmer@fokus.fraunhofer.de
>     <mailto:mathias.kretschmer@fokus.fraunhofer.de>
>     W http://www.fokus.fraunhofer.de/en/net
>
>


-- 
Dr. Mathias Kretschmer, Head of Competence Center
Fraunhofer FOKUS Network Research
A Schloss Birlinghoven, 53754 Sankt Augustin, Germany
T +49-2241-14-3466, F +49-2241-14-1050
E mathias.kretschmer@fokus.fraunhofer.de
