From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] bridge: make setlink/dellink notifications more accurate
Date: Thu, 19 Oct 2017 18:54:57 +0300
Message-ID: <1508428499-32355-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        mrv@mojatatu.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:51100 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752220AbdJSPzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:55:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id u138so16938041wmu.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:55:37 -0700 (PDT)
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
nothing changed, so we use EEXIST to signal that and in order not to break
overlapping vlan range add or script return expectations we clear it on
return, the functions used by vlan add are not expected to return EEXIST.

Thanks,
 Nik

Nikolay Aleksandrov (2):
  bridge: netlink: make setlink/dellink notifications more accurate
  bridge: vlan: return EEXIST on add if nothing changed

 net/bridge/br_netlink.c        | 49 ++++++++++++++++++++++++++----------------
 net/bridge/br_netlink_tunnel.c | 14 +++++++-----
 net/bridge/br_private_tunnel.h |  3 ++-
 net/bridge/br_vlan.c           | 38 +++++++++++++++++++++-----------
 4 files changed, 68 insertions(+), 36 deletions(-)

-- 
2.1.4
