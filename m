From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 14:58:02 +0200
Message-ID: <1271941082.14501.189.camel@jdb-workstation>
Reply-To: hawk@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:43728 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654Ab0DVNDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 09:03:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


At an unnamed ISP, we experienced a DDoS attack against one of our
customers.  This attack also caused problems for one of our Linux
based routers.

The attack was "only" generating 300 kpps (packets per sec), which
usually isn't a problem for this (fairly old) Linux Router.  But the
conntracking system chocked and reduced pps processing power to
40kpps.

I do extensive RRD/graph monitoring of the machines.  The IP conntrack
searches in the period exploded, to a stunning 700.000 searches per
sec.

http://people.netfilter.org/hawk/DDoS/2010-04-12__001/conntrack_searches001.png

First I though it might be caused by bad hashing, but after reading
the kernel code (func: __nf_conntrack_find()), I think its caused by
the loop restart (goto begin) of the conntrack search, running under
local_bh_disable().  These RCU changes to conntrack were introduced in
ea781f19 by Eric Dumazet.

Code: net/netfilter/nf_conntrack_core.c
Func: __nf_conntrack_find()

struct nf_conntrack_tuple_hash *
__nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
{
	struct nf_conntrack_tuple_hash *h;
	struct hlist_nulls_node *n;
	unsigned int hash = hash_conntrack(tuple);

	/* Disable BHs the entire time since we normally need to disable them
	 * at least once for the stats anyway.
	 */
	local_bh_disable();
begin:
	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
		if (nf_ct_tuple_equal(tuple, &h->tuple)) {
			NF_CT_STAT_INC(net, found);
			local_bh_enable();
			return h;
		}
		NF_CT_STAT_INC(net, searched);
	}
	/*
	 * if the nulls value we got at the end of this lookup is
	 * not the expected one, we must restart lookup.
	 * We probably met an item that was moved to another chain.
	 */
	if (get_nulls_value(n) != hash)
		goto begin;
	local_bh_enable();

	return NULL;
}

>From the graphs:
 http://people.netfilter.org/hawk/DDoS/2010-04-12__001/list.html

Its possible to see, that the problems are most likely caused by the
number of conntrack elements being deleted.

http://people.netfilter.org/hawk/DDoS/2010-04-12__001/conntrack_delete001.png

If you look closely at the graphs, you should be able to see, that
CPU1 is doing all the conntrack "searches", and CPU2 is doing most of
the conntrack "deletes" (and CPU1 is creating a lot of new entries).


The question is, how do we avoid this unfortunately behavior of the
delete process disturbing the search process (causing it into
looping)?


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


Extra info: Conntrack tuning
-----------
I have tuned the conntrack system on these hosts.  Firstly I have
increased the number of hash buckets for the conntrack system to
around 300.000.

 cat /sys/module/nf_conntrack/parameters/hashsize
 300032

Next I have increased the max conntracking elements to 900.000.

 cat /proc/sys/net/nf_conntrack_max
 900000



