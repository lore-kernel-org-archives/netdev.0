From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net] bonding: Don't assume 802.1Q when sending alb
 learning packets.
Date: Wed, 21 May 2014 17:48:35 +0200
Message-ID: <20140521154835.GA16470@mikrodark.usersys.redhat.com>
References: <1400685879-21843-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:55398 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaEUPtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 11:49:01 -0400
Received: by mail-we0-f170.google.com with SMTP id u57so2272533wes.29
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 08:49:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1400685879-21843-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 11:24:39AM -0400, Vlad Yasevich wrote:
>TLB/ALB learning packets always assume 802.1Q vlan protocol, but
>that is no longer the case since we now have support for Q-in-Q
>on top of bonding.  Pass the vlan protocol to alb_send_lp_vid()
>so that the packets are properly tagged.
>
>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>CC: Veaceslav Falico <vfalico@gmail.com>

There one more left - the rlb_update_client(), but it'll require a bit more
hacking with rlb_client_info struct to work. Maybe some day in the future
:).

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>---
> drivers/net/bonding/bond_alb.c | 7 ++++---
> 1 file changed, 4 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index e538478..2ec945c 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -995,7 +995,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
> /*********************** tlb/rlb shared functions *********************/
>
> static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
>-			    u16 vid)
>+			    __be16 vlan_proto, u16 vid)
> {
> 	struct learning_pkt pkt;
> 	struct sk_buff *skb;
>@@ -1021,7 +1021,7 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
> 	skb->dev = slave->dev;
>
> 	if (vid) {
>-		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vid);
>+		skb = vlan_put_tag(skb, vlan_proto, vid);
> 		if (!skb) {
> 			pr_err("%s: Error: failed to insert VLAN tag\n",
> 			       slave->bond->dev->name);
>@@ -1040,13 +1040,14 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
> 	struct list_head *iter;
>
> 	/* send untagged */
>-	alb_send_lp_vid(slave, mac_addr, 0);
>+	alb_send_lp_vid(slave, mac_addr, 0, 0);
>
> 	/* loop through vlans and send one packet for each */
> 	rcu_read_lock();
> 	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
> 		if (is_vlan_dev(upper) && vlan_get_encap_level(upper) == 0)
> 			alb_send_lp_vid(slave, mac_addr,
>+					vlan_dev_vlan_proto(upper),
> 					vlan_dev_vlan_id(upper));
> 	}
> 	rcu_read_unlock();
>-- 
>1.9.0
>
