From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding:Fix perfomance drop if one bonding device in configuration is repeatedly restarted
Date: Thu, 14 Jul 2016 01:28:26 -0700
Message-ID: <5759.1468484906@nyx>
References: <1468376491-1453-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47053 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbcGNI23 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 04:28:29 -0400
In-reply-to: <1468376491-1453-1-git-send-email-xerofoify@gmail.com>
Content-ID: <5758.1468484906.1@nyx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicholas Krause <xerofoify@gmail.com> wrote:

>This fixes a issue with the following test caseL
>
>1. Created a alb bonding(bond0) with three of 1Gb interfaces
>(eth0, eth1, eth2) under ipv4, set the bond0 ip address as
>192.168.10.101, run command "iperf -s" as the server(x86_64).
>
>2. Run command "iperf -c 192.168.10.101 -t 10000 -i 1"
>on three linux client with CentOS6.5 x86_64
>
>3. Run the following commands on server repeatly,
>"ifconfig eth1 down; sleep 20; ifconfig eth1 up".
>monitor the bonding performance with program "
>nmon_x86_64_centos6", after some time, the
>performance droped from 3000 to 2000 Mbps,
>and could not go up to 3000Mbps any more,
>it seems that the bonding doesn't rebalance
>again.
>This is due to use incorrectly checking in the function,
>rlb_choose_channel if the ethernet address is not equal
>to 64 bits before updating our mac address from arp.
>However this is incorrect as the ethernet header length
>needs to be 64bits in order to update our mac address
>from arp without the above test case having a perfomance
>regression. Fix it by checking for the ethernet header
>having 64 bits and not.

	NAK.

	I don't understand what this is trying to say, but the change
below does not look valid.

>Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>---
> drivers/net/bonding/bond_alb.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 551f0f8..d5ae8a5 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -593,7 +593,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 		if ((client_info->ip_src == arp->ip_src) &&
> 		    (client_info->ip_dst == arp->ip_dst)) {
> 			/* the entry is already assigned to this client */
>-			if (!ether_addr_equal_64bits(arp->mac_dst, mac_bcast)) {
>+			if (ether_addr_equal_64bits(arp->mac_dst, mac_bcast)) {
> 				/* update mac address from arp */
> 				ether_addr_copy(client_info->mac_dst, arp->mac_dst);

	Regardless of the description above, this test is insuring that
the code doesn't use the broadcast MAC address for the client.  Changing
it seems like a bad thing to do, as it would cause traffic for the
client to be sent to the ethernet broadcast address.

	This might, in fact, make the described test run better, but it
has nothing to do with rebalancing and would negatively impact other
hosts on the network.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
