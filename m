From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH net-next] Re: rib_trie / Fix inflate_threshold_root. Now=15
	size=11 bits
Date: Wed, 15 Jul 2009 09:43:11 +0200
Message-ID: <19037.34959.327456.662899@robur.slu.se>
References: <4A4FF40B.5090003@itcare.pl>
	<20090705162003.GA19477@ami.dom.local>
	<20090705173208.GB19477@ami.dom.local>
	<20090705213232.GG8943@linux.vnet.ibm.com>
	<20090705222301.GA3203@ami.dom.local>
	<4A513D0D.5070204@itcare.pl>
	<20090706090207.GB3065@ami.dom.local>
	<4A53D28D.8060409@itcare.pl>
	<20090707235029.GA8207@ami.dom.local>
	<4A565449.4050403@itcare.pl>
	<20090714194100.GA7952@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:38063 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325AbZGOHnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2009 03:43:13 -0400
In-Reply-To: <20090714194100.GA7952@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski writes:


Looks good. Maybe we're getting close to some generic solution to take 
a very optimistic approach wrt thresholds for root node and adjust to 
settings without the warning. Or maybe now even remove warning totally
with stata counter?

Can we even consider some other different strategy for bumping up the root 
node. 

We need all lookup performance we can get when we now try to route without 
the route cache. And we probably need to evaluate the cost for the multiple 
lookups again at least for LOCAL and MAIN when we talking routing well at 
least straight-forward simple routing. (Semantic change)

I think I've got ~6.2 Gbit/s for simplex forwarding using traffic patterns 
we see in/close to Internet core. This w/o route cache on our hi-end opterons
with 8 CPU cores using niu and ixgbe. I'll test again and your patches when
I'm back from vacation.

Cheers
					--ro

 > So it looks like the patch tested earlier could be still useful; after
 > changing the inflate_threshold_root it seems these warnings should be
 > very rare but there is no reason to alarm users with something they
 > can't fix optimally, anyway.
 > 
 > Thanks,
 > Jarek P.
 > --------------------->
 > ipv4: Fix inflate_threshold_root automatically
 > 
 > During large updates there could be triggered warnings like: "Fix
 > inflate_threshold_root. Now=25 size=11 bits" if inflate() of the root
 > node isn't finished in 10 loops. It should be much rarer now, after
 > changing the threshold from 15 to 25, and a temporary problem, so
 > this patch tries to handle it automatically using a fix variable to
 > increase by one inflate threshold for next root resizes (up to the 35
 > limit, max fix = 10). The fix variable is decreased when root's
 > inflate() finishes below 7 loops (even if some other, smaller table/
 > trie is updated -- for simplicity the fix variable is global for now).
 > 
 > Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
 > Reported-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
 > Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
 > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
 > ---
 > 
 > diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
 > --- a/net/ipv4/fib_trie.c	2009-07-13 13:32:53.000000000 +0200
 > +++ b/net/ipv4/fib_trie.c	2009-07-13 15:16:18.000000000 +0200
 > @@ -327,6 +327,8 @@ static const int inflate_threshold = 50;
 >  static const int halve_threshold_root = 15;
 >  static const int inflate_threshold_root = 25;
 >  
 > +static int inflate_threshold_root_fix;
 > +#define INFLATE_FIX_MAX 10	/* a comment in resize() */
 >  
 >  static void __alias_free_mem(struct rcu_head *head)
 >  {
 > @@ -617,7 +619,8 @@ static struct node *resize(struct trie *
 >  	/* Keep root node larger  */
 >  
 >  	if (!tn->parent)
 > -		inflate_threshold_use = inflate_threshold_root;
 > +		inflate_threshold_use = inflate_threshold_root +
 > +					inflate_threshold_root_fix;
 >  	else
 >  		inflate_threshold_use = inflate_threshold;
 >  
 > @@ -641,15 +644,27 @@ static struct node *resize(struct trie *
 >  	}
 >  
 >  	if (max_resize < 0) {
 > -		if (!tn->parent)
 > -			pr_warning("Fix inflate_threshold_root."
 > -				   " Now=%d size=%d bits\n",
 > -				   inflate_threshold_root, tn->bits);
 > -		else
 > +		if (!tn->parent) {
 > +			/*
 > +			 * It was observed that during large updates even
 > +			 * inflate_threshold_root = 35 might be needed to avoid
 > +			 * this warning; but it should be temporary, so let's
 > +			 * try to handle this automatically.
 > +			 */
 > +			if (inflate_threshold_root_fix < INFLATE_FIX_MAX)
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
 > +	} else if (max_resize > 3 && !tn->parent && inflate_threshold_root_fix)
 > +		inflate_threshold_root_fix--;
 >  
 >  	check_tnode(tn);
 >  
