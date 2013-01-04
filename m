From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V6 08/15] cxgb3: remove usage of dev->master
Date: Fri,  4 Jan 2013 09:48:56 +0100
Message-ID: <1357289343-817-9-git-send-email-jiri@resnulli.us>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:43974 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754329Ab3ADItn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 03:49:43 -0500
Received: by mail-ee0-f53.google.com with SMTP id c50so7774008eek.12
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 00:49:42 -0800 (PST)
In-Reply-To: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 942dace..3f1f501 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -182,14 +182,17 @@ static struct net_device *get_iff_from_mac(struct adapter *adapter,
 		struct net_device *dev = adapter->port[i];
 
 		if (!memcmp(dev->dev_addr, mac, ETH_ALEN)) {
+			rcu_read_lock();
 			if (vlan && vlan != VLAN_VID_MASK) {
-				rcu_read_lock();
 				dev = __vlan_find_dev_deep(dev, vlan);
-				rcu_read_unlock();
 			} else if (netif_is_bond_slave(dev)) {
-				while (dev->master)
-					dev = dev->master;
+				struct net_device *upper_dev;
+
+				while ((upper_dev =
+					netdev_master_upper_dev_get_rcu(dev)))
+					dev = upper_dev;
 			}
+			rcu_read_unlock();
 			return dev;
 		}
 	}
-- 
1.8.0
