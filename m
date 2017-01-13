From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 13/13] tcp: disable fack by default
Date: Thu, 12 Jan 2017 22:11:42 -0800
Message-ID: <20170113061142.127344-14-ycheng@google.com>
References: <20170113061142.127344-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32970 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdAMGMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:12:22 -0500
Received: by mail-pf0-f174.google.com with SMTP id y143so26044342pfb.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:12:22 -0800 (PST)
In-Reply-To: <20170113061142.127344-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables FACK by default as RACK is the successor of FACK
(inspired by the insights behind FACK).

FACK[1] in Linux works as follows: a packet P is deemed lost,
if packet Q of higher sequence is s/acked and P and Q are distant
by at least dupthresh number of packets in sequence space.

FACK is more aggressive than the IETF recommened recovery for SACK
(RFC3517 A Conservative Selective Acknowledgment (SACK)-based Loss
 Recovery Algorithm for TCP), because a single SACK may trigger
fast recovery. This obviously won't work well with reordering so
FACK is dynamically disabled upon detecting reordering.

RACK supersedes FACK by using time distance instead of sequence
distance. On reordering, RACK waits for a quarter of RTT receiving
a single SACK before starting recovery. (the timer can be made more
adaptive in the future by measuring reordering distance in time,
but currently RTT/4 seem to work well.) Once the recovery starts,
RACK behaves almost like FACK because it reduces the reodering
window to 1ms, so it fast retransmits quickly. In addition RACK
can detect loss retransmission as it does not care about the packet
sequences (being repeated or not), which is extremely useful when
the connection is going through a traffic policer.

Google server experiments indicate that disabling FACK after enabling
RACK has negligible impact on the overall loss recovery performance
with more reordering events detected.  But we still keep the FACK
implementation for backup if RACK has bugs that needs to be disabled.

[1] M. Mathis, J. Mahdavi, "Forward Acknowledgment: Refining
TCP Congestion Control," In Proceedings of SIGCOMM '96, August 1996.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 39ebc20ca1b2..1a34e9278c07 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -79,7 +79,7 @@
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
-int sysctl_tcp_fack __read_mostly = 1;
+int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
@@ -2114,7 +2114,8 @@ static inline int tcp_dupack_heuristics(const struct tcp_sock *tp)
  *		dynamically measured and adjusted. This is implemented in
  *		tcp_rack_mark_lost.
  *
- *		FACK: it is the simplest heuristics. As soon as we decided
+ *		FACK (Disabled by default. Subsumbed by RACK):
+ *		It is the simplest heuristics. As soon as we decided
  *		that something is lost, we decide that _all_ not SACKed
  *		packets until the most forward SACK are lost. I.e.
  *		lost_out = fackets_out - sacked_out and left_out = fackets_out.
-- 
2.11.0.483.g087da7b7c-goog
