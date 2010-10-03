From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv3 net-next-2.6 3/5] XFRM,IPv6: Add IRO src/dst address remapping XFRM types and i/o handlers
Date: Sun, 03 Oct 2010 15:41:04 +0200
Message-ID: <87iq1j5r7z.fsf@small.ssi.corp>
References: <cover.1285749610.git.arno@natisbad.org>
	<fd4eec3c9486c46b535e89ceed479c7536f51fb9.1285749610.git.arno@natisbad.org>
	<20100929.201618.241458205.davem@davemloft.net>
	<87iq1k99vk.fsf@small.ssi.corp>
	<20101002103205.GA3879@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:44213 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696Ab0JCNlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 09:41:10 -0400
In-Reply-To: <20101002103205.GA3879@gondor.apana.org.au> (Herbert Xu's message
	of "Sat, 2 Oct 2010 18:32:05 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Sat, Oct 02, 2010 at 12:17:35PM +0200, Arnaud Ebalard wrote:
>>
>> and I see no reason not to keep the lock we have on the state until the
>> end of the function when the state is valid (when we break), instead of
>> releasing it to get it again later. Something like the following would
>> allow removing the spin_lock()/spin_unlock() calls from all mip6 input
>> handlers (mip6_{destopt,rthdr,iro_src,iro_dst}_input()):
>
> No I moved the state lock down precisely because it should not
> be taken at a higher level as that breaks asynchronous IPsec
> processing and the fact that it isn't needed in most places.
>
> If your code needs it then you should take it rather than impose
> it on real IPsec users.

Understood. Note that I am on your side with this: my primary concern
while pushing the feature is *to not break or slow down standard IPsec*.
I do not expect my code to be accepted or even read otherwise.

As for the current point raised by David on the position of the locks in
my input handlers, they are based on the position of the locks in the
*existing* RH2 (mip6_rthdr_input()) and HAO (mip6_destopt_input())
handlers. As they serve the same purpose (src/dst address check against
state's address) and the code is basically the same, I have no reason to
do things differently as what is currently upstream.

After your reply, I took a (too long) look at the history of
xfrm6_input_addr() to understand why it is as it is. If it can spare you
some time, here is what I think happened:

 - Initially (commit fbd9a5b4, Aug 23 2006), the checks on the status of
   state, the call to x->type->input() and the changes on state's
   processing stats (x->curlft changes) were *globally* protected by a
   call to spin_lock(). The same day, a related commit (3d126890) added
   support for RH2/HAO input handler. No lock inside the handler. The
   content of xfrm6_input_addr() was:

		spin_lock(&x->lock);

                <...snip...>

		nh = x->type->input(x, skb);
		if (nh <= 0) {
			spin_unlock(&x->lock);
			xfrm_state_put(x);
			x = NULL;
			continue;
		}

		x->curlft.bytes += skb->len;
		x->curlft.packets++;

		spin_unlock(&x->lock);

 - Then, as you wrote, the state lock was moved in all input handlers
   (commit 0ebea8ef, Nov 13 2007), including RH2/HAO ones:

   @@ -128,12 +128,15 @@ static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)
    {
           struct ipv6hdr *iph = ipv6_hdr(skb);
           struct ipv6_destopt_hdr *destopt = (struct ipv6_destopt_hdr *)skb->data;
   +       int err = destopt->nexthdr;
    
   +       spin_lock(&x->lock);
           if (!ipv6_addr_equal(&iph->saddr, (struct in6_addr *)x->coaddr) &&
               !ipv6_addr_any((struct in6_addr *)x->coaddr))
   -               return -ENOENT;
   +               err = -ENOENT;
   +       spin_unlock(&x->lock);
    
   -       return destopt->nexthdr;
   +       return err;
    }

   With that commit, I think a deadlock was introduced in MIPv6 code
   because xfm6_input_addr() was left unchanged, i.e. x->type->input()
   was called with the lock held. Am I correct?

 - The code of xfrm6_input_addr() was then optimized by commit a002c6fd
   in such a way that x->type->input() was then put outside the
   protection of the lock, which (if I am not mistaken) removed the
   deadlock: 

	spin_lock(&x->lock);

	if ((!i || (x->props.flags & XFRM_STATE_WILDRECV)) &&
	    likely(x->km.state == XFRM_STATE_VALID) &&
	    !xfrm_state_check_expire(x)) {
		spin_unlock(&x->lock);
		if (x->type->input(x, skb) > 0) {
			/* found a valid state */
			break;
		}
	} else
		spin_unlock(&x->lock);

   I don't know if this is was intentional.

   But the main question remains on the position of the lock. Here,
   checks are done on the status of the state, lock is released,
   reacquired in the input handler to do additional check and then
   released again, to be reacquired later in the function to act on
   statistics. Is my reading of the code correct?


Herbert, you certainly have a better understanding of XFRM code than I
have and can probably tell if the locking behavior above is valid or
buggy. Yoshifuji-san, David or Eric may also have good ideas on that.


As a side note (I think I was not explicit enough in my previous email),
I think the possible changes to xfrm_input_addr() and MIPv6 handlers we
are discussing are not expected to impact standard IPsec code because
there are 2 different cases in which states input handlers are called 
(i.e. x->type->input()):

 - xfrm_input(): for standard IPsec case (incl. async resumption). This 
   is only for esp, ah, ipcomp and tunneling.
 - xfrm6_input_addr(): for MIPv6 extension header, i.e. RH2 and HAO in
   destopt.

and we are discussing the second.


David, as for my patches, if this is ok for you, I will keep the code of
my input handlers aligned on the code of RH2/HAO handlers and will modify
it later based on the possible corrections made on those upstream.

Don't hesitate to slap me if I made some mistakes in my analysis ;-)

Cheers,

a+
