From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Wed, 26 Oct 2011 10:56:55 -0700
Message-ID: <4EA849E7.5030503@hp.com>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:42489 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932953Ab1JZR45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 13:56:57 -0400
In-Reply-To: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2011 07:25 PM, Andy Lutomirski wrote:
> When talking to an unfixable interactive peer that fails to set
> TCP_NODELAY, disabling delayed ACKs can help mitigate the problem.
> This is an evil thing to do, but if the entire network is private,
> it's not that evil.
>
> This works around a problem with the remote *application*, so make
> it a socket option instead of a sysctl or a per-route option.
>
> Signed-off-by: Andy Lutomirski<luto@amacapital.net>
> ---
>
> This patch is a bit embarrassing.  We talk to remote applications over
> TCP that are very much interactive but don't set TCP_NODELAY.  These
> applications apparently cannot be fixed.  As a partial workaround, if we
> ACK every incoming segment, then as long as they don't transmit two
> segments per rtt, we do pretty well.

Embarrassing/evil indeed - is it really something to go into the kernel?

If the networks where this happens are indeed truly private, can they 
run a private kernel?  Or use an LD_PRELOAD hack to wedge-in a 
setsockopt(TCP_NODELAY) call into the application?  Or set something 
like tcp_naglim_def on the application system(s)?  Or have the server 
application make a setsockopt(TCP_MAXSEG) call before listen() to a 
value one byte below that of what the application is sending?

Is the application actually "virtuous" in sending logically associated 
data in one "send" call, and simply running afoul of Nagle+DelayedACK in 
having multiple distinct requests outstanding at once, or is it actually 
quite evil in that it is sending logically associated data in separate 
send calls?

rick jones

choir preaching follows:

raj@tardy:~$ cat usenet_replies/nagle_algorithm

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
    no unACKed data outstanding on the network. If yes, send the data
    in the user's send now. If no, queue the data and wait. Either the
    application will continue to call send() with enough data to get to
    a full MSS-worth of data, or the remote will ACK all the currently
    sent, unACKed data, or our retransmission timer will expire.

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
     least 2*MSS worth of data? if yes, send a window update, if no
     wait.

Now, going back to that write, write, read application, on the sending
side, the first write will be transmitted by TCP via nagle rule 2 -
the connection is otherwise idle.  However, the second small send will
be delayed as there is at that point unACKnowledged data outstanding
on the connection.

At the receiver, that small TCP segment will arrive and will be passed
to the application. The application does not have the entire app-level
message, so it will not send a reply (data to TCP) back. The typical
TCP window is much much larger than the MSS, so no window update would
be triggered by heuristic i. The data just arrived and consumed by the
application is < 2*MSS, so no window update from heuristic ii.  Since
there is no window update, no ACK is sent by heuristic b.

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
