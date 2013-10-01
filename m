From: Chris Verges <cverges@sentient-energy.com>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Tue, 1 Oct 2013 06:27:08 -0700
Message-ID: <20131001132707.GA7442@cverges-dev-lnx.sentient-energy.com>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
 <1380203383.3165.172.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:43544 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371Ab3JAN1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 09:27:23 -0400
Received: by mail-pd0-f180.google.com with SMTP id y10so7188375pdj.25
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 06:27:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380203383.3165.172.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 26, 2013 at 06:49:43AM -0700, Eric Dumazet wrote:
> On Wed, 2013-09-25 at 23:04 -0700, Chris Verges wrote:
> >   (6) Physically disconnect the USB/Ethernet adapter from the USB
> >       bus.
> >   (7) Linux removes the 'eth0' interface and associated IP address.
> > 
> > At this point, the socket _still_ shows as ESTABLISHED under
> > netstat.
> > 
> > This is the paradox.  Why is the blocking read not interrupted with
> > a socket error to indicate that the socket is no longer viable?
> 
> Because TCP layer is not sensitive to such temporary events.  You can
> plug again your iface, and IP is valid again.  Why should we give a
> permanent error for such case ?

Yes, the interface could be reconnected ... or it could not be.
Consider an embedded device where a PPP-based radio module is powered
off for a decent amount of time (hours).

  +--------+          +-----------------+
  | Client |----------| Embedded Server |
  +--------+          +-----------------+

The client establishes a connection to the server.  It requests some
data and gets a response.  The socket remains open.  The server then
decides, through some asynchronous process, that the radio needs to be
duty cycled.  So the radio is turned off.

The client attempts to make another request to the device, but
determines that the connection is dead through the normal retry
mechanisms.  It's write() operation returns something like EPIPE.  So on
the client's side, the connection is dead.

But on the server side, the socket is still open and waiting for some
more data.  The interface and IP address and even the remote client are
long gone, but the socket still persists and uses system resources.

This is primarily an issue when the server binds/listens/accepts without
using a socket pool to process sockets after the accept().  That is, the
server processes only one socket.  If the socket resource is held by
this now-dead connection, there is generally no way to reset it without
lengthy or costly keepalives (depending on whether the keepalive timer
is set long or short, respectively.)

> If network communication is cut somewhere, TCP is not supposed to
> immediately react. Normal timeouts and retransmits take place. 

I agree in the sense that "somewhere" is between the remote station
(inclusive) and the local station (exclusive.)  I would argue that the
local station could be aware of its own state changes and may choose to
respond accordingly.

I can see the arguments for why the existing behavior would be viewed
favorably.  From this particular real-world scenario that I am
encountering, I can also see why a modified behavior would be useful.
Would you consider accepting a patch that adds a new socket option to
optionally control this?  The effect would be to cause the socket to
automatically close (interrupting any blocking reads) if the underlying
address used by the socket is unregistered from the stack.  Default
behavior would be maintained.

Thanks,
Chris
