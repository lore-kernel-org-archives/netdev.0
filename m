From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next 0/8] add TX timestamping via cmsg
Date: Wed, 30 Mar 2016 18:37:20 -0400
Message-ID: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:34049 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301AbcC3Whr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 18:37:47 -0400
Received: by mail-qg0-f68.google.com with SMTP id j35so6149968qge.1
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 15:37:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

This patch series aim at enabling TX timestamping via cmsg.

Currently, to occasionally sample TX timestamping on a socket,
applications need to call setsockopt twice: first for enabling
timestamps and then for disabling them. This is an unnecessary
overhead. With cmsg, in contrast, applications can sample TX
timestamps per sendmsg().

This patch series adds the code for processing SO_TIMESTAMPING
for cmsg's of the SOL_SOCKET level, and adds the glue code for
TCP, UDP, and RAW for both IPv4 and IPv6. This implementation
supports overriding timestamp generation flags (i.e.,
SOF_TIMESTAMPING_TX_*) but not timestamp reporting flags.
Applications must still enable timestamp reporting via
setsockopt to receive timestamps.

This series does not change existing timestamping behavior for
applications that are using socket options.

I will follow up with another patch to enable timestamping for
active TFO (client-side TCP Fast Open) and also setting packet
mark via cmsgs.

Thanks!

Soheil Hassas Yeganeh (7):
  tcp: accept SOF_TIMESTAMPING_OPT_ID for passive TFO
  tcp: use one bit in TCP_SKB_CB to mark ACK timestamps
  sock: accept SO_TIMESTAMPING flags in socket cmsg
  ipv4: process socket-level control messages in IPv4
  ipv6: process socket-level control messages in IPv6
  sock: enable timestamping using control messages
  sock: document timestamping via cmsg in Documentation

Willem de Bruijn (1):
  sock: break up sock_cmsg_snd into __sock_cmsg_snd and loop

 Documentation/networking/timestamping.txt | 48 ++++++++++++++++++++++++++++--
 drivers/net/tun.c                         |  3 +-
 include/net/ip.h                          |  3 +-
 include/net/ipv6.h                        |  6 ++--
 include/net/sock.h                        | 13 +++++---
 include/net/tcp.h                         |  3 +-
 include/net/transp_v6.h                   |  3 +-
 include/uapi/linux/net_tstamp.h           | 10 +++++++
 net/can/raw.c                             |  2 +-
 net/core/sock.c                           | 49 +++++++++++++++++++++++--------
 net/ipv4/ip_sockglue.c                    |  9 +++++-
 net/ipv4/ping.c                           |  7 +++--
 net/ipv4/raw.c                            | 13 ++++----
 net/ipv4/tcp.c                            | 22 ++++++++++----
 net/ipv4/tcp_input.c                      |  2 +-
 net/ipv4/udp.c                            | 10 +++----
 net/ipv6/datagram.c                       |  9 +++++-
 net/ipv6/icmp.c                           |  6 ++--
 net/ipv6/ip6_flowlabel.c                  |  3 +-
 net/ipv6/ip6_output.c                     | 15 ++++++----
 net/ipv6/ipv6_sockglue.c                  |  3 +-
 net/ipv6/ping.c                           |  3 +-
 net/ipv6/raw.c                            |  7 +++--
 net/ipv6/udp.c                            | 10 +++++--
 net/packet/af_packet.c                    | 30 +++++++++++++++----
 net/socket.c                              | 10 +++----
 26 files changed, 225 insertions(+), 74 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
