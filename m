From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v6 0/2] Unify IPv6 sendmsg codepaths.
Date: Sat,  3 May 2014 04:11:06 +0900
Message-ID: <1399057868-3488-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	yoshifuji@linux-ipv6.org, david.laight@aculab.com,
	eric.dumazet@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:59849 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbaEBTLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:11:15 -0400
Received: by mail-pd0-f175.google.com with SMTP id p10so1253566pdj.34
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 12:11:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, here's another attempt at reducing code duplication between
the IPv6 UDP/raw/L2TP/ping sendmsg codepaths. I took Hannes's
suggestion and created an ip6_output_opts structure which groups
together parameters that go to ip6_append data (and which can
be written to directly by ip6_datagram_send_ctl).

Does this look better now?


Since there was a concern that the previous patch might impact
UDP sendmsg performance, I ran a couple of benchmarks on this
version and the results suggest that impact is in the noise.
x86_64 improved by 1-2%, but ARM got 1% worse. I suspect that
this what this means is that any optimization made to this code
is irrelevant compared to the overhead of context switches,
system call setup, copying from userspace, etc.

Specifically, I tested sending UDP on loobpack with:

  netperf -6 -H ::1 -t UDP_STREAM -- -m <size>

and counted the number of packets sent in 10 seconds, 5 times,
for UDP payload sizes of 1 byte (the minimum) and 1452. Results:

x86_64 workstation, 1-byte UDP payload: +1.1%

- Before:
  - Run #1: 2717005 2707060 2652702 2695698 2703355
  - Run #2: 2711797 2692290 2699832 2705740 2698174
- After:
  - Run #1: 2726430 2725619 2704406 2672582 2730418
  - Run #2: 2777486 2740683 2732652 2707956 2772541

x86_64 workstation, 1452-byte UDP payload: +1.8%

- Before: 2577335 2514953 2572881 2571107 2571355
- After:  2620455 2609399 2635285 2610107 2568943

Nexus 5 phone, 1-byte UDP payload (backport to kernel 3.4): -1.0%

- Before: 213955 216284 217529 217785 216854
- After:  221096 216049 216426 203414 213897


Lorenzo Colitti (2):
  net: ipv6: Unduplicate UDP, raw, and L2TP sendmsg
  net: ipv6: Use ip6_datagram_send_common in ping.

 include/net/ipv6.h       |  33 ++++++++++-
 include/net/transp_v6.h  |   7 ++-
 net/ipv6/datagram.c      | 145 +++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/icmp.c          |  27 +++++----
 net/ipv6/ip6_flowlabel.c |   6 +-
 net/ipv6/ip6_output.c    |  11 ++--
 net/ipv6/ipv6_sockglue.c |   7 ++-
 net/ipv6/ping.c          |  90 ++++++++++-------------------
 net/ipv6/raw.c           | 101 ++-------------------------------
 net/ipv6/udp.c           | 122 ++++-----------------------------------
 net/l2tp/l2tp_ip6.c      | 108 +++--------------------------------
 11 files changed, 255 insertions(+), 402 deletions(-)

-- 
1.9.1.423.g4596e3a
