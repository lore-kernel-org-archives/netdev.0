From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 17:31:02 +0200
Message-ID: <1502724662.8411.53.camel@redhat.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca>
         <1502702846.8411.25.camel@redhat.com> <1846443.VTclhqQinN@ring00>
         <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Matthew Dawson <matthew@mjdsystems.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46404 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753014AbdHNPbF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 11:31:05 -0400
In-Reply-To: <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-14 at 11:03 -0400, Willem de Bruijn wrote:
> > I'm actually surprised that only unix sockets can have negative values.  Is
> > there a reason for that?  I had assumed that sk_set_peek_off would allow
> > negative values as the code already has to support negative values due to what
> > the initial value is.
> 
> A negative initial value indicates that PEEK_OFF is disabled. It only
> makes sense to peek from a positive offset from the start of the data.

With the current code, the user space can disable peeking with offset
setting a negative offset value, after that peeking with offset has
been enabled. But only for UNIX sockets. I think the same should be
allowed for UDP sockets.

> > > I'm wondering adding an explicit SOCK_PEEK_OFF/MSG_PEEK_OFF socket flag
> > > would help simplyifing the code:
> 
> The behavior needs to be bifurcated between peeking with
> offset and without offset.
> 
> When peeking with offset is enabled by setting SO_PEEK_OFF,
> subsequent reads do move the offset, so the observed behavior
> is correct.
> 
> When sk->sk_peek_offset is negative, offset mode is disabled
> and the same packet must be read twice.
> 
> An explicit boolean flag to discern between the two may make
> the code simpler to understand, not sure whether that is logically
> required.

Yes, an explicit PEEK_OFF flag is just to keep the code simpler, so
that there is no need to add checks at every sk_peek_offset() call site
and the relevant logic can be fully encapsulated under the MSG_PEEK
branch in __skb_try_recv_from_queue(), I think/hope.
It's not a functional requirement.

Cheers,

Paolo
