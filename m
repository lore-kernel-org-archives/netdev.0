From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 5/6] bridge: a netlink notification should be sent when those attributes are changed by br_sysfs_if
Date: Tue,  5 Apr 2016 11:32:40 +0800
Message-ID: <d6f49fd173d183b78c4dd4e18e67d394438f5d7d.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
 <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1459827115.git.lucien.xin@gmail.com>
 <6197a35a2eb6df2caf90edcbf1b49da12077f659.1459827115.git.lucien.xin@gmail.com>
 <baf4788b6ac529a2132ace735fc1caf4989307da.1459827115.git.lucien.xin@gmail.com>
 <9bf0874c74438a287968ef5190599214333b52be.1459827115.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35702 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbcDEDdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 23:33:12 -0400
Received: by mail-pf0-f193.google.com with SMTP id r187so145382pfr.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 20:33:12 -0700 (PDT)
In-Reply-To: <9bf0874c74438a287968ef5190599214333b52be.1459827115.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when we change the attributes of bridge or br_port by netlink,
a relevant netlink notification will be sent, but if we change them
by ioctl or sysfs, no notification will be sent.

We should ensure that whenever those attributes change internally or from
sysfs/ioctl, that a netlink notification is sent out to listeners.

Also, NetworkManager will use this in the future to listen for out-of-band
bridge master attribute updates and incorporate them into the runtime
configuration.

This patch is used for br_sysfs_if, and we also move br_ifinfo_notify out
of store_flag.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_if.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index efe415a..1e04d4d 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -61,7 +61,6 @@ static int store_flag(struct net_bridge_port *p, unsigned long v,
 	if (flags != p->flags) {
 		p->flags = flags;
 		br_port_flags_change(p, mask);
-		br_ifinfo_notify(RTM_NEWLINK, p);
 	}
 	return 0;
 }
@@ -253,8 +252,10 @@ static ssize_t brport_store(struct kobject *kobj,
 			spin_lock_bh(&p->br->lock);
 			ret = brport_attr->store(p, val);
 			spin_unlock_bh(&p->br->lock);
-			if (ret == 0)
+			if (!ret) {
+				br_ifinfo_notify(RTM_NEWLINK, p);
 				ret = count;
+			}
 		}
 		rtnl_unlock();
 	}
-- 
2.1.0
