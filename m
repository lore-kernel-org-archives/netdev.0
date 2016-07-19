From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for local udp tunneled skbs
Date: Tue, 19 Jul 2016 09:48:52 +0200
Message-ID: <6e03064e-8c8c-79f4-815a-7271899f0a5a@stressinduktion.org>
References: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
 <1468842574-1243-3-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45859 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbcGSHsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 03:48:55 -0400
In-Reply-To: <1468842574-1243-3-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.07.2016 13:49, Shmulik Ladkani wrote:
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
> according to the IPSKB_FRAG_SEGS flag, which is only set during ipv4
> forwarding (not set in the bridged case).
> 
> In order to support the bridged case, we'll mark skbs arriving from an
> ingress interface that get udp-encaspulated as "allowed to be fragmented",
> causing their network_seglen to be validated by 'ip_finish_output_gso'
> (and fragment if needed).
> 
> Note the TUNNEL_DONT_FRAGMENT tun_flag is still honoured (both in the
> gso and non-gso cases), which serves users wishing to forbid
> fragmentation at the udp tunnel endpoint.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Given current vxlan behavior regarding fragmentation from non-gso frames
(which we probably can never change), this is in my opinion the best way
forward to make it symmetrical with non-gso. As don't fragment is still
honored after all I don't see any problems with this approach:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
