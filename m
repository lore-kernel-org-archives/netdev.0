From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 8 Nov 2016 12:25:37 +1100
Message-ID: <20161108122537.40fa6e58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/netlink/genetlink.c

between commit:

  00ffc1ba02d8 ("genetlink: fix a memory leak on error path")

from the net tree and commit:

  2ae0f17df1cd ("genetlink: use idr to track families")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/netlink/genetlink.c
index 49c28e8ef01b,bbd3bff885a1..000000000000
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@@ -402,11 -360,17 +360,17 @@@ int genl_register_family(struct genl_fa
  	} else
  		family->attrbuf = NULL;
  
+ 	family->id = idr_alloc(&genl_fam_idr, family,
+ 			       start, end + 1, GFP_KERNEL);
+ 	if (family->id < 0) {
+ 		err = family->id;
 -		goto errout_locked;
++		goto errout_free;
+ 	}
+ 
  	err = genl_validate_assign_mc_groups(family);
  	if (err)
- 		goto errout_free;
+ 		goto errout_remove;
  
- 	list_add_tail(&family->family_list, genl_family_chain(family->id));
  	genl_unlock_all();
  
  	/* send all events */
@@@ -417,14 -381,13 +381,15 @@@
  
  	return 0;
  
+ errout_remove:
+ 	idr_remove(&genl_fam_idr, family->id);
 +errout_free:
 +	kfree(family->attrbuf);
  errout_locked:
  	genl_unlock_all();
- errout:
  	return err;
  }
- EXPORT_SYMBOL(__genl_register_family);
+ EXPORT_SYMBOL(genl_register_family);
  
  /**
   * genl_unregister_family - unregister generic netlink family
