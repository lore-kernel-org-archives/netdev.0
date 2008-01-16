From: David Miller <davem@davemloft.net>
Subject: Re: memory leakage in bridge(kernel-2.6.23.14)
Date: Wed, 16 Jan 2008 04:31:06 -0800 (PST)
Message-ID: <20080116.043106.42218321.davem@davemloft.net>
References: <S1755641AbYAPH4o/20080116075644Z+1872@vger.kernel.org>
	<200801161006.AZZ53966@topsec.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: wyb@topsec.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753845AbYAPMbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 07:31:07 -0500
In-Reply-To: <200801161006.AZZ53966@topsec.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <wyb@topsec.com.cn>
Date: Wed, 16 Jan 2008 18:04:53 +0800

> In SMP, if a bridge fdb is being created when another CPU at the same time
> delete the bridge, this newly created fdb may incur a leakage:

netdev@vger.kernel.org (CC:'d) is the proper place to report
things like this.

'linux-net' is only for general user questions about the networking,
not for bug reports, patch postings, or developer discussion.  The
'netdev' list is for that.

Thank you.

> 
> CPU0:
> 
> static void del_nbp(struct net_bridge_port *p)
> {
> 	/*
> 	 * CPU1 enter br_fdb_update(), bridge port is still valid.
> 	 */
> 	......
> 	spin_lock_bh(&br->lock);
> 	br_stp_disable_port(p);
> 	spin_unlock_bh(&br->lock);
> 
> 	br_ifinfo_notify(RTM_DELLINK, p);
> 
> 	br_fdb_delete_by_port(br, p, 1);
> 
> 	/*
> 	 * CPU1 call fdb_create() for the being deleted bridge,
> 	 * a fdb would be add to bridge's fdb hash table, and will never
> 	 * be freed. because when deleting a bridge, linux flush fdb for
> each
> 	 * bridge port, but this newly created fdb belong to no bridge port
> 	 */
> 	......
> }
> 
> To fix this, fdb_create() should be changed to:
> {
> 	struct net_bridge_fdb_entry *fdb;
> 
> 	/*
> 	 * if the bridge port is deleted, then return.
> 	 */
> 	if (!(source->state == BR_STATE_LEARNING ||
> 	      source->state == BR_STATE_FORWARDING))
> 		return;
> 
> 	fdb = kmem_cache_alloc(br_fdb_cache, GFP_ATOMIC);
> 	if (fdb) {
> 		memcpy(fdb->addr.addr, addr, ETH_ALEN);
> 		atomic_set(&fdb->use_count, 1);
> 		hlist_add_head_rcu(&fdb->hlist, head);
> 
> 		fdb->dst = source;
> 		fdb->is_local = is_local;
> 		fdb->is_static = is_local;
> 		fdb->ageing_timer = jiffies;
> 	}
> 	return fdb;
> }
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
