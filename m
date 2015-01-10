From: Tom Herbert <therbert@google.com>
Subject: Re: [Question] vxlan_features_check()
Date: Sat, 10 Jan 2015 08:23:54 -0800
Message-ID: <CA+mtBx-BD4WboiNSrwPpoNH13OeRTheN2zHExSqSoXYpTDaQRw@mail.gmail.com>
References: <31318D46B5DF3F4AB71CC057601E9FEB12BFBC57@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sriharsha Basavapatna <Sriharsha.Basavapatna@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:55283 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbbAJQXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 11:23:55 -0500
Received: by mail-ie0-f174.google.com with SMTP id at20so19692016iec.5
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 08:23:55 -0800 (PST)
In-Reply-To: <31318D46B5DF3F4AB71CC057601E9FEB12BFBC57@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 10:52 PM, Sriharsha Basavapatna
<Sriharsha.Basavapatna@emulex.com> wrote:
> Hi Jesse, Tom,
>
> The current implementation of vxlan_features_check() disables csum/gso flags
> for only a subset of Non-VxLAN tunnels - those with tunnel outer transport type
> of UDP. Is there any reason why this was not done for non-UDP tunnels like
> GRE too ? This can avoid additional code in the driver ndo_features_check()
> to disable those flags for non-UDP tunnels.  Please let me know if I'm
> missing something here.
>
> The current code in vxlan_features_check() is this:
>         if ((l4_hdr == IPPROTO_UDP) &&
>             (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
>              skb->inner_protocol != htons(ETH_P_TEB) ||
>              (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
>               sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
>                 return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
>
> That should change to:
>         if (l4_hdr != IPPROTO_UDP ||
>             skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
>             skb->inner_protocol != htons(ETH_P_TEB) ||
>             (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
>             sizeof(struct udphdr) + sizeof(struct vxlanhdr)))
>                 return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
>
No, this isn't correct. vxlan_features_check is only commenting on
vxlan support. If a driver supports GRE GRO (NETIF_F_GSO_GRE is a
feature) and there are limitations then it can create it's own
features check.

> Thanks,
> -Harsha
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
