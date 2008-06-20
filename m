From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 6/8] ipv4: Check return of dev_set_allmulti
Date: Fri, 20 Jun 2008 08:55:32 +0800
Message-ID: <485B0004.9020108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56796 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754671AbYFTA72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 20:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv4/ipmr.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 11700a4..2d0b92c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -398,6 +398,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	struct vif_device *v = &vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
+	int err;
 
 	/* Is vif busy ? */
 	if (VIF_EXISTS(vifi))
@@ -435,7 +436,10 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
 		return -EADDRNOTAVAIL;
 	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
-	dev_set_allmulti(dev, +1);
+	/* Check whether allmulti overflow */
+	err = dev_set_allmulti(dev, 1);
+	if (err)
+		return err;
 	ip_rt_multicast_event(in_dev);
 
 	/*
-- 
1.5.3.4



