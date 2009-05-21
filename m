From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 14:51:22 -0300
Message-ID: <20090521175122.GL5956@ghostprotocols.net>
References: <20090520230652.GB5956@ghostprotocols.net> <469958e00905210938s371b5dect28c7b1f8bb751ad1@mail.gmail.com> <20090521165515.GK5956@ghostprotocols.net> <469958e00905211026q468de6fbh2b5932d177b7c7a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Caitlin Bestler <caitlin.bestler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55797 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbZEURv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 13:51:27 -0400
Content-Disposition: inline
In-Reply-To: <469958e00905211026q468de6fbh2b5932d177b7c7a9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, May 21, 2009 at 10:26:58AM -0700, Caitlin Bestler escreveu:
> On Thu, May 21, 2009 at 9:55 AM, Arnaldo Carvalho de Melo
> <acme@ghostprotocols.net> wrote:
> 
> >
> > I.e. recvmmsg would save the value of sk->sk_rcvtimeo at entry and
> > restore at exit, and would somehow go on subtracting the time
> > sock_recvmsg() took from it so that the following call finds a reduced
> > sk->sk_rcvtimeo iif it was configured in the first place and the socket
> > is in blocking mode.
> >
> > How does that sound?
> >
> 
> I suspect that an additional timeout value will be needed ultimately.

So you mean we need a timeout to wait for a datagram, that remains being
sk->sk_rcvtimeo (SO_RCVTIMEO), and one that is passed as a parameter to
recvmmsg?
 
> Essentially there is the existing timeout (how long will I wait before I
> want to be told that there have been no messages) and an additional
> "delivery pending" timeout (how long can the delivery of a message
> be delayed to attempt to coalesce it with other messages).

I gather this is an yes for the question I asked above :)
 
> There is also one sticky compliance issue with SCTP, delivery of an
> UNORDERED message MUST NOT be delayed waiting for other traffic.
> There is no guarantee that the local client will be scheduled immediately,
> just a prohibition on delaying delivery for the purpose of bundling.
> 
> That might mean a specific transport would have to support multiple
> conditional timeouts: maximum delay after an SCTP Event, after an
> UNORDERED message, after a message with PPID X, etc. Or for
> TCP after a PUSH FLAG, or after certain flags have been set, etc.
> 
> Those could probably be reduced to delivering immediately after
> any message that the transport flags as "urgent", and *all* error
> completions are urgent (which is what the code first shown does).

checking if MSG_OOB is set in the last datagram returned by the
unlocked_recvmsg call, that would make recvmmsg return imediately even
if in blocking mode and not having filled the array, ok.
 
> The specific transport could then use setsockopt to control what
> messages qualified as "urgent" in a transport specific manner.

OK

- Arnaldo
