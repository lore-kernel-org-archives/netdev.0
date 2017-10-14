From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v2 0/5] TCP Wave
Date: Sat, 14 Oct 2017 13:47:09 +0200
Message-ID: <20171014114714.3694-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:47911 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752024AbdJNLtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 07:49:41 -0400
Received: by mail-wm0-f67.google.com with SMTP id t69so25628390wmt.2
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 04:49:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

after the round of review on our v1 patch (you can find the relevant
thread here [1]) we have improved our code of TCP Wave, a new congestion
control algorithm.

Context: TCP Wave (TCPW) replaces the window-based transmission paradigm
of the standard TCP with a burst-based transmission, the ACK-clock
scheduling with a self-managed timer and the RTT-based congestion
control loop with an Ack-based Capacity and Congestion Estimation (ACCE)
module. In non-technical words, it sends data down the stack when a
timer expires, and the timing of the received ACKs contribute to
updating this timer regularly. We have left many debug messages to help
people understand what is going on inside the module. We plan to remove
almost all of them in the final submission.

We added this new sender paradigm without deeply touching existing code;
we re-used the existing infrastructure (TCP pacing timer, added with
commit 218af599fa635b107cfe10acf3249c4dfe5e4123), thanks to the
suggestion of Eric Dumazet. In fact, we only added four (optional) new
congestion control functions:

+         /* get the expiration time for the pacing timer (optional) */
+         u64 (*get_pacing_time)(struct sock *sk);
+         /* the pacing timer is expired (optional) */
+         void (*pacing_timer_expired)(struct sock *sk);
+         /* get the # segs to send out when the timer expires (optional) */
+         u32 (*get_segs_per_round)(struct sock *sk);
+         /* the TCP has sent some segments (optional) */
+         void (*segments_sent)(struct sock *sk, u32 sent);

to manage the previously mentioned pacing timer. With these functions, a
congestion control can set the pacing time, be informed when it expires,
indicate how many segments can leave when it expires, and know how many
segments really left the TCP layer after it has expired.

Thanks to the reviewers' suggestions we believe that the code has
improved in clarity and performance. David Laight, Stephen Hemminger,
David Miller, Neal Cardwell, Eric Dumazet, and all others that replied
privately, thank you.

Again, we would greatly appreciate any feedback, comments, suggestions,
corrections and so on. Thank you for your attention.

Cesare, Francesco, Ahmed, Natale

[1] http://lists.openwall.net/netdev/2017/07/28/219

---
Changes in v2:
 - Using TCP pacing timer instead of adding a new one
 - Using ktime_t instead of jiffies to measure the time
 - Avoided the use of custom debug facilities
 - Cleaned the variable declarations

Natale Patriciello (5):
  tcp: Added a function to retrieve pacing timer
  tcp: implemented pacing_expired
  tcp: added get_segs_per_round
  tcp: added segment sent
  wave: Added TCP Wave

 MAINTAINERS                    |    6 +
 include/net/tcp.h              |    8 +
 include/uapi/linux/inet_diag.h |   13 +
 net/ipv4/Kconfig               |   16 +
 net/ipv4/Makefile              |    1 +
 net/ipv4/tcp_output.c          |   61 ++-
 net/ipv4/tcp_wave.c            | 1035 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1127 insertions(+), 13 deletions(-)
 create mode 100644 net/ipv4/tcp_wave.c

-- 
2.14.2
