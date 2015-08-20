From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net af_key: Fix RCU splat
Date: Thu, 20 Aug 2015 16:36:50 -0700
Message-ID: <1440113810.6610.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440085900-8917-1-git-send-email-dsa@cumulusnetworks.com>
	 <1440089462.6610.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55D65B5E.4080407@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35965 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbbHTXgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 19:36:53 -0400
Received: by pdbmi9 with SMTP id mi9so19363614pdb.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 16:36:52 -0700 (PDT)
In-Reply-To: <55D65B5E.4080407@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-20 at 15:57 -0700, David Ahern wrote:
> On 8/20/15 9:51 AM, Eric Dumazet wrote:
> > On Thu, 2015-08-20 at 08:51 -0700, David Ahern wrote:
> >> Hit the following splat testing VRF change for ipsec:

...

> >>
> >> diff --git a/net/key/af_key.c b/net/key/af_key.c
> >> index b397f0aa9005..73527e7dd247 100644
> >> --- a/net/key/af_key.c
> >> +++ b/net/key/af_key.c
> >> @@ -1670,7 +1670,7 @@ static int pfkey_register(struct sock *sk, struct sk_buff *skb, const struct sad
> >>   		return -ENOBUFS;
> >>   	}
> >>
> >> -	pfkey_broadcast(supp_skb, GFP_KERNEL, BROADCAST_REGISTERED, sk, sock_net(sk));
> >> +	pfkey_broadcast(supp_skb, GFP_ATOMIC, BROADCAST_REGISTERED, sk, sock_net(sk));
> >>
> >>   	return 0;
> >>   }
> >
> > I would rather remove the useless rcu locking from pfkey_broadcast() if
> > a mutex properly protects the thing.
> 
> rcu_read_lock was added by Stephen with 7f6b9dbd5afbd. It does not 
> appear the net->xfrm.xfrm_cfg_mutex mutex added by 283bc9f35bbbc 
> properly covers the locking. ie., the rcu_read_lock is needed.

Then please cook a complete patch, and add a 'Fixes: ...' tag


# git grep -n pfkey_broadcast|grep GFP_KERNEL
net/key/af_key.c:336:	pfkey_broadcast(skb, GFP_KERNEL, BROADCAST_ONE, sk, sock_net(sk));
net/key/af_key.c:1368:	pfkey_broadcast(resp_skb, GFP_KERNEL, BROADCAST_ONE, sk, net);
net/key/af_key.c:1673:	pfkey_broadcast(supp_skb, GFP_KERNEL, BROADCAST_REGISTERED, sk, sock_net(sk));
net/key/af_key.c:1850:	pfkey_broadcast(skb, GFP_KERNEL, BROADCAST_ALL, NULL, sock_net(sk));
net/key/af_key.c:2773:	pfkey_broadcast(skb_clone(skb, GFP_KERNEL), GFP_KERNEL,

Presumably we should remove "gfp_t allocation" pfkey_broadcast() argument
if we need to use GFP_ATOMIC in all cases.
