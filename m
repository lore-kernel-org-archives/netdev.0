From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of timestamps?
Date: Tue, 4 Mar 2014 14:14:44 -0500
Message-ID: <CABrhC0k5-x=qJgH4izXtRR=9+cLJh_emAy9Yt=+xrY6K5982Fg@mail.gmail.com>
References: <53151E55.9000503@hp.com>
	<CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com>
	<53162093.1040208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:48422 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756058AbaCDTOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 14:14:45 -0500
Received: by mail-vc0-f179.google.com with SMTP id lc6so570942vcb.10
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 11:14:45 -0800 (PST)
In-Reply-To: <53162093.1040208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 4, 2014 at 1:50 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 03/03/2014 07:22 PM, John Heffner wrote:
>> If you look where things really go wrong, the receiver is sending
>> anomalous SACK blocks that will trigger the SACK renege handling path.
>>   Reneging triggers go-back-n behavior, so we see the spurious
>> retransmits from there on.
>
>
> Should those subsequent ACKs be clocking-out additional retransmissions like
> they appear to do? (Assuming I'm not projecting into the trace) Or is that
> an unavoidable consequence of there being no timestamps with which to tell
> which send was being ACKed?

It's possible that if they had timestamps, the ACKs for for original
transmits might not open up the window, thus preventing the
retransmits from going out.  But I'm not nearly familiar enough with
the details of the current retransmit machinery to know for sure.
Reneging like this (go-back-n before a timeout) is not a
commonly-exercised case, so I wouldn't be too surprised if the sender
isn't doing the smartest possible thing.


>> The most notable bad segment is this one:
>> 18:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.],
>> ack 3171368, win 32716, options [nop,nop,sack 1 {3171368:3177208}],
>> length 0
>> It contains a SACK block contiguous with the acked seqno.
>
>
> I've gone back through one of the other traces and found the same thing
> therein.
>
>
>> There is some other strangeness just before that, where the SACK
>> block shrinks then grows again.
>
>
> That would be this yes?
>
> 15:20:46.798816 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
> 3660468:3661928, ack 4262, win 297, length 1460
> 15:20:46.799027 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
> 3168256, win 32081, options [nop,nop,sack 1 {3171368:3172828}], length 0
> 15:20:46.799042 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
> 3661928:3664848, ack 4262, win 297, length 2920
> 15:20:46.799465 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3172828}], length 0
> 15:20:46.799479 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
> 3664848:3666308, ack 4262, win 297, length 1460
> 15:20:46.799497 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3174288}], length 0
> 15:20:46.799504 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3175748}], length 0
> 15:20:46.799509 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
> 3666308:3667768, ack 4262, win 297, length 1460
> 15:20:46.799773 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
> 3171176, win 32491, options [nop,nop,sack 1 {3171368:3172828}], length 0
> 15:20:46.799787 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
> 3667768:3669228, ack 4262, win 297, length 1460
> 15:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
> 3171368, win 32716, options [nop,nop,sack 1 {3171368:3177208}], length 0
> 15:20:46.800081 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
> 3171368:3172828, ack 4262, win 297, length 1460
>
> Might that be packet-reordering in the other direction?  Sadly, I don't have
> good "both sides" traces as the receiving system doesn't seem to capture
> traffic terribly well.  I suppose TCP timestamps might have helped answer
> that question.

Regardless of any possible reordering, in this case we know something
odd is going on in the receiver because ACK advances at the same time
the SACK block shrinks.

  -John
