From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 0/2] Fix issues with vlans without REORDER_HEADER
Date: Mon, 16 Nov 2015 15:43:43 -0500
Message-ID: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
Cc: phil@nwl.cc, kaber@trash.net,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35753 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbKPUnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:43:53 -0500
Received: by qgec40 with SMTP id c40so58326759qge.2
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 12:43:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A while ago Phil Sutter brought up an issue with vlans without
REORDER_HEADER and bridges.  The problem was that if a vlan
without REORDER_HEADER was a port in the bridge, the bridge ended
up forwarding corrupted packets that still contained the vlan header.
The same issue exists for bridge mode macvlan/macvtap devices.

An additional issue with vlans without REORDER_HEADER is that stacking
them also doesn't work.  The reason here is that skb_reorder_vlan_header()
function assumes that it on ETH_HLEN bytes deep into the packet.  That
is not the case, when you a vlan without REORRDER_HEADER flag set.

This series attempts to correct these 2 issues.

1) To solve the stacked vlans problem, the patch simply use
skb->mac_len as an offset to start copying mac addresses that
is part of header reordering.

2) To fix the issue with bridge/macvlan/macvtap, the second patch
simply doesn't write the vlan header back to the packet if the
vlan device is either a bridge or a macvlan port.  This ends up
being the simplest and least performance intrussive solution.

I've considered extending patch 2 to all stacked devices (essentially
checked for the presense of rx_handler), but that feels like a broader
restriction and _may_ break existing uses.  

Thanks
-vlad

Vladislav Yasevich (2):
  vlan: Fix untag operations of stacked vlans with REORDER_HEADER off
  vlan: Do not put vlan headers back on bridge and macvlan ports

 include/linux/netdevice.h | 5 +++++
 net/8021q/vlan_core.c     | 4 +++-
 net/core/skbuff.c         | 3 ++-
 3 files changed, 10 insertions(+), 2 deletions(-)

-- 
1.9.3
