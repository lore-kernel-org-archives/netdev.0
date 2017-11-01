From: Vitaly Davidovich <vitalyd@gmail.com>
Subject: TCP connection closed without FIN or RST
Date: Wed, 1 Nov 2017 16:25:27 -0400
Message-ID: <CAHjP37HOFvQyitEC1s73PHoj120AhE6C6N+FXGUfbd82XO+GQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:49660 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755218AbdKAUZa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 16:25:30 -0400
Received: by mail-lf0-f52.google.com with SMTP id w21so3909251lfc.6
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 13:25:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm seeing some puzzling TCP behavior that I'm hoping someone on this
list can shed some light on.  Apologies if this isn't the right forum
for this type of question.  But here goes anyway :)

I have client and server x86-64 linux machines with the 4.1.35 kernel.
I set up the following test/scenario:

1) Client connects to the server and requests a stream of data.  The
server (written in Java) starts to send data.
2) Client then goes to sleep for 15 minutes (I'll explain why below).
3) Naturally, the server's sendq fills up and it blocks on a write() syscall.
4) Similarly, the client's recvq fills up.
5) After 15 minutes the client wakes up and reads the data off the
socket fairly quickly - the recvq is fully drained.
6) At about the same time, the server's write() fails with ETIMEDOUT.
The server then proceeds to close() the socket.
7) The client, however, remains forever stuck in its read() call.

When the client is stuck in read(), netstat on the server does not
show the tcp connection - it's gone.  On the client, netstat shows the
connection with 0 recv (and send) queue size and in ESTABLISHED state.

I have done a packet capture (using tcpdump) on the server, and
expected to see either a FIN or RST packet to be sent to the client -
neither of these are present.  What is present, however, is a bunch of
retrans from the server to the client, with what appears to be
exponential backoff.  However, the conversation just stops around the
time when the ETIMEDOUT error occurred.  I do not see any attempt to
abort or gracefully shut down the TCP stream.

When I strace the server thread that was blocked on write(), I do see
the ETIMEDOUT error from write(), followed by a close() on the socket
fd.

Would anyone possibly know what could cause this? Or suggestions on
how to troubleshoot further? In particular, are there any known cases
where a FIN or RST wouldn't be sent after a write() times out due to
too many retrans? I believe this might be related to the tcp_retries2
behavior (the system is configured with the default value of 15),
where too many retrans attempts will cause write() to error with a
timeout.  My understanding is that this shouldn't do anything to the
state of the socket on its own - it should stay in the ESTABLISHED
state.  But then presumably a close() should start the shutdown state
machine by sending a FIN packet to the client and entering FIN WAIT1
on the server.

Ok, as to why I'm doing a test where the client sleeps for 15 minutes
- this is an attempt at reproducing a problem that I saw with a client
that wasn't sleeping intentionally, but otherwise the situation
appeared to be the same - the server write() blocked, eventually timed
out, server tcp session was gone, but client was stuck in a read()
syscall with the tcp session still in ESTABLISHED state.

Thanks a lot ahead of time for any insights/help!
