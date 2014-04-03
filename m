From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH v4 3/4] bonding: Added bond_tlb_xmit() for tlb mode.
Date: Wed,  2 Apr 2014 17:33:23 -0700
Message-ID: <1396485203-4060-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:44224 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933374AbaDCAdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 20:33:25 -0400
Received: by mail-ob0-f201.google.com with SMTP id gq1so269695obb.4
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 17:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-organized the xmit function for the lb mode separating tlb xmit
from the alb mode. This will enable use of the hashing policies
like 802.3ad mode. Also extended use of xmit-hash-policy to tlb mode.

Now the tlb-mode defaults to BOND_XMIT_POLICY_LAYER2 if the xmit policy
module parameter is not set (just like 802.3ad, or Xor mode).

Change-Id: I140257403d272df75f477b380207338d0f04963e
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v2:
  Micro optimization - switch statement from ntohs(var) to htons(const) 
v3:
  Rebase
v4:
  [Trivial] Added Documentation changes.

 Documentation/networking/bonding.txt |  2 +-
 drivers/net/bonding/bond_alb.c       | 26 ++++++++++++++++++++++++++
 drivers/net/bonding/bond_alb.h       |  1 +
 drivers/net/bonding/bond_main.c      |  6 ++++--
 drivers/net/bonding/bond_options.c   |  2 +-
 5 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index a383c00392d0..a97c567f24e8 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -769,7 +769,7 @@ use_carrier
 xmit_hash_policy
 
 	Selects the transmit hash policy to use for slave selection in
-	balance-xor and 802.3ad modes.  Possible values are:
+	balance-xor, 802.3ad, and tlb modes.  Possible values are:
 
 	layer2
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 5cd36016c393..153232ed4b3f 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1381,6 +1381,32 @@ out:
 	return NETDEV_TX_OK;
 }
 
+int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct ethhdr *eth_data;
+	struct slave *tx_slave = NULL;
+	u32 hash_index;
+
+	skb_reset_mac_header(skb);
+	eth_data = eth_hdr(skb);
+
+	/* Do not TX balance any multicast or broadcast */
+	if (!is_multicast_ether_addr(eth_data->h_dest)) {
+		switch (skb->protocol) {
+		case htons(ETH_P_IP):
+		case htons(ETH_P_IPX):
+		    /* In case of IPX, it will falback to L2 hash */
+		case htons(ETH_P_IPV6):
+			hash_index = bond_xmit_hash(bond, skb);
+			tx_slave = tlb_choose_channel(bond, hash_index & 0xFF, skb->len);
+			break;
+		}
+	}
+
+	return bond_do_alb_xmit(skb, bond, tx_slave);
+}
+
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index e09dd4bfafff..5fc76c01636c 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -175,6 +175,7 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave);
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
+int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6e96d510bc8d..e2b9d3dd8c3d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3774,8 +3774,9 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 	case BOND_MODE_8023AD:
 		return bond_3ad_xmit_xor(skb, dev);
 	case BOND_MODE_ALB:
-	case BOND_MODE_TLB:
 		return bond_alb_xmit(skb, dev);
+	case BOND_MODE_TLB:
+		return bond_tlb_xmit(skb, dev);
 	default:
 		/* Should never happen, mode already checked */
 		pr_err("%s: Error: Unknown bonding mode %d\n",
@@ -3996,7 +3997,8 @@ static int bond_check_params(struct bond_params *params)
 
 	if (xmit_hash_policy) {
 		if ((bond_mode != BOND_MODE_XOR) &&
-		    (bond_mode != BOND_MODE_8023AD)) {
+		    (bond_mode != BOND_MODE_8023AD) &&
+		    (bond_mode != BOND_MODE_TLB)) {
 			pr_info("xmit_hash_policy param is irrelevant in mode %s\n",
 				bond_mode_name(bond_mode));
 		} else {
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 724e30fa20b9..dc3893841752 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -199,7 +199,7 @@ static const struct bond_option bond_opts[] = {
 	[BOND_OPT_XMIT_HASH] = {
 		.id = BOND_OPT_XMIT_HASH,
 		.name = "xmit_hash_policy",
-		.desc = "balance-xor and 802.3ad hashing method",
+		.desc = "balance-xor, 802.3ad, and tlb hashing method",
 		.values = bond_xmit_hashtype_tbl,
 		.set = bond_option_xmit_hash_policy_set
 	},
-- 
1.9.1.423.g4596e3a
