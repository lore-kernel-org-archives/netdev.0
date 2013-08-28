From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v3 07/13] bonding: make bond_arp_send_all use
 upper device list
Date: Wed, 28 Aug 2013 19:23:35 +0200
Message-ID: <20130828172335.GM1992@redhat.com>
References: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
 <1377705842-8276-8-git-send-email-vfalico@redhat.com>
 <521E2932.6060307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753950Ab3H1RYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 13:24:50 -0400
Content-Disposition: inline
In-Reply-To: <521E2932.6060307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 12:45:38PM -0400, Vlad Yasevich wrote:
>On 08/28/2013 12:03 PM, Veaceslav Falico wrote:
...snip...
>>+		/* search for upper device, like vlan/bridge/team/etc */
>>+		rcu_read_lock();
>>+		netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
>>+			if (upper == rt->dst.dev) {
>>+				/* if it's a vlan - get its VID */
>>+				if (is_vlan_dev(rt->dst.dev))
>>+					vlan_id = vlan_dev_vlan_id(rt->dst.dev);
>>+
>>+				rcu_read_unlock();
>>+				goto found;
>>+			}
>
>How does this work in the following config:
>	eth0,eth1 <--- bond <--- vlans 1,2,3 <---- bridge (ip address)

Great catch, it won't work. I'm not sure if the old code does work (cause
bond->dev already has vlans on top of it, so it has the ->vlan_info, and
thus __vlan_find_dev_deep() won't go recursive, but rather check the
bond->dev for the ip address, though I might be wrong), but I'll try to
take a look at the new code to make it work.

First what comes to mind (untested, not compiled):

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 47e1052..36d6899 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2323,7 +2323,7 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
  
  static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
  {
-	struct net_device *upper;
+	struct net_device *upper, *real_dev;
  	struct list_head *iter;
  	struct rtable *rt;
  	__be32 *targets = bond->params.arp_targets, addr;
@@ -2350,6 +2350,16 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
  		/* search for upper device, like vlan/bridge/team/etc */
  		rcu_read_lock();
  		netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
+			if (is_vlan_dev(upper)) {
+				real_dev = __vlan_find_dev_deep(netdev_master_upper_dev_get_rcu(upper),
+								htons(ETH_P_8021Q),
+								vlan_dev_vlan_id(upper));
+				if (real_dev == rt->dst.dev){
+					vlan_id = vlan_dev_vlan_id(upper);
+					upper = real_dev;
+				}
+			}
+
  			if (upper == rt->dst.dev) {
  				/* if it's a vlan - get its VID */
  				if (is_vlan_dev(rt->dst.dev))

>
>-vlad
