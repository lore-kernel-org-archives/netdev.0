From: Shaohua Li <shli@kernel.org>
Subject: [PATCH v5 net 0/2] ipv6: fix flowlabel issue for reset packet
Date: Mon, 14 Aug 2017 19:53:19 -0700
Message-ID: <cover.1502761278.git.shli@fb.com>
Cc: Kernel-team@fb.com, Shaohua Li <shli@fb.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49836 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750989AbdHOCxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 22:53:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>

Please see below tcpdump output:
21:00:48.109122 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [S], cksum 0x0529 (incorrect -> 0xf56c), seq 3282214508, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 0,nop,wscale 7], length 0
21:00:48.109381 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [S.], cksum 0x0529 (incorrect -> 0x49ad), seq 1923801573, ack 3282214509, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 2500903437,nop,wscale 7], length 0
21:00:48.109548 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1bdf), seq 1, ack 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
21:00:48.109823 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 62) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [P.], cksum 0x053f (incorrect -> 0xb8b1), seq 1:31, ack 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 30
21:00:48.109910 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [.], cksum 0x0521 (incorrect -> 0x1bc1), seq 1, ack 31, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
21:00:48.110043 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [P.], cksum 0x0539 (incorrect -> 0xb726), seq 1:25, ack 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 24
21:00:48.110173 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba7), seq 31, ack 25, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
21:00:48.110211 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [F.], cksum 0x0521 (incorrect -> 0x1ba7), seq 25, ack 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 0
21:00:48.151099 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba6), seq 31, ack 26, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
21:00:49.110524 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [P.], cksum 0x0539 (incorrect -> 0xb324), seq 31:55, ack 26, win 342, options [nop,nop,TS val 2500904438 ecr 2500903438], length 24
21:00:49.110637 IP6 (flowlabel 0xb34d5, hlim 64, next-header TCP (6) payload length: 20) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [R], cksum 0x0515 (incorrect -> 0x668c), seq 1923801599, win 0, length 0

The flowlabel of reset packet (0xb34d5) and flowlabel of normal packet
(0xd827f) are different. This causes our router doesn't correctly close tcp
connection. We are using flowlabel to do load balance. Routers in the path
maintain connection state. So if flow label changes, the packet is routed
through a different router. In this case, the old router doesn't get the reset
packet to close the tcp connection. The patches try to fix the issue.

Thanks,
Shaohua


Shaohua Li (2):
  net: remove unnecessary rotation
  net: fix tcp reset packet flowlabel for ipv6

 include/net/ipv6.h       | 48 +++++++++++++++++++++++++++++++++---------------
 net/ipv4/tcp_minisocks.c |  8 +++++++-
 net/ipv6/tcp_ipv6.c      | 18 +++++++++++++++++-
 3 files changed, 57 insertions(+), 17 deletions(-)

-- 
2.9.5
