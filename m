From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 10443] New: VLAN: link level multicasts addresses
 disappears...
Date: Sun, 13 Apr 2008 08:08:19 +0200
Message-ID: <4801A353.2000906@trash.net>
References: <bug-10443-10286@http.bugzilla.kernel.org/>	<20080411214134.dd7a9ffc.akpm@linux-foundation.org> <20080412.001045.177916063.davem@davemloft.net> <48019DAF.4010302@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050100080502070107020403"
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, dmitry@butskoy.name,
	greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbYDMGIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 02:08:25 -0400
In-Reply-To: <48019DAF.4010302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050100080502070107020403
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> David Miller wrote:
>> From: Andrew Morton <akpm@linux-foundation.org>
>> Date: Fri, 11 Apr 2008 21:41:34 -0700
>>
>>> There's a test case in the bugzilla report.
>>
>> Could be fixed by:
>>
>> commit 0ed21b321a13421e2dfeaa70a6c324e05e3e91e6
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Wed Mar 26 00:15:17 2008 -0700
>>
>>     [VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying device
> 
> Either that patch or this one I guess:
> 
> [NET]: Messed multicast lists after dev_mc_sync/unsync
> 
> I'll go through our recent multicast fixes and check which
> ones make sense for -stable.

The "messed multicast lists" patch is already in the latest -stable
release. I've attached backports of two more multicast fixes.

Dave, could you forward them to -stable please in case you're
fine with them? Thanks.





--------------050100080502070107020403
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NET]: Fix multicast device ioctl checks

Upstream commit 61ee6bd487b9cc160e533034eb338f2085dc7922:

SIOCADDMULTI/SIOCDELMULTI check whether the driver has a set_multicast_list
method to determine whether it supports multicast. Drivers implementing
secondary unicast support use set_rx_mode however.

Check for both dev->set_multicast_mode and dev->set_rx_mode to determine
multicast capabilities.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: David S. Miller <davem@davemloft.net>

---
commit 4eed9fb2564cf763918b9711558169e06dbfb8d5
tree 1cead411884581aa0b8932edcc399cab9551e556
parent 16c64cac7d9c6a503f49887219c4fe675e7d43d9
author Patrick McHardy <kaber@trash.net> Wed, 26 Mar 2008 02:12:11 -0700
committer Patrick McHardy <kaber@trash.net> Sun, 13 Apr 2008 08:04:43 +0200

 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4d44372..82f77ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3240,7 +3240,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			return -EOPNOTSUPP;
 
 		case SIOCADDMULTI:
-			if (!dev->set_multicast_list ||
+			if ((!dev->set_multicast_list && !dev->set_rx_mode) ||
 			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 				return -EINVAL;
 			if (!netif_device_present(dev))
@@ -3249,7 +3249,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 					  dev->addr_len, 1);
 
 		case SIOCDELMULTI:
-			if (!dev->set_multicast_list ||
+			if ((!dev->set_multicast_list && !dev->set_rx_mode) ||
 			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 				return -EINVAL;
 			if (!netif_device_present(dev))

--------------050100080502070107020403
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying device

Upstream commit 0ed21b321a13421e2dfeaa70a6c324e05e3e91e6:

Changing these flags requires to use dev_set_allmulti/dev_set_promiscuity
or dev_change_flags. Setting it directly causes two unwanted effects:

- the next dev_change_flags call will notice a difference between
  dev->gflags and the actual flags, enable promisc/allmulti
  mode and incorrectly update dev->gflags

- this keeps the underlying device in promisc/allmulti mode until
  the VLAN device is deleted

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: David S. Miller <davem@davemloft.net>

---
commit da2c2dd3bbd2e57ebf6ce9a404ede39a3103d4bd
tree 86c0ea5efb73fada291d7ed70897afd5b6234c7b
parent 4eed9fb2564cf763918b9711558169e06dbfb8d5
author Patrick McHardy <kaber@trash.net> Sun, 13 Apr 2008 08:06:00 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 13 Apr 2008 08:06:00 +0200

 net/8021q/vlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 032bf44..156ad38 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -326,7 +326,7 @@ static int vlan_dev_init(struct net_device *dev)
 	int subclass = 0;
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
-	dev->flags  = real_dev->flags & ~IFF_UP;
+	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI);
 	dev->iflink = real_dev->ifindex;
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |

--------------050100080502070107020403--
