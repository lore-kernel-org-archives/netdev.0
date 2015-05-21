From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Looking for a lost patch
Date: Wed, 20 May 2015 19:06:36 -0700
Message-ID: <555D3DAC.4080003@gmail.com>
References: <55538E1F.2020505@gmail.com> <20150518073809.GD8928@secunet.com> <555A0D0E.5040102@redhat.com> <20150519075724.GI8928@secunet.com> <555B81AF.5050401@redhat.com> <20150520063223.GM8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35905 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbbEUCGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 22:06:38 -0400
Received: by pabts4 with SMTP id ts4so87598896pab.3
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 19:06:38 -0700 (PDT)
In-Reply-To: <20150520063223.GM8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2015 11:32 PM, Steffen Klassert wrote:
> On Tue, May 19, 2015 at 11:32:15AM -0700, Alexander Duyck wrote:
>> On 05/19/2015 12:57 AM, Steffen Klassert wrote:
>>> The MTU should be 1500. All the IPsec overhead is handled by PMTU
>>> discovery, just like in the case we use IPsec without vti tunnels.
>>> The IPv6 side of vti does it like that.
>> The problem is the PMTU isn't communicated to things that make use
>> of the tunnel.  For example if I do a "ping -s 2000 x.x.x.x" across
>> an IPv6 VTI interface it will fail currently as it assumes the MTU
>> is 1500 and so it is fragmenting the ping packet at sizes that won't
>> be communicated across the underlying interface.
> Well, the problem is that the local socket is still attached on the
> skb. The socket gets an error notification if the packet is too big,
> but ping does not care much about these error notifications.
>
> One option to get such applications to work is to orphan the skb
> in the vti xmit function. Then the packet is not assumed to be
> local, so PMTU discovery is triggered on that route.
>
> Something like this should work for IPv6:
>
> diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
> index ed9d681..cd50bc1 100644
> --- a/net/ipv6/ip6_vti.c
> +++ b/net/ipv6/ip6_vti.c
> @@ -459,6 +459,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
>   		goto tx_err_dst_release;
>   	}
>   
> +	skb_orphan(skb);
>   	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
>   	skb_dst_set(skb, dst);
>   	skb->dev = skb_dst(skb)->dev;
>

This works, sort-of.  I have to ping from both ends before I can start 
to send traffic.

I am going to do some digging.  It seems like there should be some way 
to get the PMTU fed back into the PMTU for the VTI interface. If we can 
do that it would save a ton of pain.

- Alex
