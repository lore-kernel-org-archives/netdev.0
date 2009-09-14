From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 4/4] bonding: add sysfs files to display tlb and alb
	hash table contents
Date: Mon, 14 Sep 2009 10:45:32 -0400
Message-ID: <20090914144532.GU8515@gospo.rdu.redhat.com>
References: <20090911211317.GT8515@gospo.rdu.redhat.com> <26430.1252705697@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755575AbZINOpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 10:45:55 -0400
Content-Disposition: inline
In-Reply-To: <26430.1252705697@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 02:48:17PM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >bonding: add sysfs files to display tlb and alb hash table contents
> 
> 	Isn't it considered bad form to have sysfs files that kick out
> large amounts of data like this?  Not that I think this is a bad
> facility to have, just checking on the mechanism.
> 

I'm not aware of such a restriction -- though I'm sure at least one
person out there doesn't like it.

If that's the case, there are certainly a few files that should be
cleaned up:

# find -type f -exec wc -l {} 2> /dev/null \; | sort -r -n | head -10
1657 ./firmware/acpi/tables/SSDT
132 ./firmware/acpi/tables/dynamic/SSDT2
128 ./devices/pci0000:00/0000:00:1c.5/0000:3f:00.0/vpd
27 ./devices/system/node/node0/meminfo
24 ./devices/pnp0/00:08/options
24 ./devices/pnp0/00:07/options
12 ./devices/pci0000:00/0000:00:1e.0/resource
12 ./devices/pci0000:00/0000:00:1c.5/resource
12 ./devices/pci0000:00/0000:00:1c.4/resource
12 ./devices/pci0000:00/0000:00:1c.0/resource


