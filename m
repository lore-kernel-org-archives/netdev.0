From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v1 5/9] bonding: convert bond_has_this_ip() to
 use upper devices
Date: Mon, 26 Aug 2013 22:53:38 +0200
Message-ID: <20130826205338.GA3723@minipsycho.orion>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
 <1377549162-7522-6-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:47669 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab3HZUxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 16:53:42 -0400
Received: by mail-ee0-f44.google.com with SMTP id b47so1864889eek.3
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 13:53:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1377549162-7522-6-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 26, 2013 at 10:32:38PM CEST, vfalico@redhat.com wrote:
>Currently, bond_has_this_ip() is aware only of vlan upper devices, and thus
>will return false if the address is associated with the upper bridge or any
>other device, and thus will break the arp logic.
>
>Fix this by using the upper device list. For every upper device we verify
>if the address associated with it is our address, and if yes - return true.
>
>v1: use netdev_for_each_upper_dev()
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/bonding/bond_main.c |   25 +++++++++++++------------
> 1 files changed, 13 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 40eb250..dbac1ce 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2392,24 +2392,25 @@ re_arm:
> 	}
> }
> 
>-static int bond_has_this_ip(struct bonding *bond, __be32 ip)
>+static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
> {
>-	struct vlan_entry *vlan;
>-	struct net_device *vlan_dev;
>+	struct net_device *upper;
>+	struct list_head *iter;
>+	bool ret = false;
> 
> 	if (ip == bond_confirm_addr(bond->dev, 0, ip))
>-		return 1;
>+		return true;
> 
>-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>-		rcu_read_lock();
>-		vlan_dev = __vlan_find_dev_deep(bond->dev, htons(ETH_P_8021Q),
>-						vlan->vlan_id);
>-		rcu_read_unlock();
>-		if (vlan_dev && ip == bond_confirm_addr(vlan_dev, 0, ip))
>-			return 1;
>+	rcu_read_lock();
>+	netdev_for_each_upper_dev(bond->dev, upper, iter) {
>+		if (ip == bond_confirm_addr(upper, 0, ip)) {
>+			ret = true;
>+			break;
>+		}

You need the same recursion __vlan_find_dev_deep() is doing. If you do
not do that, you will miss anything over the first upper level.


> 	}
>+	rcu_read_unlock();
> 
>-	return 0;
>+	return ret;
> }
> 
> /*
>-- 
>1.7.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
