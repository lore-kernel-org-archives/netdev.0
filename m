From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH v2] bonding: extend bond_arp_send_all to bridge devices
Date: Mon, 05 Nov 2012 15:28:15 -0600
Message-ID: <50982F6F.2050600@canonical.com>
References: <1352146448-8921-1-git-send-email-chris.j.arges@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030106090905040109020108"
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352146448-8921-1-git-send-email-chris.j.arges@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030106090905040109020108
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 11/05/2012 02:14 PM, Chris J Arges wrote:
> ARP monitoring does not work when we have a network in the
> following configuration:
> 
> eth0----+ +----bond0.100----br0-100---{+virtual machines
>           | |
>           +----bond0----+----br0---(fixed IP)->--{LAN arp_ip_target}
>           | |
> eth1----+ +----bond0.200----br0-200---{+virtual machines
> 
> This patch extends bond_arp_send_all to also check if a device
> is also in a bridge.
> 
> This is related to the following issues:
> http://launchpad.net/bugs/736226
> http://bugzilla.kernel.org/show_bug.cgi?id=31822
> 
> Thanks to help from Andy Gospodarek.
> 
> Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
> ---
>  drivers/net/bonding/bond_main.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 6c284d1..f11a2e1 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2670,6 +2670,19 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>  			continue;
>  		}
>  
> +		/*
> +		 * Check if the target is part of a bridge.
> +		 */
> +		if (rt->dst.dev->priv_flags & IFF_EBRIDGE) {
> +			printk("bondbridge: %s->priv_flags has IFF_EBRIDGE\n", rt->dst.dev->name);
> +
> +			/* Send ARP request */
> +			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], bond->master_ip, 0);
> +			printk("bondbridge: bond_arp_send %d\n", 0);
> +
> +			continue;
> +		}
> +
>  		if (net_ratelimit()) {
>  			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
>  				   bond->dev->name, &targets[i],
> 



--------------030106090905040109020108
Content-Type: text/x-patch;
 name="0001-bonding-extend-bond_arp_send_all-to-bridge-devices.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-bonding-extend-bond_arp_send_all-to-bridge-devices.patc";
 filename*1="h"

>From 859cbc745670491f716663f6309df7674b38bb33 Mon Sep 17 00:00:00 2001
From: Chris J Arges <chris.j.arges@canonical.com>
Date: Thu, 6 Sep 2012 14:17:40 -0500
Subject: [PATCH v2] bonding: extend bond_arp_send_all to bridge devices

ARP monitoring does not work when we have a network in the
following configuration:

eth0----+ +----bond0.100----br0-100---{+virtual machines
          | |
          +----bond0----+----br0---(fixed IP)->--{LAN arp_ip_target}
          | |
eth1----+ +----bond0.200----br0-200---{+virtual machines

This patch extends bond_arp_send_all to also check if a device
is also in a bridge.

This is related to the following issues:
http://launchpad.net/bugs/736226
http://bugzilla.kernel.org/show_bug.cgi?id=31822

Thanks to help from Andy Gospodarek.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 drivers/net/bonding/bond_main.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b2530b0..cb791f6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2708,6 +2708,18 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			continue;
 		}
 
+		/*
+		 * Check if the target is part of a bridge.
+		 */
+		if (rt->dst.dev->priv_flags & IFF_EBRIDGE) {
+			/* Confirm addr is part of the bridge */
+			addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
+
+			/* Send ARP request */
+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], addr, 0);
+			continue;
+		}
+
 		if (net_ratelimit()) {
 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 				   bond->dev->name, &targets[i],
-- 
1.7.9.5



--------------030106090905040109020108--
