From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 13:45:45 -0300
Message-ID: <20090521164545.GJ5956@ghostprotocols.net>
References: <20090520230652.GB5956@ghostprotocols.net> <20090521161000.GA6638@ioremap.net> <20090521162753.GI5956@ghostprotocols.net> <1242923615.29604.409.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Steven Whitehouse <steve@chygwyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44453 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752773AbZEUQqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 12:46:06 -0400
Content-Disposition: inline
In-Reply-To: <1242923615.29604.409.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, May 21, 2009 at 05:33:35PM +0100, Steven Whitehouse escreveu:
> Hi,
> 
> On Thu, 2009-05-21 at 13:27 -0300, Arnaldo Carvalho de Melo wrote:
> > Em Thu, May 21, 2009 at 08:10:00PM +0400, Evgeniy Polyakov escreveu:
> > > Hi Arnaldo.
> > > 
> > > On Wed, May 20, 2009 at 08:06:52PM -0300, Arnaldo Carvalho de Melo (acme@redhat.com) wrote:
> > > > Meaning receive multiple messages, reducing the number of syscalls and
> > > > net stack entry/exit operations.
> > > > 
> > > > Next patches will introduce mechanisms where protocols that want to
> > > > optimize this operation will provide an unlocked_recvmsg operation.
> > >  
> > > What's the difference from the single msg with multiple iovecs?
> > 
> > recvmsg consumes just one skb, a datagram, truncating if it has more
> > bytes than asked and giving less bytes than asked for if the skb being
> > consumer is smaller than requested.
> > 
> > WRT iovec, it gets this skb/datagram and goes on filling iovec entry by
> > entry, till it exhausts the skb.
> > 
> > The usecase here is: UDP socket has multiple skbs in its receive queue,
> > so application will make several syscalls to get those skbs while we
> > could return multiple datagrams in just one syscall + fd lookup + LSM
> > validation + lock_sock + release_sock.
> > 
> Its not just UDP/SOCK_DGRAM either. SOCK_SEQPACKET has to return after
> each message because it is not allowed to (nor can it, given the api)
> return more than one message in a single call. So with small messages
> that can add up to a lot of calls. This way the MSG_EOR flags can be
> preserved in the correct places,

Yeah, SOCK_SEQPACKET are just not optimized in the current patch, it
could, just providing a sk_prot->unlocked_recvmsg call, etc.

And to use sock_common_recvmsg in its socket->ops, which not all
protocol families do, but was my plan long ago to make all use so that
we could shorten the path, etc :-)

- Arnaldo
