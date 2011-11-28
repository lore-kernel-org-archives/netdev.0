From: Dimitris Michailidis <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] net: introduce skb_flow_dissect()
Date: Mon, 28 Nov 2011 08:25:39 -0800
Message-ID: <4ED3B603.4010702@chelsio.com>
References: <1322493738.2292.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>, Dan Siemon <dan-BZ4SNL/Vixll57MIdRCFDg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322493738.2292.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/28/2011 07:22 AM, Eric Dumazet wrote:
> We use at least two flow dissectors in network stack, with known
> limitations and code duplication.
> 
> Introduce skb_flow_dissect() to factorize this, highly inspired from
> existing dissector from __skb_get_rxhash()
> 
> Note : We extensively use skb_header_pointer(), this permits us to not
> touch skb at all.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  include/net/flow_keys.h   |   15 ++++
>  net/core/Makefile         |    2 
>  net/core/flow_dissector.c |  134 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 150 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> new file mode 100644
> index 0000000..7a61e21
> --- /dev/null
> +++ b/include/net/flow_keys.h
> @@ -0,0 +1,15 @@
> +#ifndef _NET_FLOW_KEYS_H
> +#define _NET_FLOW_KEYS_H
> +
> +struct flow_keys {
> +	__be32 src;
> +	__be32 dst;
> +	union {
> +		__be32 ports;
> +		__be16 port16[2];
> +	};
> +	u8 ip_proto;
> +};
> +
> +extern bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
> +#endif
> diff --git a/net/core/Makefile b/net/core/Makefile
> index 3606d40..c4ecc86 100644
> --- a/net/core/Makefile
> +++ b/net/core/Makefile
> @@ -3,7 +3,7 @@
>  #
>  
>  obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
> -	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o
> +	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o
>  
>  obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
>  
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> new file mode 100644
> index 0000000..d0e085b
> --- /dev/null
> +++ b/net/core/flow_dissector.c
> @@ -0,0 +1,134 @@
> +#include <linux/skbuff.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/if_vlan.h>
> +#include <net/ip.h>
> +#include <linux/if_tunnel.h>
> +#include <linux/if_pppox.h>
> +#include <linux/ppp_defs.h>
> +#include <net/flow_keys.h>
> +
> +
> +bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
> +{
> +	int poff, nhoff = skb_network_offset(skb);
> +	u8 ip_proto;
> +	u16 proto = skb->protocol;

__be16 instead of u16 for proto?
