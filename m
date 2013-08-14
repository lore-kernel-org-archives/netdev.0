From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP Connection teardown seems to violate TCP specification
Date: Wed, 14 Aug 2013 14:38:51 -0700
Message-ID: <520BF8EB.4060800@hp.com>
References: <1376508095.4596.12.camel@nexus> <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com> <520BE51F.40208@hp.com> <1376515097.9293.6.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:49101 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760471Ab3HNVix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 17:38:53 -0400
In-Reply-To: <1376515097.9293.6.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2013 02:18 PM, Damian Lukowski wrote:
> At least in curl, the close() seems to be implicit as it occurs
> at the very end of the trace:
>
> close(3)                                = 0
> exit_group(0)                           = ?
> +++ exited with 0 +++
>
> Nevertheless, shouldn't the stack keep on reading the input
> even if the local application is not interested in it?
> The other side might rely on it, and I've seen webserver logs
> which indicate SSL read errors likely because of this.

Ignoring for a moment the SSL matter, if you get a tutorial on (BSD) 
sockets or a copy of the works of the likes of the late W. Richard 
Stevens you will find that the semantics of close() are such that there 
is no way for the received data to be consumed by an application - it no 
longer has a reference to the socket, so to where can the data go?

If then data arrives, what is TCP to do?  Clearly, from the standpoint 
of TCP, something is amiss.  The local application has indicated it is 
not expecting any more data (by calling close()) and more data has 
arrived.  TCP could discard the data and not ACK it, which would simply 
leave the remote TCP retransmitting until a limit was reached at the 
remote.  TCP could bit-bucket the data and send-back ACKs, but that is 
giving a false sense of "success" to the remote application.  So, TCP 
does the only thing it can do - it sends a Reset (RST) segment back to 
the sender.  This then is an indication that something went wrong - in 
this case there was an application-layer error.  Sadly, TCP has no way 
to say that rather than some other TCP-level error - it has just the one 
RST bit.

If the other side relies on the data it is sending being consumed, and 
the local side close()es, that is an indication of an application-layer 
failure - they did not "handshake" their goodbye correctly.

Also, close() is not the half-close of which you read in the TCP RFC. 
In the BSD Sockets interface (not to be confused with the "sockets" 
mentioned in the RFC) the call one makes to effect a half-close of a 
connection is shutdown(SHUT_WR).  In that case, the application retains 
a reference to the socket, and so can consume data until the remote end 
itself then calls either SHUTDOWN(SHUT_WR) or close() (close() being OK 
here at the remote because the connection is already half-closed so the 
remote isn't going to be receiving any data in the first place).

So, at the client side or more accurately the side initiating TCP 
connection shutdown the sequence should be something like:

1) shutdown(SHUT_WR) - this will cause TCP to send a FINished segment to 
the remote TCP, and the remote TCP will indicate this to the remote 
application via a read return of zero.
2) wait for a read return of zero, perhaps bit bucketing data - this 
read return of zero will indicate that the remote application has gotten 
the notification and has itself closed
3) close()

Now, step two can be ever so slightly problematic - how long to wait?

As for SSL...  I cannot begin to pretend to be an SSL protocol expert, 
but in looking at some traces recently, and at one of the more recent 
RFCs, I think they have a slight hole in their specification.  The 
(current?) spec says that an SSL Close Notify alert message is to be 
sent (exchanged?) when terminating the SSL session.  The specs also say 
that a client can just send the Close Notify and go away. (eg a close - 
implicit or explicit)

Trouble is, the remote side will want to send a Close Notify of its own. 
  If the client has Close Notified and scooted, or even just close()ed 
without a Close Notify sent, the remote/server's Close Notify will hit 
the client's TCP stack and elicit a RST segment.  Even better is when 
there is a statefull firewall between client and server, which then 
closes-off the four-tuple.  If that RST is lost on the way back to the 
server, the server TCP will continue retransmitting the Close Notify 
message, which will hit the firewall and be dropped.  The firewall may 
then log "Hey, I dropped this packet trying to get in" entries for each 
of those retransmissions, which then may cause people looking at said 
logs to become "concerned..."

rick jones
