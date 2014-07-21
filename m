From: Quentin Armitage <quentin@armitage.org.uk>
Subject: Re: [PATCH] ipv4: Make IP_MULTICAST_ALL and IP_MSFILTER work on raw
 sockets
Date: Mon, 21 Jul 2014 09:42:58 +0100
Message-ID: <1405932178.3485.66.camel@samson1.armitage.org.uk>
References: <1405701503.3485.49.camel@samson1.armitage.org.uk>
	 <20140720.212728.2235972803070688024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140720.212728.2235972803070688024.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-07-20 at 21:27 -0700, David Miller wrote:
> From: Quentin Armitage <quentin@armitage.org.uk>
> Date: Fri, 18 Jul 2014 17:38:23 +0100
> 
> Currently, although IP_MULTICAST_ALL and IP_MSFILTER ioctl calls succeed on
> raw sockets, there is no code to implement the functionality on received
> packets; it is only implemented for UDP sockets. The raw(7) man page states:
> "In addition, all ip(7) IPPROTO_IP socket options valid for datagram sockets
> are supported", which implies these ioctls should work on raw sockets.
> 
> To fix this, add a call to ip_mc_sf_allow on raw sockets.
> 
> This should not break any existing code, since the current position of
> not calling ip_mc_sf_filter makes it behave as if neither the IP_MULTICAST_ALL
> nor the IP_MSFILTER ioctl had been called. Adding the call to ip_mc_sf_allow
> will therefore maintain the current behaviour so long as IP_MULTICAST_ALL and
> IP_MSFILTER ioctls are not called. Any code that currently is calling
> IP_MULTICAST_ALL or IP_MSFILTER ioctls on raw sockets presumably is wanting
> the filter to be applied, although no filtering will currently be occurring.
> 
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
> ---
>  net/ipv4/raw.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index 2c65160..2e1628c 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -58,6 +58,7 @@
>  #include <linux/in_route.h>
>  #include <linux/route.h>
>  #include <linux/skbuff.h>
> +#include <linux/igmp.h>
>  #include <net/net_namespace.h>
>  #include <net/dst.h>
>  #include <net/sock.h>
> @@ -174,7 +175,9 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
>  
>         while (sk) {
>                 delivered = 1;
> -               if (iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) {
> +               if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
> +                   ip_mc_sf_allow(sk, iph->daddr, iph->saddr,
> +                                  skb->dev->ifindex)) {
>                         struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
>  
>                         /* Not releasing hash table! */
> -- 
> 1.7.7.6
> 
> 
> 
> Please form your subject line properly, the text should be of the form:
> 
> [PATCH] ${SUBSYSTEM}: Description.
> 
> Your's is missing the subsystem prefix, which should probable be "ipv4: "
> in this case.

Subsystem ipv4: added to subject.
