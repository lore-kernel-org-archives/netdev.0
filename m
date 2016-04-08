From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 3/6] bridge: simplify the stp_state_store by calling store_bridge_parm
Date: Sat,  9 Apr 2016 00:03:30 +0800
Message-ID: <8c14a891d0a8bcea071d4e5305776a5c5cd9fd17.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
 <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
 <6197a35a2eb6df2caf90edcbf1b49da12077f659.1460131308.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:35843 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932688AbcDHQD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:03:58 -0400
Received: by mail-ig0-f196.google.com with SMTP id kb1so2989811igb.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 09:03:57 -0700 (PDT)
In-Reply-To: <6197a35a2eb6df2caf90edcbf1b49da12077f659.1460131308.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some repetitive codes in stp_state_store, we can remove
them by calling store_bridge_parm.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 137cd3b..f9d484e 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -128,27 +128,21 @@ static ssize_t stp_state_show(struct device *d,
 }
 
 
-static ssize_t stp_state_store(struct device *d,
-			       struct device_attribute *attr, const char *buf,
-			       size_t len)
+static int set_stp_state(struct net_bridge *br, unsigned long val)
 {
-	struct net_bridge *br = to_bridge(d);
-	char *endp;
-	unsigned long val;
-
-	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
-		return -EPERM;
-
-	val = simple_strtoul(buf, &endp, 0);
-	if (endp == buf)
-		return -EINVAL;
-
 	if (!rtnl_trylock())
 		return restart_syscall();
 	br_stp_set_enabled(br, val);
 	rtnl_unlock();
 
-	return len;
+	return 0;
+}
+
+static ssize_t stp_state_store(struct device *d,
+			       struct device_attribute *attr, const char *buf,
+			       size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_stp_state);
 }
 static DEVICE_ATTR_RW(stp_state);
 
-- 
2.1.0
