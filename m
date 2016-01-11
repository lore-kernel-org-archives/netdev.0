From: Matti Vaittinen <matti.vaittinen@nokia.com>
Subject: [PATCH 1/1] net: netlink: Fix multicast group storage allocation for
 families with more than one groups
Date: Mon, 11 Jan 2016 14:26:19 +0200
Message-ID: <20160111122610.GA28615@fi-ourus-dhcp00977.emea.nsn-net.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sverdlin Alexander <alexander.sverdlin@nokia.com>,
	Pennanen Teppo Olavi <teppo.o.pennanen@nokia.com>
To: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Jiri Benc <jbenc@redhat.com>, Yaowei Bai <bywxiaobai@163.com>,
	Matti Vaittinen <matti.vaittinen@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:57573 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759638AbcAKLZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 06:25:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

    I got an oops when developing a driver utilizing more than 32
    multicast groups. After a little print adding I saw that part of 
    the address of policy struct was overwritten. It seems to me that
    amount of longs needed to store the multicast addresses is
    calculated wrong for families with more than one multicast groups.
    Problem is easy to reproduce by: 
    
    1. generating a module which registers large amount of multicast 
    groups.
    2. Loading the module
    3. Sending the netlink message which requests multicast groups for
    this family.

    I believe step 3 may not be even needed if there is enough of the
    groups registered.

    Patch created against just cloned net repository below.

    Br.
        Matti Vaittinen



Multicast groups are stored in global buffer. Check for needed buffer size
incorrectly compares buffer size to first id for family. This means that
for families with more than one mcast id one may allocate too small buffer
and end up writing rest of the groups to some unallocated memory. Fix the 
buffer size check to compare allocated space to last mcast id for the 
family.

Tested on ARM using kernel 3.14

Signed-off-by: Matti Vaittinen <matti.vaittinen@nokia.com>
---
 net/netlink/genetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index bc0e504..a992083 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -185,7 +185,7 @@ static int genl_allocate_reserve_groups(int n_groups, int *first_id)
 			}
 		}
 
-		if (id >= mc_groups_longs * BITS_PER_LONG) {
+		if (id + n_groups >= mc_groups_longs * BITS_PER_LONG) {
 			unsigned long new_longs = mc_groups_longs +
 						  BITS_TO_LONGS(n_groups);
 			size_t nlen = new_longs * sizeof(unsigned long);
-- 
2.1.0
