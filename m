From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/15] mlxsw: Reflect nexthop status changes
Date: Wed, 08 Feb 2017 15:43:45 -0500 (EST)
Message-ID: <20170208.154345.288561019647245358.davem@davemloft.net>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
        <20170208.152848.118275722298964427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58632 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdBHUpQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:45:16 -0500
In-Reply-To: <20170208.152848.118275722298964427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 08 Feb 2017 15:28:48 -0500 (EST)

> Looks really nice, series applied, thanks!

Jiri, just FYI, I bungled up merging this.  And I am trying to fix
that up.

I forgot to include patch #14, but I'll apply that now in the
mainline.

I get a warning, in mlxsw_sp_nexthop_group_create() because the
compiler thinks that 'nh' can be use uninitialized.  And I think
the compiler is pointing out something legitimate.

This cleanup loop in err_nexthop_group_insert and err_nexthop_init
needs to take the 'nh' from &nh_grp->nexthops[i] instead of using
whatever is left in 'nh' for all mlxsw_sp_nexthop_fini() calls.

So I'm going to augment the commit of patch #14 to make it go:

@@ -1667,8 +1667,10 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 
 err_nexthop_group_insert:
 err_nexthop_init:
-	for (i--; i >= 0; i--)
+	for (i--; i >= 0; i--) {
+		nh = &nh_grp->nexthops[i];
 		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
+	}
 	kfree(nh_grp);
 	return ERR_PTR(err);
 }
