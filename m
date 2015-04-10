From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 96381] New: TUN/TAP user API regression in 3.19,
 non-bloking read returns 0 when no data is available rather than EAGAIN
Date: Fri, 10 Apr 2015 13:10:59 -0700
Message-ID: <20150410131059.304d579c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36607 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbbDJUKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:10:54 -0400
Received: by pabsx10 with SMTP id sx10so31371725pab.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:10:54 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id gm3sm3089191pbb.83.2015.04.10.13.10.53
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Apr 2015 13:10:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 9 Apr 2015 09:25:41 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 96381] New: TUN/TAP user API regression in 3.19, non-bloking read returns 0 when no data is available rather than EAGAIN


https://bugzilla.kernel.org/show_bug.cgi?id=96381

            Bug ID: 96381
           Summary: TUN/TAP user API regression in 3.19, non-bloking read
                    returns 0 when no data is available rather than EAGAIN
           Product: Networking
           Version: 2.5
    Kernel Version: 3.19.3
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: ambrop7@gmail.com
        Regression: No

With kernel 3.19, a read() from a TUN/TAP file descriptor in non-blocking mode
will return 0 when no data is available, rather than fail with EAGAIN. This
breaks certain applications which will interpret the 0 return value as a
zero-length packet and happily go on reading more packets.

Here's relevant parts of my application showing the change of behavior and how
the application locks up with kernel 3.19.

-- strace with 3.18 --
open("/dev/net/tun", O_RDWR)            = 5
ioctl(5, TUNSETIFF, 0x7ffe24f1e620)     = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 6
ioctl(6, SIOCGIFMTU, {ifr_name="tun4", ifr_mtu=1500}) = 0
close(6)                                = 0
fcntl(5, F_SETFL, O_RDONLY|O_NONBLOCK)  = 0
epoll_ctl(3, EPOLL_CTL_ADD, 5, {0, {u32=6509592, u64=6509592}}) = 0
read(5, 0xac8010, 1500)                 = -1 EAGAIN (Resource temporarily
unavailable)
epoll_ctl(3, EPOLL_CTL_MOD, 5, {EPOLLIN, {u32=6509592, u64=6509592}}) = 0

-- strace with 3.19 --
open("/dev/net/tun", O_RDWR)            = 5
ioctl(5, TUNSETIFF, 0x7ffea2f4d970)     = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 6
ioctl(6, SIOCGIFMTU, {ifr_name="tun4", ifr_mtu=1500}) = 0
close(6)                                = 0
fcntl(5, F_SETFL, O_RDONLY|O_NONBLOCK)  = 0
epoll_ctl(3, EPOLL_CTL_ADD, 5, {0, {u32=6509592, u64=6509592}}) = 0
read(5, "", 1500)                       = 0
read(5, "", 1500)                       = 0
read(5, "", 1500)                       = 0
read(5, "", 1500)                       = 0
read(5, "", 1500)                       = 0
...

-- 
You are receiving this mail because:
You are the assignee for the bug.
