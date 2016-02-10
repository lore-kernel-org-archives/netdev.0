From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Wed, 10 Feb 2016 08:40:55 +0100
Message-ID: <CALx6S37sD+MNK+kp9oLnEYHEUkOy_NdQK6bq-aMQP2Mvw9M4Qg@mail.gmail.com>
References: <1455036424-6403-1-git-send-email-david@weave.works>
	<1455036424-6403-3-git-send-email-david@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	dev@openvswitch.org, Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Wragg <david@weave.works>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34574 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbcBJHk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 02:40:56 -0500
Received: by mail-io0-f182.google.com with SMTP id 9so13225110iom.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 23:40:56 -0800 (PST)
In-Reply-To: <1455036424-6403-3-git-send-email-david@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 9, 2016 at 5:47 PM, David Wragg <david@weave.works> wrote:
> Allow the MTU of geneve devices to be set to large values, in order to
> exploit underlying networks with larger frame sizes.
>
> GENEVE does not have a fixed encapsulation overhead (an openvswitch
> rule can add variable length options), so there is no relevant maximum
> MTU to enforce.  A maximum of IP_MAX_MTU is used instead.
> Encapsulated packets that are too big for the underlying network will
> get dropped on the floor.
>
This defeats the purpose of having an MTU. The advertised MTU
indicates how large a packet that the interface if willing to handle.
Upper layers use this information, and if they need to send a packet
larger than MTU they take appropriate action such as fragmenting
packet or sending an ICMP PTB error. If a packets are sent on the
interface that are smaller than MTU and are being "dropped on the
floor" for being too big, a sender would get no indication at all why
its packets are being dropped.

The correct thing to do is determine the maximum amount of
encapsulation overhead that can ever be set in a packet and use for
setting the MTU. For instance, when RCO is enable in GUE, the size of
the option is included in tunnel->encap_hlen even though it will not
be used in all packets (via ip_tunnel_change_mtu). If there is no way
to determine a maximum overhead a priori from configuration, then
maximum overhead could be assumed to be maximum possible encapsulation
header size which for Geneve is 132 bytes IIRC.

Tom

> Signed-off-by: David Wragg <david@weave.works>
> ---
>  drivers/net/geneve.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 0b14ac3..05cef11 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -1039,6 +1039,16 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>         return geneve_xmit_skb(skb, dev, info);
>  }
>
> +static int geneve_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +       /* GENEVE overhead is not fixed, so we can't enforce a more
> +          precise max MTU. */
> +       if (new_mtu < 68 || new_mtu > IP_MAX_MTU)
> +               return -EINVAL;
> +       dev->mtu = new_mtu;
> +       return 0;
> +}
> +
>  static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
>  {
>         struct ip_tunnel_info *info = skb_tunnel_info(skb);
> @@ -1083,7 +1093,7 @@ static const struct net_device_ops geneve_netdev_ops = {
>         .ndo_stop               = geneve_stop,
>         .ndo_start_xmit         = geneve_xmit,
>         .ndo_get_stats64        = ip_tunnel_get_stats64,
> -       .ndo_change_mtu         = eth_change_mtu,
> +       .ndo_change_mtu         = geneve_change_mtu,
>         .ndo_validate_addr      = eth_validate_addr,
>         .ndo_set_mac_address    = eth_mac_addr,
>         .ndo_fill_metadata_dst  = geneve_fill_metadata_dst,
> --
> 2.5.0
>
