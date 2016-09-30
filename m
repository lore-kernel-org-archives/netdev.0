From: Jay Smith <jay@kentik.com>
Subject: Re: UDP wierdness around skb_copy_and_csum_datagram_msg()
Date: Fri, 30 Sep 2016 10:35:25 -0700
Message-ID: <87a8epp9ya.fsf@kentik.com>
References: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com> <1475112246.28155.122.camel@edumazet-glaptop3.roam.corp.google.com> <CAA3=++_6O69hcutQ_FmaivrR3UV-uKScyX8+iHOBV9kraizOFQ@mail.gmail.com> <3897844.9kvF4Wy8aS@debian64>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jay Smith <jay@kentik.com>, Alan Curry <rlwinm@sdf.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        "davem\@davemloft.net" <davem@davemloft.net>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32889 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932348AbcI3RfS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 13:35:18 -0400
Received: by mail-pa0-f48.google.com with SMTP id cd13so37292436pac.0
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 10:35:17 -0700 (PDT)
In-reply-to: <3897844.9kvF4Wy8aS@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Christian Lamparter writes:

> On Wednesday, September 28, 2016 7:20:39 PM CEST Jay Smith wrote:
>> Actually, on a little more searching of this list's archives, I think
>> that this discussion:  https://patchwork.kernel.org/patch/9260733/ is
>> about exactly the same issue I've found, except from the TCP side. I'm
>> cc'ing a few of the participants from that discussion.
>> 
>> So is the patch proposed there (copying and restoring the entire
>> iov_iter in skb_copy_and_csum_datagram_msg()) being considered as a
>> fix?
>
> From Alan's post:
>
> "My ugly patch fixes this in the most obvious way: make a local copy of
> msg->msg_iter before the call to skb_copy_and_csum_datagram(), and copy
> it back if the checksum is bad, just before goto csum_error;"
>
> IMHO this meant that the patch is a proof of concept for his problem.

It's also the simplest thing that fixes all of the relevant cases (udp4,
udp6, tcp4).  Basically, the state of the iov_iter (which, if I'm
reading correctly, consists of three elements -- iov_offset, count, and
nr_segs all change values as the iterator moves through the vectors)
needs to be backed-up and restored at exactly the points in datagram.c
where Alan's patch does so.

Whether that should be done with memcpy, as Alan does, or by exposing
some more abstract backup/restore functions from iov_iter.c is a matter
of taste.  I'm happy to accept the call of someone more maintainer-ish
on that.


> Al Viro identified more inconsistencies within the error-paths that deal
> with EFAULT in the whole area (in and around skb_copy_and_csum_datagram()).

Was this in some other thread?  The only other discussion I see of that
function in the "PROBLEM: network data corruption..." thread is around
this patch https://patchwork.kernel.org/patch/9245023/ , which as Al
says was just a diagnostic patch -- it intentionally doesn't handle the
multiple-vector case.

It seems like the EFAULT case in skb_copy_and_csum_datagram() would
indicate that the iov_iter code ran out of room to copy the current
message, even though it's checked for that room at datagram.c:738.
Which I guess is possible -- there could be some non-obvious counting
error in the iov_inter.c macros.  But, at least in the UDP cases, it
wouldn't trigger the same problem as a checksum failure -- the EFAULT
gets returned to the caller in that case, and the buffer isn't meant
to be valid.  It's only in the checksum case that we retry underneath
the udp_recvmsg() covers, and end up returning the supposedly-rejected data.


>
> As for fixing the issue: I'm happy to test and review patches. 
> The trouble is that nobody seem to be able to produce them...

Sorry -- is the trouble you're talking about here that no-one's produced
a patch, or that we don't have a reproduction of the problem?  I don't
think either is true.

The test program I'd attached to my first mail reliably reproduces
the UDP version of the problem.  It's pretty simple: listen on a UDP
port (using loopback, so that there's no hardware csum offload), use a
raw socket to send a datagram with a bad UDP checksum, then send a good
datagram, and then finally read from the socket.  On post-3.19 kernels,
you always get the contents of the bad packet at the start of the user
buffer: 

# bin/csumtestn 69
listening on port 47193
recvmsg returned 9 bytes: BAD DATABAD DATABAD DATABAD DATABAD DATABAD DATABAD DATABAD DATABAD DGood data

After Alan's patch, the good packet's contents are at the start of the
buffer, where they belong:

# bin/csumtestn 69
listening on port 54620
recvmsg returned 9 bytes: Good dataAD DATABAD DATABAD DATABAD DATABAD DATABAD DATABAD DATABAD D

So functionally, I believe that Alan's patch does the trick.  I haven't
actually tested it on UDP6, but a similar test should work there.

Inserting the bad packets deterministically into a TCP connection is
trickier, but I thought in the previous thread that you and Alan both
had wireless hardware configurations that frequently generated checksum
errors, and that Alan's claim was that his patch gave him good TCP data
even in the presence of those checksum errors.  Or do I misunderstand?

(Just to be clear, though, if there is a need for a new patch, for
whatever reason, I'm happy to generate one.)
