From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 01:10:05 -0400
Message-ID: <48C6052D.2080203@redhat.com>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51432 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbYIIFLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 01:11:42 -0400
In-Reply-To: <48C5A9A9.9040503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Christopher Snook wrote:
>> Hey folks --
>>
>> We frequently get requests from customers for a tunable to disable 
>> Nagle system-wide, to be bug-for-bug compatible with Solaris. 
> 
> Which ndd setting is that in Solaris, and is it an explicit disabling of 
> Nagle (which wouldn't be much better than arbitrary setting of 
> TCP_NODELAY by apps anyway), or is it a tuning of the send size against 
> which Nagle is comparing?

Dunno, but I'm told it effectively sets TCP_NODELAY on every socket on 
the box.

>> We routinely reject these requests, as letting naive TCP apps
>> accidentally flood the network is considered harmful. Still, it would
>> be very nice if we could reduce Nagle-induced latencies system-wide,
>> if we could do so without disabling Nagle completely.
>>
>> If you write a multi-threaded app that sends lots of small messages 
>> across TCP sockets, and you do not use TCP_NODELAY, you'll often see 
>> 40 ms latencies as the network stack waits for more senders to fill an 
>> MTU-sized packet before transmitting. 
> 
> How does an application being multi-threaded enter into it?  IIRC, it is 
> simply a matter of wanting to go "write, write, read" on the socket 
> where the writes are sub-MSS.

Sorry, I'm getting my problems confused.  Being multi-threaded isn't the 
root problem, it just makes the behavior much less predictable.  Instead 
of getting the latency every other write, you might get it once in every 
million writes on a highly-threaded workload, which masks the source of 
the problem.

>> Even worse, these apps may work fine across the LAN with a 1500 MTU
>> and then counterintuitively perform much worse over loopback with a
>> 16436 MTU.
> 
> Without knowing if those apps were fundamentally broken and just got 
> "lucky" at a 1500 byte MTU we cannot really say if it is truly 
> counterintuitive :)

This is open to debate, but there are certainly a great many apps doing 
a great deal of very important business that are subject to this problem 
to some degree.

>> To combat this, many apps set TCP_NODELAY, often without the abundance 
>> of caution that option should entail.  Other apps leave it alone, and 
>> suffer accordingly.
>>
>> If we could simply lower this latency, without changing the 
>> fundamental behavior of the TCP stack, it would be a great benefit to 
>> many latency-sensitive apps, and discourage the unnecessary use of 
>> TCP_NODELAY.
>>
>> I'm afraid I don't know the TCP stack intimately enough to understand 
>> what side effects this might have.  Can someone more familiar with the 
>> nagle implementations please enlighten me on how this could be done, 
>> or why it shouldn't be?
> 
> 
> IIRC, the only way to lower the latency experienced by an application 
> running into latencies associated with poor interaction with Nagle is to 
> either start generating immediate ACKnowledgements at the reciever, 
> lower the standalone ACK timer on the receiver, or start a very short 
> timer on the sender.  I doubt that (m)any of those are terribly palatable.

I'd like to know where the 40 ms magic number comes from.  That's the 
one that really hurts, and if we could lower that without doing horrible 
things elsewhere in the stack, as a non-default tuning option, a lot of 
people would be very happy.

