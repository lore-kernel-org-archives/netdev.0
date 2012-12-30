From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/15] vlan: add link to upper device
Date: Sun, 30 Dec 2012 12:58:10 +0100
Message-ID: <1356868702-8144-4-git-send-email-jiri@resnulli.us>
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
Received: from mail-ea0-f169.google.com ([209.85.215.169]:48867 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466Ab2L3L7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 06:59:15 -0500
Received: by mail-ea0-f169.google.com with SMTP id a12so4763659eaa.14
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 03:59:14 -0800 (PST)
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/8021q/vlan.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a292e80..babfde9 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -105,6 +105,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 */
 	unregister_netdevice_queue(dev, head);
 
+	netdev_upper_dev_unlink(real_dev, dev);
+
 	if (grp->nr_vlan_devs == 0)
 		vlan_gvrp_uninit_applicant(real_dev);
 
@@ -162,9 +164,13 @@ int register_vlan_dev(struct net_device *dev)
 	if (err < 0)
 		goto out_uninit_applicant;
 
+	err = netdev_upper_dev_link(real_dev, dev);
+	if (err)
+		goto out_uninit_applicant;
+
 	err = register_netdevice(dev);
 	if (err < 0)
-		goto out_uninit_applicant;
+		goto out_upper_dev_unlink;
 
 	/* Account for reference in struct vlan_dev_priv */
 	dev_hold(real_dev);
@@ -180,6 +186,8 @@ int register_vlan_dev(struct net_device *dev)
 
 	return 0;
 
+out_upper_dev_unlink:
+	netdev_upper_dev_unlink(real_dev, dev);
 out_uninit_applicant:
 	if (grp->nr_vlan_devs == 0)
 		vlan_gvrp_uninit_applicant(real_dev);
-- 
1.8.0
