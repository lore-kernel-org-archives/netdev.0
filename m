From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99461] New: recvfrom SYSCALL infinite loop/deadlock
 chewing 100% CPU [was __libc_recv (fd=fd@entry=300,
 buf=buf@entry=0x7f6042880600, n=n@entry=5, flags=-1, flags@entry=258) at
 ../sysdeps/unix/sysv/linux/x86_64/recv.c:33]
Date: Tue, 9 Jun 2015 17:05:06 -0700
Message-ID: <20150609170506.7789783d@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:36219 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbbFJAFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 20:05:04 -0400
Received: by qcxw10 with SMTP id w10so12082100qcx.3
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 17:05:03 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id w67sm3395067qha.7.2015.06.09.17.05.02
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:05:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 5 Jun 2015 12:39:38 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99461] New: recvfrom SYSCALL infinite loop/deadlock chewing 100% CPU [was __libc_recv (fd=fd@entry=300, buf=buf@entry=0x7f6042880600, n=n@entry=5, flags=-1, flags@entry=258) at ../sysdeps/unix/sysv/linux/x86_64/recv.c:33]


https://bugzilla.kernel.org/show_bug.cgi?id=99461

            Bug ID: 99461
           Summary: recvfrom SYSCALL infinite loop/deadlock chewing 100%
                    CPU [was __libc_recv (fd=fd@entry=300,
                    buf=buf@entry=0x7f6042880600, n=n@entry=5, flags=-1,
                    flags@entry=258) at
                    ../sysdeps/unix/sysv/linux/x86_64/recv.c:33]
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13.0
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: dan@censornet.com
        Regression: No

This is a repost of a bug I reported initially to the GNU libc bug list
(https://sourceware.org/bugzilla/show_bug.cgi?id=18493).

I was advised by Andreas Schwab that __libc_recv function is just a thin
wrapper around the recvfrom system call, and to report this to "the kernel
people", which I assume is you people.

Here's a summary of the problem:

In a multi-threaded pthreads process running on Ubuntu 14.04 AMD64 (with over
1000 threads) which uses real time FIFO scheduling, we occasionally see calls
to recv() with flags (MSG_PEEK | MSG_WAITALL) get stuck in an infinte loop or
deadlock meaning the threads lock up chewing as much CPU as they can (due to
FIFO scheduling) while stuck inside recv().

Here's an example gdb back trace:

[Switching to thread 4 (Thread 0x7f6040546700 (LWP 27251))]
#0  0x00007f6231d2f7eb in __libc_recv (fd=fd@entry=146,
buf=buf@entry=0x7f6040543600, n=n@entry=5, flags=-1, flags@entry=258) at
../sysdeps/unix/sysv/linux/x86_64/recv.c:33
33      ../sysdeps/unix/sysv/linux/x86_64/recv.c: No such file or directory.
(gdb) bt
#0  0x00007f6231d2f7eb in __libc_recv (fd=fd@entry=146,
buf=buf@entry=0x7f6040543600, n=n@entry=5, flags=-1, flags@entry=258) at
../sysdeps/unix/sysv/linux/x86_64/recv.c:33
#1  0x0000000000421945 in recv (__flags=258, __n=5, __buf=0x7f6040543600,
__fd=146) at /usr/include/x86_64-linux-gnu/bits/socket2.h:44
[snip]

The socket is a TCP socket in blocking mode, the recv() call is inside an outer
loop with a counter, and I've checked the counter with gdb and it's always at
1, meaning that I'm sure that the outer loop isn't the problem, the thread is
indeed deadlocked inside the recv() internals.

Other nodes: 
* There always seems to be 2 or more threads deadlocked in the same place (same
recv() call but with distinct FDs)
* The threads calling recv() have cancellation disbaled by previously
executing: thread_setcancelstate(PTHREAD_CANCEL_DISABLE, NULL);

I've even tried adding a poll() call for POLLRDNORM on the socket before
calling recv() with MSG_PEEK | MSG_WAITALL flags to try to make sure there's
data available on the socket before calling *recv()*, but it makes no
difference.

So, I don't know what is wrong here, I've read all the recv() documentation and
believe that recv() is being used correctly, the only conclusion I can come to
is that there is a bug in libc recv() when using flags MSG_PEEK | MSG_WAITALL
with thousands of pthreads running.

-- 
You are receiving this mail because:
You are the assignee for the bug.