> Below is some boilerplate I have on Nagle that isn't Linux-specific:
> 
> <begin>
> 
> $ cat usenet_replies/nagle_algorithm
> 
>  > I'm not familiar with this issue, and I'm mostly ignorant about what
>  > tcp does below the sockets interface. Can anybody briefly explain what
>  > "nagle" is, and how and when to turn it off? Or point me to the
>  > appropriate manual.
> 
> In broad terms, whenever an application does a send() call, the logic
> of the Nagle algorithm is supposed to go something like this:
> 
> 1) Is the quantity of data in this send, plus any queued, unsent data,
> greater than the MSS (Maximum Segment Size) for this connection? If
> yes, send the data in the user's send now (modulo any other
> constraints such as receiver's advertised window and the TCP
> congestion window). If no, go to 2.
> 
> 2) Is the connection to the remote otherwise idle? That is, is there
> no unACKed data outstanding on the network. If yes, send the data in
> the user's send now. If no, queue the data and wait. Either the
> application will continue to call send() with enough data to get to a
> full MSS-worth of data, or the remote will ACK all the currently sent,
> unACKed data, or our retransmission timer will expire.
> 
> Now, where applications run into trouble is when they have what might
> be described as "write, write, read" behaviour, where they present
> logically associated data to the transport in separate 'send' calls
> and those sends are typically less than the MSS for the connection.
> It isn't so much that they run afoul of Nagle as they run into issues
> with the interaction of Nagle and the other heuristics operating on
> the remote. In particular, the delayed ACK heuristics.
> 
> When a receiving TCP is deciding whether or not to send an ACK back to
> the sender, in broad handwaving terms it goes through logic similar to
> this:
> 
> a) is there data being sent back to the sender? if yes, piggy-back the
> ACK on the data segment.
> 
> b) is there a window update being sent back to the sender? if yes,
> piggy-back the ACK on the window update.
> 
> c) has the standalone ACK timer expired.
> 
> Window updates are generally triggered by the following heuristics:
> 
> i) would the window update be for a non-trivial fraction of the window
> - typically somewhere at or above 1/4 the window, that is, has the
> application "consumed" at least that much data? if yes, send a
> window update. if no, check ii.
> 
> ii) would the window update be for, the application "consumed," at
> least 2*MSS worth of data? if yes, send a window update, if no wait.
> 
> Now, going back to that write, write, read application, on the sending
> side, the first write will be transmitted by TCP via logic rule 2 -
> the connection is otherwise idle. However, the second small send will
> be delayed as there is at that point unACKnowledged data outstanding
> on the connection.
> 
> At the receiver, that small TCP segment will arrive and will be passed
> to the application. The application does not have the entire app-level
> message, so it will not send a reply (data to TCP) back. The typical
> TCP window is much much larger than the MSS, so no window update would
> be triggered by heuristic i. The data just arrived is < 2*MSS, so no
> window update from heuristic ii. Since there is no window update, no
> ACK is sent by heuristic b.
> 
> So, that leaves heuristic c - the standalone ACK timer. That ranges
> anywhere between 50 and 200 milliseconds depending on the TCP stack in
> use.
> 
> If you've read this far :) now we can take a look at the effect of
> various things touted as "fixes" to applications experiencing this
> interaction.  We take as our example a client-server application where
> both the client and the server are implemented with a write of a small
> application header, followed by application data.  First, the
> "default" case which is with Nagle enabled (TCP_NODELAY _NOT_ set) and
> with standard ACK behaviour:
> 
>               Client                     Server
>              Req Header        ->
>                                <-        Standalone ACK after Nms
>              Req Data          ->
>                                <-        Possible standalone ACK
>                                <-        Rsp Header
>              Standalone ACK    ->
>                                <-        Rsp Data
>     Possible standalone ACK    ->
> 
> 
> For two "messages" we end-up with at least six segments on the wire.
> The possible standalone ACKs will depend on whether the server's
> response time, or client's think time is longer than the standalone
> ACK interval on their respective sides. Now, if TCP_NODELAY is set we
> see:
> 
> 
>               Client                     Server
>              Req Header        ->
>              Req Data          ->
>                                <-        Possible Standalone ACK after Nms
>                                <-        Rsp Header
>                                <-        Rsp Data
>      Possible Standalone ACK   ->
> 
> In theory, we are down two four segments on the wire which seems good,
> but frankly we can do better.  First though, consider what happens
> when someone disables delayed ACKs
> 
>               Client                     Server
>              Req Header        ->
>                                <-        Immediate Standalone ACK
>              Req Data          ->
>                                <-        Immediate Standalone ACK
>                                <-        Rsp Header
>    Immediate Standalone ACK    ->
>                                <-        Rsp Data
>    Immediate Standalone ACK    ->
> 
> Now we definitly see 8 segments on the wire.  It will also be that way
> if both TCP_NODELAY is set and delayed ACKs are disabled.
> 
> How about if the application did the "right" think in the first place?
> That is sent the logically associated data at the same time:
> 
> 
>               Client                     Server
>              Request        ->
>                             <-           Possible Standalone ACK
>                                <-        Response
>    Possible Standalone ACK    ->
> 
> We are down to two segments on the wire.
> 
> For "small" packets, the CPU cost is about the same regardless of data
> or ACK.  This means that the application which is making the propper
> gathering send call will spend far fewer CPU cycles in the networking
> stack.
> 
> <end>
> 
> Now, there are further wrinkles :)  Is that application trying to 
> pipeline requests on the application - then we have paths that can look 
> rather like the separate header from data cases above until the 
> concurrent requests outstanding get above the MSS threshold.
> 
> My recollection of the original Nagle writeups is the intention is to 
> optimize the ratio of data to data+headers.  Back when those writeups 
> were made, 536 byte MSSes were still considered pretty large, and 1460 
> would have been positively spacious.  I doubt that anyone were 
> considering the probability of a 16384 byte MTU.  It could be argued 
> that in such an environment of the timeperiod, where stack tunables 
> weren't all the rage and the MSS ranges were reasonably well bounded, it 
> was a sufficient expedient to base the "is this enough data" decision 
> off the MSS for the connection.  You certainly couldn't do any better 
> than an MSS's worth of data per segment and segment sizes weren't 
> astronomical.  Now that MTU's and MSS's can get so much larger, that 
> expedient may indeed not be so worthwhile.   An argument could be made 
> that a ratio of data to data plus headers of say 0.97 (1448/1500) is 
> "good enough" and that requiring a ratio of 16384/16436 = 0.9968 is 
> taking things too far by default.
> 
> That said, I still don't like covering the backsides of poorly written 
> applications doing two or more writes for logically associated data.
> 
> rick jones

Most of the apps where people care about this enough to complain to 
their vendor (the cases I hear about) are in messaging apps, where 
they're relaying a stream of events that have little to do with each 
other, and they want TCP to maintain the integrity of the connection and 
do a modicum of bandwidth management, but 40 ms stalls greatly exceed 
their latency tolerances.  Using TCP_NODELAY is often the least bad 
option, but sometimes it's infeasible because of its effect on the 
network, and it certainly adds to the network stack overhead.  A more 
tunable Nagle delay would probably serve many of these apps much better.

-- Chris
