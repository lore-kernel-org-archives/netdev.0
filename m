From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] net: sctp: Add partial support for MSG_MORE
 on SCTP
Date: Mon, 14 Jul 2014 15:15:36 -0400
Message-ID: <53C42C58.3050108@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1726EEB7@AcuExch.aculab.com> <53C04509.70304@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D17271E0B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:44799 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147AbaGNTPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 15:15:40 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17271E0B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2014 12:27 PM, David Laight wrote:
> From: Vlad Yasevich
> ...
>>> +	/* Setting MSG_MORE currently has the same effect as enabling Nagle.
>>> +	 * This means that the user can't force bundling of the first two data
>>> +	 * chunks.  It does mean that all the data chunks will be sent
>>> +	 * without an extra timer.
>>> +	 * It is enough to save the last value since any data sent with
>>> +	 * MSG_MORE clear will already have been sent (subject to flow control).
>>> +	 */
>>> +	if (msg->msg_flags & MSG_MORE)
>>> +		sp->tx_delay |= SCTP_F_TX_MSG_MORE;
>>> +	else
>>> +		sp->tx_delay &= ~SCTP_F_TX_MSG_MORE;
>>> +
>>
>> This is ok for 1-1 sockets, but it doesn't really work for 1-many sockets.  If one of
>> the associations uses MSG_MORE while another does not, we'll see some interesting
>> side-effects on the wire.
> 
> They shouldn't cause any grief, and are somewhat unlikely.
> Unless multiple threads/processes are writing data into the same socket
> and are also flipping MSG_MORE (and the socket locking allows the
> send path to run concurrently - I suspect it doesn't).
> 
> AFAICT the tx_delay/Nagle flag is looked at in two code paths:
> 1) After the application tries to send some data.
> 2) When processing a received ack chunk.
> 
> For 1-many sockets I suspect the code that checks tx_delay after a send()
> is executed before a send() from a different thread could change the value.
> And that sends for alternate destinations won't try to clear the tx queue
> for the other association.
> So the send() processing is unlikely to be affected by the MSG_MORE flag
> value for the other association.

But the MSG_MORE is not per association.  It is per socket.  So if you have
a process with 2 threads that clears Nagle (sets SCTP_NODELAY) and then
uses MSG_MORE to force bundling when it has a lot of data in queue then
you can have the following:
  1: send(MSG_MORE)
  1: send(MSG_MORE)
  2: send()

The send from thread2 will reset the tx_delay across the socket.  If
association from thread 1 then receives a SACK, it will flush the queue
before it's ready.  So, you have a side-effect that you don't get the
bundling that you are really after with MSG_MORE usage.

> 
> The only time there will be sendable data for (2) is if the connection
> were flow-controlled off, or if data were unsent due the MSG_MORE/Nagle
> being set when the last send was processed.
> Most likely the queued data will be sent - either because there is nothing
> outstanding, because there is more than a packet full, or because the last
> send had MSG_MORE clear.
> 
> The expectation is that an application will send some data chunks with
> MSG_MORE set, followed by one with it clear.
> 

Within a single thread, sure.  But it you have multiple association as above,
you could end up with a scenario where MSG_MORE is almost useless.

> The only scenario I can see that might be unexpected is:
> - a 1-many socket.
> - one destination flow controlled (ie waiting an ack chunk) but
>   with less than 1500 bytes queued.
> - send with MSG_MORE set for a different destination.
> - ack received, queued data not sent.
> 
> But if you are waiting for ack chunks on a 1-many socket you are already
> in deep trouble - since there is only a single socket send buffer.

Not always.  A lot of deployments that use 1-many socket specifically
change buffering policy.

> 
> I don't think this is a problem.

Not, it is not a _problem_, but it does make MSG_MORE rather useless
in some situations.  Waiting for an ACK across low-latency links
is rare, but in a high-latency scenarios where you want to utilize the
bandwidth better with bundling, you may not see the gains you expect.

Since MSG_MORE is association, it should be handled as such and an
a change on one association should not effect the others.

-vlad
> 
> 	David
> 
> 
