From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for local udp tunneled skbs
Date: Mon, 18 Jul 2016 12:06:00 +0200
Message-ID: <27e9a6c3-1648-892c-bcaa-254e5332a42e@stressinduktion.org>
References: <1468582987-18990-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:40198 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751490AbcGRKGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 06:06:03 -0400
In-Reply-To: <1468582987-18990-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.07.2016 13:43, Shmulik Ladkani wrote:
> Given:
>  - tap0 and vxlan0 are bridged
>  - vxlan0 stacked on eth0, eth0 having small mtu (e.g. 1400)
> 
> Assume GSO skbs arriving from tap0 having a gso_size as determined by
> user-provided virtio_net_hdr (e.g. 1460 corresponding to VM mtu of 1500).
> 
> After encapsulation these skbs have skb_gso_network_seglen that exceed
> eth0's ip_skb_dst_mtu.
> 
> These skbs are accidentally passed to ip_finish_output2 AS IS.
> Alas, each final segment (segmented either by validate_xmit_skb or by
> hardware UFO) would be larger than eth0 mtu.
> As a result, those above-mtu segments get dropped on certain networks.
> 
> This behavior is not aligned with the NON-GSO case:
> Assume a non-gso 1500-sized IP packet arrives from tap0. After
> encapsulation, the vxlan datagram is fragmented normally at the
> ip_finish_output-->ip_fragment code path.
> 
> The expected behavior for the GSO case would be segmenting the
> "gso-oversized" skb first, then fragmenting each segment according to
> dst mtu, and finally passing the resulting fragments to ip_finish_output2.
> 
> 'ip_finish_output_gso' already supports this "Slowpath" behavior,
> but it is only considered if IPSKB_FORWARDED is set (which is not set in
> the bridged case).
> 
> In order to support the bridged case, we'll mark skbs arriving from an
> ingress interface that get udp-encaspulated as "allowed to be fragmented".
> 
> This mark (as well as the original IPSKB_FORWARDED mark) gets tested in
> 'ip_finish_output_gso', in order to determine whether validating the
> network seglen is needed.
> 
> Note the TUNNEL_DONT_FRAGMENT tun_flag is still honoured (both in the
> gso and non-gso cases), which serves users wishing to forbid
> fragmentation at the udp tunnel endpoint.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

I think this is reasonable, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
