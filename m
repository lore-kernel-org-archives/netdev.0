From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 23 Mar 2011 11:05:53 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103231100440.1463@ja.ssi.bg>
References: <alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg> <20110303.112328.59677094.davem@davemloft.net> <alpine.LFD.2.00.1103041013360.1452@ja.ssi.bg> <20110322.215655.245381151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55654 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752089Ab1CWJA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 05:00:28 -0400
In-Reply-To: <20110322.215655.245381151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Tue, 22 Mar 2011, David Miller wrote:

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
>   inet_addr_onlink() is a simple list traversal.
>
> 2) We know the old code works.
>
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> net/ipv4/devinet.c |   16 ++++++++++++++++
> 1 files changed, 16 insertions(+), 0 deletions(-)
>
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index d5a4553..5345b0b 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -64,6 +64,8 @@
> #include <net/rtnetlink.h>
> #include <net/net_namespace.h>
>
> +#include "fib_lookup.h"
> +
> static struct ipv4_devconf ipv4_devconf = {
> 	.data = {
> 		[IPV4_DEVCONF_ACCEPT_REDIRECTS - 1] = 1,
> @@ -151,6 +153,20 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
> 			break;
> 		}
> 	}
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
> 	if (result && devref)
> 		dev_hold(result);
> 	rcu_read_unlock();
> -- 
> 1.7.4.1

 	Not tested but looks ok for me.

Regards

--
Julian Anastasov <ja@ssi.bg>
