From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 0/7] TCP Fast Open client
Date: Mon, 16 Jul 2012 14:16:43 -0700
Message-ID: <1342473410-6265-1-git-send-email-ycheng@google.com>
Cc: sivasankar@cs.ucsd.edu, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f202.google.com ([209.85.212.202]:50050 "EHLO
	mail-wi0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab2GPVRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 17:17:03 -0400
Received: by wibhr14 with SMTP id hr14so179190wib.1
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 14:17:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 include/linux/snmp.h                   |    3 +-
 include/linux/socket.h                 |    1 +
 include/linux/tcp.h                    |   17 +++-
 include/net/inet_common.h              |    6 +-
 include/net/inetpeer.h                 |    2 +
 include/net/tcp.h                      |   30 ++++++-
 net/ipv4/Makefile                      |    2 +-
 net/ipv4/af_inet.c                     |   26 ++++-
 net/ipv4/inetpeer.c                    |    2 +
 net/ipv4/proc.c                        |    1 +
 net/ipv4/syncookies.c                  |    2 +-
 net/ipv4/sysctl_net_ipv4.c             |   33 +++++++
 net/ipv4/tcp.c                         |   61 +++++++++++-
 net/ipv4/tcp_fastopen.c                |  163 ++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c                   |   76 +++++++++++++--
 net/ipv4/tcp_ipv4.c                    |    5 +-
 net/ipv4/tcp_minisocks.c               |    4 +-
 net/ipv4/tcp_output.c                  |  153 +++++++++++++++++++++++++++---
 net/ipv6/syncookies.c                  |    2 +-
 net/ipv6/tcp_ipv6.c                    |    2 +-
 21 files changed, 561 insertions(+), 43 deletions(-)
 create mode 100644 net/ipv4/tcp_fastopen.c

-- 
1.7.7.3
