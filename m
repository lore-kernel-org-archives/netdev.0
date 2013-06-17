From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 1/3] vxlan: fix race between flush and incoming learning
Date: Mon, 17 Jun 2013 12:09:57 -0700
Message-ID: <1371496199-5424-2-git-send-email-stephen@networkplumber.org>
References: <1371496199-5424-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:45462 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab3FQTKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 15:10:06 -0400
Received: by mail-pa0-f44.google.com with SMTP id lj1so3161356pab.31
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 12:10:05 -0700 (PDT)
In-Reply-To: <1371496199-5424-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for a packet to arrive during vxlan_stop(), and
have a dynamic entry created. Close this by checking if device
is up.

 CPU1                             CPU2
vxlan_stop
  vxlan_flush
     hash_lock acquired
                                  vxlan_encap_recv
                                     vxlan_snoop
                                        waiting for hash_lock
     hash_lock relased
  vxlan_flush done
                                        hash_lock acquired
                                        vxlan_fdb_create

This is a day-one bug in vxlan goes back to 3.7.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3b1d2ee..577a069 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -571,7 +571,6 @@ static void vxlan_snoop(struct net_device *dev,
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
-	int err;
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
@@ -588,12 +587,15 @@ static void vxlan_snoop(struct net_device *dev,
 	} else {
 		/* learned new entry */
 		spin_lock(&vxlan->hash_lock);
-		err = vxlan_fdb_create(vxlan, src_mac, src_ip,
-				       NUD_REACHABLE,
-				       NLM_F_EXCL|NLM_F_CREATE,
-				       vxlan->dst_port,
-				       vxlan->default_dst.remote_vni,
-				       0, NTF_SELF);
+
+		/* close off race between vxlan_flush and incoming packets */
+		if (netif_running(dev))
+			vxlan_fdb_create(vxlan, src_mac, src_ip,
+					 NUD_REACHABLE,
+					 NLM_F_EXCL|NLM_F_CREATE,
+					 vxlan->dst_port,
+					 vxlan->default_dst.remote_vni,
+					 0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
 	}
 }
-- 
1.7.10.4
