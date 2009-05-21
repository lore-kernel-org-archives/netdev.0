From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Wed, 20 May 2009 23:05:41 -0300
Message-ID: <20090521020541.GD5956@ghostprotocols.net>
References: <20090520230652.GB5956@ghostprotocols.net> <20090521004634.GB29869@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52771 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbZEUCFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2009 22:05:51 -0400
Content-Disposition: inline
In-Reply-To: <20090521004634.GB29869@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, May 20, 2009 at 08:46:34PM -0400, Neil Horman escreveu:
> On Wed, May 20, 2009 at 08:06:52PM -0300, Arnaldo Carvalho de Melo wrote:
> > Meaning receive multiple messages, reducing the number of syscalls and
> > net stack entry/exit operations.
> > 
> > Next patches will introduce mechanisms where protocols that want to
> > optimize this operation will provide an unlocked_recvmsg operation.
> > 
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Its a neat idea, I like the possibility on saving lots of syscalls for
> busy sockets, but I imagine the addition of a new syscall gives people pause.  I
> wonder if simply augmenting the existing recvmsg syscall with a message flag to
> indicate that multiple messages can be received on that call.
> 
> What I would propose looks something like:
> 
> 1) define a new flag in the msghdr pointer for msg_flags, MSG_COMPOUND.  Setting
> this on the call lets the protocol we can store multiple messages
> 
> 2) if this flag is set the msg_control pointer should contain a cmsghdr with a
> new type MSG_COMPOUND_NEXT, in which the size is sizeof(void *) and the data
> contains a pointer to the next msghdr pointer.
> 
> 3) The kernel can iteratively fill out buffers passed in through the chain,
> setting the MSG_COMPOUND flag on each msghdr that contains valid data.  The
> first msghdr to not have the MSG_COMPOUND flag set denotes the last buffer that
> the kernel put valid data in.  This way the buffer chain pointer is kept
> unchanged, and userspace can follow it to free the data if need be.
> 
> Thoughts?

I didn't went into such detail when discussing this with Dave on IRC,
but I thought about something like using a setsockopt to tell the kernel
that the socket was in multiple message mode, lemme look at the
discussion to be faithful to it...

[18:22] <acme> I see, but the bastardization I was thinking was about just
putting a datagram per iovec instead of taking a datagram and go on
spilling it over the iovec entries, if some sockopt was set, as a first
try ;-)
[18:23] <davem> Oh I see
[18:23] <davem> that would work too

But I think that the interface I proposed, that was Dave's general idea,
should be ok as well for sendmmsg, to send multiple messages to
different destinations using markings like one msg_iovlen to signal that
the previous msg_iov/msg_iovlen should be used for a different
destination.

The reasoning behing the proposed interface was to mostly keep the
existing way of passing iovecs to the kernel, but this time around
passing multiple iovecs instead of just one.

Existing code would just have to make the iovecs, msg_name, etc be
arrays instead of rethinking how to talk to the kernel completely.

So... lets hear more opinions :-)

Ah, I went to a local pub to relax and left three machines non-stop
pounding a "chrt -f 1 ./rcvmmsg 5001 64" patched server and it hold up
for hours:

nr_datagrams received: 24
    4352 bytes received from mica.ghostprotocols.net in 17 datagrams
    1536 bytes received from doppio.ghostprotocols.net in 6 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
nr_datagrams received: 18
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    3072 bytes received from doppio.ghostprotocols.net in 12 datagrams
    256 bytes received from mica.ghostprotocols.net in 1 datagrams
    256 bytes received from doppio.ghostprotocols.net in 1 datagrams
    256 bytes received from mica.ghostprotocols.net in 1 datagrams
    256 bytes received from doppio.ghostprotocols.net in 1 datagrams
    256 bytes received from mica.ghostprotocols.net in 1 datagrams
nr_datagrams received: 26
    5120 bytes received from mica.ghostprotocols.net in 20 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    1280 bytes received from doppio.ghostprotocols.net in 5 datagrams
nr_datagrams received: 18
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    1792 bytes received from doppio.ghostprotocols.net in 7 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    1792 bytes received from doppio.ghostprotocols.net in 7 datagrams
    256 bytes received from mica.ghostprotocols.net in 1 datagrams
    256 bytes received from do^C    256 bytes received from filo.ghostprotocols.net in 1 datagrams

:-)

- Arnaldo
