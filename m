From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Thu, 13 Nov 2008 14:29:57 +0100
Message-ID: <1226582997.7685.4786.camel@twins>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
	 <4909D551.9080309@cosmosbay.com>  <491C282A.5050802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Corey Minyard <minyard@acm.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:28556 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbYKMNaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:30:08 -0500
In-Reply-To: <491C282A.5050802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-13 at 14:14 +0100, Eric Dumazet wrote:
> hlist uses NULL value to finish a chain.
> 
> hlist_nulls variant use the low order bit set to 1 to signal an end-of-list marker.
> 
> This allows to store many different end markers, so that some RCU lockless
> algos (used in TCP/UDP stack for example) can save some memory barriers in
> fast paths.
> 
> Two new files are added :
> 
> include/linux/list_nulls.h
>   - mimics hlist part of include/linux/list.h, derived to hlist_nulls variant

How is the !rcu variant useful?

> include/linux/rculist_nulls.h
>   - mimics hlist part of include/linux/rculist.h, derived to hlist_nulls variant
> 
>    Only four helpers are declared for the moment :
> 
>      hlist_nulls_del_init_rcu(), hlist_nulls_del_rcu(),
>      hlist_nulls_add_head_rcu() and hlist_nulls_for_each_entry_rcu()
> 
> prefetches() were removed, since an end of list is not anymore NULL value.
> prefetches() could trigger useless (and possibly dangerous) memory transactions.
> 
> Example of use (extracted from __udp4_lib_lookup())
> 
> 	struct sock *sk, *result;
>         struct hlist_nulls_node *node;
>         unsigned short hnum = ntohs(dport);
>         unsigned int hash = udp_hashfn(net, hnum);
>         struct udp_hslot *hslot = &udptable->hash[hash];
>         int score, badness;
> 
>         rcu_read_lock();
> begin:
>         result = NULL;
>         badness = -1;
>         sk_nulls_for_each_rcu(sk, node, &hslot->head) {
>                 score = compute_score(sk, net, saddr, hnum, sport,
>                                       daddr, dport, dif);
>                 if (score > badness) {
>                         result = sk;
>                         badness = score;
>                 }
>         }
>         /*
>          * if the nulls value we got at the end of this lookup is
>          * not the expected one, we must restart lookup.
>          * We probably met an item that was moved to another chain.
>          */
>         if (get_nulls_value(node) != hash)
>                 goto begin;

So by not using some memory barriers (would be nice to have it
illustrated which ones), we can race and end up on the wrong chain, in
case that happens we detect this by using this per-chain terminator and
try again.

It would be really good to have it explained in the rculist_nulls.h
comments what memory barriers are missing, what races they open, and how
the this special terminator trick closes that race.

I'm sure most of us understand it now, but will we still in a few
months? - how about new people?

Other than that, very cool stuff! :-)

