From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/4] net: bridge: simplify receive path and consolidate forwarding paths
Date: Thu, 14 Jul 2016 06:09:58 +0300
Message-ID: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	davem@davemloft.net, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34239 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbcGNSDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 14:03:52 -0400
Received: by mail-pf0-f177.google.com with SMTP id h14so32058354pfe.1
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 11:03:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This set tries to simplify the receive and forwarding paths. Patch 01 is
a trivial style adjustment, patch 02 removes one conditional from the
unicast fast path, patch 03 removes another conditional and more imporantly
removes the skb0/skb2 ambiguity about locally receiving the skb and
switches to a boolean called "local_rcv".
Patch 04 is the most important change which consolidates the forwarding
paths for locally originated and forwarded packets into __br_forward. This
allows us to remove the function pointers giving a minor performance boost,
more importantly it makes it much easier to reason about the forwarding
path and reduces the code duplication that was needed when making changes.
Also it allows the receive path to fully setup the environment prior to
calling any forwarding functions (i.e. to properly set unicast, local_rcv
and search for unicast/mcast dst).
Functionally everything should stay the same after this set.

I've done basic tests with unicast/multicast/broadcast Tx/Rx. Please
review carefully.

Thank you,
 Nik

Nikolay Aleksandrov (4):
  net: bridge: minor style adjustments in br_handle_frame_finish
  net: bridge: rearrange flood vs unicast receive paths
  net: bridge: drop skb2/skb0 variables and use a local_rcv boolean
  net: bridge: remove _deliver functions and consolidate forward code

 net/bridge/br_device.c                   |  22 ++--
 net/bridge/br_forward.c                  | 195 +++++++++++--------------------
 net/bridge/br_input.c                    |  62 +++++-----
 net/bridge/br_private.h                  |  29 ++---
 net/bridge/netfilter/nft_reject_bridge.c |   8 +-
 5 files changed, 125 insertions(+), 191 deletions(-)

-- 
2.4.3
