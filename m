From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: Prevent IPv6 link local address on enslaved devices
Date: Fri, 08 Jan 2016 11:56:01 -0800
Message-ID: <4679.1452282961@famine>
References: <1452281616-14447-1-git-send-email-kheiss@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56638 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbcAHT4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 14:56:06 -0500
In-reply-to: <1452281616-14447-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karl Heiss <kheiss@gmail.com> wrote:

>Upstream commit 1f718f0f4f97 ("bonding: populate neighbour's private on
>enslave") undoes the fix provided by commit c2edacf80e15 ("bonding / ipv6: no
>addrconf for slaves separately from master") by effectively setting
>the slave flag after the slave has been opened.  If the slave comes up quickly
>enough, it will go through the IPv6 addrconf before the slave flag has been
>set and will get a link local IPv6 address.
>
>Set IFF_SLAVE before dev_open() and clear it after dev_close() to ensure that
>addrconf knows to ignore on state change.

	I think prepending "During bonding enslavement and removal
processing," (or the equivalent) makes the above sentence a bit clearer
as to what's going on.

>Fixes: 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
>
>Signed-off-by: Karl Heiss <kheiss@gmail.com>
>---
> drivers/net/bonding/bond_main.c |    8 ++++++--
> 1 files changed, 6 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 9e0f8a7..200358e 100644
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
>@@ -1216,7 +1215,6 @@ static void bond_upper_dev_unlink(struct net_device *bond_dev,
> 				  struct net_device *slave_dev)
> {
> 	netdev_upper_dev_unlink(slave_dev, bond_dev);
>-	slave_dev->flags &= ~IFF_SLAVE;
> 	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
> }

	Will this change cause issues for user space monitoring of the
RTM_NEWLINKs, as now the message will have IFF_SLAVE in the flags for
both the "link" and "unlink" cases?  How would link be distinguished
from unlink?

	Since the unlink happens only in __bond_release_one or in the
case of a failure within bond_enslave, does clearing the flag in
bond_upper_dev_unlink cause any actual issues?

	-J

>@@ -1465,6 +1463,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		}
> 	}
> 
>+	/* set slave flag before open to prevent IPv6 addrconf */
>+	slave_dev->flags |= IFF_SLAVE;
>+
> 	/* open the slave since the application closed it */
> 	res = dev_open(slave_dev);
> 	if (res) {
>@@ -1725,6 +1726,7 @@ err_close:
> 	dev_close(slave_dev);
> 
> err_restore_mac:
>+	slave_dev->flags &= ~IFF_SLAVE;
> 	if (!bond->params.fail_over_mac ||
> 	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
> 		/* XXX TODO - fom follow mode needs to change master's
>@@ -1906,6 +1908,8 @@ static int __bond_release_one(struct net_device *bond_dev,
> 	/* close slave before restoring its mac address */
> 	dev_close(slave_dev);
> 
>+	slave_dev->flags &= ~IFF_SLAVE;
>+
> 	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE ||
> 	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
> 		/* restore original ("permanent") mac address */
>-- 
>1.7.1
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
