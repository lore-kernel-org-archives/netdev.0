From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] GRO: fix merging a paged skb after non-paged skbs
Date: Tue, 25 Jan 2011 11:24:35 +1000
Message-ID: <1295918675.4105.5.camel@localhost>
References: <20110124184752.1d0947dd@delilah>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	linux-net-drivers@solarflare.com
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31384 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab1AYBYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 20:24:38 -0500
In-Reply-To: <20110124184752.1d0947dd@delilah>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-24 at 18:47 +0100, Michal Schmidt wrote:
> Suppose that several linear skbs of the same flow were received by GRO. They
> were thus merged into one skb with a frag_list. Then a new skb of the same flow
> arrives, but it is a paged skb with data starting in its frags[].
> 
> Before adding the skb to the frag_list skb_gro_receive() will of course adjust
> the skb to throw away the headers. It correctly modifies the page_offset and
> size of the frag, but it leaves incorrect information in the skb:
>  ->data_len is not decreased at all.
>  ->len is decreased only by headlen, as if no change were done to the frag.
> Later in a receiving process this causes skb_copy_datagram_iovec() to return
> -EFAULT and this is seen in userspace as the result of the recv() syscall.
> 
> In practice the bug can be reproduced with the sfc driver. By default the
> driver uses an adaptive scheme when it switches between using
> napi_gro_receive() (with skbs) and napi_gro_frags() (with pages). The bug is
> reproduced when under rx load with enough successful GRO merging the driver
> decides to switch from the former to the latter.
[...]

This is odd because I thought we made sure to flush before making such a
change.  Perhaps that got lost during the conversion from inet_lro to
GRO?

Anyway, thanks very much for fixing this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

