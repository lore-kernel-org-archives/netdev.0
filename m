From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 23 Mar 2011 08:24:23 -0700
Message-ID: <20110323082423.321bf8ce@nehalam>
References: <alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
	<20110303.112328.59677094.davem@davemloft.net>
	<alpine.LFD.2.00.1103041013360.1452@ja.ssi.bg>
	<20110322.215655.245381151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54928 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932773Ab1CWPY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 11:24:26 -0400
In-Reply-To: <20110322.215655.245381151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Mar 2011 21:56:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Fri, 4 Mar 2011 10:39:55 +0200 (EET)
> 
> > On Thu, 3 Mar 2011, David Miller wrote:
> > 
> >> I suspect that even if we need to handle prefixes, we can still use
> >> the hash for optimistic lookup, and fallback to a local table FIB
> >> inspection if that fails.
> > 
> > 	Yes, as ip_route_output_slow uses __ip_dev_find for
> > fl4_src there should be some kind of fallback to local table,
> > so that traffic from 127.0.0.2 to 127.0.0.3 or other local
> > subnets on loopback can work. Another option is to use
> > inet_addr_onlink but I suspect people can add many addresses
> > on loopback: inet_addr_onlink(loopback_indev, addr, 0)
> 
> I just got back to this, sorry for taking so long :-)
> 
> Here is the patch I've come up with and will commit to
> net-2.6, thanks!
> 
> --------------------
> ipv4: Fallback to FIB local table in __ip_dev_find().
> 
> In commit 9435eb1cf0b76b323019cebf8d16762a50a12a19
> ("ipv4: Implement __ip_dev_find using new interface address hash.")
> we reimplemented __ip_dev_find() so that it doesn't have to
> do a full FIB table lookup.
> 
> Instead, it consults a hash table of addresses configured to
> interfaces.
> 
> This works identically to the old code in all except one case,
> and that is for loopback subnets.
> 
> The old code would match the loopback device for any IP address
> that falls within a subnet configured to the loopback device.
> 
> Handle this corner case by doing the FIB lookup.
> 
> We could implement this via inet_addr_onlink() but:
> 
> 1) Someone could configure many addresses to loopback and
>    inet_addr_onlink() is a simple list traversal.
> 
> 2) We know the old code works.
> 
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/devinet.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index d5a4553..5345b0b 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -64,6 +64,8 @@
>  #include <net/rtnetlink.h>
>  #include <net/net_namespace.h>
>  
> +#include "fib_lookup.h"
> +
>  static struct ipv4_devconf ipv4_devconf = {
>  	.data = {
>  		[IPV4_DEVCONF_ACCEPT_REDIRECTS - 1] = 1,
> @@ -151,6 +153,20 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
>  			break;
>  		}
>  	}
> +	if (!result) {
> +		struct flowi4 fl4 = { .daddr = addr };
> +		struct fib_result res = { 0 };
> +		struct fib_table *local;
> +
> +		/* Fallback to FIB local table so that communication
> +		 * over loopback subnets work.
> +		 */
> +		local = fib_get_table(net, RT_TABLE_LOCAL);
> +		if (local &&
> +		    !fib_table_lookup(local, &fl4, &res, FIB_LOOKUP_NOREF) &&
> +		    res.type == RTN_LOCAL)
> +			result = FIB_RES_DEV(res);
> +	}
>  	if (result && devref)
>  		dev_hold(result);
>  	rcu_read_unlock();

Acked-by: Stephen Hemminger <shemminger@vyatta.com>



-- 
