From: Patrick McHardy <kaber@trash.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 15:17:40 +0200
Message-ID: <4BD04C74.9020402@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation> <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hawk@comx.dk, Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33478 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396Ab0DVNRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 09:17:42 -0400
In-Reply-To: <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Thu, Apr 22, 2010 at 8:58 PM, Jesper Dangaard Brouer <hawk@comx.dk> wrote:
>> At an unnamed ISP, we experienced a DDoS attack against one of our
>> customers.  This attack also caused problems for one of our Linux
>> based routers.
>>
>> The attack was "only" generating 300 kpps (packets per sec), which
>> usually isn't a problem for this (fairly old) Linux Router.  But the
>> conntracking system chocked and reduced pps processing power to
>> 40kpps.
>>
>> I do extensive RRD/graph monitoring of the machines.  The IP conntrack
>> searches in the period exploded, to a stunning 700.000 searches per
>> sec.
>>
>> http://people.netfilter.org/hawk/DDoS/2010-04-12__001/conntrack_searches001.png
>>
>> First I though it might be caused by bad hashing, but after reading
>> the kernel code (func: __nf_conntrack_find()), I think its caused by
>> the loop restart (goto begin) of the conntrack search, running under
>> local_bh_disable().  These RCU changes to conntrack were introduced in
>> ea781f19 by Eric Dumazet.
>>
>> Code: net/netfilter/nf_conntrack_core.c
>> Func: __nf_conntrack_find()
>>
>> struct nf_conntrack_tuple_hash *
>> __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
>> {
>>        struct nf_conntrack_tuple_hash *h;
>>        struct hlist_nulls_node *n;
>>        unsigned int hash = hash_conntrack(tuple);
>>
>>        /* Disable BHs the entire time since we normally need to disable them
>>         * at least once for the stats anyway.
>>         */
>>        local_bh_disable();
>> begin:
>>        hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
>>                if (nf_ct_tuple_equal(tuple, &h->tuple)) {
>>                        NF_CT_STAT_INC(net, found);
>>                        local_bh_enable();
>>                        return h;
>>                }
>>                NF_CT_STAT_INC(net, searched);
>>        }
>>        /*
>>         * if the nulls value we got at the end of this lookup is
>>         * not the expected one, we must restart lookup.
>>         * We probably met an item that was moved to another chain.
>>         */
>>        if (get_nulls_value(n) != hash)
>>                goto begin;
>>        local_bh_enable();
>>
> 
> We should add a retry limit there.

We can't do that since that would allow false negatives.
