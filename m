From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH v2 0/7] TCP Fast Open client
Date: Wed, 18 Jul 2012 14:01:40 -0700
Message-ID: <1342645307-17772-1-git-send-email-ycheng@google.com>
Cc: sivasankar@cs.ucsd.edu, ycheng@google.com, netdev@vger.kernel.org
To: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:57063 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab2GRVCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:02:33 -0400
Received: by yhl10 with SMTP id 10so216945yhl.1
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:02:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ChangeLog since v1:
  - Reduce tons of code by storing Fast Open stats in the TCP metrics :)
  - Clarify the purpose of using an experimental option in patch 1/7

This patch series implement the client functionality of TCP Fast Open.
TCP Fast Open (TFO) allows data to be carried in the SYN and SYN-ACK
packets and consumed by the receiving end during the initial connection
handshake, thus providing a saving of up to one full round trip time (RTT)
compared to standard TCP requiring a three-way handshake (3WHS) to
complete before data can be exchanged.

The protocol change is detailed in the IETF internet draft at
http://www.ietf.org/id/draft-ietf-tcpm-fastopen-00.txt . The research
paper (http://conferences.sigcomm.org/co-next/2011/papers/1569470463.pdf)
studied the performance impact of HTTP using Fast Open, based on this
Linux implementation and the Chrome browser.

To use Fast Open, the client application (active SYN sender) must 
replace connect() socket call with sendmsg() or sendto() with the new
MSG_FASTOPEN flag. If the server supports Fast Open the data exchange
starts at TCP handshake. Otherwise the connection will automatically
fall back to conventional TCP.

Yuchung Cheng (7):
  net-tcp: Fast Open base
  net-tcp: Fast Open client - cookie cache
  net-tcp: Fast Open client - sending SYN-data
  net-tcp: Fast Open client - receiving SYN-ACK
  net-tcp: Fast Open client - sendmsg(MSG_FASTOPEN)
  net-tcp: Fast Open client - detecting SYN-data drops
  net-tcp: Fast Open client - cookie-less mode

 Documentation/networking/ip-sysctl.txt |   13 +++
 include/linux/snmp.h                   |    1 +
 include/linux/socket.h                 |    1 +
 include/linux/tcp.h                    |   17 ++++-
 include/net/inet_common.h              |    6 +-
 include/net/tcp.h                      |   28 ++++++-
 net/ipv4/Makefile                      |    2 +-
 net/ipv4/af_inet.c                     |   26 +++++-
 net/ipv4/proc.c                        |    1 +
 net/ipv4/syncookies.c                  |    2 +-
 net/ipv4/sysctl_net_ipv4.c             |    7 ++
 net/ipv4/tcp.c                         |   61 ++++++++++++-
 net/ipv4/tcp_fastopen.c                |   11 +++
 net/ipv4/tcp_input.c                   |   76 ++++++++++++++--
 net/ipv4/tcp_ipv4.c                    |    5 +-
 net/ipv4/tcp_metrics.c                 |   51 +++++++++++
 net/ipv4/tcp_minisocks.c               |    4 +-
 net/ipv4/tcp_output.c                  |  153 +++++++++++++++++++++++++++++---
 net/ipv6/syncookies.c                  |    2 +-
 net/ipv6/tcp_ipv6.c                    |    2 +-
 20 files changed, 427 insertions(+), 42 deletions(-)
 create mode 100644 net/ipv4/tcp_fastopen.c

-- 
1.7.7.3
