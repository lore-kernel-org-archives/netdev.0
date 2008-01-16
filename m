From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: memory leakage in bridge(kernel-2.6.23.14)
Date: Wed, 16 Jan 2008 11:04:08 -0800
Message-ID: <20080116110408.21d46e7e@speedy>
References: <S1755641AbYAPH4o/20080116075644Z+1872@vger.kernel.org>
	<200801161006.AZZ53966@topsec.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: <wyb@topsec.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55697 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235AbYAPTEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 14:04:09 -0500
In-Reply-To: <200801161006.AZZ53966@topsec.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jan 2008 18:04:53 +0800
<wyb@topsec.com.cn> wrote:

> 
> In SMP, if a bridge fdb is being created when another CPU at the same time
> delete the bridge, this newly created fdb may incur a leakage:
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

That check is not enough, since the state might change during
fdb_create.


I think fdb_delete_by_port needs to be moved after RCU barrier event.
Something like this (untested) patch.

--- a/net/bridge/br_if.c	2008-01-16 11:00:09.000000000 -0800
+++ b/net/bridge/br_if.c	2008-01-16 11:01:11.000000000 -0800
@@ -116,6 +116,9 @@ static void destroy_nbp_rcu(struct rcu_h
 {
 	struct net_bridge_port *p =
 			container_of(head, struct net_bridge_port, rcu);
+
+	br_fdb_delete_by_port(p->br, p, 1);
+
 	destroy_nbp(p);
 }
 
@@ -143,8 +146,6 @@ static void del_nbp(struct net_bridge_po
 
 	br_ifinfo_notify(RTM_DELLINK, p);
 
-	br_fdb_delete_by_port(br, p, 1);
-
 	list_del_rcu(&p->list);
 
 	rcu_assign_pointer(dev->br_port, NULL);
