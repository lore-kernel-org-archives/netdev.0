From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V2 net] netdevice: Include NETIF_F_HW_CSUM when intersecting features
Date: Thu, 20 Apr 2017 15:17:24 -0400
Message-ID: <1492715844-30273-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36676 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947006AbdDTTRh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:17:37 -0400
Received: by mail-qt0-f193.google.com with SMTP id t52so8927807qtb.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 12:17:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While hardware device use either NETIF_F_(IP|IPV6)_CSUM or
NETIF_F_HW_CSUM, all of the software devices use HW_CSUM.
This results in an interesting situation when the software
device is configured on top of hw device using (IP|IPV6)_CSUM.
In this situation, the user can't turn off checksum offloading
features on the software device.

This patch resolves that by adding NETIF_F_HW_CSUM to the mask
if a feature set includes only IP|IPV6 csum.  This allows the user
to control the upper (software) device checksum, while at the same
time correctly propagating lower device changes up.

CC: Michal Kubecek <mkubecek@suse.cz>
CC: Alexander Duyck <alexander.duyck@gmail.com>
CC: Tom Herbert <tom@herbertland.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

---

V2: Addressed comments from Alex Duyck.  I tested this with hacked virtio
device that set IP|IPV6 checksums instead of HW.  Configuring a vlan on
top gave the vlan device with 'ip-generic: on' setting (using HW checksum).
This allows me to change vlan checksum offloads independent of virt-io nic.
Changes to virtio-nic propagated up to vlan, turning off the offloading
correctly.

 include/linux/netdevice.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b0aa089..81aed2f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4009,10 +4009,10 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
 							  netdev_features_t f2)
 {
 	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
-		if (f1 & NETIF_F_HW_CSUM)
-			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
-		else
-			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
+		if (f1 & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
+			f1 |= NETIF_F_HW_CSUM;
+		if(f2 & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
+			f2 |= NETIF_F_HW_CSUM;
 	}
 
 	return f1 & f2;
-- 
2.7.4
