From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] BPF program access to transport header
Date: Fri, 30 Apr 2010 22:15:09 +0200
Message-ID: <4BDB3A4D.5020507@trash.net>
References: <20100430193916.GZ19334@cel.leo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64442 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758274Ab0D3UPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:15:12 -0400
In-Reply-To: <20100430193916.GZ19334@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul LeoNerd Evans wrote:
> Via the SKF_NET_OFF extension area, a BPF program has nice easy access
> to the network header, wherever it might happen to be in the packet.
> This makes it simpler to write filters on e.g. IPv4 headers, knowing
> that fields will always be at simple offsets relative to SKF_NET_OFF.
> Using the data at WORD[SKF_AD_PROTO] it's easy also to find out what
> network protocol this is.
> 
> I would like to provide similar for the transport header. Without doing
> so, it is very hard to parse e.g. UDP or TCP headers that may be
> contained within IPv6 protocol, because of the linked-list way IPv6
> headers chain on to each other. BPF doesn't provide a while() loop or
> any kind of backward jump, meaning the filter program has to be
> loop-unrolled a static number of times. This quickly leads to very large
> programs.
> 
> I forsee a number of issues with trying to provide this:
> 
>  * How to provide the protocol number (e.g. 6 for TCP, 1 for ICMP) to
>    the BPF program

Using one of the registers?

>  * How to obtain the transport offset - AIUI, the skf_transport_offset()
>    won't actually be set yet by the time the filter program runs.

For IPv4 its trivial. For IPv6 you could use ipv6_skip_exthdr().
A slightly more flexible way would be to use something like the
netfilter ipv6_find_hdr() function to get the offset of any header
type. The protocol number could be returned in one of the registers
(the other one would contain the offset).

>  * What to do if the underlying protocol doesn't support a transport
>    layer above it - e.g. ARP.

I'd say simply abort the filter.

> Ideally, this would make it easy to filter, say, TCP destination port
> 80, by doing the following:
> 
>   LD WORD[SKF_AD_PROTO]
>   JEQ ETHERTYPE_IPV4, 1, fail
>   JEQ ETHERTYPE_IPv6, 0, fail
> 
>   LD WORD[SKF_AD_TRANSPROTO]
>   JEQ IPPROTO_TCP, 0, fail
> 
>   LD WORD[SKF_TRANS_OFF+0]
>   JEQ 80, 0, fail
> 
>   LD len
>   RET A
> 
> fail:
>   RET 0
> 
> In this short simple BPF program we've avoided all the issues involved
> with trying to parse IPv6 headers.
> 
> Can we make this work?

