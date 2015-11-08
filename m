From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Sun, 08 Nov 2015 01:33:56 +0100
Message-ID: <563E9874.6040403@iogearbox.net>
References: <cover.1446842228.git.daniel@iogearbox.net>	 <5cdcd969eec9228a18c0dc54f9cc4b7b6b07ce05.1446842228.git.daniel@iogearbox.net>	 <1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>	 <20151107.133502.833614670001999282.davem@davemloft.net>	 <1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com> <1446923165.17135.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, jasowang@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48028 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbbKHAeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 19:34:06 -0500
In-Reply-To: <1446923165.17135.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2015 08:06 PM, Eric Dumazet wrote:
> On Sat, 2015-11-07 at 10:53 -0800, Eric Dumazet wrote:
>
>> Well, imagine following scenario (a real one, as I use it all of time,
>> thus how I discovered all trafgen traffic ends up on one slave only)
>>
>> Even if qdisc is bypassed on the bond0, the current handling does not
>> prevent going to the slave qdiscs.
>>
>> So it is not clear to me why we do a selective probe depending on the
>> bypass of first qdisc.
>
> Presumably the transport_header only needs to be set for gso packets in
> some drivers (look at igbvf_tso() for example)
>
> It looks like we might need an audit and/or some guidelines/fixes.

Hmm, yeah, on a (only quick) look, it seems this is mostly needed for the
virtio_net related code in packet_snd() / packet_recvmsg(), not handled in
RX/TX ring paths actually.

$ git grep -n gso_size net/packet/
net/packet/af_packet.c:2748:                    if (vnet_hdr.gso_size == 0)
net/packet/af_packet.c:2825:            skb_shinfo(skb)->gso_size =
net/packet/af_packet.c:2826:                    __virtio16_to_cpu(vio_le(), vnet_hdr.gso_size);
net/packet/af_packet.c:3219:                    vnet_hdr.gso_size =
net/packet/af_packet.c:3220:                            __cpu_to_virtio16(vio_le(), sinfo->gso_size);

Need to take a closer look on Monday.
