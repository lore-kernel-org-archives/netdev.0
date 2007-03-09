From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.19/2.6.20 BUG in inet_rtm_newaddr()/__inet_insert_ifa()
Date: Fri, 9 Mar 2007 19:22:36 +0100
Message-ID: <20070309182236.GA21587@janus>
References: <20070309103333.GA17232@janus> <20070309123016.GA4736@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:57614 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752710AbXCISWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 13:22:37 -0500
Content-Disposition: inline
In-Reply-To: <20070309123016.GA4736@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2007 at 03:30:17PM +0300, Evgeniy Polyakov wrote:
> On Fri, Mar 09, 2007 at 11:33:33AM +0100, Frank van Maarseveen (frankvm@frankvm.com) wrote:
> > Try this:
> > 
> > ip addr add 172.18.12.99/21 dev dummy0
> > ip addr add broadcast 172.18.15.255 dev dummy0
> 
> Attached patch fixes the problem.
> 
> nlmsg_parse() in rtm_to_ifaddr() sucessfully returns zero, but
> subsequent check for prefix len and LOCAL ifa fails, so NULL is returned
> instead of negative error value embedded in the pointer which is
> expected by error logic in inet_rtm_newaddr().
> 
> ---
> 
> Return negative error value (embedded in the pointer) instead of returning NULL.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index e10794d..98a00d0 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -502,8 +502,10 @@ static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
>  		goto errout;
>  
>  	ifm = nlmsg_data(nlh);
> -	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL)
> +	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL) {
> +		err = -EINVAL;
>  		goto errout;
> +	}
>  
>  	dev = __dev_get_by_index(ifm->ifa_index);
>  	if (dev == NULL) {
> 
> -- 
> 	Evgeniy Polyakov

Ok that worked.. not as I expected. I don't understand the EINVAL and
"ip addr" shows no broadcast address for eth0 when a classless address is
added as the primary (and only) address like in the above example. That's
why I tried to set it manually in the second "ip" command.

-- 
Frank
