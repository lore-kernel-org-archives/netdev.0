From: Robert Olsson <robert@robur.slu.se>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Sun, 28 Jun 2009 13:04:51 +0200
Message-ID: <19015.20051.432572.460207@robur.slu.se>
References: <19012.37515.146191.198843@robur.slu.se>
	<20090627192057.GA5041@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, "Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:57084 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbZF1LEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2009 07:04:49 -0400
In-Reply-To: <20090627192057.GA5041@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski writes:

 > Robert, you and Eric pointed at memory problems, so I thought I missed
 > something. But after the second look I see "skipped node resize" should
 > show this, but it's always zero on these reports. So, isn't it possible
 > the current inflate_threshold_root is simply unreachable with some
 > conditions, at least within 10 loops?
 > 
 > Then these settable thresholds might be more useful here than memory
 > fixes, but here is some idea to try handle this automatically within
 > some limits. The patch below increases inflate_threshold_root (only)
 > up to ~50% of its initial value if needed, and should be able to go
 > back sometimes.

 Yes we keep the old tnode size and the convergence interval was some
 of the concerns. That why this checks was added. Still we want to
 inflate the root node to a very max. 

 So this approach with halving or doubling tnodes towards the root
 node was the suggest by Dyntree paper. I asked Stefan (one of the
 authors) if we could get safe and very offensive settings. But 
 from what I understood there was no easy way to calculate this. 
 So any bright ideas in this area are very welcome. But we should
 also monitor size of root and average tree depth so we don't
 take an to defensive approach just to solve this case.

 The memory patches and "manual RCU" are also interesting to address
 the case with PREEMTP's.

 Inserts and deletes are also very fast due to the flat tree so I think
 we can "slow down" this a bit if need to be safe with all PREEMPT's.

 Thanks for giving this area energy.

 Cheers
					--ro


 > Pawel and Jorge, could you try this? (It applies to 2.6.29 too, with
 > some offsets.)
 > 
 > Thanks,
 > Jarek P.
 > ---
 > 
 >  net/ipv4/fib_trie.c |   23 ++++++++++++++++-------
 >  1 files changed, 16 insertions(+), 7 deletions(-)
 > 
 > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
 > index 012cf5a..1dc1bb4 100644
 > --- a/net/ipv4/fib_trie.c
 > +++ b/net/ipv4/fib_trie.c
 > @@ -318,6 +318,7 @@ static const int halve_threshold = 25;
 >  static const int inflate_threshold = 50;
 >  static const int halve_threshold_root = 8;
 >  static const int inflate_threshold_root = 15;
 > +static int inflate_threshold_root_fix;
 >  
 >  
 >  static void __alias_free_mem(struct rcu_head *head)
 > @@ -602,7 +603,8 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 >  	/* Keep root node larger  */
 >  
 >  	if (!tn->parent)
 > -		inflate_threshold_use = inflate_threshold_root;
 > +		inflate_threshold_use = inflate_threshold_root +
 > +					inflate_threshold_root_fix;
 >  	else
 >  		inflate_threshold_use = inflate_threshold;
 >  
 > @@ -626,15 +628,22 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 >  	}
 >  
 >  	if (max_resize < 0) {
 > -		if (!tn->parent)
 > -			pr_warning("Fix inflate_threshold_root."
 > -				   " Now=%d size=%d bits\n",
 > -				   inflate_threshold_root, tn->bits);
 > -		else
 > +		if (!tn->parent) {
 > +			if (inflate_threshold_root_fix * 2 <
 > +			    inflate_threshold_root)
 > +				inflate_threshold_root_fix++;
 > +			else
 > +				pr_warning("Fix inflate_threshold_root."
 > +					   " Now=%d size=%d bits fix=%d\n",
 > +					   inflate_threshold_root, tn->bits,
 > +					   inflate_threshold_root_fix);
 > +		} else {
 >  			pr_warning("Fix inflate_threshold."
 >  				   " Now=%d size=%d bits\n",
 >  				   inflate_threshold, tn->bits);
 > -	}
 > +		}
 > +	} else if (max_resize < 5 && !tn->parent && inflate_threshold_root_fix)
 > +		inflate_threshold_root_fix--;
 >  
 >  	check_tnode(tn);
 >  
