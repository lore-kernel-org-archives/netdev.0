From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 0/5] net-timestamp: address blinding and batching
Date: Fri,  9 Jan 2015 12:31:54 -0500
Message-ID: <1420824719-28848-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	eric.dumazet@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:61288 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbAIRcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:32:03 -0500
Received: by mail-yh0-f43.google.com with SMTP id z6so4714281yhz.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:32:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Two issues were raised during recent timestamping discussions:
1. looping full packets on the error queue exposes packet headers
2. TCP timestamping with retransmissions generates many timestamps

This RFC patchset is an attempt at addressing both without breaking
legacy behavior.

Patch 1 reintroduces the "no payload" timestamp option, which loops
timestamps onto an empty skb. Patch 2 then gives administrators the
power to block all timestamp requests by unprivileged users that
contain data. I proposed this earlier as a backward compatible
workaround in the discussion of

  net-timestamp: pull headers for SOCK_STREAM
  http://patchwork.ozlabs.org/patch/414810/

Patch 3 only updates the txtimestamp example to test this option.

When looping timestamps without data, there is no need to associate
a timestamp with a specific packet. Patch 4 loops multiple timestamps
onto a single outstanding packet if this has no payload. It is a
variant of the cookies approach that David proposed in

  net-timestamp: TCP timestamping
  http://patchwork.ozlabs.org/patch/376513/

That patch turns out to introduce a quite a bit of code to save
relatively few bytes because
1. no-payload already limits the per-skb size that is queued and
2. batching is limited by send() failing as soon as there is an
   outstanding packet on the error queue. Therefore, I'm fine
with dropping this. By now, it is at least recorded in patchwork.

Patch 5, finally, creates a new short SO_TIMESTAMPING option,
SOF_TIMESTAMPING_TX, that combines all recent options, as a push
to get future applications to use the new ID and no-payload based
API by default.


Willem de Bruijn (5):
  net-timestamp: no-payload option
  net-timestamp: no-payload only sysctl
  net-timestamp: no-payload option in txtimestamp test
  net-timestamp: tx timestamp cookies
  net-timestamp: tx timestamping default mode flag

 .../networking/timestamping/txtimestamp.c          |  28 ++++-
 include/linux/skbuff.h                             |  12 ++
 include/net/sock.h                                 |   4 +-
 include/uapi/linux/errqueue.h                      |   1 +
 include/uapi/linux/net_tstamp.h                    |  11 +-
 net/core/skbuff.c                                  | 134 ++++++++++++++++++---
 net/core/sock.c                                    |   3 +
 net/core/sysctl_net_core.c                         |   9 ++
 net/ipv4/ip_sockglue.c                             |   9 +-
 net/ipv6/datagram.c                                |   4 +-
 net/rxrpc/ar-error.c                               |   5 +
 net/socket.c                                       |  64 +++++++++-
 12 files changed, 250 insertions(+), 34 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
