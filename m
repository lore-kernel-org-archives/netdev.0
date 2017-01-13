From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 00/13] tcp: RACK fast recovery
Date: Thu, 12 Jan 2017 22:11:29 -0800
Message-ID: <20170113061142.127344-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35221 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdAMGMG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:12:06 -0500
Received: by mail-pf0-f172.google.com with SMTP id f144so25918897pfa.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:12:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch set enables RACK loss detection (draft-ietf-tcpm-rack-01)
to trigger fast recovery with a reordering timer.

Previously RACK has been running in auxiliary mode where it is
used to detect packet losses once the recovery has triggered by
other algorithms (e.g., FACK). By inspecting packet timestamps,
RACK can start ACK-driven repairs timely. A few similar heuristics
are no longer needed and are either removed or disabled to reduce
the complexity of the Linux TCP loss recovery engine:

  1. FACK (Forward Acknowledgement)
  2. Early Retransmit (RFC5827)
  3. thin_dupack (fast recovery on single DUPACK for thin-streams)
  4. NCR (Non-Congestion Robustness RFC4653) (RFC4653)
  5. Forward Retransmit

After this change, Linux's loss recovery algorithms consist of
  1. Conventional DUPACK threshold approach (RFC6675)
  2. RACK and Tail Loss Probe (draft-ietf-tcpm-rack-01)
  3. RTO plus F-RTO extension (RFC5682)

The patch set has been tested on Google servers extensively and
presented in several IETF meetings. The data suggests that RACK
successfully improves recovery performance:
https://www.ietf.org/proceedings/97/slides/slides-97-tcpm-draft-ietf-tcpm-rack-01.pdf
https://www.ietf.org/proceedings/96/slides/slides-96-tcpm-3.pdf

Yuchung Cheng (13):
  tcp: new helper function for RACK loss detection
  tcp: new helper for RACK to detect loss
  tcp: record most recent RTT in RACK loss detection
  tcp: add reordering timer in RACK loss detection
  tcp: use sequence to break TS ties for RACK loss detection
  tcp: check undo conditions before detecting losses
  tcp: enable RACK loss detection to trigger recovery
  tcp: extend F-RTO to catch more spurious timeouts
  tcp: remove forward retransmit feature
  tcp: remove early retransmit
  tcp: remove RFC4653 NCR
  tcp: remove thin_dupack feature
  tcp: disable fack by default

 Documentation/networking/ip-sysctl.txt |  31 +----
 include/linux/tcp.h                    |   8 +-
 include/net/inet_connection_sock.h     |   4 +-
 include/net/tcp.h                      |  40 ++----
 net/ipv4/inet_diag.c                   |   2 +-
 net/ipv4/sysctl_net_ipv4.c             |   7 --
 net/ipv4/tcp.c                         |   9 +-
 net/ipv4/tcp_input.c                   | 224 +++++++++++++--------------------
 net/ipv4/tcp_ipv4.c                    |   2 +-
 net/ipv4/tcp_metrics.c                 |   1 -
 net/ipv4/tcp_minisocks.c               |   1 -
 net/ipv4/tcp_output.c                  |  75 ++---------
 net/ipv4/tcp_recovery.c                | 148 ++++++++++++++++------
 net/ipv4/tcp_timer.c                   |   4 +-
 net/ipv6/tcp_ipv6.c                    |   2 +-
 15 files changed, 237 insertions(+), 321 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
