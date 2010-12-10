From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in  disable_ipv6 support
Date: Thu, 9 Dec 2010 20:02:45 -0800
Message-ID: <20101209200245.542caba9@nehalam>
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
Received: from mail.vyatta.com ([76.74.103.46]:41891 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903Ab0LJECs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 23:02:48 -0500
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

This patch is cleaner but still fails for the non ::1 address case.

 # ip addr add 2000:db8::1/64 dev lo
 # ping6 ::1                                 -- works
 # ping6 2000:db8::1                         --works
 # ip li set dev lo down
 # ping6 ::1                                 -- does not work (expected)
 # ping6 2000:db8::1                         -- ditto
 # ip il set dev lo up
 # ping6 ::1                                 -- works (good)
 # ping6 2000:db8::1                         -- fails (network unreachable)


Looks like connected route is not getting restored correctly, probably
because loopback has NOARP flag set. 

The problem may not be true for just loopback, it may also apply to
tunnels.
