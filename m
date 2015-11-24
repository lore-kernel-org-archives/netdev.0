From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 24 Nov 2015 11:18:35 +1100
Message-ID: <20151124111835.0f5f0328@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/ipmr.c

between commit:

  0e615e9601a1 ("net: ipmr: fix static mfc/dev leaks on table destruction")

from the net tree and commit:

  7ef8f65df976 ("net: ipmr: fix code and comment style")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/ipmr.c
index 292123bc30fa,a2d248d9c35c..000000000000
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@@ -1204,30 -1210,24 +1210,25 @@@ static int ipmr_mfc_add(struct net *net
  	return 0;
  }
  
- /*
-  *	Close the multicast socket, and clear the vif tables etc
-  */
- 
+ /* Close the multicast socket, and clear the vif tables etc */
 -static void mroute_clean_tables(struct mr_table *mrt)
 +static void mroute_clean_tables(struct mr_table *mrt, bool all)
  {
  	int i;
  	LIST_HEAD(list);
  	struct mfc_cache *c, *next;
  
  	/* Shut down all active vif entries */
- 
  	for (i = 0; i < mrt->maxvif; i++) {
 -		if (!(mrt->vif_table[i].flags & VIFF_STATIC))
 -			vif_delete(mrt, i, 0, &list);
 +		if (!all && (mrt->vif_table[i].flags & VIFF_STATIC))
 +			continue;
 +		vif_delete(mrt, i, 0, &list);
  	}
  	unregister_netdevice_many(&list);
  
  	/* Wipe the cache */
- 
  	for (i = 0; i < MFC_LINES; i++) {
  		list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list) {
 -			if (c->mfc_flags & MFC_STATIC)
 +			if (!all && (c->mfc_flags & MFC_STATIC))
  				continue;
  			list_del_rcu(&c->list);
  			mroute_netlink_event(mrt, c, RTM_DELROUTE);
