From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Thu, 07 Dec 2006 20:23:48 +0900
Message-ID: <4577F9C4.2020301@miyazawa.org>
References: <456FB283.9090904@miyazawa.org>	<20061206203537.2e5ba9ec.kazunori@miyazawa.org>	<20061206.233749.122048397.davem@davemloft.net> <20061206.234857.70203259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:48360 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1032051AbWLGLYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 06:24:45 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061206.234857.70203259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 06 Dec 2006 23:37:49 -0800 (PST)
> 
>> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
>> Date: Wed, 6 Dec 2006 20:35:37 +0900
>>
>>> BTW, I have a question about descrementing the reference count of
>>> rt->peer.  The reference cound in normal "dst" structure is
>>> decremented by calling inet_putpeer from ipv4_dst_destroy. But
>>> xfrm4_dst_destroy does not call inet_putpeer.  Where do we decrement
>>> the count? Should xfrm4_dst_destroy do that?
>> Indeed, it is a real leak.  And yes, I believe that xfrm4_dst_destroy()
>> should release it.  I will make this fix, thank you.
> 
> For reference, this is the fix I checked in.
> 
> Thanks again for spotting this problem.
> 

Thank you for making the patch.
Will it be merged to 2.6.19.x?

> I suppose your patch will need to add an address family check for this
> too.  Actually... I think address family check is needed for 'idev'
> release in xfrm4_dst_destroy() too, if you agree please also add that
> fix to your patch.
> 

Yes, I will add address family check for your patch.

Umm, I guess we don't need address family check because xdst
is allocated with xfrm4_dst_ops and the family of rt0 is
always equal to the original address family.
They are always AF_INET in this case.

I will try to fix the unresolved symbol issue.

> It is very complicated, using IPV6 route in xfrm4 code, because now
> all "X->u.rt" references need to be audited.
> 
> commit 26db167702756d0022f8ea5f1f30cad3018cfe31
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Wed Dec 6 23:45:15 2006 -0800
> 
>     [IPSEC]: Fix inetpeer leak in ipv4 xfrm dst entries.
>     
>     We grab a reference to the route's inetpeer entry but
>     forget to release it in xfrm4_dst_destroy().
>     
>     Bug discovered by Kazunori MIYAZAWA <kazunori@miyazawa.org>
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index d4107bb..fb9f69c 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -274,6 +274,8 @@ static void xfrm4_dst_destroy(struct dst
>  
>  	if (likely(xdst->u.rt.idev))
>  		in_dev_put(xdst->u.rt.idev);
> +	if (likely(xdst->u.rt.peer))
> +		inet_putpeer(xdst->u.rt.peer);
>  	xfrm_dst_destroy(xdst);
>  }
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Kazunori Miyazawa
