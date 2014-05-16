From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 0/2] Fixed stacked vlan usage on top of bonds
Date: Fri, 16 May 2014 17:20:37 -0400
Message-ID: <1400275239-15419-1-git-send-email-vyasevic@redhat.com>
Cc: vfalico@gmail.com, kaber@trash.net, j.vosburgh@gmail.com,
	andy@greyhouse.net, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766AbaEPVUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 17:20:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bonding device driver now support q-in-q on top for bonds.  There are
a few issues here though.

First, when arp monitoring is used, bonding driver will not correctly
tag traffic if the source of the arp device was configured on top of
q-in-q.  It may also incorrectly pick the wrong vlan id if the ordering
of that upper devices isn't as expected (there is no guarntee on ordering).

Second, the alb/tlb may use what would be considered 'inner' vlans in
its learning announcements, as it simply announces all vlans configured
on top of the bond without regard for encapsulation/stacking.

This series fixes the above 2 issues.  This series also depends on the
functionality introduced in
	http://patchwork.ozlabs.org/patch/349766/

Since v1:
  - Changed how patch1 verifies the device path.  We no longer use the
    _all_upper version of the function.  We find the path and if it was
    found, then collect the vlan information.
  - Use the constant to devine maximum vlan nest level support on top
    of bonding.  This can be changed if 2 is too low.
  - Inlude patch2 into the series.

Vlad Yasevich (2):
  bonding: Fix stacked device detection in arp monitoring
  bonding: Fix alb mode to only use first level vlans.

 drivers/net/bonding/bond_alb.c  |   2 +-
 drivers/net/bonding/bond_main.c | 134 +++++++++++++++++++---------------------
 drivers/net/bonding/bonding.h   |   1 +
 include/linux/if_vlan.h         |   6 ++
 include/linux/netdevice.h       |   9 +++
 net/core/dev.c                  |  26 ++++++++
 6 files changed, 108 insertions(+), 70 deletions(-)

-- 
1.9.0
