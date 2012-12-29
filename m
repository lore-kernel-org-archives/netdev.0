From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/15] qlcnic: guard __vlan_find_dev_deep() by rcu_read_lock
Date: Sat, 29 Dec 2012 11:38:36 +0100
Message-ID: <1356777522-19652-10-git-send-email-jiri@resnulli.us>
References: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-ea0-f172.google.com ([209.85.215.172]:41425 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab2L2KjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 05:39:20 -0500
Received: by mail-ea0-f172.google.com with SMTP id a1so4733611eaa.31
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 02:39:19 -0800 (PST)
In-Reply-To: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu_read_lock was missing here

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d833f59..95b628f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2867,12 +2867,14 @@ qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 
 	qlcnic_config_indev_addr(adapter, netdev, event);
 
+	rcu_read_lock();
 	for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
 		dev = __vlan_find_dev_deep(netdev, vid);
 		if (!dev)
 			continue;
 		qlcnic_config_indev_addr(adapter, dev, event);
 	}
+	rcu_read_unlock();
 }
 
 static int qlcnic_netdev_event(struct notifier_block *this,
-- 
1.8.0
