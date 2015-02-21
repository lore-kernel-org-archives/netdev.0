From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: ban stacked bonding support
Date: Sat, 21 Feb 2015 17:59:45 +0100
Message-ID: <20150221165945.GF2092@nanopsycho.orion>
References: <20150220222042.GA15595@p183.telecom.by>
 <22754.1424474040@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34471 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbBUQ7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 11:59:50 -0500
Received: by mail-wg0-f49.google.com with SMTP id l18so18399647wgh.8
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 08:59:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <22754.1424474040@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 21, 2015 at 12:14:00AM CET, jay.vosburgh@canonical.com wrote:
>Alexey Dobriyan <adobriyan@gmail.com> wrote:
>
>>Does Linux support it at all?
>>
>>In short: if you add bonding master as a slave, and then release it,
>>it will no longer be a IFF_BONDING creating problems like described at
>>https://bugzilla.kernel.org/show_bug.cgi?id=89541
>>
>>	echo +bond1 >/sys/class/net/bonding_masters
>>	echo 1 >/sys/class/net/bond1/bonding/mode
>>	echo +bond2 >/sys/class/net/bonding_masters
>>	echo +bond2 >/sys/class/net/bond1/bonding/slaves
>>	echo -bond2 >/sys/class/net/bond1/bonding/slaves
>>	echo -bond2 >/sys/class/net/bonding_masters
>>
>>	cat /proc/net/bonding/bond2		# should not exist
>>		[oops]
>>
>>Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>
>	I think it's time to disallow stacking like this; it never
>really worked quite right as far as I can remember, and I thought it was
>disallowed at some point in the past.  I don't believe the stacked bonds
>function correctly for receive in the current kernel, either, although
>I'd have to test it again to confirm that.
>
>	The usual case for desiring to stack bonds is an active-backup
>pair of LACP / 802.3ad bonds (such as the bugzilla referenced above),
>but the 802.3ad mode handles this situation internally, so no stack is
>necessary.

Exactly. There is no real use-case for stacked bonding.

>
>>---
>>
>> drivers/net/bonding/bond_main.c |    5 +++++
>> 1 file changed, 5 insertions(+)
>>
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1248,6 +1248,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>> 			    slave_dev->name);
>> 	}
>> 
>>+	if (slave_dev->flags & IFF_MASTER) {
>>+		netdev_dbg(bond_dev, "stacked bonding not supported\n");
>>+		return -EBUSY;
>>+	}
>>+
>> 	/* already enslaved */
>> 	if (slave_dev->flags & IFF_SLAVE) {
>> 		netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
>
>	Instead of a separate block for IFF_MASTER, the IFF_SLAVE line
>could be replaced with something like:
>
>	if (netif_is_bond_slave(slave_dev) || netif_is_bond_master(slave_dev)) {
>		netdev_dbg(bond_dev, "Error: Device is bond slave or master\n");
>
>	With that caveat:
>
>Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>
>	This is probably a good candidate for -stable as well.
>
>	-J
>
>---
>	-Jay Vosburgh, jay.vosburgh@canonical.com
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
