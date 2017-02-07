From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 194241] New: LXC - setns() performance issue with more
 than 1vCPU
Date: Tue, 7 Feb 2017 08:30:32 -0800
Message-ID: <20170207083032.1882acd1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34810 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751037AbdBGQaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:30:35 -0500
Received: by mail-pg0-f41.google.com with SMTP id 14so40079807pgg.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 08:30:35 -0800 (PST)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id l71sm12871881pga.13.2017.02.07.08.30.34
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Feb 2017 08:30:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 07 Feb 2017 02:18:18 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 194241] New: LXC - setns() performance issue with more than 1=
vCPU


https://bugzilla.kernel.org/show_bug.cgi?id=3D194241

            Bug ID: 194241
           Summary: LXC - setns() performance issue with more than 1vCPU
           Product: Networking
           Version: 2.5
    Kernel Version: 3.6.57 , 3.16.7
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: skarmarkar@sonusnet.com
        Regression: No

Created attachment 254411
  --> https://bugzilla.kernel.org/attachment.cgi?id=3D254411&action=3Dedit =
=20
sample program to reproduce the issue

Description of problem:
Facing a peculiar problem with setns () call.=20
Trying to test the network namespace basic functionality and performance te=
sts.
The basic test is to create two network namespaces (nstest1, and nstest2) a=
nd
enabled the loopback interfaces in them.
Then the test program called setns () function (Re-associate thread with a
namespace) to switch from namespace to nstest1, then from nstest1 to nstest=
2,
from nstest2 to ntest1 etc. (round-robin).


Version-Release number of selected component (if applicable):

As part of the tests tried on kernel 3.6.57 and kernel 3.16.7, and ran the =
same
setns() tests with only one CPU, and observed system call rates of several
million calls per second. The results were incredibly different - for kernel
3.6.57 it was 0.22 micro second per setns() call vs. 2.1 milli second (10,0=
00
times faster; for kernel 3.16.7 it was 0.16 micro second per setns() call v=
s.
31 milli second (200,000 times faster).

1.       On kernel 3.6.57, the same test run on 1-CPU VM executed 100,000,0=
00
setns () calls in 22 seconds (4,545,454 calls per second; 0.22 micro second=
 per
call).=20
2.       On kernel 3.6.57, the same test run on 2-CPU or 4-CPU VM executed
10000 setns() calls in 21 seconds (476 calls per second; 2.1 milli second p=
er
call)


How reproducible:
easily and always reproducible

Steps to Reproduce:

Attached test program

Details on the program below-
test_netns.c =E2=80=93 (attached).

  - Based on http://linux.die.net/man/2/setns
Build:
  $ gcc -g -o test_netns test_netns.c

Test setup:
  1. Create network namespaces nstest1 and nstest2, and bring up loopback (=
lo)=20
     # ip netns add nstest1
     # ip netns add nstest2
     # ip netns exec nstest1 ip link set dev lo up
     # ip netns exec nstest2 ip link set dev lo up
  2. Make sure that the namespaces are seen.
     # ip netns
     nstest1
     nstest2
     # ls /var/run/netns/
nstest1  nstest2
  3. Get the PID of the current process. This PID is to be used in the test
command.
     # echo $$
     24821
     #
  4. Run the test. Need to replace [PID] from the Step 3; replace [ITERS] w=
ith
number of desired
     setns() calls.
     # ./test_netns /var/run/netns/nstest1 /var/run/netns/nstest2
/proc/[PID]/ns/net [ITERS] "/sbin/ip link"
  4.A Example for running the test for 1000 iterations for PID=3D24821 for =
three
namespaces:=20
     two namespaces and process's own:
     # ./test_netns /var/run/netns/nstest1 /var/run/netns/nstest2
/proc/24821/ns/net 1000 "/sbin/ip link"

Actual results:


Expected results:


Additional info:

--=20
You are receiving this mail because:
You are the assignee for the bug.
