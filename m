From: Rick Jones <rick.jones2@hp.com>
Subject: Re: get beyond 1Gbps with pktgen on 10Gb nic?
Date: Tue, 18 May 2010 09:50:47 -0700
Message-ID: <4BF2C567.2070609@hp.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net>	<1273584925.2107.6.camel@achroite.uk.solarflarecom.com>	<4BE97DD7.7000704@candelatech.com>	<4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85C81@MILEXCH2.ds.jdsu.net>	<AANLkTilZseWJCHnDXSjwUYol7ewXewIhMJG-tqWO_C86@mail.gmail.com>	<4BEAF44E.8090201@hp.com> <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC00D@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:28386 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124Ab0ERQuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 12:50:51 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC00D@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jon Zhou wrote:
> hi rick:
> 
> do you mean "TCP_NODELAY" will send with packet size as I expect
> without this option,netperf might sent packet with large size? (but
> eventually it will be splitted into MTU size?)

First things first - netperf only ever calls send() with the size you give it 
via the command line.

It is what happens after that which matters.  Specifically, then when/how TCP 
decides to send the data across the network.  Setting TCP_NODELAY will disable 
the Nagle Algorithm, which, 99 times out of 10, will cause each send() call by 
the application to be a separate TCP segment.  The 100th time out of 10, 
something like a retransmission or a zero window from the remote etc may still 
cause multiple small send() calls to be aggregated into larger segments.  How 
much larger will depend on the Maximum Segment Size (MSS) for the connection, 
the MTU is one of the inputs to the decision of what to use for the MSS.

At the end of this message is a bit of boilerplate I have on the aforementioned 
Nagle algorithm. It is a bit generic, not stack-specific.  It discusses issues 
beyond benchmarking considerations, so keep that in mind while you are reading it.

happy benchmarking,

rick jones


$ cat usenet_replies/nagle_algorithm

 > I'm not familiar with this issue, and I'm mostly ignorant about what
 > tcp does below the sockets interface. Can anybody briefly explain what
 > "nagle" is, and how and when to turn it off? Or point me to the
 > appropriate manual.

In broad terms, whenever an application does a send() call, the logic
of the Nagle algorithm is supposed to go something like this:

1) Is the quantity of data in this send, plus any queued, unsent data,
greater than the MSS (Maximum Segment Size) for this connection? If
yes, send the data in the user's send now (modulo any other
constraints such as receiver's advertised window and the TCP
congestion window). If no, go to 2.

2) Is the connection to the remote otherwise idle? That is, is there
no unACKed data outstanding on the network. If yes, send the data in
the user's send now. If no, queue the data and wait. Either the
application will continue to call send() with enough data to get to a
full MSS-worth of data, or the remote will ACK all the currently sent,
unACKed data, or our retransmission timer will expire.

Now, where applications run into trouble is when they have what might
be described as "write, write, read" behaviour, where they present
logically associated data to the transport in separate 'send' calls
and those sends are typically less than the MSS for the connection.
It isn't so much that they run afoul of Nagle as they run into issues
with the interaction of Nagle and the other heuristics operating on
the remote. In particular, the delayed ACK heuristics.

When a receiving TCP is deciding whether or not to send an ACK back to
the sender, in broad handwaving terms it goes through logic similar to
this:

a) is there data being sent back to the sender? if yes, piggy-back the
ACK on the data segment.

b) is there a window update being sent back to the sender? if yes,
piggy-back the ACK on the window update.

c) has the standalone ACK timer expired.

Window updates are generally triggered by the following heuristics:

i) would the window update be for a non-trivial fraction of the window
- typically somewhere at or above 1/4 the window, that is, has the
application "consumed" at least that much data? if yes, send a
window update. if no, check ii.

ii) would the window update be for, the application "consumed," at
least 2*MSS worth of data? if yes, send a window update, if no wait.

Now, going back to that write, write, read application, on the sending
side, the first write will be transmitted by TCP via logic rule 2 -
the connection is otherwise idle. However, the second small send will
be delayed as there is at that point unACKnowledged data outstanding
on the connection.

At the receiver, that small TCP segment will arrive and will be passed
to the application. The application does not have the entire app-level
message, so it will not send a reply (data to TCP) back. The typical
TCP window is much much larger than the MSS, so no window update would
be triggered by heuristic i. The data just arrived is < 2*MSS, so no
window update from heuristic ii. Since there is no window update, no
ACK is sent by heuristic b.

So, that leaves heuristic c - the standalone ACK timer. That ranges
anywhere between 50 and 200 milliseconds depending on the TCP stack in
use.

If you've read this far :) now we can take a look at the effect of
various things touted as "fixes" to applications experiencing this
interaction.  We take as our example a client-server application where
both the client and the server are implemented with a write of a small
application header, followed by application data.  First, the
"default" case which is with Nagle enabled (TCP_NODELAY _NOT_ set) and
with standard ACK behaviour:

               Client                     Server
              Req Header        ->
                                <-        Standalone ACK after Nms
              Req Data          ->
                                <-        Possible standalone ACK
                                <-        Rsp Header
              Standalone ACK    ->
                                <-        Rsp Data
     Possible standalone ACK    ->


For two "messages" we end-up with at least six segments on the wire.
The possible standalone ACKs will depend on whether the server's
response time, or client's think time is longer than the standalone
ACK interval on their respective sides. Now, if TCP_NODELAY is set we
see:


               Client                     Server
              Req Header        ->
              Req Data          ->
                                <-        Possible Standalone ACK after Nms
                                <-        Rsp Header
                                <-        Rsp Data
      Possible Standalone ACK   ->

In theory, we are down two four segments on the wire which seems good,
but frankly we can do better.  First though, consider what happens
when someone disables delayed ACKs

               Client                     Server
              Req Header        ->
                                <-        Immediate Standalone ACK
              Req Data          ->
                                <-        Immediate Standalone ACK
                                <-        Rsp Header
    Immediate Standalone ACK    ->
                                <-        Rsp Data
    Immediate Standalone ACK    ->

Now we definitly see 8 segments on the wire.  It will also be that way
if both TCP_NODELAY is set and delayed ACKs are disabled.

How about if the application did the "right" think in the first place?
That is sent the logically associated data at the same time:


               Client                     Server
              Request        ->
                             <-           Possible Standalone ACK
                                <-        Response
    Possible Standalone ACK    ->

We are down to two segments on the wire.

For "small" packets, the CPU cost is about the same regardless of data
or ACK.  This means that the application which is making the propper
gathering send call will spend far fewer CPU cycles in the networking
stack.
