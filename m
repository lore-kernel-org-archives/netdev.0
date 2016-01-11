From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net v2] bonding: Prevent IPv6 link local address on enslaved devices
Date: Mon, 11 Jan 2016 08:30:22 -0800
Message-ID: <29720.1452529822@famine>
References: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34818 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933843AbcAKQa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 11:30:26 -0500
In-reply-to: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karl Heiss <kheiss@gmail.com> wrote:

>Commit 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
>undoes the fix provided by commit c2edacf80e15 ("bonding / ipv6: no addrconf
>for slaves separately from master") by effectively setting the slave flag
>after the slave has been opened.  If the slave comes up quickly enough, it
>will go through the IPv6 addrconf before the slave flag has been set and
>will get a link local IPv6 address.
>
>In order to ensure that addrconf knows to ignore the slave devices on state
>change, set IFF_SLAVE before dev_open() during bonding enslavement.
>
>Fixes: 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
>
>Signed-off-by: Karl Heiss <kheiss@gmail.com>

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

>---
>- Changes since 'v1':
>  - Revert clearing the IFF_SLAVE flag later during bond release so that
>    RTM_NEWLINK messages will correctly reflect the slave state.
>  - Update commit message for clarity.
>---
> drivers/net/bonding/bond_main.c |    5 ++++-
> 1 files changed, 4 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 9e0f8a7..f1692e4 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1207,7 +1207,6 @@ static int bond_master_upper_dev_link(struct net_device *bond_dev,
> 	err = netdev_master_upper_dev_link_private(slave_dev, bond_dev, slave);
> 	if (err)
> 		return err;
>-	slave_dev->flags |= IFF_SLAVE;
> 	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
> 	return 0;
> }
>@@ -1465,6 +1464,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		}
> 	}
> 
>+	/* set slave flag before open to prevent IPv6 addrconf */
>+	slave_dev->flags |= IFF_SLAVE;
>+
> 	/* open the slave since the application closed it */
> 	res = dev_open(slave_dev);
> 	if (res) {
>@@ -1725,6 +1727,7 @@ err_close:
> 	dev_close(slave_dev);
> 
> err_restore_mac:
>+	slave_dev->flags &= ~IFF_SLAVE;
> 	if (!bond->params.fail_over_mac ||
> 	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
> 		/* XXX TODO - fom follow mode needs to change master's
>-- 
>1.7.1
>
