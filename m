From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of timestamps?
Date: Tue, 4 Mar 2014 15:35:56 -0500
Message-ID: <CADVnQyn7qqAZn5ZF8wQP_Hn-9s84uc4DUC6r8_ne7bY5Kexycg@mail.gmail.com>
References: <53151E55.9000503@hp.com>
	<CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com>
	<53162093.1040208@hp.com>
	<CABrhC0k5-x=qJgH4izXtRR=9+cLJh_emAy9Yt=+xrY6K5982Fg@mail.gmail.com>
	<53162A6E.2010907@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Heffner <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:53032 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344AbaCDUf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 15:35:58 -0500
Received: by mail-ea0-f182.google.com with SMTP id b10so600380eae.27
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 12:35:57 -0800 (PST)
In-Reply-To: <53162A6E.2010907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What's the receiver OS in this trace? It's reneging on SACKs. :-) Take
a look at this ACK:

18:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: .
4262:4262(0) ack 3171368 win 32716 <nop,nop,sack 1 {3171368:3177208}>

Note that it's ACKing 3171368 and SACKing the adjacent sequence range:
{3171368:3177208}. That's not cool.

I think that's causing the Linux sender to enter the
tcp_check_sack_reneging() code path, which calls tcp_enter_loss().

It seems that the Linux sender did not enable FRTO for that
tcp_enter_loss() invocation. Maybe there is some way we can revise the
logic to enable FRTO in cases like this, so we can detect that the
retransmission was not needed, and abort the stream of spurious
retransmissions...

neal


On Tue, Mar 4, 2014 at 2:33 PM, Rick Jones <rick.jones2@hp.com> wrote:
>>>> There is some other strangeness just before that, where the SACK
>>>> block shrinks then grows again.
>>>
>>>
>>>
>>> That would be this yes?
>>>
>>> 15:20:46.798816 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>>> 3660468:3661928, ack 4262, win 297, length 1460
>>> 15:20:46.799027 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>>> 3168256, win 32081, options [nop,nop,sack 1 {3171368:3172828}], length 0
>>> 15:20:46.799042 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>>> 3661928:3664848, ack 4262, win 297, length 2920
>>> 15:20:46.799465 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>>> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3172828}], length 0
>>> 15:20:46.799479 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>>> 3664848:3666308, ack 4262, win 297, length 1460
>>> 15:20:46.799497 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>>> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3174288}], length 0
>>> 15:20:46.799504 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>>> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3175748}], length 0
>>> 15:20:46.799509 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>>> 3666308:3667768, ack 4262, win 297, length 1460
>>> 15:20:46.799773 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>>> 3171176, win 32491, options [nop,nop,sack 1 {3171368:3172828}], length 0
>>> 15:20:46.799787 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>>> 3667768:3669228, ack 4262, win 297, length 1460
>>> 15:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>>> 3171368, win 32716, options [nop,nop,sack 1 {3171368:3177208}], length 0
>>> 15:20:46.800081 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>>> 3171368:3172828, ack 4262, win 297, length 1460
>>>
>>> Might that be packet-reordering in the other direction?  Sadly, I don't
>>> have
>>> good "both sides" traces as the receiving system doesn't seem to capture
>>> traffic terribly well.  I suppose TCP timestamps might have helped answer
>>> that question.
>>
>>
>> Regardless of any possible reordering, in this case we know something
>> odd is going on in the receiver because ACK advances at the same time
>> the SACK block shrinks.
>
>
> Ah yes, I'd not picked-up on that.
>
> thanks,
>
> rick jones
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
