From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: account for current skb length when deciding
 about UFO
Date: Fri, 23 Jun 2017 13:30:47 -0400 (EDT)
Message-ID: <20170623.133047.1805346217749425359.davem@davemloft.net>
References: <20170619110343.7CB5EA1377@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ananda.raju@neterion.com, james.z.li@ericsson.com,
        yoshfuji@linux-ipv6.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619110343.7CB5EA1377@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 19 Jun 2017 13:03:43 +0200 (CEST)

> Our customer encountered stuck NFS writes for blocks starting at specific
> offsets w.r.t. page boundary caused by networking stack sending packets via
> UFO enabled device with wrong checksum. The problem can be reproduced by
> composing a long UDP datagram from multiple parts using MSG_MORE flag:
> 
>   sendto(sd, buff, 1000, MSG_MORE, ...);
>   sendto(sd, buff, 1000, MSG_MORE, ...);
>   sendto(sd, buff, 3000, 0, ...);
> 
> Assume this packet is to be routed via a device with MTU 1500 and
> NETIF_F_UFO enabled. When second sendto() gets into __ip_append_data(),
> this condition is tested (among others) to decide whether to call
> ip_ufo_append_data():
> 
>   ((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))
> 
> At the moment, we already have skb with 1028 bytes of data which is not
> marked for GSO so that the test is false (fragheaderlen is usually 20).
> Thus we append second 1000 bytes to this skb without invoking UFO. Third
> sendto(), however, has sufficient length to trigger the UFO path so that we
> end up with non-UFO skb followed by a UFO one. Later on, udp_send_skb()
> uses udp_csum() to calculate the checksum but that assumes all fragments
> have correct checksum in skb->csum which is not true for UFO fragments.
> 
> When checking against MTU, we need to add skb->len to length of new segment
> if we already have a partially filled skb and fragheaderlen only if there
> isn't one.
> 
> In the IPv6 case, skb can only be null if this is the first segment so that
> we have to use headersize (length of the first IPv6 header) rather than
> fragheaderlen (length of IPv6 header of further fragments) for skb == NULL.
> 
> Fixes: e89e9cf539a2 ("[IPv4/IPv6]: UFO Scatter-gather approach")
> Fixes: e4c5e13aa45c ("ipv6: Should use consistent conditional judgement for
> 	ip6 fragment between __ip6_append_data and ip6_finish_output")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied and queued up for -stable, thanks.
