From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next 10/17] fm10k: add TEB check to fm10k_gre_is_nvgre
Date: Thu, 3 Dec 2015 16:54:01 -0800
Message-ID: <CALx6S35nF58aS1hR1MVtNQ8Y1iv5zt-OzMT_2dXSA5ysqPD7yw@mail.gmail.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1449188994-64940-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33847 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbLDAyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 19:54:02 -0500
Received: by igvg19 with SMTP id g19so25715522igv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 16:54:01 -0800 (PST)
In-Reply-To: <1449188994-64940-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 4:29 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
>
> The NVGRE protocol should be run over transparent ethernet bridge
> protocol, so we should verify this in our check whether the GRE tunnel
> is NVGRE. While we're touching fm10k_main.c, update the copyright year.
>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> index 746a198..c5f7e0d 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> @@ -1,5 +1,5 @@
>  /* Intel Ethernet Switch Host Interface Driver
> - * Copyright(c) 2013 - 2014 Intel Corporation.
> + * Copyright(c) 2013 - 2015 Intel Corporation.
>   *
>   * This program is free software; you can redistribute it and/or modify it
>   * under the terms and conditions of the GNU General Public License,
> @@ -708,6 +708,10 @@ static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
>         if (nvgre_hdr->flags & FM10K_NVGRE_RESERVED0_FLAGS)
>                 return NULL;
>
> +       /* verify protocol is transparent Ethernet bridging */
> +       if (nvgre_hdr->proto != htons(ETH_P_TEB))
> +               return NULL;
> +
>         /* report start of ethernet header */
>         if (nvgre_hdr->flags & NVGRE_TNI)
>                 return (struct ethhdr *)(nvgre_hdr + 1);

I don't understand this. Just because a packet is GRE with ETH_P_TEB
set and only using keyid does not make it a GRE packet. What happens
if someone creates a GRE tunnel on this same host with keyid and
starts sending packets on it?

BTW, these is a potentially similar issue in fm10k_port_is_vxlan.
ndo_vxlan_port informs the driver of a vxlan port that may be received
in a destination (presumably after the port has been bound for the
tunnel). This says _nothing_ about source ports or the destination
port. For instance, there is nothing that prevents an application from
sending UDP packets to a "VXLAN port". If application does this, will
it's packets be messed up by the offload misinterpreting the packets
as VXLAN?

As for this code:

        int hlen = ip_hdrlen(skb);

        /* currently only IPv4 is supported due to hlen above */

I'm just speechless ;-)


> --
> 2.5.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
