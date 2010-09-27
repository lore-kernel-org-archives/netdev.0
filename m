From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 12:12:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1009271159070.2191@u.domain.uli>
References: <20100926232530.GK12373@1wt.eu> <20100926.181202.28824153.davem@davemloft.net> <20100927053901.GL12373@1wt.eu> <20100926.234202.241938788.davem@davemloft.net> <20100927073443.GR12373@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56667 "EHLO u.domain.uli"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758958Ab0I0JNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 05:13:05 -0400
In-Reply-To: <20100927073443.GR12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Mon, 27 Sep 2010, Willy Tarreau wrote:

> case A (current one) :
>   we send the response to the client from an orphaned connection.
>   Most of the times, the client won't have any issue and will get the
>   response. In some rare circumstances, some data sent by the client
>   after the response causes an RST to be emitted, which may destroy
>   in flight data. But those issues are extremely rare, still they
>   happen.
>
> case B (my proposal, and was the case before the RFC2525 fix) :
>   we send the response to the client.
>   it acks it
>   we send an RST. End of the transfer. Total time: 50ms (avg RTT over ADSL).
>
> case C (alternative) :
>   we send the response to the client.
>   the application can't know it has acked it, and must maintain the
>   connection open for however long is necessary to get the only form
>   of ACK the application can detect: the FIN from the client, which
>   is 6 minutes on my ADSL line for 10 meg.

 	If it is not already mentioned, the application can
know if sent data is acked. I think, ioctl SIOCOUTQ is for
this purpose. May be the application that wants to send
reliably HTTP error response before closing should do something
like:

- add this FD in some list for monitoring instead of keeping
large connection state
- use shutdown SHUT_WR to add FIN after response
- use setsockopt SO_RCVBUF with some low value to close the
RX window, we do not want the body
- wait for POLLHUP (FIN), not for POLLIN because we want to
ignore data, not to read it. Still, data can be read and
dropped if needed to release the socket memory
- use timer to limit the time we wait our data to be acked
- use SIOCOUTQ to know if everything is received in peer and
then close the fd

> In case C, not only the state remains *a lot* longer, but the bandwidth
> usage is much worse, and in the end the client does not even get the reset
> that we're trying to ensure it gets to indicate that the data were dropped.
>
> So while case C is a reliable workaround, it's the least efficient method
> and the most expensive one in terms of memory, CPU, network bandwidth,
> socket usage, file descriptor usage and perceived time.
>
> You see, I'm not trying to make dirty dangerous things to save a few
> lines of code. I'm even OK to have a lot of linux-specific code to make
> use of the features the linux stack provides that makes it more efficient
> than other implementations. I'm just seeking reliability.
>
> Willy

Regards

--
Julian Anastasov <ja@ssi.bg>
