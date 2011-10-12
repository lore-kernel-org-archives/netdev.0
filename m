From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/1] net: hold sock reference while processing tx
 timestamps
Date: Wed, 12 Oct 2011 21:27:53 +0200
Message-ID: <1318447673.3933.47.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 (sfid-20111012_203706_058621_68EB8D6B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34299 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab1JLT17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 15:27:59 -0400
In-Reply-To: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at> (sfid-20111012_203706_058621_68EB8D6B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-12 at 20:36 +0200, Richard Cochran wrote:
> The pair of functions,
> 
>  * skb_clone_tx_timestamp()
>  * skb_complete_tx_timestamp()
> 
> were designed to allow timestamping in PHY devices. The first
> function, called during the MAC driver's hard_xmit method, identifies
> PTP protocol packets, clones them, and gives them to the PHY device
> driver. The PHY driver may hold onto the packet and deliver it at a
> later time using the second function, which adds the packet to the
> socket's error queue.
> 
> As pointed out by Johannes, nothing prevents the socket from
> disappearing while the cloned packet is sitting in the PHY driver
> awaiting a timestamp. This patch fixes the issue by taking a reference
> on the socket for each such packet. In addition, the comments
> regarding the usage of these function are expanded to highlight the
> rule that PHY drivers must use skb_complete_tx_timestamp() to release
> the packet, in order to release the socket reference, too.

This still needs a fix to the PHY driver right? It has a case that can
kfree_skb() the skb instead of passing it back to
complete_tx_timestamp().

> -	if (!hwtstamps)
> +	if (!hwtstamps) {
> +		sock_put(sk);
> +		kfree_skb(skb);
>  		return;
> +	}

Is that right w/o skb->sk = NULL?


The other thing I was wondering -- what if we just set truesize to 1 (we
don't have any truesize checks) and account the skb to the socket
normally. Not really a good way either though.

FWIW I just decided to do it the other way around in mac80211 -- keep
the original SKB that's charged to the socket for the error queue, and
use a clone to actually do the TX.

johannes
