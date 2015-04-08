From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs
 consistent
Date: Tue, 07 Apr 2015 22:35:49 -0400 (EDT)
Message-ID: <20150407.223549.335906307265617841.davem@davemloft.net>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com>
	<1428455025-5945-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jiri@resnulli.us, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbbDHCfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 22:35:51 -0400
In-Reply-To: <1428455025-5945-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue,  7 Apr 2015 18:03:45 -0700

> +
> +	/* don't recompute skb->csum back and forth while pushing/pulling L2 */
> +	__skb_push(skb, hard_header_len);
>  	result = tc_classify(skb, fl, &res);
> +	__skb_pull(skb, hard_header_len);

This is not legal.

This SKB can be referenced by other entities, such as AF_PACKET
sockets and other network taps on input.  You absolutely do not
have private access to this SKB object, and any modification you
make to it will be seen by others.

Therefore you cannot push and pull the headers, because that
modification will be seen by the other entities referencing this SKB.

This is why every network protocol's input path must do something
like:

	skb = skb_share_check(skb, GFP_ATOMIC);

before pulling headers.

And you do not want to add this expensive operation here.

That would be really stupid overhead just to accomodate BPF things.

Instead just propagate some offset into the locations that care about
the skb data location.
