From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP connection closed without FIN or RST
Date: Wed, 01 Nov 2017 13:51:55 -0700
Message-ID: <1509569515.3828.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAHjP37HOFvQyitEC1s73PHoj120AhE6C6N+FXGUfbd82XO+GQg@mail.gmail.com>
         <1509568471.3828.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vitaly Davidovich <vitalyd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:53763 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751922AbdKAUv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 16:51:58 -0400
Received: by mail-io0-f170.google.com with SMTP id 189so9006860iow.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 13:51:57 -0700 (PDT)
In-Reply-To: <1509568471.3828.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-11-01 at 13:34 -0700, Eric Dumazet wrote:
> On Wed, 2017-11-01 at 16:25 -0400, Vitaly Davidovich wrote:
> > Hi all,
> > 
> > I'm seeing some puzzling TCP behavior that I'm hoping someone on this
> > list can shed some light on.  Apologies if this isn't the right forum
> > for this type of question.  But here goes anyway :)
> > 
> > I have client and server x86-64 linux machines with the 4.1.35 kernel.
> > I set up the following test/scenario:
> > 
> > 1) Client connects to the server and requests a stream of data.  The
> > server (written in Java) starts to send data.
> > 2) Client then goes to sleep for 15 minutes (I'll explain why below).
> > 3) Naturally, the server's sendq fills up and it blocks on a write() syscall.
> > 4) Similarly, the client's recvq fills up.
> > 5) After 15 minutes the client wakes up and reads the data off the
> > socket fairly quickly - the recvq is fully drained.
> > 6) At about the same time, the server's write() fails with ETIMEDOUT.
> > The server then proceeds to close() the socket.
> > 7) The client, however, remains forever stuck in its read() call.
> > 
> > When the client is stuck in read(), netstat on the server does not
> > show the tcp connection - it's gone.  On the client, netstat shows the
> > connection with 0 recv (and send) queue size and in ESTABLISHED state.
> > 
> > I have done a packet capture (using tcpdump) on the server, and
> > expected to see either a FIN or RST packet to be sent to the client -
> > neither of these are present.  What is present, however, is a bunch of
> > retrans from the server to the client, with what appears to be
> > exponential backoff.  However, the conversation just stops around the
> > time when the ETIMEDOUT error occurred.  I do not see any attempt to
> > abort or gracefully shut down the TCP stream.
> > 
> > When I strace the server thread that was blocked on write(), I do see
> > the ETIMEDOUT error from write(), followed by a close() on the socket
> > fd.
> > 
> > Would anyone possibly know what could cause this? Or suggestions on
> > how to troubleshoot further? In particular, are there any known cases
> > where a FIN or RST wouldn't be sent after a write() times out due to
> > too many retrans? I believe this might be related to the tcp_retries2
> > behavior (the system is configured with the default value of 15),
> > where too many retrans attempts will cause write() to error with a
> > timeout.  My understanding is that this shouldn't do anything to the
> > state of the socket on its own - it should stay in the ESTABLISHED
> > state.  But then presumably a close() should start the shutdown state
> > machine by sending a FIN packet to the client and entering FIN WAIT1
> > on the server.
> > 
> > Ok, as to why I'm doing a test where the client sleeps for 15 minutes
> > - this is an attempt at reproducing a problem that I saw with a client
> > that wasn't sleeping intentionally, but otherwise the situation
> > appeared to be the same - the server write() blocked, eventually timed
> > out, server tcp session was gone, but client was stuck in a read()
> > syscall with the tcp session still in ESTABLISHED state.
> > 
> > Thanks a lot ahead of time for any insights/help!
> 
> We might have an issue with win 0 probes (Probe0), hitting a max number
> of retransmits/probes.
> 
> I can check this

If the receiver does not reply to window probes, then sender consider
the flow is dead after 10 attempts (/proc/sys/net/ipv4/tcp_retries2 )

Not sure why sending a FIN or RST in this state would be okay, since
there is obviously something wrong on the receiver TCP implementation.

If after sending 10 probes, we need to add 10 more FIN packets just in
case there is still something at the other end, it adds a lot of
overhead on the network.
