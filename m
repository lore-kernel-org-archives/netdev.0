From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 14/17] net/bridge/br_multicast.c:677:54: sparse: incorrect type in argument 3 (different address spaces)
Date: Thu, 13 Dec 2012 08:51:55 +0800
Message-ID: <50c926ab.AI4jRk2MW3J/QuQj%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46997 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755231Ab2LMAwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 19:52:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   520dfe3a3645257bf83660f672c47f8558f3d4c4
commit: cfd567543590f71ca0af397437e2554f9756d750 [14/17] bridge: add support of adding and deleting mdb entries


sparse warnings:

net/bridge/br_multicast.c:635:17: sparse: incorrect type in assignment (different address spaces)
net/bridge/br_multicast.c:635:17:    expected struct net_bridge_port_group [noderef] <asn:4>*next
net/bridge/br_multicast.c:635:17:    got struct net_bridge_port_group *next
+ net/bridge/br_multicast.c:677:54: sparse: incorrect type in argument 3 (different address spaces)
net/bridge/br_multicast.c:677:54:    expected struct net_bridge_port_group *next
net/bridge/br_multicast.c:677:54:    got struct net_bridge_port_group [noderef] <asn:4>*<noident>
net/bridge/br_multicast.c:1175:48: sparse: restricted __be16 degrades to integer
net/bridge/br_multicast.c:1175:48: sparse: restricted __be16 degrades to integer
net/bridge/br_multicast.c:1175:48: sparse: restricted __be16 degrades to integer
net/bridge/br_multicast.c:1175:48: sparse: restricted __be16 degrades to integer
net/bridge/br_multicast.c:1175:48: sparse: restricted __be16 degrades to integer
net/bridge/br_multicast.c:1175:48: sparse: restricted __be16 degrades to integer

vim +677 net/bridge/br_multicast.c

cfd56754 Cong Wang         2012-12-11  629  	p = kzalloc(sizeof(*p), GFP_ATOMIC);
cfd56754 Cong Wang         2012-12-11  630  	if (unlikely(!p))
cfd56754 Cong Wang         2012-12-11  631  		return NULL;
cfd56754 Cong Wang         2012-12-11  632  
cfd56754 Cong Wang         2012-12-11  633  	p->addr = *group;
cfd56754 Cong Wang         2012-12-11  634  	p->port = port;
cfd56754 Cong Wang         2012-12-11 @635  	p->next = next;
cfd56754 Cong Wang         2012-12-11  636  	hlist_add_head(&p->mglist, &port->mglist);
cfd56754 Cong Wang         2012-12-11  637  	setup_timer(&p->timer, br_multicast_port_group_expired,
cfd56754 Cong Wang         2012-12-11  638  		    (unsigned long)p);
cfd56754 Cong Wang         2012-12-11  639  	return p;
cfd56754 Cong Wang         2012-12-11  640  }
cfd56754 Cong Wang         2012-12-11  641  
eb1d1641 Herbert Xu        2010-02-27  642  static int br_multicast_add_group(struct net_bridge *br,
8ef2a9a5 YOSHIFUJI Hideaki 2010-04-18  643  				  struct net_bridge_port *port,
8ef2a9a5 YOSHIFUJI Hideaki 2010-04-18  644  				  struct br_ip *group)
eb1d1641 Herbert Xu        2010-02-27  645  {
eb1d1641 Herbert Xu        2010-02-27  646  	struct net_bridge_mdb_entry *mp;
eb1d1641 Herbert Xu        2010-02-27  647  	struct net_bridge_port_group *p;
e8051688 Eric Dumazet      2010-11-15  648  	struct net_bridge_port_group __rcu **pp;
eb1d1641 Herbert Xu        2010-02-27  649  	unsigned long now = jiffies;
eb1d1641 Herbert Xu        2010-02-27  650  	int err;
eb1d1641 Herbert Xu        2010-02-27  651  
eb1d1641 Herbert Xu        2010-02-27  652  	spin_lock(&br->multicast_lock);
eb1d1641 Herbert Xu        2010-02-27  653  	if (!netif_running(br->dev) ||
eb1d1641 Herbert Xu        2010-02-27  654  	    (port && port->state == BR_STATE_DISABLED))
eb1d1641 Herbert Xu        2010-02-27  655  		goto out;
eb1d1641 Herbert Xu        2010-02-27  656  
eb1d1641 Herbert Xu        2010-02-27  657  	mp = br_multicast_new_group(br, port, group);
eb1d1641 Herbert Xu        2010-02-27  658  	err = PTR_ERR(mp);
4c0833bc Tobias Klauser    2010-12-10  659  	if (IS_ERR(mp))
eb1d1641 Herbert Xu        2010-02-27  660  		goto err;
eb1d1641 Herbert Xu        2010-02-27  661  
eb1d1641 Herbert Xu        2010-02-27  662  	if (!port) {
8a870178 Herbert Xu        2011-02-12  663  		mp->mglist = true;
eb1d1641 Herbert Xu        2010-02-27  664  		mod_timer(&mp->timer, now + br->multicast_membership_interval);
eb1d1641 Herbert Xu        2010-02-27  665  		goto out;
eb1d1641 Herbert Xu        2010-02-27  666  	}
eb1d1641 Herbert Xu        2010-02-27  667  
e8051688 Eric Dumazet      2010-11-15  668  	for (pp = &mp->ports;
e8051688 Eric Dumazet      2010-11-15  669  	     (p = mlock_dereference(*pp, br)) != NULL;
e8051688 Eric Dumazet      2010-11-15  670  	     pp = &p->next) {
eb1d1641 Herbert Xu        2010-02-27  671  		if (p->port == port)
eb1d1641 Herbert Xu        2010-02-27  672  			goto found;
eb1d1641 Herbert Xu        2010-02-27  673  		if ((unsigned long)p->port < (unsigned long)port)
eb1d1641 Herbert Xu        2010-02-27  674  			break;
eb1d1641 Herbert Xu        2010-02-27  675  	}
eb1d1641 Herbert Xu        2010-02-27  676  
cfd56754 Cong Wang         2012-12-11 @677  	p = br_multicast_new_port_group(port, group, *pp);
eb1d1641 Herbert Xu        2010-02-27  678  	if (unlikely(!p))
eb1d1641 Herbert Xu        2010-02-27  679  		goto err;
eb1d1641 Herbert Xu        2010-02-27  680  	rcu_assign_pointer(*pp, p);

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
