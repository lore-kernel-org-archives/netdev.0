From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Mon, 19 Oct 2015 09:59:38 -0700
Message-ID: <20151019095938.72ea48e6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34281 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbbJSQ73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 12:59:29 -0400
Received: by padhk11 with SMTP id hk11so34886543pad.1
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 09:59:28 -0700 (PDT)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id xm4sm37650639pab.27.2015.10.19.09.59.28
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 09:59:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This looks like corner case, but worth forwarding.

Begin forwarded message:

Date: Mon, 19 Oct 2015 13:21:33 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)


https://bugzilla.kernel.org/show_bug.cgi?id=106241

            Bug ID: 106241
           Summary: shutdown(3)/close(3) behaviour is incorrect for
                    sockets in accept(3)
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.0-229.14.1.el7.x86_64
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: Alan.Burlison@oracle.com
        Regression: No

Created attachment 190501
  --> https://bugzilla.kernel.org/attachment.cgi?id=190501&action=edit
Test program illustrating the problem

The Linux behaviour in the current scenario is incorrect:

1. ThreadA opens, binds, listens and accepts on a socket, waiting for
connections.

2. Some time later ThreadB calls shutdown on the socket ThreadA is waiting in
accept on.

Here is what happens:

On Linux, the shutdown call in ThreadB succeeds and the accept call in ThreadA
returns with EINVAL.

On Solaris, the shutdown call in ThreadB fails and returns ENOTCONN. ThreadA
continues to wait in accept.

Relevant POSIX manpages:

http://pubs.opengroup.org/onlinepubs/9699919799/functions/accept.html
http://pubs.opengroup.org/onlinepubs/9699919799/functions/shutdown.html

The POSIX shutdown manpage says:

"The shutdown() function shall cause all or part of a full-duplex connection on
the socket associated with the file descriptor socket to be shut down."
...
"[ENOTCONN] The socket is not connected."

Page 229 & 303 of "UNIX System V Network Programming" say:

"shutdown can only be called on sockets that have been previously connected"

"The socket [passed to accept that] fd refers to does not participate in the
connection. It remains available to receive further connect indications"

That is pretty clear, sockets being waited on with accept are not connected by
definition. Nor is it the accept socket connected when a client connects to it,
it is the socket returned by accept that is connected to the client. Therefore
the Solaris behaviour of failing the shutdown call is correct.

In order to get the required behaviour of ThreadB causing ThreadA to exit the
accept call with an error, the correct way is for ThreadB to call close on the
socket that ThreadA is waiting on in accept.

On Solaris, calling close in ThreadB succeeds, and the accept call in ThreadA
fails and returns EBADF.

On Linux, calling close in ThreadB succeeds but ThreadA continues to wait in
accept until there is an incoming connection. That accept returns successfully.
However subsequent accept calls on the same socket return EBADF.

The Linux behaviour is fundamentally broken in three places:

1. Allowing shutdown to succeed on an unconnected socket is incorrect.  

2. Returning a successful accept on a closed file descriptor is incorrect,
especially as future accept calls on the same socket fail.

3. Once shutdown has been called on the socket, calling close on the socket
fails with EBADF. That is incorrect, shutdown should just prevent further IO on
the socket, it should not close it.

-- 
You are receiving this mail because:
You are the assignee for the bug.
