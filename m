From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ip: fix error queue empty skb handling
Date: Sun, 08 Mar 2015 23:02:11 -0400 (EDT)
Message-ID: <20150308.230211.1441656915237102392.davem@davemloft.net>
References: <1425778402-10720-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jan@gondor.com, richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbCIDCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 23:02:13 -0400
In-Reply-To: <1425778402-10720-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Sat,  7 Mar 2015 20:33:22 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> When reading from the error queue, msg_name and msg_control are only
> populated for some errors. A new exception for empty timestamp skbs
> added a false positive on icmp errors without payload.
> 
> `traceroute -M udpconn` only displayed gateways that return payload
> with the icmp error: the embedded network headers are pulled before
> sock_queue_err_skb, leaving an skb with skb->len == 0 otherwise.
> 
> Fix this regression by refining when msg_name and msg_control
> branches are taken. The solutions for the two fields are independent.
> 
> msg_name only makes sense for errors that configure serr->port and
> serr->addr_offset. Test the first instead of skb->len. This also fixes
> another issue. saddr could hold the wrong data, as serr->addr_offset
> is not initialized  in some code paths, pointing to the start of the
> network header. It is only valid when serr->port is set (non-zero).
> 
> msg_control support differs between IPv4 and IPv6. IPv4 only honors
> requests for ICMP and timestamps with SOF_TIMESTAMPING_OPT_CMSG. The
> skb->len test can simply be removed, because skb->dev is also tested
> and never true for empty skbs. IPv6 honors requests for all errors
> aside from local errors and timestamps on empty skbs.
> 
> In both cases, make the policy more explicit by moving this logic to
> a new function that decides whether to process msg_control and that
> optionally prepares the necessary fields in skb->cb[]. After this
> change, the IPv4 and IPv6 paths are more similar.
> 
> The last case is rxrpc. Here, simply refine to only match timestamps.
> 
> Fixes: 49ca0d8bfaf3 ("net-timestamp: no-payload option")
> 
> Reported-by: Jan Niehusmann <jan@gondor.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks for fixing this Willem.
