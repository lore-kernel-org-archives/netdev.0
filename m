From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net] delete rlb entry if ip of bonding is deleted
Date: Wed, 29 Feb 2012 20:19:59 -0800
Message-ID: <10138.1330575599@death.nxdomain>
References: <4F4EF3FB.8080507@gmail.com> <b68da7936fe7ed8e6e15edecb41a140a07026ace.1330573426.git.panweiping3@gmail.com>
Cc: netdev@vger.kernel.org, jbohac@suse.cz, andy@greyhouse.net
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:47516 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146Ab2CAEUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 23:20:06 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 29 Feb 2012 23:20:05 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3E0A438C805A
	for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 23:20:02 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q214K18j318972
	for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 23:20:01 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q214KDWp008502
	for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 21:20:14 -0700
In-reply-to: <b68da7936fe7ed8e6e15edecb41a140a07026ace.1330573426.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Weiping Pan <panweiping3@gmail.com> wrote:

>When the ip of bonding is deleted, its rlb table still contains old invalid
>mappings, just delete them to avoid poisoning other clients arp cache.

	I don't believe this patch will handle the case that Jiri
mentioned earlier: the bond host is acting as a router or bridge.  The
key here is that the "source address" in question is not assigned to the
bond at all, but comes from another host whose traffic passes through
the bond.

	On the other hand, the logic of this patch might be useful to
purge table entries for local addresses when they are deconfigured from
the bond.  I don't think it's a complete solution by itself, though.

	-J

>Signed-off-by: Weiping Pan <panweiping3@gmail.com>
>---
> drivers/net/bonding/bond_alb.c  |   35 +++++++++++++++++++++++++++++++++++
> drivers/net/bonding/bond_alb.h  |    2 ++
> drivers/net/bonding/bond_main.c |    1 +
> 3 files changed, 38 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index f820b26..928c636 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -853,6 +853,41 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
> 	_unlock_rx_hashtbl_bh(bond);
> }
>
>+/* delete all rlb entries which has ip as ip_src */
>+void bond_alb_delete_entry(struct bonding *bond, __be32 ip)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	u32 curr_index;
>+
>+	_lock_rx_hashtbl_bh(bond);
>+
>+	curr_index = bond_info->rx_hashtbl_head;
>+	while (curr_index != RLB_NULL_INDEX) {
>+		struct rlb_client_info *curr = &(bond_info->rx_hashtbl[curr_index]);
>+		u32 next_index = bond_info->rx_hashtbl[curr_index].next;
>+		u32 prev_index = bond_info->rx_hashtbl[curr_index].prev;
>+		if (curr->assigned && (curr->ip_src == ip)) {
>+			if (curr_index == bond_info->rx_hashtbl_head) {
>+				bond_info->rx_hashtbl_head = next_index;
>+			}
>+
>+			if (prev_index != RLB_NULL_INDEX) {
>+				bond_info->rx_hashtbl[prev_index].next = next_index;
>+			}
>+
>+			if (next_index != RLB_NULL_INDEX) {
>+				bond_info->rx_hashtbl[next_index].prev = prev_index;
>+			}
>+
>+			rlb_init_table_entry(curr);
>+		}
>+
>+		curr_index = next_index;
>+	}
>+
>+	_unlock_rx_hashtbl_bh(bond);
>+}
>+
> /*********************** tlb/rlb shared functions *********************/
>
> static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
>diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>index 90f140a..38863fc 100644
>--- a/drivers/net/bonding/bond_alb.h
>+++ b/drivers/net/bonding/bond_alb.h
>@@ -163,5 +163,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
> void bond_alb_monitor(struct work_struct *);
> int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
> void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
>+
>+void bond_alb_delete_entry(struct bonding *bond, __be32 ip);
> #endif /* __BOND_ALB_H__ */
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 435984a..ec071b9 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3315,6 +3315,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
> 				return NOTIFY_OK;
> 			case NETDEV_DOWN:
> 				bond->master_ip = 0;
>+				bond_alb_delete_entry(bond, ifa->ifa_local);
> 				return NOTIFY_OK;
> 			default:
> 				return NOTIFY_DONE;
>-- 
>1.7.4.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
