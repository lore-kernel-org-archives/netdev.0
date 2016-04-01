From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 0/2] Fixes for GRO and GRE tunnels
Date: Fri, 01 Apr 2016 11:05:16 -0700
Message-ID: <20160401175741.13882.24175.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33181 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbcDASFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:05:20 -0400
Received: by mail-pa0-f50.google.com with SMTP id zm5so96729335pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 11:05:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pair of patches addresses a few issues I have discovered over the last
week or so concerning GRO and GRE tunnels.

The first patch addresses an item I called out as an issue with FOU/GUE
encapsulating GRE, and I finally had a chance to test it and verify that
the code concerning it was broken so I took the opportunity to fix it so
that we cannot generate a FOU/GUE frame that is encapsulating a GRE tunnel
with checksum while requesting TSO/GSO for the frame.

The second patch actually addresses something I realized was an issue if we
feed a tunnel through GRO and back out through GSO.  Specifically it was
possible for GRO to generate overlapping IPv4 ID ranges as the outer IP IDs
were being ignored for tunnels.  Ignoring the IP IDs like this should only
be valid if the DF bit is set.  This is normally the case for IPIP, SIT,
and GRE tunnels, but not so for UDP tunnels.  In the case that the DF bit
is not set we store off the fact that there was a delta from what we were
expecting and when we hit the inner-most header we validate the value as to
avoid generating a frame which could lead to an IP ID collision on packets
that could eventually be fragmented.  A side effect is that the inner-most
IP ID test is relaxed as well, but the worst case scenario is that we GRO a
frame with a throw-away ID sequence anyway so if anything segmenting such a
frame with the wrong IP IDs should have no negative effects.

---

Alexander Duyck (2):
      GRE: Disable segmentation offloads w/ CSUM and we are encapsulated via FOU
      ipv4/GRO: Make GRO conform to RFC 6864


 include/linux/netdevice.h |    5 ++++-
 net/core/dev.c            |    2 ++
 net/ipv4/af_inet.c        |   23 ++++++++++++++++-------
 net/ipv4/fou.c            |    6 ++++++
 net/ipv4/gre_offload.c    |    8 ++++++++
 net/ipv4/ip_gre.c         |   13 ++++++++++---
 net/ipv6/ip6_offload.c    |    3 ---
 7 files changed, 46 insertions(+), 14 deletions(-)
