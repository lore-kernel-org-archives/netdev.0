From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in  disable_ipv6 support
Date: Thu, 9 Dec 2010 08:27:03 -0800
Message-ID: <20101209082703.6e5519e7@nehalam>
References: <m17hfnlpe1.fsf@fess.ebiederm.org>
	<4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org>
	<4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org>
	<20101208154932.5bc4b254@nehalam>
	<m11v5rekg3.fsf@fess.ebiederm.org>
	<m1ipz3d46m.fsf@fess.ebiederm.org>
	<m1mxofa8dg.fsf_-_@fess.ebiederm.org>
	<4D00F58A.2050307@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, stable@kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46906 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab0LIQ1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 11:27:07 -0500
In-Reply-To: <4D00F58A.2050307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 Dec 2010 10:28:10 -0500
Brian Haley <brian.haley@hp.com> wrote:

> On 12/08/2010 11:16 PM, Eric W. Biederman wrote:
> > Finding the real bug is beyond me right now, but fixing the regression
> > in disable_ipv6 is simple.  We can just delete ::1 when we bring down
> > the loopback interface, and it will be restored automatically when we
> > bring the loopback interface back up.
> 
> Hi Eric,
> 
> This would work as well, same check, different way.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 23cc8e1..5d16a9d 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2728,7 +2728,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  		   and not link-local, then retain it. */
>  		if (!how &&
>  		    (ifa->flags&IFA_F_PERMANENT) &&
> -		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
> +		    !(ipv6_addr_type(&ifa->addr) &
> +		      (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_LOOPBACK))) {
>  			list_move_tail(&ifa->if_list, &keep_list);
>  
>  			/* If not doing DAD on this address, just keep it. */

Checking the address type is incorrect. Any type of address can be applied to
loopback interface. If you look a couple lines there is a special case for
loopback which keeps the address.

> 		/* If just doing link down, and address is permanent
> 		   and not link-local, then retain it. */
> 		if (!how &&
> 		    (ifa->flags&IFA_F_PERMANENT) &&
> 		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
> 			list_move_tail(&ifa->if_list, &keep_list);
> 
> 			/* If not doing DAD on this address, just keep it. */
> 			if ((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
> 			    idev->cnf.accept_dad <= 0 ||
> 			    (ifa->flags & IFA_F_NODAD))

I think the problem is on coming back up, not on the down step.

