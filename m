From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv3 net-next-2.6 3/5] XFRM,IPv6: Add IRO src/dst address remapping XFRM types and i/o handlers
Date: Sat, 02 Oct 2010 12:17:35 +0200
Message-ID: <87iq1k99vk.fsf@small.ssi.corp>
References: <cover.1285749610.git.arno@natisbad.org>
	<fd4eec3c9486c46b535e89ceed479c7536f51fb9.1285749610.git.arno@natisbad.org>
	<20100929.201618.241458205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:34712 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab0JBKR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Oct 2010 06:17:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller <davem@davemloft.net> writes:

>> +static int mip6_iro_src_reject(struct xfrm_state *x, struct sk_buff *skb, struct flowi *fl)
>> +{
>> +	int err = 0;
>> +
>> +	/* XXX We may need some reject handler at some point but it is not
>> +	 * critical yet: see xfrm_secpath_reject() in net/xfrm/xfrm_policy.c
>> +	 * and aslo what mip6_destopt_reject() implements */
>> +
>> +	printk("XXX FIXME: mip6_iro_src_reject() called\n");
>
> pr_debug() or pr_err() or get rid of it altogher and use WARN_ON() or
> similar.

I will take a look at this reject handler tomorrow (implement or remove it).


>> +	spin_lock(&x->lock);
>> +	if (!ipv6_addr_equal(&iph->daddr, (struct in6_addr *)x->coaddr) &&
>> +	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
>> +		err = -ENOENT;
>> +	spin_unlock(&x->lock);
>
> What are you actually protecting with this lock?  The moment you drop
> it the x->coaddr can change which changes the result you should return
> here.
>
> I suspect you either don't need the lock, or you need to lock at a higher
> level.

I basically trusted RH2 input handler code and reused it as a basis:

  static int mip6_rthdr_input(struct xfrm_state *x, struct sk_buff *skb)
  {
  	struct ipv6hdr *iph = ipv6_hdr(skb);
  	struct rt2_hdr *rt2 = (struct rt2_hdr *)skb->data;
  	int err = rt2->rt_hdr.nexthdr;
  
  	spin_lock(&x->lock);
  	if (!ipv6_addr_equal(&iph->daddr, (struct in6_addr *)x->coaddr) &&
  	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
  		err = -ENOENT;
  	spin_unlock(&x->lock);
  
  	return err;
  }

*At that time*, I considered the lock useful to prevent changes on coaddr
during the two checks, i.e. to make it coherent. But I think you are
right and I see no reason for the lock not to be at a higher level:
I may have missed somthing but AFAICT, from a look at the code, there is
nothing preventing x->coaddr to  be updated (via xfrm_sa_update()) just
before or just after the checks.

I took a look at the callers for mip6 handlers and if I am not mistaken
there is *only* xfrm6_input_addr() because xfrm_input() only handles
esp, ah and ipcomp extension headers and not mip6-related ones
(i.e. only IPsec-related ones, those with a SPI). Here is a snippet of
the interesting (lock-wise) part of xfrm6_input_addr():

>	for (i = 0; i < 3; i++) {
>
>               <....snip....>
>
> 		spin_lock(&x->lock);
> 
> 		if ((!i || (x->props.flags & XFRM_STATE_WILDRECV)) &&
> 		    likely(x->km.state == XFRM_STATE_VALID) &&
> 		    !xfrm_state_check_expire(x)) {
> 			spin_unlock(&x->lock);
> 			if (x->type->input(x, skb) > 0) {
> 				/* found a valid state */
> 				break;
> 			}
> 		} else
> 			spin_unlock(&x->lock);
> 
> 		xfrm_state_put(x);
> 		x = NULL;
> 	}
> 
> 	if (!x) {
> 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
> 		xfrm_audit_state_notfound_simple(skb, AF_INET6);
> 		goto drop;
> 	}
> 
> 	skb->sp->xvec[skb->sp->len++] = x;
> 
> 	spin_lock(&x->lock);
> 
> 	x->curlft.bytes += skb->len;
> 	x->curlft.packets++;
> 
> 	spin_unlock(&x->lock);

and I see no reason not to keep the lock we have on the state until the
end of the function when the state is valid (when we break), instead of
releasing it to get it again later. Something like the following would
allow removing the spin_lock()/spin_unlock() calls from all mip6 input
handlers (mip6_{destopt,rthdr,iro_src,iro_dst}_input()):

> 		spin_lock(&x->lock);
>
> 		if ((!i || (x->props.flags & XFRM_STATE_WILDRECV)) &&
> 		    likely(x->km.state == XFRM_STATE_VALID) &&
> 		    !xfrm_state_check_expire(x)) {
> 			if (x->type->input(x, skb) > 0) {
> 				/* found a valid state */
> 				break;
> 			} 
> 		}
>
> 		spin_unlock(&x->lock);
>
> 		xfrm_state_put(x);
> 		x = NULL;
> 	}
> 
> 	if (!x) {
> 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
> 		xfrm_audit_state_notfound_simple(skb, AF_INET6);
> 		goto drop;
> 	}
> 
> 	skb->sp->xvec[skb->sp->len++] = x;
> 
> 	x->curlft.bytes += skb->len;
> 	x->curlft.packets++;
> 
> 	spin_unlock(&x->lock);

If this is ok, I will add a patch to the set to do that and also remove
the locks from the input handlers I introduce.

Cheers,

a+
