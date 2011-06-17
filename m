From: Brandon Black <blblack@gmail.com>
Subject: Re: [PATCH] net: Add sendmmsg socket system call
Date: Fri, 17 Jun 2011 08:15:02 -0500
Message-ID: <BANLkTimZV2uoKmeHztv=PH9Ycq+mOYdhdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:45081 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758947Ab1FQNPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 09:15:03 -0400
Received: by qyk9 with SMTP id 9so53383qyk.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 06:15:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re: the patch in http://lists.openwall.net/netdev/2011/05/03/12 ,
which is now in the 3.0-rc kernels

I was wondering if would it be possible / valid to add support to
sendmmsg() for skipping packets with a zero msg_iovlen?  The use-case
I'm think of here is a daemon that's basically looping on recvmmsg() +
sendmmsg() to cut overhead.  The simplest userspace approach in this
sort of case is to re-use the same mmsg_hdr and set of iov's for both
recvmmsg() and sendmmsg().

Consider this scenario though: It may, for example, receive 8 packets,
parse them in userspace, decide packet #5 is malformed, and then wish
to respond only to packets 1-4,6-8.  However, in order to drop a
response packet from the set with the current sendmmsg()
implementation, the userspace code would have to shift all of the
mmsg_hdr entries down to close the gaps where no response was desired.
 If sendmmsg() had code to simply skip the underlying sendmsg() on
msg_iovlen = 0, it becomes a lot simpler to handle this case.  sendmsg
with a msg_iovlen of zero currently sends a packet with no data (just
UDP headers in the UDP case) it seems.

The arguments against this would be that some applications may have a
use for sending zero-data-bytes packets via this mechanism today
(although there's the alternate path for this with msg_iovlen = 1 and
a zero length for the actual iov within), and the overhead of adding
another branch in the sendmmsg() code.  I suppose there's a middle
route too, where we add a custom flags for sendmmsg() to turn on this
behavior, and leave the default at today's behavior.

Anyone have any thoughts for/against this idea?  Leaving this alone in
the kernel and doing the shifting in userspace isn't too bad a
solution either, but if nobody has a problem with patching in the
"skip on msg_iovlen == 0" behavior it does make the userspace code
cleaner and simpler.

-- Brandon
