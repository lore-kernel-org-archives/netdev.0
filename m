From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v3 net 5/5] vxlan: fix race between flush and incoming
 learning
Date: Mon, 10 Jun 2013 17:37:19 -0700
Message-ID: <20130610173719.438d0c03@nehalam.linuxnetplumber.net>
References: <20130611002547.346603375@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:64084 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443Ab3FKAhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 20:37:40 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so6811964pbc.16
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 17:37:39 -0700 (PDT)
In-Reply-To: <20130611002547.346603375@vyatta.com>
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

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v3 - no changes

Should go to -net. Too much of a "theoritical race" for stable.


--- a/drivers/net/vxlan.c	2013-06-10 15:10:43.271357218 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 15:23:19.541044803 -0700
@@ -611,7 +611,6 @@ static bool vxlan_snoop(struct net_devic
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
-	int err;
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
@@ -632,12 +631,15 @@ static bool vxlan_snoop(struct net_devic
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
 
