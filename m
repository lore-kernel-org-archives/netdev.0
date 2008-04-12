From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10443] New: VLAN: link level multicasts
 addresses disappears...
Date: Sat, 12 Apr 2008 00:10:45 -0700 (PDT)
Message-ID: <20080412.001045.177916063.davem@davemloft.net>
References: <bug-10443-10286@http.bugzilla.kernel.org/>
	<20080411214134.dd7a9ffc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	dmitry@butskoy.name, greearb@candelatech.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759897AbYDLHKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 03:10:45 -0400
In-Reply-To: <20080411214134.dd7a9ffc.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 11 Apr 2008 21:41:34 -0700

> There's a test case in the bugzilla report.

Could be fixed by:

commit 0ed21b321a13421e2dfeaa70a6c324e05e3e91e6
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 26 00:15:17 2008 -0700

    [VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying device
    
    Changing these flags requires to use dev_set_allmulti/dev_set_promiscuity
    or dev_change_flags. Setting it directly causes two unwanted effects:
    
    - the next dev_change_flags call will notice a difference between
      dev->gflags and the actual flags, enable promisc/allmulti
      mode and incorrectly update dev->gflags
    
    - this keeps the underlying device in promisc/allmulti mode until
      the VLAN device is deleted
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8fbcefe..480ea90 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -660,7 +660,7 @@ static int vlan_dev_init(struct net_device *dev)
 	int subclass = 0;
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
-	dev->flags  = real_dev->flags & ~IFF_UP;
+	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI);
 	dev->iflink = real_dev->ifindex;
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |
