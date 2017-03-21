From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Tue, 21 Mar 2017 15:49:16 -0700
Message-ID: <CALx6S36OBcdbk==Fi-bqO0BdAFzk1TkL76PPUwUQ8Dgz518zBw@mail.gmail.com>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
 <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
 <674d67f5d76f761f3e872dff274a8bda@codeaurora.org> <CALx6S340TYEFDAbQfG6X4P0tPJWvyxyXpnLgp9JY7UoBuPEJVA@mail.gmail.com>
 <1489191742.28631.35.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S36eXpOn70paFnkSyafMkF7Q=MQWJKKb2=d6+hNpK-8V8A@mail.gmail.com>
 <e643b82c330eabfa0cef21c480eb6c2c@codeaurora.org> <CALx6S343iWzOKrKwHquG8qmyLyKOgQr_KroHyypE_9MFt2+1BQ@mail.gmail.com>
 <c965b4cc8b5f81cc17836f91423935f5@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev-owner@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35890 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933007AbdCUWtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 18:49:23 -0400
Received: by mail-qt0-f196.google.com with SMTP id n37so23331825qtb.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 15:49:22 -0700 (PDT)
In-Reply-To: <c965b4cc8b5f81cc17836f91423935f5@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 7:07 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
>> Less than 1% performance improvement in a benchmark doesn't justify
>> the complexity of the patch. Eric's hypothesis was that an unconnected
>> UDP socket may show issues because of cache misses in look-ups due to
>> so many different sources. This should be fairly easy to benchmark by
>> randomly setting source address in your test (IP any and routing my
>> need to be set appropriately).
>>
>
> With different source addresses, a larger increase is seen here
> (633->654Mbps).
>
Thanks for running the tests. It's obviously not a huge win at least
relative to performance improvement we got from early demux, but I
suppose with very specific and engineered loads this might have value.
Please include this is next patch sets.

Generally, I think a good goal moving forward would be a to apply the
0 or 1 times rule for connection lookup. That is for any transport
tuple in a receive packet we want to do at most one connection lookup.
So early demux would need to apply to unconnected sockets and then we
wouldn't have to do the second lookup in UDP (or TCP for a SYN)
receive (note we also do an extra lookup for GRO with UDP
encapsulation). A reason we haven't this before might be that the
lookup may actually find the wrong socket (for example we go into a
different network namespace). Maybe the stack should consider any
lookup result outside of the protocol stack to be provisional (and it
would be super nice if we could somehow cache a dst with an
unconnected socket also ;-) )

Tom

>
> --
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> a Linux Foundation Collaborative Project
