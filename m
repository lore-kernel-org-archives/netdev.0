From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/2] bonding: restore NETIF_F_VLAN_CHALLENGED properly in bond_del_vlan()
Date: Fri, 03 Jun 2011 17:26:51 -0700
Message-ID: <28701.1307147211@death>
References: <20110603201424.GB24804@midget.suse.cz>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pedro Garcia <pedro.netdev@dondevamos.com>,
	Patrick McHardy <kaber@trash.net>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:52146 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756660Ab1FDA07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 20:26:59 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p540IiiT008392
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 18:18:44 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p540QuFK166024
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 18:26:56 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p540Qssb007482
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 18:26:55 -0600
In-reply-to: <20110603201424.GB24804@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>Since commit ad1afb00, bond_del_vlan() never restores
>NETIF_F_VLAN_CHALLENGED as intended.  bond->vlan_list is never
>empty once the 8021q module is loaded, because the special VLAN 0
>is always kept registered on the bond interface. Change the
>condition to check if bond->vlan_list contains exactly one item
>instead of checking for an empty list.
>
>Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 17b4dd9..4d317cd 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -329,9 +329,10 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
>
> 			kfree(vlan);
>
>-			if (list_empty(&bond->vlan_list) &&
>+			if (bond->vlan_list.next->next == &bond->vlan_list &&
> 			    (bond->slave_cnt == 0)) {
>-				/* Last VLAN removed and no slaves, so
>+				/* Last VLAN removed (the only member of vlan_list
>+				 * is the special vid == 0 vlan) and no slaves, so
> 				 * restore block on adding VLANs. This will
> 				 * be removed once new slaves that are not
> 				 * VLAN challenged will be added.

	Could we do this instead in bond_release, when the last slave is
removed?  The CHALLENGED flag just prevents adding new VLANs; existing
ones would persist until a new slave was added.

	Since CHALLENGED slaves are in the minority these days (looks
like just IPoIB, one wimax and one obscure ethernet chipset) we could
even invert the logic: only assert CHALLENGED for the master when such a
slave is added.  We'd have to issue a NETDEV_CHANGEADDR when the master
picks up or releases its MAC address so the VLANs would pick it up, but
that's not a really big deal, and we probably ought to do that anyway.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
