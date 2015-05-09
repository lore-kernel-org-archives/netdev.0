From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 0/6] packet: refine rollover
Date: Sat,  9 May 2015 17:24:55 -0400
Message-ID: <1431206701-5019-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	david.laight@aculab.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:33810 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbEIVZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:25:07 -0400
Received: by yhw29 with SMTP id 29so27649819yhw.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 14:25:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

efine packet socket rollover:

1. mitigate a case of lock contention
2. avoid exporting resource exhaustion to other sockets,
   by migrating only to a victim socket that has ample room
3. avoid reordering of most flows on the socket,
   by migrating first the flow responsible for load imbalance
4. help processes detect load imbalance,
   by exporting rollover counters

Context: rollover implements flow migration in packet socket fanout
groups in case of extreme load imbalance. It is a specific
implementation of migration that minimizes reordering by selecting
the same victim socket when possible (and by selecting subsequent
victims in a round robin fashion, from which its name derives).

Changes:
  v1 -> v2:
    - huge flow detection: run lockless
    - huge flow detection: replace stored index with random
    - contention avoidance: test in packet_poll while lock held
    - contention avoidance: clear pressure sooner

          packet_poll and packet_recvmsg would clear only if the sock
          is empty to avoid taking the necessary lock. But,
          * packet_poll already holds this lock, so a lockless variant
            __packet_rcv_has_room is cheap.
          * packet_recvmsg is usually called only for non-ring sockets,
            which also runs lockless.

    - preparation: drop "single return" patch

          packet_rcv_has_room is now a locked wrapper around
          __packet_rcv_has_room, achieving the same (single footer).

Willem de Bruijn (6):
  packet: rollover prepare: move code out of callsites
  packet: rollover prepare: per-socket state
  packet: rollover only to socket with headroom
  packet: rollover lock contention avoidance
  packet: rollover huge flows before small flows
  packet: rollover statistics

 include/uapi/linux/if_packet.h |   7 ++
 net/packet/af_packet.c         | 172 ++++++++++++++++++++++++++++++++++-------
 net/packet/internal.h          |  12 ++-
 3 files changed, 163 insertions(+), 28 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
