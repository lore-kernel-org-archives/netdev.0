From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net RESEND] bonding: set correct vlan id for alb xmit path
Date: Tue, 11 Mar 2014 17:26:39 +0100
Message-ID: <20140311162639.GB2770@redhat.com>
References: <531E7168.1030407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055AbaCKQ1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 12:27:03 -0400
Content-Disposition: inline
In-Reply-To: <531E7168.1030407@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 10:14:00AM +0800, Ding Tianhong wrote:
>The commit d3ab3ffd1d728d7ee77340e7e7e2c7cfe6a4013e
>(bonding: use rlb_client_info->vlan_id instead of ->tag)
>remove the rlb_client_info->tag, but occur some issues,
>The vlan_get_tag() will return 0 for success and -EINVAL for
>error, so the client_info->vlan_id always be set to 0 if the
>vlan_get_tag return 0 for success, so the client_info would
>never get a correct vlan id, and could not send a skb for vlan id 0.

VLAN id 0 is a reserved value, afaik, used for traffic prioritizing (by
8021p), so it shouldn't be treated as a normal VLAN.

Also, I remember that it was used internally for HW filtering, so it might
interfere with those (if a devices has NETIF_F_HW_VLAN_CTAG_FITLER VLAN id
0 is added automatically).

Based on these I don't think that bonding should see VLAN 0 as a normal
VLAN.

>
>Fix this by convert the client_info->vlan_id from u16 to s16,
>and set to -1 for default value, the s16 is enough for the range
>of the vlan id.
>
>Fixes: d3ab3ffd1d7 (bonding: use rlb_client_info->vlan_id instead of ->tag)
>
>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_alb.c | 8 ++++----
> drivers/net/bonding/bond_alb.h | 2 +-
> 2 files changed, 5 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index aaeeacf..fa95f70 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -539,7 +539,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
>
> 		skb->dev = client_info->slave->dev;
>
>-		if (client_info->vlan_id) {
>+		if (client_info->vlan_id >= 0) {
> 			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), client_info->vlan_id);
> 			if (!skb) {
> 				pr_err("%s: Error: failed to insert VLAN tag\n",
>@@ -722,8 +722,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 			client_info->ntt = 0;
> 		}
>
>-		if (!vlan_get_tag(skb, &client_info->vlan_id))
>-			client_info->vlan_id = 0;
>+		if (vlan_get_tag(skb, &client_info->vlan_id))
>+			client_info->vlan_id = -1;
>
> 		if (!client_info->assigned) {
> 			u32 prev_tbl_head = bond_info->rx_hashtbl_used_head;
>@@ -827,7 +827,7 @@ static void rlb_init_table_entry_dst(struct rlb_client_info *entry)
> 	entry->used_prev = RLB_NULL_INDEX;
> 	entry->assigned = 0;
> 	entry->slave = NULL;
>-	entry->vlan_id = 0;
>+	entry->vlan_id = -1;
> }
> static void rlb_init_table_entry_src(struct rlb_client_info *entry)
> {
>diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>index e09dd4bf..b49af98 100644
>--- a/drivers/net/bonding/bond_alb.h
>+++ b/drivers/net/bonding/bond_alb.h
>@@ -125,7 +125,7 @@ struct rlb_client_info {
> 	u8  assigned;		/* checking whether this entry is assigned */
> 	u8  ntt;		/* flag - need to transmit client info */
> 	struct slave *slave;	/* the slave assigned to this client */
>-	unsigned short vlan_id;	/* VLAN tag associated with IP address */
>+	short vlan_id;		/* VLAN tag associated with IP address */
> };
>
> struct tlb_slave_info {
>-- 
>1.8.0
>
>
