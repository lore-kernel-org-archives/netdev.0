From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] ipv6: don't use CHECKSUM_PARTIAL on MSG_MORE/UDP_CORK
 sockets
Date: Tue, 20 Oct 2015 17:39:47 -0400
Message-ID: <5626B4A3.6080900@gmail.com>
References: <1445351922-8463-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sd@quesysnail.net, bcodding@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33234 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbbJTVkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 17:40:09 -0400
Received: by qkcy65 with SMTP id y65so14101253qkc.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 14:40:08 -0700 (PDT)
In-Reply-To: <1445351922-8463-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2015 10:38 AM, Hannes Frederic Sowa wrote:
> MSG_MORE might cause the packet to get fragmented in the end when
> passed down to the flush function and the transhdrlen check alone is
> not sufficient to protect against fragmentation. Instead check if the
> socket user intends to add more data to the socket on the first packet.
> 
> This broke checksum calculation for UDPv6 for NFS protocols.
> 
> Fixes: 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Tested-by: Sabrina Dubroca <sd@quesysnail.net>
> Tested-by: Benjamin Coddington <bcodding@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_output.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 61d403e..95c5780 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1317,6 +1317,7 @@ emsgsize:
>  	 * sums only work when transhdrlen is set.
>  	 */
>  	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
> +	    !(flags & MSG_MORE) &&
>  	    length + fragheaderlen < mtu &&
>  	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
>  	    !exthdrlen)
> 

Hmm... so while this solves this problem by simply avoiding the combination of
skb #1 having CHECKSUM_PARTIAL and others having CHECKSUM_NONE, I think the actual
problem is a bit deeper.
The above combination seems to work for me since udp6_hwcsum_outgoing() corrects
the checksum.  However, my testing so far has been on nics that have NETIF_F_V6_CSUM,
but without UFO support.

On such systems a simple test of using MSG_MORE an IPv6 udp socket sending 200 bytes
followed by 2000 bytes works correctly.

I am now wondering if this might be UFO related instead and looking for a nic that
has UFO support.

-vlad
