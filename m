From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 93121] New: fib_lookup failed to find blackhole or
 prohibit or unreachable routes
Date: Thu, 12 Feb 2015 05:45:55 -0800
Message-ID: <20150212054555.7746b3ee@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:56949 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbbBLNqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 08:46:08 -0500
Received: by mail-pa0-f53.google.com with SMTP id lf10so11477568pab.12
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 05:46:08 -0800 (PST)
Received: from uryu.home.lan ([144.49.132.22])
        by mx.google.com with ESMTPSA id k3sm3839890pde.79.2015.02.12.05.46.06
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 05:46:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 12 Feb 2015 08:36:12 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 93121] New: fib_lookup failed to find blackhole or prohibit or unreachable routes


https://bugzilla.kernel.org/show_bug.cgi?id=93121

            Bug ID: 93121
           Summary: fib_lookup failed to find blackhole or prohibit or
                    unreachable routes
           Product: Networking
           Version: 2.5
    Kernel Version: since v3.6
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: alexandergusarov@gmail.com
        Regression: No

Trying functional of blackhole | prohibit | unreachable routes i have found
that kernel always generate ICMP Network Unreachable (type 3 code 0) packets as
reply to packets going to blackhole route.
It seems to after removing routing cache in kernel 3.6 fib_lookup() failed to
find something in FIB.
Trying functional on different versions of kernel show me that functional is
broken after kernel 3.5.
I tried: 
Ubuntu 10.04 whith 2.6.32 kernel - OK
Ubuntu 10.04 whith 3.0.0  kernel - OK
Ubuntu 12.04 whith 3.2.0  kernel - OK
Ubuntu 12.04 whith 3.5.0  kernel - OK
Ubuntu 12.04 whith 3.8.0  kernel - ERROR
Ubuntu 14.04 whith 3.13.0 kernel - ERROR
Ubuntu 15.04 whith 3.18.0 kernel - ERROR (daily build)

Steps to reproduce:
1) Two linux machines whith static IP adresses 
   Alpha - 192.168.1.1/24
   Beta  - 192.168.1.2/24
2) on Beta add route to 192.168.128.0/17 and blackhole routes to subbets
   $ ip route add 192.168.128.0/17 via 192.168.1.1 
   $ ip route add blackhole 192.168.128.0/19 
   $ ip route add prohibit 192.168.160.0/19 
   $ ip route add unreachable 192.168.192.0/19 
3) on Alpha add route to 192.168.128.0/17
   $ ip route add 192.168.128.0/17 via 192.168.1.2
4) on Alpha ping 192.168.128.1 (expected no reply)
   $ ping 192.168.128.1
   PING 192.168.128.1 (192.168.128.1) 56(84) bytes of data.
   From 192.168.1.1 icmp_seq=1 Destination Net Unreachable
   From 192.168.1.1 icmp_seq=2 Destination Net Unreachable
   ...
5) on Alpha ping 192.168.160.1 (expected reply "Packet Filtred")
   $ ping 192.168.160.1
   PING 192.168.160.1 (192.168.160.1) 56(84) bytes of data.
   From 192.168.1.1 icmp_seq=1 Destination Net Unreachable
   From 192.168.1.1 icmp_seq=2 Destination Net Unreachable
   ...
6) on Alpha ping 192.168.192.1 (expected reply "Host Unreachable")
   $ ping 192.168.192.1
   PING 192.168.192.1 (192.168.192.1) 56(84) bytes of data.
   From 192.168.1.1 icmp_seq=1 Destination Net Unreachable
   From 192.168.1.1 icmp_seq=2 Destination Net Unreachable
   ...

I apologize for my bad English

-- 
You are receiving this mail because:
You are the assignee for the bug.
