From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 03/15] vlan: add link to upper device
Date: Tue, 14 Aug 2012 17:05:36 +0200
Message-ID: <1344956748-2099-4-git-send-email-jiri@resnulli.us>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52683 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756522Ab2HNPGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 11:06:04 -0400
Received: by mail-ee0-f46.google.com with SMTP id l10so194033eei.19
        for <netdev@vger.kernel.org>; Tue, 14 Aug 2012 08:06:04 -0700 (PDT)
In-Reply-To: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/8021q/vlan.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9096bcb..2dca0fa 100644
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
1.7.10.4
