From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay L2
Date: Thu, 29 Sep 2016 16:18:47 +0100
Message-ID: <57ED30D7.6000009@katalix.com>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: kleptog@svana.org, netdev@vger.kernel.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com
To: "R. Parameswaran" <parameswaran.r7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/09/16 21:52, R. Parameswaran wrote:
> From ed585bdd6d3d2b3dec58d414f514cd764d89159d Mon Sep 17 00:00:00 2001
> From: "R. Parameswaran" <rparames@brocade.com>
> Date: Thu, 22 Sep 2016 13:19:25 -0700
> Subject: [PATCH] L2TP:Adjust intf MTU,factor underlay L3,overlay L2
>
> Take into account all of the tunnel encapsulation headers when setting
> up the MTU on the L2TP logical interface device. Otherwise, packets
> created by the applications on top of the L2TP layer are larger
> than they ought to be, relative to the underlay MTU, leading to
> needless fragmentation once the outer IP encap is added.
>
> Specifically, take into account the (outer, underlay) IP header
> imposed on the encapsulated L2TP packet, and the Layer 2 header
> imposed on the inner IP packet prior to L2TP encapsulation.
>
> Do not assume an Ethernet (non-jumbo) underlay. Use the PMTU mechanism
> and the dst entry in the L2TP tunnel socket to directly pull up
> the underlay MTU (as the baseline number on top of which the
> encapsulation headers are factored in).  Fall back to Ethernet MTU
> if this fails.
>
> Signed-off-by: R. Parameswaran <rparames@brocade.com>
>
> Reviewed-by: "N. Prachanda" <nprachan@brocade.com>,
> Reviewed-by: "R. Shearman" <rshearma@brocade.com>,
> Reviewed-by: "D. Fawcus" <dfawcus@brocade.com>
> ---
>  net/l2tp/l2tp_eth.c | 48 ++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 44 insertions(+), 4 deletions(-)
>
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index 57fc5a4..dbcd6bd 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -30,6 +30,9 @@
>  #include <net/xfrm.h>
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/udp.h>
>  
>  #include "l2tp_core.h"
>  
> @@ -206,6 +209,46 @@ static void l2tp_eth_show(struct seq_file *m, void *arg)
>  }
>  #endif
>  
> +static void l2tp_eth_adjust_mtu(struct l2tp_tunnel *tunnel,
> +				struct l2tp_session *session,
> +				struct net_device *dev)
> +{
> +	unsigned int overhead = 0;
> +	struct dst_entry *dst;
> +
> +	if (session->mtu != 0) {
> +		dev->mtu = session->mtu;
> +		dev->needed_headroom += session->hdr_len;
> +		if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
> +			dev->needed_headroom += sizeof(struct udphdr);
> +		return;
> +	}
> +	overhead = session->hdr_len;
> +	/* Adjust MTU, factor overhead - underlay L3 hdr, overlay L2 hdr*/
> +	if (tunnel->sock->sk_family == AF_INET)
> +		overhead += (ETH_HLEN + sizeof(struct iphdr));
> +	else if (tunnel->sock->sk_family == AF_INET6)
> +		overhead += (ETH_HLEN + sizeof(struct ipv6hdr));
What about options in the IP header? If certain options are set on the
socket, the IP header may be larger.

> +	/* Additionally, if the encap is UDP, account for UDP header size */
> +	if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
> +		overhead += sizeof(struct udphdr);
> +	/* If PMTU discovery was enabled, use discovered MTU on L2TP device */
> +	dst = sk_dst_get(tunnel->sock);
> +	if (dst) {
> +		u32 pmtu = dst_mtu(dst);
> +
> +		if (pmtu != 0)
> +			dev->mtu = pmtu;
> +		dst_release(dst);
> +	}
> +	/* else (no PMTUD) L2TP dev MTU defaulted to Ethernet MTU in caller */
> +	session->mtu = dev->mtu - overhead;
> +	dev->mtu = session->mtu;
> +	dev->needed_headroom += session->hdr_len;
> +	if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
> +		dev->needed_headroom += sizeof(struct udphdr);
> +}
> +
>  static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
>  {
>  	struct net_device *dev;
> @@ -255,11 +298,8 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
>  	}
>  
>  	dev_net_set(dev, net);
> -	if (session->mtu == 0)
> -		session->mtu = dev->mtu - session->hdr_len;
> -	dev->mtu = session->mtu;
> -	dev->needed_headroom += session->hdr_len;
>  
> +	l2tp_eth_adjust_mtu(tunnel, session, dev);
>  	priv = netdev_priv(dev);
>  	priv->dev = dev;
>  	priv->session = session;
