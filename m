From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH 2/2] bonding: restore NETIF_F_VLAN_CHALLENGED properly in
 bond_del_vlan()
Date: Fri, 10 Jun 2011 22:27:20 +0200
Message-ID: <20110610202720.GA4256@midget.suse.cz>
References: <20110603201424.GB24804@midget.suse.cz>
 <28701.1307147211@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pedro Garcia <pedro.netdev@dondevamos.com>,
	Patrick McHardy <kaber@trash.net>, mirq-linux@rere.qmqm.pl
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60249 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758004Ab1FJU10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 16:27:26 -0400
Content-Disposition: inline
In-Reply-To: <28701.1307147211@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jun 03, 2011 at 05:26:51PM -0700, Jay Vosburgh wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> 
> >Since commit ad1afb00, bond_del_vlan() never restores
> >NETIF_F_VLAN_CHALLENGED as intended.  bond->vlan_list is never
> >empty once the 8021q module is loaded, because the special VLAN 0
> >is always kept registered on the bond interface. Change the
> >condition to check if bond->vlan_list contains exactly one item
> >instead of checking for an empty list.
> >
> >Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> >
> >diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >index 17b4dd9..4d317cd 100644
> >--- a/drivers/net/bonding/bond_main.c
> >+++ b/drivers/net/bonding/bond_main.c
> >@@ -329,9 +329,10 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
> >
> > 			kfree(vlan);
> >
> >-			if (list_empty(&bond->vlan_list) &&
> >+			if (bond->vlan_list.next->next == &bond->vlan_list &&
> > 			    (bond->slave_cnt == 0)) {
> >-				/* Last VLAN removed and no slaves, so
> >+				/* Last VLAN removed (the only member of vlan_list
> >+				 * is the special vid == 0 vlan) and no slaves, so
> > 				 * restore block on adding VLANs. This will
> > 				 * be removed once new slaves that are not
> > 				 * VLAN challenged will be added.
> 
> 	Could we do this instead in bond_release, when the last slave is
> removed?  The CHALLENGED flag just prevents adding new VLANs; existing
> ones would persist until a new slave was added.

Actually, this has already happenned with commit b2a103e6. Sorry
I originally checked with an older kernel. This makes the above
patch obsolete and calls for a little cleanup (below).

b2a103e6 has changed the behaviour a little. Before, if you had a
vlan configured on a bond and removed the last slave, the
CHALLENGED flag would stay off, until you deleted the vlan.  Now,
CHALLENGED is turned on as soon as the last slave is deleted.

BTW, this can lead to a sort of inconsistent state, where CHALLENGED
is on and the bond has vlans.

> Since CHALLENGED slaves are in the minority these days (looks
> like just IPoIB, one wimax and one obscure ethernet chipset) we
> could even invert the logic: only assert CHALLENGED for the
> master when such a slave is added.

This sounds good. I don't understand why bonding currently tries
to prevent VLANs on an slave-less bond, and I might not be the
only one. Citing a comment in bond_fix_features():

	/* Disable adding VLANs to empty bond. But why? --mq */

Another comment, in bond_setup():

        /* At first, we block adding VLANs. That's the only way to
         * prevent problems that occur when adding VLANs over an
         * empty bond. The block will be removed once non-challenged
         * slaves are enslaved.
         */

Do we need to prevent this at all? What are the potential
problems?

Anyway a little cleanup:


bonding: clean up bond_del_vlan()

1) the setting of NETIF_F_VLAN_CHALLENGED in bond_del_vlan() is
useless since commit b2a103e6 because bond_fix_features() now
sets NETIF_F_VLAN_CHALLENGED whenever the last slave is being
removed.

2) the code never triggers anyway as vlan_list is never empty
since ad1afb00.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -329,16 +329,6 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 
 			kfree(vlan);
 
-			if (list_empty(&bond->vlan_list) &&
-			    (bond->slave_cnt == 0)) {
-				/* Last VLAN removed and no slaves, so
-				 * restore block on adding VLANs. This will
-				 * be removed once new slaves that are not
-				 * VLAN challenged will be added.
-				 */
-				bond->dev->features |= NETIF_F_VLAN_CHALLENGED;
-			}
-
 			res = 0;
 			goto out;
 		}

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