> >While debugging some problems with alb (mode 6) bonding I realized that
> >being able to output the contents of both hash tables would be helpful.
> >This is what the output looks like for the two files:
> >
> >device  load
> >eth1    491
> >eth2    491
> >hash device   last device   tx bytes       load        next previous
> >2    eth1     eth1          2254           491         0    0
> >3    eth2     eth2          2744           491         0    0
> >6             eth2          0              488         0    0
> >8             eth2          0              461698      0    0
> >1b            eth2          0              249         0    0
> >eb            eth2          0              21          0    0
> >ff            eth2          0              22          0    0
> >
> >hash ip_src          ip_dst          mac_dst           slave assign ntt
> >2    10.0.3.2        10.0.3.11       00:e0:81:71:ee:a9 eth1  1      0
> >3    10.0.3.2        10.0.3.10       00:e0:81:71:ee:a9 eth2  1      0
> >8    10.0.3.2        10.0.3.1        00:e0:81:71:ee:a9 eth2  1      0
> >
> >These were a great help debugging the fixes I have just posted and they
> >might be helpful for others, so I decided to include them in my
> >patchset.
> >
> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >
> >---
> > drivers/net/bonding/bond_alb.c   |   61 ++++++++++++++++++++++++++++++++++++++
> > drivers/net/bonding/bond_alb.h   |    2 +
> > drivers/net/bonding/bond_sysfs.c |   40 +++++++++++++++++++++++++
> > 3 files changed, 103 insertions(+), 0 deletions(-)
> >
> >diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> >index 7db8835..4e930e3 100644
> >--- a/drivers/net/bonding/bond_alb.c
> >+++ b/drivers/net/bonding/bond_alb.c
> >@@ -778,6 +778,67 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
> > 	return tx_slave;
> > }
> >
> >+int rlb_print_rx_hashtbl(struct bonding *bond, char *buf)
> >+{
> >+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> >+	struct rlb_client_info *client_info;
> >+	u32 hash_index;
> >+	u32 count = 0;
> >+	
> >+	_lock_rx_hashtbl(bond);
> >+
> >+	count = sprintf(buf, "hash ip_src          ip_dst          mac_dst           slave assign ntt\n");
> >+	hash_index = bond_info->rx_hashtbl_head;
> >+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
> >+		client_info = &(bond_info->rx_hashtbl[hash_index]);
> >+		count += sprintf(buf + count,"%-4x %-15pi4 %-15pi4 %pM %-5s %-6d %d\n",
> >+				 hash_index,
> >+				 &client_info->ip_src,
> >+				 &client_info->ip_dst,
> >+				 client_info->mac_dst,
> >+				 client_info->slave->dev->name,
> >+				 client_info->assigned,
> >+				 client_info->ntt);
> >+	}
> >+
> >+	_unlock_rx_hashtbl(bond);
> >+	return count;
> >+}
> >+
> >+int tlb_print_tx_hashtbl(struct bonding *bond, char *buf)
> >+{
> >+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> >+	u32 hash_index;
> >+	u32 count = 0;
> >+	struct slave *slave;
> >+	int i;
> >+	
> >+	_lock_tx_hashtbl(bond);
> >+
> >+	count += sprintf(buf, "device  load\n");
> >+	bond_for_each_slave(bond, slave, i) {
> >+		struct tlb_slave_info *slave_info = &(SLAVE_TLB_INFO(slave));
> >+		count += sprintf(buf + count,"%-7s %d\n",slave->dev->name,slave_info->load);
> >+	}
> >+	count += sprintf(buf + count, "hash device   last device   tx bytes       load        next previous\n");
> >+	for (hash_index = 0; hash_index < TLB_HASH_TABLE_SIZE; hash_index++) {
> >+		struct tlb_client_info *client_info = &(bond_info->tx_hashtbl[hash_index]);
> >+		if (client_info->tx_slave || client_info->last_slave) {
> >+			count += sprintf(buf + count,"%-4x %-8s %-13s %-14d %-11d %-4x %d\n",
> >+					 hash_index,
> >+					 (client_info->tx_slave) ? client_info->tx_slave->dev->name : "",
> >+					 (client_info->last_slave) ? client_info->last_slave->dev->name : "",
> >+					 client_info->tx_bytes,
> >+					 client_info->load_history,
> >+					 (client_info->next != TLB_NULL_INDEX) ? client_info->next : 0,
> >+					 (client_info->prev != TLB_NULL_INDEX) ? client_info->prev : 0);
> >+		}
> >+	}
> >+
> >+	_unlock_tx_hashtbl(bond);
> >+	return count;
> >+}
> >+
> > /* Caller must hold rx_hashtbl lock */
> > static void rlb_init_table_entry(struct rlb_client_info *entry)
> > {
> >diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
> >index b65fd29..8543447 100644
> >--- a/drivers/net/bonding/bond_alb.h
> >+++ b/drivers/net/bonding/bond_alb.h
> >@@ -132,5 +132,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
> > void bond_alb_monitor(struct work_struct *);
> > int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
> > void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
> >+int rlb_print_rx_hashtbl(struct bonding *bond, char *buf);
> >+int tlb_print_tx_hashtbl(struct bonding *bond, char *buf);
> > #endif /* __BOND_ALB_H__ */
> >
> >diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> >index 55bf34f..1123e1f 100644
> >--- a/drivers/net/bonding/bond_sysfs.c
> >+++ b/drivers/net/bonding/bond_sysfs.c
> >@@ -1480,6 +1480,44 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
> > static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
> >
> >
> >+/*
> >+ * Show current tlb/alb tx hash table.
> >+ */
> >+static ssize_t bonding_show_tlb_tx_hash(struct device *d,
> >+					   struct device_attribute *attr,
> >+					   char *buf)
> >+{
> >+	int count = 0;
> >+	struct bonding *bond = to_bond(d);
> >+
> >+	if (bond->params.mode == BOND_MODE_ALB ||
> >+	    bond->params.mode == BOND_MODE_TLB) {
> >+		count = tlb_print_tx_hashtbl(bond, buf);
> >+	}
> >+
> >+	return count;
> >+}
> >+static DEVICE_ATTR(tlb_tx_hash, S_IRUGO, bonding_show_tlb_tx_hash, NULL);
> 
> 	Should the mode here be S_IRUSR (0400, instead of 0444)?
> Otherwise, a nefarious user could "while 1 cat /sys/.../tlb_tx_hash" and
> keep the hash table lock fairly busy.  Since the lock is acquired for
> every packet on tx, that's probably a bad thing.
> 
> >+
> >+/*
> >+ * Show current alb rx hash table.
> >+ */
> >+static ssize_t bonding_show_alb_rx_hash(struct device *d,
> >+					   struct device_attribute *attr,
> >+					   char *buf)
> >+{
> >+	int count = 0;
> >+	struct bonding *bond = to_bond(d);
> >+
> >+	if (bond->params.mode == BOND_MODE_ALB) {
> >+		count = rlb_print_rx_hashtbl(bond, buf);
> >+	}
> >+
> >+	return count;
> >+}
> >+static DEVICE_ATTR(alb_rx_hash, S_IRUGO, bonding_show_alb_rx_hash, NULL);
> 
> 	Same comment as for the mode of the tlb_tx_hash, although the rx
> hash table lock is much more lightly used, so it might not be a real
> problem.
> 
> >
> > static struct attribute *per_bond_attrs[] = {
> > 	&dev_attr_slaves.attr,
> >@@ -1505,6 +1543,8 @@ static struct attribute *per_bond_attrs[] = {
> > 	&dev_attr_ad_actor_key.attr,
> > 	&dev_attr_ad_partner_key.attr,
> > 	&dev_attr_ad_partner_mac.attr,
> >+	&dev_attr_alb_rx_hash.attr,
> >+	&dev_attr_tlb_tx_hash.attr,
> > 	NULL,
> > };
> >
> >-- 
> >1.5.5.6
> >
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
