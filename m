From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 21:24:50 +0200
Message-ID: <20100927192450.GU12373@1wt.eu>
References: <20100926232530.GK12373@1wt.eu> <20100926.181202.28824153.davem@davemloft.net> <20100927053901.GL12373@1wt.eu> <20100926.234202.241938788.davem@davemloft.net> <20100927073443.GR12373@1wt.eu> <alpine.LFD.2.00.1009271159070.2191@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45725 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755640Ab0I0TY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 15:24:57 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1009271159070.2191@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian

[removed Davem from the CC upon his request, not to pollute him]

On Mon, Sep 27, 2010 at 12:12:24PM +0300, Julian Anastasov wrote:
> 	If it is not already mentioned, the application can
> know if sent data is acked. I think, ioctl SIOCOUTQ is for
> this purpose. May be the application that wants to send
> reliably HTTP error response before closing should do something
> like:
> 
> - add this FD in some list for monitoring instead of keeping
> large connection state
> - use shutdown SHUT_WR to add FIN after response
> - use setsockopt SO_RCVBUF with some low value to close the
> RX window, we do not want the body
> - wait for POLLHUP (FIN), not for POLLIN because we want to
> ignore data, not to read it. Still, data can be read and
> dropped if needed to release the socket memory
> - use timer to limit the time we wait our data to be acked
> - use SIOCOUTQ to know if everything is received in peer and
> then close the fd

Thanks very much for this suggestion. I was looking for something
like this and even looked at the tcp_info struct, but it did not
look very easy to use.

Still, I think that polling on POLLIN and checking with SIOCOUTQ
on every read to see if the out queue is now empty would do the
trick, without forcing to read huge amounts of unnecessary data.

I'll simply enclose that inside a #ifdef LINUX and that should be
OK. It kinda sucks to be able to workaround low level issues at the
application level but at least this workaround is acceptable.

Regards,
Willy

