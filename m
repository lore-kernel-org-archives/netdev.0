From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 81661] New: Network Performance Regression for large TCP
 transfers starting with v3.10
Date: Mon, 4 Aug 2014 09:05:29 -0700
Message-ID: <20140804090529.1a5d146d@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:48965 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbaHDQFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 12:05:32 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so10269179pab.14
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 09:05:31 -0700 (PDT)
Received: from haswell.linuxnetplumber.net (static-50-53-72-226.bvtn.or.frontiernet.net. [50.53.72.226])
        by mx.google.com with ESMTPSA id ce13sm27328511pdb.76.2014.08.04.09.05.31
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Aug 2014 09:05:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 4 Aug 2014 06:13:12 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 81661] New: Network Performance Regression for large TCP transfers starting with v3.10


https://bugzilla.kernel.org/show_bug.cgi?id=81661

            Bug ID: 81661
           Summary: Network Performance Regression for large TCP transfers
                    starting with v3.10
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10 and later
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: Alexander.Steffen@infineon.com
        Regression: No

Created attachment 145061
  --> https://bugzilla.kernel.org/attachment.cgi?id=145061&action=edit
tshark captures of good/bad performance

Our network consists of two separate geographical locations, that are
transparently connected with some kind of VPN. Using newer kernel versions
(v3.10 or later) we noticed a strange performance regression when transferring
larger amounts of data via TCP (e.g. HTTP downloads of files). It only affects
transfers from one location to the other, but not the other way around. The
kernel version of the receiving machine does not seem to have any influence
(tested: v3.2, v3.5, v3.11), whereas on the sending machine everything starting
with v3.10 results in bad performance.

The problem could be reproduced using iperf and bisecting showed
3e59cb0ddfd2c59991f38e89352ad8a3c71b2374 to be the first bad commit. Reverting
this commit on top of v3.15.4 restores the performance of previous kernels.

Reproducing this problem in a different environment does not seem to be so
easy. Therefore, I've attached packet captures created with tshark on both the
sending and the receiving side for the last good commit and the first bad
commit when using iperf to demonstrate the problem (see output below). Our
network experts did not find anything obviously wrong with the network
configuration. Can you see any problem there from the packet captures? Or was
the algorithm removed in 3e59cb0ddfd2c59991f38e89352ad8a3c71b2374 not so bad
after all?


This is the iperf output of 3cc7587b30032b7c4dd9610a55a77519e84da7db (the last
good commit):
user@site1:~$ iperf -c site2
------------------------------------------------------------
Client connecting to site2, TCP port 5001 TCP window size: 20.1 KByte (default)
------------------------------------------------------------
[  3] local 172.31.22.15 port 32821 connected with 172.31.25.248 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.1 sec  15.5 MBytes  12.9 Mbits/sec

This is the iperf output of 3e59cb0ddfd2c59991f38e89352ad8a3c71b2374 (the first
bad commit):
user@site1:~$ iperf -c site2
------------------------------------------------------------
Client connecting to site2, TCP port 5001 TCP window size: 20.1 KByte (default)
------------------------------------------------------------
[  3] local 172.31.22.15 port 39947 connected with 172.31.25.248 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-11.3 sec  1.88 MBytes  1.39 Mbits/sec

This is the corresponding iperf output on the server side:
user@site2:~$ iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 172.31.25.248 port 5001 connected with 172.31.22.15 port 32821
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.7 sec  15.5 MBytes  12.1 Mbits/sec [  5] local 172.31.25.248 port
5001 connected with 172.31.22.15 port 39947
[  5]  0.0-19.0 sec  1.88 MBytes   826 Kbits/sec

-- 
You are receiving this mail because:
You are the assignee for the bug.
