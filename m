From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 3/3] net: sctp: Add partial support for
 MSG_MORE on SCTP
Date: Mon, 14 Jul 2014 16:27:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17271E0B@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1726EEB7@AcuExch.aculab.com>
 <53C04509.70304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49643 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755709AbaGNQ2m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:28:42 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32337-07 for <netdev@vger.kernel.org>;
 Mon, 14 Jul 2014 17:28:32 +0100 (BST)
In-Reply-To: <53C04509.70304@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
...
> > +	/* Setting MSG_MORE currently has the same effect as enabling Nagle.
> > +	 * This means that the user can't force bundling of the first two data
> > +	 * chunks.  It does mean that all the data chunks will be sent
> > +	 * without an extra timer.
> > +	 * It is enough to save the last value since any data sent with
> > +	 * MSG_MORE clear will already have been sent (subject to flow control).
> > +	 */
> > +	if (msg->msg_flags & MSG_MORE)
> > +		sp->tx_delay |= SCTP_F_TX_MSG_MORE;
> > +	else
> > +		sp->tx_delay &= ~SCTP_F_TX_MSG_MORE;
> > +
> 
> This is ok for 1-1 sockets, but it doesn't really work for 1-many sockets.  If one of
> the associations uses MSG_MORE while another does not, we'll see some interesting
> side-effects on the wire.

They shouldn't cause any grief, and are somewhat unlikely.
Unless multiple threads/processes are writing data into the same socket
and are also flipping MSG_MORE (and the socket locking allows the
send path to run concurrently - I suspect it doesn't).

AFAICT the tx_delay/Nagle flag is looked at in two code paths:
1) After the application tries to send some data.
2) When processing a received ack chunk.

For 1-many sockets I suspect the code that checks tx_delay after a send()
is executed before a send() from a different thread could change the value.
And that sends for alternate destinations won't try to clear the tx queue
for the other association.
So the send() processing is unlikely to be affected by the MSG_MORE flag
value for the other association.

The only time there will be sendable data for (2) is if the connection
were flow-controlled off, or if data were unsent due the MSG_MORE/Nagle
being set when the last send was processed.
Most likely the queued data will be sent - either because there is nothing
outstanding, because there is more than a packet full, or because the last
send had MSG_MORE clear.

The expectation is that an application will send some data chunks with
MSG_MORE set, followed by one with it clear.

The only scenario I can see that might be unexpected is:
- a 1-many socket.
- one destination flow controlled (ie waiting an ack chunk) but
  with less than 1500 bytes queued.
- send with MSG_MORE set for a different destination.
- ack received, queued data not sent.

But if you are waiting for ack chunks on a 1-many socket you are already
in deep trouble - since there is only a single socket send buffer.

I don't think this is a problem.

	David
