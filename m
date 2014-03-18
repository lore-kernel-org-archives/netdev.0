From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCHv2 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 17:40:49 +0200
Message-ID: <CAEnQRZDqSXLOHOHqK=1BvvidPWD_44bB7Srq61aX5-iDTmmQkw@mail.gmail.com>
References: <201403181521.s2IFL99N027716@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:62076 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbaCRPku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 11:40:50 -0400
Received: by mail-wi0-f176.google.com with SMTP id hr14so3864147wib.15
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 08:40:49 -0700 (PDT)
In-Reply-To: <201403181521.s2IFL99N027716@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 5:21 PM, David L Stevens <dlstevens@us.ibm.com> wrote:
>
>         The VXLAN neigh_reduce() code is completely non-functional since
> check-in. Specific errors:
>
> 1) The original code drops all packets with a multicast destination address,
>         even though neighbor solicitations are sent to the solicited-node
>         address, a multicast address. The code after this check was never run.
> 2) The neighbor table lookup used the IPv6 header destination, which is the
>         solicited node address, rather than the target address from the
>         neighbor solicitation. So neighbor lookups would always fail if it
>         got this far. Also for L3MISSes.
> 3) The code calls ndisc_send_na(), which does a send on the tunnel device.
>         The context for neigh_reduce() is the transmit path, vxlan_xmit(),
>         where the host or a bridge-attached neighbor is trying to transmit
>         a neighbor solicitation. To respond to it, the tunnel endpoint needs
>         to do a *receive* of the appropriate neighbor advertisement. Doing a
>         send, would only try to send the advertisement, encapsulated, to the
>         remote destinations in the fdb -- hosts that definitely did not do the
>         corresponding solicitation.
> 4) The code uses the tunnel endpoint IPv6 forwarding flag to determine the
>         isrouter flag in the advertisement. This has nothing to do with whether
>         or not the target is a router, and generally won't be set since the
>         tunnel endpoint is bridging, not routing, traffic.
>
>         The patch below creates a proxy neighbor advertisement to respond to
> neighbor solicitions as intended, providing proper IPv6 support for neighbor
> reduction.
>
> Changes since v1:
>
> - reworked code to be structurally similar to arp_reduce()
>
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index eb59b14..e319c6d 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1336,14 +1336,106 @@ out:
>  }
>
>  #if IS_ENABLED(CONFIG_IPV6)
> +
> +static struct sk_buff *vxlan_na_create(struct sk_buff *request,
> +       struct neighbour *n, bool isrouter)
> +{
> +       struct net_device *dev = request->dev;
> +       struct sk_buff *reply = NULL;
> +       struct nd_msg *ns, *na;
> +       struct ipv6hdr *pip6 = ipv6_hdr(reply);
> +       u8 *daddr;
> +       int olen = 8; /* opt hdr + ETH_ALEN for target */
> +       int i, len;
> +
> +       if (dev == NULL)
> +               return NULL;
> +
> +       ns = (struct nd_msg *)skb_transport_header(request);
> +
> +       len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
> +               sizeof(*na) + olen + dev->needed_tailroom;
> +       reply = alloc_skb(len, GFP_ATOMIC);
> +       if (reply == NULL)
> +               goto out;

I think here you can just return NULL, instead of going to out. Also we could
remove the out label,since this is the only place that jumps to it.

thanks,
Daniel.
