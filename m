From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/2] vlan: add proto and regulate the /proc/net/vlan/config
Date: Fri, 7 Mar 2014 20:10:51 +0800
Message-ID: <1394194251-11656-3-git-send-email-dingtianhong@huawei.com>
References: <1394194251-11656-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:32482 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbaCGMLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 07:11:19 -0500
In-Reply-To: <1394194251-11656-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan support 2 proto: 802.1q and 802.1ad, so add it
to /proc/net/vlan/config, and the old format seems inappropriate,
regulate it.

---------------------- the old format: --------------------------

VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
eth2.5         | 5  | eth2
eth2.5.100     | 100  | eth2.5
eth2.5.20      | 20  | eth2.5

----------------------- the new format: -------------------------

VLAN Dev Name  | Proto   | VID  | Real Dev
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
eth2.1000      | 802.1ad | 1000 | eth2
eth2.5         | 802.1ad | 5    | eth2
eth2.5.20      | 802.1ad | 20   | eth2.5

-----------------------------------------------------------------

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlanproc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index a40abbc..e571347 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -254,7 +254,7 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN) {
 		const char *nmtype = NULL;
 
-		seq_puts(seq, "VLAN Dev name	 | VLAN ID\n");
+		seq_puts(seq, "VLAN Dev Name  | Proto   | VID  | Real Dev\n");
 
 		if (vn->name_type < ARRAY_SIZE(vlan_name_type_str))
 		    nmtype =  vlan_name_type_str[vn->name_type];
@@ -265,8 +265,11 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 		const struct net_device *vlandev = v;
 		const struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 
-		seq_printf(seq, "%-15s| %d  | %s\n",  vlandev->name,
-			   vlan->vlan_id,    vlan->real_dev->name);
+		seq_printf(seq, "%-15s| %s | %-4d | %s\n",
+			   vlandev->name,
+			   vlan->vlan_proto == htons(ETH_P_8021Q) ?
+			   "802.1q" : "802.1ad",
+			   vlan->vlan_id, vlan->real_dev->name);
 	}
 	return 0;
 }
-- 
1.8.0
