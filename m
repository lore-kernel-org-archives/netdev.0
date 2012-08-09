From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Thu, 09 Aug 2012 12:23:31 -0700
Message-ID: <21070.1344540211@death.nxdomain>
References: <1344537049-11473-1-git-send-email-fbl@redhat.com> <1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com>
Cc: Flavio Leitner <fbl@redhat.com>, netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Leonardo Chiquitto <lchiquitto@suse.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:38004 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759194Ab2HITXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 15:23:55 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 9 Aug 2012 13:23:54 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C632B19D8048
	for <netdev@vger.kernel.org>; Thu,  9 Aug 2012 19:23:44 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q79JNmLO142790
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2012 13:23:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q79JNbEs021943
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2012 13:23:38 -0600
In-reply-to: <1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:

>On Thu, 2012-08-09 at 15:30 -0300, Flavio Leitner wrote:
>> It doesn't make any sense to allow the master to become
>> its slave. That creates a loop of events causing a crash.
>
>What if there are other intermediate devices, e.g. the slave is a VLAN
>sub-device of the bond?  And doesn't team also have this problem?
>
>I think a more general check for such loops might be required.

	I thought we had disallowed any nesting of bonds at all, but I
checked the netdev archives, and it appears we discussed it (and agreed
it didn't work), but it kind of petered out.

http://patchwork.ozlabs.org/patch/79705/

	In any event, I think a patch like the following would get all
cases (double enslavement or enslavement of any bonding master) in one
place:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6fae5f3..d14651c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1505,18 +1505,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	int link_reporting;
 	int res = 0;
 
+	if (slave_dev->priv_flags & IFF_BONDING) {
+		pr_debug("Error, Device was already enslaved\n");
+		return -EBUSY;
+	}
+
 	if (!bond->params.use_carrier && slave_dev->ethtool_ops == NULL &&
 		slave_ops->ndo_do_ioctl == NULL) {
 		pr_warning("%s: Warning: no link monitoring support for %s\n",
 			   bond_dev->name, slave_dev->name);
 	}
 
-	/* already enslaved */
-	if (slave_dev->flags & IFF_SLAVE) {
-		pr_debug("Error, Device was already enslaved\n");
-		return -EBUSY;
-	}
-
 	/* vlan challenged mutual exclusion */
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {


	This is basically the same logic that Jiri Bohac originally
proposed in the discussion I mention above, although this patch moves
the test further up and combines the master and slave tests into one.

	Comments?  I haven't tested this at all, but I think the logic
is correct.  I don't think having two separate tests to get special
"master" and "slave" error cases is worthwhile.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
