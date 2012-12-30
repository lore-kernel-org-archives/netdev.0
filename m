From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/15] cxgb3: remove usage of dev->master
Date: Sun, 30 Dec 2012 12:58:15 +0100
Message-ID: <1356868702-8144-9-git-send-email-jiri@resnulli.us>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:45184 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab2L3MAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 07:00:11 -0500
Received: by mail-ee0-f44.google.com with SMTP id b47so5954920eek.3
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 04:00:10 -0800 (PST)
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
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
