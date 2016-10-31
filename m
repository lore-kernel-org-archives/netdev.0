From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Don't use ufo handling on later transformed
 packets
Date: Mon, 31 Oct 2016 13:12:14 -0400 (EDT)
Message-ID: <20161031.131214.468355414764451079.davem@davemloft.net>
References: <1477473674-21702-1-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, fw@strlen.de
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944921AbcJaRMT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:12:19 -0400
In-Reply-To: <1477473674-21702-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Wed, 26 Oct 2016 11:21:14 +0200

> Similar to commit c146066ab802 ("ipv4: Don't use ufo handling on later
> transformed packets"), don't perform UFO on packets that will be IPsec
> transformed. To detect it we rely on the fact that headerlen in
> dst_entry is non-zero only for transformation bundles (xfrm_dst
> objects).
> 
> Unwanted segmentation can be observed with a NETIF_F_UFO capable device,
> such as a dummy device:
> 
>   DEV=dum0 LEN=1493
> 
>   ip li add $DEV type dummy
>   ip addr add fc00::1/64 dev $DEV nodad
>   ip link set $DEV up
>   ip xfrm policy add dir out src fc00::1 dst fc00::2 \
>      tmpl src fc00::1 dst fc00::2 proto esp spi 1
>   ip xfrm state add src fc00::1 dst fc00::2 \
>      proto esp spi 1 enc 'aes' 0x0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b
> 
>   tcpdump -n -nn -i $DEV -t &
>   socat /dev/zero,readbytes=$LEN udp6:[fc00::2]:$LEN
> 
> tcpdump output before:
> 
>   IP6 fc00::1 > fc00::2: frag (0|1448) ESP(spi=0x00000001,seq=0x1), length 1448
>   IP6 fc00::1 > fc00::2: frag (1448|48)
>   IP6 fc00::1 > fc00::2: ESP(spi=0x00000001,seq=0x2), length 88
> 
> ... and after:
> 
>   IP6 fc00::1 > fc00::2: frag (0|1448) ESP(spi=0x00000001,seq=0x1), length 1448
>   IP6 fc00::1 > fc00::2: frag (1448|80)
> 
> Fixes: e89e9cf539a2 ("[IPv4/IPv6]: UFO Scatter-gather approach")
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thank you.
