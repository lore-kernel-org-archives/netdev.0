From: Annie Li <annie.li@oracle.com>
Subject: [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Thu, 15 Nov 2012 15:03:07 +0800
Message-ID: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Cc: annie.li@oracle.com
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28740 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145Ab2KOHET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 02:04:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements persistent grants for xen-netfront/netback. This
mechanism maintains page pools in netback/netfront, these page pools is used to
save grant pages which are mapped. This way improve performance which is wasted
when doing grant operations.

Current netback/netfront does map/unmap grant operations frequently when
transmitting/receiving packets, and grant operations costs much cpu clock. In
this patch, netfront/netback maps grant pages when needed and then saves them
into a page pool for future use. All these pages will be unmapped when
removing/releasing the net device.

In netfront, two pools are maintained for transmitting and receiving packets.
When new grant pages are needed, the driver gets grant pages from this pool
first. If no free grant page exists, it allocates new page, maps it and then
saves it into the pool. The pool size for transmit/receive is exactly tx/rx
ring size. The driver uses memcpy(not grantcopy) to copy data grant pages.
Here, memcpy is copying the whole page size data. I tried to copy len size data
from offset, but network does not seem work well. I am trying to find the root
cause now.

In netback, it also maintains two page pools for tx/rx. When netback gets a
request, it does a search first to find out whether the grant reference of
this request is already mapped into its page pool. If the grant ref is mapped,
the address of this mapped page is gotten and memcpy is used to copy data
between grant pages. However, if the grant ref is not mapped, a new page is
allocated, mapped with this grant ref, and then saved into page pool for
future use. Similarly, memcpy replaces grant copy to copy data between grant
pages. In this implementation, two arrays(gnttab_tx_vif,gnttab_rx_vif) are
used to save vif pointer for every request because current netback is not
per-vif based. This would be changed after implementing 1:1 model in netback.

This patch supports both persistent-grant and non persistent grant. A new
xenstore key "feature-persistent-grants" is used to represent this feature.

This patch is based on linux3.4-rc3. I hit netperf/netserver failure on
linux latest version v3.7-rc1, v3.7-rc2 and v3.7-rc4. Not sure whether this
netperf/netserver failure connects compound page commit in v3.7-rc1, but I did
hit BUG_ON with debug patch from thread
http://lists.xen.org/archives/html/xen-devel/2012-10/msg00893.html


Annie Li (4):
  xen/netback: implements persistent grant with one page pool.
  xen/netback: Split one page pool into two(tx/rx) page pool.
  Xen/netfront: Implement persistent grant in netfront.
  fix code indent issue in xen-netfront.

 drivers/net/xen-netback/common.h    |   24 ++-
 drivers/net/xen-netback/interface.c |   26 +++
 drivers/net/xen-netback/netback.c   |  215 ++++++++++++++++++--
 drivers/net/xen-netback/xenbus.c    |   14 ++-
 drivers/net/xen-netfront.c          |  378 +++++++++++++++++++++++++++++------
 5 files changed, 570 insertions(+), 87 deletions(-)

-- 
1.7.3.4
