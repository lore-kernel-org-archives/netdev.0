From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 11:03:50 -0400
Message-ID: <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Matthew Dawson <matthew@mjdsystems.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35895 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdHNPEb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 11:04:31 -0400
Received: by mail-oi0-f53.google.com with SMTP id g131so86264958oic.3
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 08:04:31 -0700 (PDT)
In-Reply-To: <1846443.VTclhqQinN@ring00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm actually surprised that only unix sockets can have negative values.  Is
> there a reason for that?  I had assumed that sk_set_peek_off would allow
> negative values as the code already has to support negative values due to what
> the initial value is.

A negative initial value indicates that PEEK_OFF is disabled. It only
makes sense to peek from a positive offset from the start of the data.

>> I'm wondering adding an explicit SOCK_PEEK_OFF/MSG_PEEK_OFF socket flag
>> would help simplyifing the code:

The behavior needs to be bifurcated between peeking with
offset and without offset.

When peeking with offset is enabled by setting SO_PEEK_OFF,
subsequent reads do move the offset, so the observed behavior
is correct.

When sk->sk_peek_offset is negative, offset mode is disabled
and the same packet must be read twice.

An explicit boolean flag to discern between the two may make
the code simpler to understand, not sure whether that is logically
required.

>> no need for negative offset; set such
>> flag when SOL_SOCKET/SO_PEEK_OFF with a non negative value is called
>> (and clear it when a negative value is used), forward such flag to
>> __skb_try_recv_datagram/__skb_try_recv_from_queue and use it to select
>> the proper peek behaviour.
> The negative value is documented and supported for unix sockets, so I don't
> think we can just reject all negative values.

What is the documented behavior on those sockets? The original
patch that introduced it explicitly mentions peek mode as disabled
when the value is negative:

  https://www.spinics.net/lists/netdev/msg189589.html

> However, I do see a way to
> implement that while supporting user space sending negative values.  If that
> is preferred let me know and I'll see what I can make.
>
> I assume that would make this patch target net-next?

I suspect that we can fix this with a small enough patch to be able
to send to net.

> Would it be possible to
> pull this into net so it can fix this regression for the next kernel release,
> while I work on getting the better solution finished?  I'm happy to to make
> __skb_try_recv_datagram/__skb_try_recv_from_queue accept the extra parameter
> so they don't see an offset less then 0 in this patch.
>
> --
> Matthew
