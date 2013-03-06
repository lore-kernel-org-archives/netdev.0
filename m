From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bond: add support to read speed and duplex via ethtool
Date: Wed, 06 Mar 2013 11:25:12 -0800
Message-ID: <22416.1362597912@death.nxdomain>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:44846 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532Ab3CFTZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:25:25 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 6 Mar 2013 12:25:25 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0969C38C805C
	for <netdev@vger.kernel.org>; Wed,  6 Mar 2013 14:25:21 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r26JPJA4257046
	for <netdev@vger.kernel.org>; Wed, 6 Mar 2013 14:25:20 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r26JPH5s004137
	for <netdev@vger.kernel.org>; Wed, 6 Mar 2013 12:25:18 -0700
In-reply-to: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>This patch adds support for the get_settings ethtool op to the bonding
>driver.  This was motivated by users who wanted to get the speed of the
>bond and compare that against throughput to understand utilization.
>The behavior before this patch was added was problematic when computing
>line utilization after trying to get link-speed and throughput via SNMP.
>
>The general plan for computing link-speed was as follows:
>
>Mode                 Formula
>----                 -------
>active-backup        speed of current active slave
>broadcast            speed of first slave with known speed
>all other modes      aggregate speed of all slaves with known speed

	I'll just point out that the balance-tlb mode is asymmetric; it
uses all slaves for transmission, but only one slave for reception.
Ethtool only has a single speed for both directions, so this is probably
the best choice, but it should still be noted.

>Output from ethtool looks like this for a round-robin bond:
>
>Settings for bond0:
>	Supported ports: [ ]
>	Supported link modes:   Not reported
>	Supported pause frame use: No
>	Supports auto-negotiation: No
>	Advertised link modes:  Not reported
>	Advertised pause frame use: No
>	Advertised auto-negotiation: No
>	Speed: 11000Mb/s
>	Duplex: Full
>	Port: Twisted Pair
>	PHYAD: 0
>	Transceiver: internal
>	Auto-negotiation: off
>	MDI-X: Unknown
>	Link detected: yes
>
>I tested this and verified it works as expected.  A test was also done
>on a version backported to an older kernel and it worked well there.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>---
> drivers/net/bonding/bond_main.c | 47 +++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 47 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 7bd068a..6e70ff0 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4224,6 +4224,52 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
> 	}
> }
>
>+static int bond_ethtool_get_settings(struct net_device *bond_dev,
>+				     struct ethtool_cmd *ecmd)
>+{
>+	struct bonding *bond = netdev_priv(bond_dev);
>+	struct slave *slave;
>+	int i;
>+	unsigned long speed = 0;
>+
>+	ecmd->speed = SPEED_UNKNOWN;
>+	ecmd->duplex = DUPLEX_UNKNOWN;
>+
>+	read_lock(&bond->lock);
>+	switch (bond->params.mode) {
>+	case BOND_MODE_ACTIVEBACKUP:
>+		read_lock(&bond->curr_slave_lock);
>+		if (bond->curr_active_slave &&
>+		    bond->curr_active_slave->speed != SPEED_UNKNOWN) {
>+			ecmd->speed = bond->curr_active_slave->speed;
>+			ecmd->duplex = bond->curr_active_slave->duplex;
>+		}
>+		read_unlock(&bond->curr_slave_lock);
>+		break;
>+	case BOND_MODE_BROADCAST:
>+		bond_for_each_slave(bond, slave, i) {
>+			if (slave->speed != SPEED_UNKNOWN) {
>+				ecmd->speed = slave->speed;
>+				ecmd->duplex = slave->duplex;
>+				break;
>+			}
>+		}
>+		break;

	Does anybody really use broadcast mode?  Not that I'm saying
this is incorrect, I'm just wondering in general.

>+	default:
>+		bond_for_each_slave(bond, slave, i) {
>+			if (slave->speed != SPEED_UNKNOWN) {
>+				speed += slave->speed;
>+			}
>+			if (ecmd->duplex == DUPLEX_UNKNOWN &&
>+			    slave->duplex != DUPLEX_UNKNOWN)
>+				ecmd->duplex = slave->duplex;

	Should the calculations skip slaves that are not BOND_LINK_UP?
If the ARP monitor is running, some slaves may be carrier up (and have
slave->speed set), but are not actually in use by the bond, at least for
transmission.

	-J

>+		}
>+		ecmd->speed = speed;
>+	}
>+	read_unlock(&bond->lock);
>+	return 0;
>+}
>+
> static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
> 				     struct ethtool_drvinfo *drvinfo)
> {
>@@ -4235,6 +4281,7 @@ static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
>
> static const struct ethtool_ops bond_ethtool_ops = {
> 	.get_drvinfo		= bond_ethtool_get_drvinfo,
>+	.get_settings		= bond_ethtool_get_settings,
> 	.get_link		= ethtool_op_get_link,
> };
>
>-- 
>1.7.11.7

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
