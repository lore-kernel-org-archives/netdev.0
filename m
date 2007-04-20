From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] PPPoE: race between interface going down and
 release()
Date: Fri, 20 Apr 2007 16:27:56 -0700 (PDT)
Message-ID: <20070420.162756.78644819.davem@davemloft.net>
References: <20070311044143.GD17712@florz.florz.dyndns.org>
	<1173667016.24373.36.camel@kdsk1.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florz@florz.de, netdev@vger.kernel.org
To: mostrows@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55250
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751349AbXDTX1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:27:52 -0400
In-Reply-To: <1173667016.24373.36.camel@kdsk1.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Ostrowski <mostrows@earthlink.net>
Date: Sun, 11 Mar 2007 21:36:56 -0500

> Attached below is my take on how to address this problem.  
> This addresses any concerns you may have had about checking po->pppoe_dev==NULL,
> because accesses to this field are now synchronized with pppoe_hash_lock.
> 
> Once we can settle on a fix for this, I'll deal with the SID==0 issue 
> (trying to do that now would just cause patch conflicts).

This patch doesn't apply becuase in the actual pppoe.c code:

> -	read_lock_bh(&pppoe_hash_lock);
> +	write_lock_bh(&pppoe_hash_lock);
>  	for (hash = 0; hash < PPPOE_HASH_SIZE; hash++) {
>  		struct pppox_sock *po = item_hash_table[hash];
>  
>  		while (po != NULL) {
> -			if (po->pppoe_dev == dev) {
> -				struct sock *sk = sk_pppox(po);
> -
> -				sock_hold(sk);
> -
> -				/* We hold a reference to SK, now drop the
> -				 * hash table lock so that we may attempt
> -				 * to lock the socket (which can sleep).
> -				 */

That code doesn't look like that.  At the end, instead there is:

			     sock_hold(sk);
			     po->pppoe_dev = NULL;

and that goes back all the way to 2.6.12 and beyond before
we moved over to GIT.

So I'm having trouble figuring out what tree you generated
that patch against :-)  Perhaps there was an earlier patch
I missed or something.

But I won't second guess and leave it to you to let me know
what I should actually apply.

Thanks.
