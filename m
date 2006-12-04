From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC][6/7] inter address family ipsec tunnel
Date: Mon, 04 Dec 2006 11:50:09 +0900
Message-ID: <45738CE1.3070304@miyazawa.org>
References: <20061130.170503.35356518.davem@davemloft.net>	<456FB878.4080109@miyazawa.org>	<20061203.175847.08320724.davem@davemloft.net> <20061203.182814.74748972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:11980 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1759030AbWLDCus
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 21:50:48 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061203.182814.74748972.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

Thank you for your tracing the bug.

I understood the issue.
Mmm, if we can not use ut->family, can we use
ut->id.family instead?

Or is it also uninitialized?

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 03 Dec 2006 17:58:47 -0800 (PST)
> 
>> Kazunori, a bug from the changes I did apply:
>>
>> [  761.318131] kernel BUG at net/key/af_key.c:1925!
> 
> I found the problem, it's because of the xfrm_user.c change where
> we clobber the xp->family value with ut->family.
> 
> But we never ever verified nor cared about the ut->family value
> because previously templates were all of the same family as the
> policy, so there was no reason to check or verify the ut->family
> value.
> 
> So applications left it at zero.
> 
> This means you did no testing of the xfrm_user.c netlink changes.
> 
> We can "fix" this with some patch like the below, changing
> ut->family to xp->family if it is left at zero, but it is clear
> that since we've never checked this value it can be any value.
> What if it is left uninitialized by the application and the
> garbage value just happens to be AF_INET6 or something?
> 
> To me this means that ut->family is %100 unreliable and we cannot
> count on it in any way, and we'll need to specify the family in
> some other way.
> 
> BTW, is it OK to clobber the entire policy's xp->family with the
> top-most ut->family?  Shouldn't the application set the policy's
> family to AF_INET6 if it wants the outer-most template to be
> AF_INET6?
> 
> How can changing the policy family be valid?  Doing this means we'll
> interpret the selectors of the policy differently from what the
> application originally provided.  This setting of xp->family therefore
> cannot make any sense, it must remain at whatever value the
> application gave us.
> 
> I really regret applying these patches, they are in a very bad shape
> and poorly designed.  Now every openswan user will get an OOPS
> when they try to bring up their tunnels with Linus's current tree.
> 
> I think instead of the patch below, I'm going to revert at least
> the xfrm_user part of these changes. :-/
> 
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 6f97665..76c7cdc 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -857,6 +857,11 @@ static void copy_templates(struct xfrm_p
>  {
>  	int i;
>  
> +
> +	/* Backward compat for older applications.  */
> +	if (ut->family == 0)
> +		ut->family = xp->family;
> +
>  	xp->xfrm_nr = nr;
>  	xp->family = ut->family;
>  	for (i = 0; i < nr; i++, ut++) {
> 

--
Kazunori Miyazawa
