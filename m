From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH 2/2] bonding: restore NETIF_F_VLAN_CHALLENGED properly in
 bond_del_vlan()
Date: Fri, 3 Jun 2011 22:14:24 +0200
Message-ID: <20110603201424.GB24804@midget.suse.cz>
References: <20110603200738.GA24804@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pedro Garcia <pedro.netdev@dondevamos.com>,
	Patrick McHardy <kaber@trash.net>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48411 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399Ab1FCUO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 16:14:26 -0400
Content-Disposition: inline
In-Reply-To: <20110603200738.GA24804@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit ad1afb00, bond_del_vlan() never restores
NETIF_F_VLAN_CHALLENGED as intended.  bond->vlan_list is never
empty once the 8021q module is loaded, because the special VLAN 0
is always kept registered on the bond interface. Change the
condition to check if bond->vlan_list contains exactly one item
instead of checking for an empty list.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 17b4dd9..4d317cd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -329,9 +329,10 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 
 			kfree(vlan);
 
-			if (list_empty(&bond->vlan_list) &&
+			if (bond->vlan_list.next->next == &bond->vlan_list &&
 			    (bond->slave_cnt == 0)) {
-				/* Last VLAN removed and no slaves, so
+				/* Last VLAN removed (the only member of vlan_list
+				 * is the special vid == 0 vlan) and no slaves, so
 				 * restore block on adding VLANs. This will
 				 * be removed once new slaves that are not
 				 * VLAN challenged will be added.
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

