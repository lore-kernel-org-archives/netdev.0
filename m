From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 08:26:16 -0500
Message-ID: <1165238776.3664.40.camel@localhost>
References: <1165158707.3517.92.camel@localhost>
	 <45741386.5070002@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:38156 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936829AbWLDN0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:26:23 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1855792nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 05:26:20 -0800 (PST)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45741386.5070002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 13:24 +0100, Patrick McHardy wrote:

> A few cases that will behave incorrectly:
> 
> - two policies in xfrm_policy_inexact with the same direction:
>   after the first iteration we have last_pol = send_pol = first policy
>   and no messages sent, after the second iteration we have
>   send_pol = first policy, last_pol = second policy and still no
>   messages sent. Since send_pol && send_pol != last_pol, the
>   second to last block will send send_pol with last_dir, since
>   count > 0 the last block will send send_pol again. So we get
>   two times the first policy and zero times the second one.
> 
> - same case as above, but policies in opposite directions. The
>   first policy will again be sent twice, but with last_dir, which
>   is the direction of the second policy.
> 
> - three policies in xfrm_policy_inexact, two with similar direction,
>   one with opposite direction. The first two iterations look similar
>   and no policies are dumped, during the third iteration we have
>   count && send_pol && send_pol != last_pol. So send_pol (the
>   first policy) is sent, but with direction dir, which is at that
>   time the opposite direction of the policy.
> 
> 
> I guess its easy to construct more cases. In general I don't see
> how remebering only the last direction can work since two policies
> with potentially different directions are remembered. Within the
> loop you always use dir, which also look wrong.

All very valid points.
Yikes, the directionality is not something i thought clearly about or
tested well. I can fix this but this code will only get fuglier. How
about the following approach:

I add a new callback which is passed in the invocation to walk. 
This callback is invoked at the end to signal the end of the walk, sort
of what done() does in netlink.
netlink doesnt use this call but pfkey does. So the burden is then moved
to pfkey to keep track of the stoopid count.

Thoughts?

cheers,
jamal

