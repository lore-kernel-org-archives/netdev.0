From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] packet: on direct_xmit, limit tso and csum to
 supported devices
Date: Sat, 29 Oct 2016 15:03:30 -0400 (EDT)
Message-ID: <20161029.150330.623989945389570570.davem@davemloft.net>
References: <1477495387-36861-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbcJ2TDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:03:32 -0400
In-Reply-To: <1477495387-36861-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 26 Oct 2016 11:23:07 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> When transmitting on a packet socket with PACKET_VNET_HDR and
> PACKET_QDISC_BYPASS, validate device support for features requested
> in vnet_hdr.
> 
> Drop TSO packets sent to devices that do not support TSO or have the
> feature disabled. Note that the latter currently do process those
> packets correctly, regardless of not advertising the feature.
> 
> Because of SKB_GSO_DODGY, it is not sufficient to test device features
> with netif_needs_gso. Full validate_xmit_skb is needed.
> 
> Switch to software checksum for non-TSO packets that request checksum
> offload if that device feature is unsupported or disabled. Note that
> similar to the TSO case, device drivers may perform checksum offload
> correctly even when not advertising it.
> 
> When switching to software checksum, packets hit skb_checksum_help,
> which has two BUG_ON checksum not in linear segment. Packet sockets
> always allocate at least up to csum_start + csum_off + 2 as linear.
> 
> Tested by running github.com/wdebruij/kerneltools/psock_txring_vnet.c
> 
>   ethtool -K eth0 tso off tx on
>   psock_txring_vnet -d $dst -s $src -i eth0 -l 2000 -n 1 -q -v
>   psock_txring_vnet -d $dst -s $src -i eth0 -l 2000 -n 1 -q -v -N
> 
>   ethtool -K eth0 tx off
>   psock_txring_vnet -d $dst -s $src -i eth0 -l 1000 -n 1 -q -v -G
>   psock_txring_vnet -d $dst -s $src -i eth0 -l 1000 -n 1 -q -v -G -N
> 
> v2:
>   - add EXPORT_SYMBOL_GPL(validate_xmit_skb_list)
> 
> Fixes: d346a3fae3ff ("packet: introduce PACKET_QDISC_BYPASS socket option")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable.
