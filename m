From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v1 0/5] TCP Wave
Date: Fri, 28 Jul 2017 21:59:14 +0200
Message-ID: <20170728195919.10099-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32807 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752754AbdG1UAi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 16:00:38 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so27202383wrd.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 13:00:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
We are working on a new TCP congestion control algorithm, aiming at satisfying
new requirements coming from current networks. For instance, adaptation to
bandwidth/delay changes (due to mobility, dynamic switching, handover), and
optimal exploitation of very high link capacity and efficient transmission of
small objects, irrespective of the underlying link characteristics.

TCP Wave (TCPW) replaces the window-based transmission paradigm of the standard
TCP with a burst-based transmission, the ACK-clock scheduling with a
self-managed timer and the RTT-based congestion control loop with an Ack-based
Capacity and Congestion Estimation (ACCE) module. In non-technical words, it
sends data down the stack when its internal timer expires, and the timing of
the received ACKs contribute to updating this timer regularly.

We tried to add this new sender paradigm without deeply touching existing code.
In fact, we added four (optional) new congestion control functions:

+       /* get the expiration time for the send timer (optional) */
+       unsigned long (*get_send_timer_exp_time)(struct sock *sk);
+       /* no data to transmit at the timer expiration (optional) */
+       void (*no_data_to_transmit)(struct sock *sk);
+       /* the send timer is expired (optional) */
+       void (*send_timer_expired)(struct sock *sk);
+       /* the TCP has sent some segments (optional) */
+       void (*segment_sent)(struct sock *sk, u32 sent);

And a timer (tp->send_timer) which uses a send callback to push data down the
stack. If the first of these function, get_send_timer_exp_time,  is not
implemented by the current congestion control, then the timer sending timer is
never set, therefore falling back to the old, ACK-clocked, behavior.

The TCPW module itself extensively make use of the existing infrastructure and
parameters to calculate its timer, plus some heuristics when it is not possible
to have trustworthy values from the network.

You can find more stuff related to TCPW (extended results, the test programs
used and the setup for the experiments, a document describing the algorithm in
detail and so on) at:

[1] http://tlcsat.uniroma2.it/tcpwave4linux/

We would greatly appreciate any feedback from you, comments, suggestions,
corrections and so on. Thank you for your attention.

Cesare, Francesco, Ahmed, Natale

Natale Patriciello (5):
  tcp: Added callback for timed sender operations
  tcp: Implemented the timing-based operations
  tcp: PSH frames sent without timer involved
  tcp: Add initial delay to allow data queueing
  wave: Added basic version of TCP Wave

 MAINTAINERS           |   6 +
 include/linux/tcp.h   |   3 +
 include/net/tcp.h     |   8 +
 net/ipv4/Kconfig      |  16 +
 net/ipv4/Makefile     |   1 +
 net/ipv4/tcp.c        |   8 +-
 net/ipv4/tcp_ipv4.c   |   2 +
 net/ipv4/tcp_output.c |  73 +++-
 net/ipv4/tcp_wave.c   | 914 ++++++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 1023 insertions(+), 8 deletions(-)
 create mode 100644 net/ipv4/tcp_wave.c

-- 
2.13.2
