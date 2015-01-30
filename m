From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 0/3] net-timestamp: blinding
Date: Fri, 30 Jan 2015 13:29:30 -0500
Message-ID: <1422642573-6126-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:57247 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbbA3S3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 13:29:51 -0500
Received: by mail-yk0-f172.google.com with SMTP id 9so17816055ykp.3
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 10:29:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Changes
  (v2 -> v3)
  - rebase only: v2 did not make it to patchwork / netdev
  (v1 -> v2)
  - fix capability check in patch 2
      this could be moved into net/core/sock.c as sk_capable_nouser()
  (rfc -> v1)
  - dropped patch 4: timestamp batching
      due to complexity, as discussed
  - dropped patch 5: default mode
      because it does not really cover all use cases, as discussed
  - added documentation
  - minor fix, see patch 2


Two issues were raised during recent timestamping discussions:
1. looping full packets on the error queue exposes packet headers
2. TCP timestamping with retransmissions generates many timestamps

This RFC patchset is an attempt at addressing both without breaking
legacy behavior.

Patch 1 reintroduces the "no payload" timestamp option, which loops
timestamps onto an empty skb. This reduces the pressure on SO_RCVBUF
from looping many timestamps. It does not reduce the number of recv()
calls needed to process them. The timestamp cookie mechanism developed
in http://patchwork.ozlabs.org/patch/427213/ did, but this is
considerably simpler.

Patch 2 then gives administrators the power to block all timestamp
requests that contain data by unprivileged users. I proposed this
earlier as a backward compatible workaround in the discussion of

  net-timestamp: pull headers for SOCK_STREAM
  http://patchwork.ozlabs.org/patch/414810/

Patch 3 only updates the txtimestamp example to test this option.
Verified that with option '-n', length is zero in all cases and
option '-I' (PKTINFO) stops working.


Willem de Bruijn (3):
  net-timestamp: no-payload option
  net-timestamp: no-payload only sysctl
  net-timestamp: no-payload option in txtimestamp test

 Documentation/networking/timestamping.txt          | 21 ++++++++++++
 .../networking/timestamping/txtimestamp.c          | 28 ++++++++++++---
 Documentation/sysctl/net.txt                       |  8 +++++
 include/net/sock.h                                 |  1 +
 include/uapi/linux/net_tstamp.h                    |  3 +-
 net/core/skbuff.c                                  | 40 ++++++++++++++++++----
 net/core/sock.c                                    |  3 ++
 net/core/sysctl_net_core.c                         |  9 +++++
 net/ipv4/ip_sockglue.c                             |  7 ++--
 net/ipv6/datagram.c                                |  5 ++-
 net/rxrpc/ar-error.c                               |  5 +++
 11 files changed, 113 insertions(+), 17 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
