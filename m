From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/2] LSM: Add inet_sys_snd_skb() LSM hook
Date: Fri, 4 Jan 2008 17:37:50 -0500
Message-ID: <200801041737.50883.paul.moore@hp.com>
References: <20080103172539.14445.1668.stgit@flek.americas.hpqcorp.net> <200801040938.27515.paul.moore@hp.com> <20080104.130902.217217806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:21468 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbYADWh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 17:37:56 -0500
In-Reply-To: <20080104.130902.217217806.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 January 2008 4:09:02 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Fri, 4 Jan 2008 09:38:27 -0500
>
> > Unfortunately, it's not quite that easy at present.  The only field
> > we have in the skb where we could possibly set a flag is the
> > secmark field which is already taken.
>
> Herbert Xu added a "peeked" field in net-2.6.25 that is only used on
> input while processing socket receive queues.  You could use it on
> output.

Actually, I went back to the drawing board and I think I found a 
solution that _should_ work using the existing postroute hook.  It 
isn't as general but it is relatively simple.

Historically the problem has been with labeled IPsec and the fact that 
the postroute hook can get hit multiple times when it is in use.  While 
yes, the packet is different each time through the hook but the packet's 
security label never changes (the packet's security label is determined 
by the original sender).  From a security point of view we really only 
want to check the packet once on the way out and we want that check to 
happen at the very end, not while packet transforms are in progress.  
This was the motivation for the new LSM hook.

After the new hook was rejected I took a step back and thought about the 
problem a bit more.  The multi-hit postroute hook problem was really 
only an issue for IPsec; the other labeling protocols don't have this 
problem because they don't do any transformation of the packet.  If we 
could find a quick way to determine when all of the IPsec processing 
was finished would could use the existing postroute hook approach and 
simply fall through if the hook was hit when IPsec processing was still 
needed.

I still need to test this to make sure it does everything we need, but 
I'm pretty certain that using the we can key off the skb->dst->xfrm 
value as a way to determine if a packet is done with it's IPsec 
transformation, if any.  Basically we rewrite our postroute hook to 
look something like this:

 int hook(...)
 {
	/* stuff to do every time */

	if (skb->dst->xfrm != NULL)
		return NF_ACCEPT;

	/* stuff to do only on the last time we are called */

 }

If it doesn't end up meeting our needs I'll look into the 'peeked' 
field, thanks for the suggestion.

-- 
paul moore
linux security @ hp
