From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v3 0/2] bridge: make setlink/dellink notifications more accurate
Date: Thu, 26 Oct 2017 00:59:40 +0300
Message-ID: <1508968782-15530-1-git-send-email-nikolay@cumulusnetworks.com>
References: <43f36fb0-8543-7e60-a80e-6da35d74b69a@cumulusnetworks.com>
Cc: dsa@cumulusnetworks.com, mrv@mojatatu.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:52866 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdJYWAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:00:19 -0400
Received: by mail-wm0-f68.google.com with SMTP id t139so4609653wmt.1
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 15:00:18 -0700 (PDT)
In-Reply-To: <43f36fb0-8543-7e60-a80e-6da35d74b69a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Before this set the bridge would generate a notification on vlan add or del
even if they didn't actually do any changes, which confuses listeners and
is generally not preferred. We could also lose notifications on actual
changes if one adds a range of vlans and there's an error in the middle.
The problem with just breaking and returning an error is that we could
break existing user-space scripts which rely on the vlan delete to clear
all existing entries in the specified range and ignore the non-existing
errors (typically used to clear the current vlan config).
So in order to make the notifications more accurate while keeping backwards
compatibility we add a boolean that tracks if anything actually changed
during the config calls.

The vlan add is more difficult to fix because it always returns 0 even if
nothing changed, but we cannot use a specific error because the drivers
can return anything and we may mask it, also we'd need to update all places
that directly return the add result, thus to signal that a vlan was created
or updated and in order not to break overlapping vlan range add we pass
down the new boolean that tracks changes to the add functions to check
if anything was actually updated.

v3: rebased to latest net-next and fixed non-vlan config functions reported
    by kbuild test bot
v2: pass changed down to vlan add instead of masking errors

Thanks,
 Nik


Nikolay Aleksandrov (2):
  bridge: netlink: make setlink/dellink notifications more accurate
  bridge: vlan: signal if anything changed on vlan add

 net/bridge/br_netlink.c        | 51 ++++++++++++++++-----------
 net/bridge/br_netlink_tunnel.c | 14 +++++---
 net/bridge/br_private.h        | 12 ++++---
 net/bridge/br_private_tunnel.h |  3 +-
 net/bridge/br_vlan.c           | 78 ++++++++++++++++++++++++++++++------------
 5 files changed, 106 insertions(+), 52 deletions(-)

-- 
2.1.4
