From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net] bonding: emit event when bonding changes MAC
Date: Thu, 29 Mar 2012 10:19:44 -0700
Message-ID: <15892.1333041584@death.nxdomain>
References: <5e96194e81e0540ebd35cf0bb1b407aa15a20613.1332910907.git.wpan@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, lwang@redhat.com,
	linux-kernel@vger.kernel.org
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51599 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933597Ab2C2RVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 13:21:06 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 29 Mar 2012 11:20:59 -0600
In-reply-to: <5e96194e81e0540ebd35cf0bb1b407aa15a20613.1332910907.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Weiping Pan <wpan@redhat.com> wrote:

>When a bonding device is configured with fail_over_mac=active,
>we expect to see the MAC address of the new active slave as the source MAC
>address after failover. But we see that the source MAC address is the MAC
>address of previous active slave.
>
>Emit NETDEV_CHANGEADDR event when bonding changes its MAC address, in order
>to let arp_netdev_event flush neighbour cache and route cache.
>
>How to reproduce this bug ?
>
>                       -----------hostB----------------
>hostA ----- switch ---|-- eth0--bond0(192.168.100.2/24)|
>(192.168.100.1/24  \--|-- eth1-/                       |
>                       --------------------------------
>
>1 on hostB,
>modprobe bonding mode=1 miimon=500 fail_over_mac=active downdelay=1000
>num_grat_arp=1
>ifconfig bond0 192.168.100.2/24 up
>ifenslave bond0 eth0
>ifenslave bond0 eth1
>
>then eth0 is the active slave, and MAC of bond0 is MAC of eth0.
>
>2 on hostA, ping 192.168.100.2
>
>3 on hostB,
>tcpdump -i bond0 -p icmp -XXX
>you will see bond0 uses MAC of eth0 as source MAC in icmp reply.
>
>4 on hostB,
>ifconfig eth0 down
>tcpdump -i bond0 -p icmp -XXX (just keep it running in step 3)
>you will see first bond0 uses MAC of eth1 as source MAC in icmp
>reply, then it will use MAC of eth0 as source MAC.
>
>Signed-off-by: Weiping Pan <wpan@redhat.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>---
> drivers/net/bonding/bond_main.c |    8 +++++++-
> 1 files changed, 7 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index b920d82..a20b585 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -892,9 +892,15 @@ static void bond_do_fail_over_mac(struct bonding *bond,
>
> 	switch (bond->params.fail_over_mac) {
> 	case BOND_FOM_ACTIVE:
>-		if (new_active)
>+		if (new_active) {
> 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
> 			       new_active->dev->addr_len);
>+			write_unlock_bh(&bond->curr_slave_lock);
>+			read_unlock(&bond->lock);
>+			call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>+			read_lock(&bond->lock);
>+			write_lock_bh(&bond->curr_slave_lock);
>+		}
> 		break;
> 	case BOND_FOM_FOLLOW:
> 		/*
>-- 
>1.7.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
