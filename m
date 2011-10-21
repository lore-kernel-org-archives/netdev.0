From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/3] net: hold sock reference while processing tx
 timestamps
Date: Fri, 21 Oct 2011 13:44:48 +0200
Message-ID: <1319197488.3964.15.camel@jlt3.sipsolutions.net>
References: <cover.1319193734.git.richard.cochran@omicron.at>
	 <f13715e7d094e7989581f5eacf0efe9d15379e10.1319193734.git.richard.cochran@omicron.at>
	 (sfid-20111021_125010_572009_F96AE567)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:45516 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217Ab1JULoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 07:44:54 -0400
In-Reply-To: <f13715e7d094e7989581f5eacf0efe9d15379e10.1319193734.git.richard.cochran@omicron.at> (sfid-20111021_125010_572009_F96AE567)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-21 at 12:49 +0200, Richard Cochran wrote:
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

It just now occurred to me that technically I think you could use a
destructor function that just points to something like this:

void tstamp_clone_free(struct sk_buff *skb)
{
	sock_put(skb->sk);
}

but just forcing drivers to use the right API seems equally good to me.

> These functions first appeared in v2.6.36.
> 
> Reported-by: Johannes Berg <johannes@sipsolutions.net>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> Cc: <stable@vger.kernel.org>


Thanks all for the discussions! :-)

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

johannes
