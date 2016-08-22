From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: ip_finish_output_gso: Allow fragmenting segments of
 tunneled skbs if their DF is unset
Date: Mon, 22 Aug 2016 11:48:23 +0200
Message-ID: <1471859303.3970877.702207417.066809DC@webmail.messagingengine.com>
References: <1471767752-7849-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>, wenxu <wenxu@ucloud.cn>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36105 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750927AbcHVJsZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 05:48:25 -0400
In-Reply-To: <1471767752-7849-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Aug 21, 2016, at 10:22, Shmulik Ladkani wrote:
> In b8247f095e,
> 
>    "net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU,
>    allow segmentation for local udp tunneled skbs"
> 
> gso skbs arriving from an ingress interface that go through UDP
> tunneling, are allowed to be fragmented if the resulting encapulated
> segments exceed the dst mtu of the egress interface.
> 
> This aligned the behavior of gso skbs to non-gso skbs going through udp
> encapsulation path.
> 
> However the non-gso vs gso anomaly is present also in the following
> cases of a GRE tunnel:
>  - ip_gre in collect_md mode, where TUNNEL_DONT_FRAGMENT is not set
>    (e.g. OvS vport-gre with df_default=false)
>  - ip_gre in nopmtudisc mode, where IFLA_GRE_IGNORE_DF is set
> 
> In both of the above cases, the non-gso skbs get fragmented, whereas the
> gso skbs (having skb_gso_network_seglen that exceeds dst mtu) get
> dropped,
> as they don't go through the segment+fragment code path.
> 
> Fix: Setting IPSKB_FRAG_SEGS if the tunnel specified IP_DF bit is NOT
> set.
> 
> Tunnels that do set IP_DF, will not go to fragmentation of segments.
> This preserves behavior of ip_gre in (the default) pmtudisc mode.
> 
> Fixes: b8247f095e ("net: ip_finish_output_gso: If skb_gso_network_seglen
> exceeds MTU, allow segmentation for local udp tunneled skbs")
> Reported-by: wenxu <wenxu@ucloud.cn>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Your dissecting of the current state of fragmentation handling also
looked fine. I wonder if it would now make sense to add a sysctl to add
back the dropping of packets in case they can't be fragmented by a
bridge, as we made sure that the defaults don't break for anyone.

Thanks,
Hannes
