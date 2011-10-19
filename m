From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 13:50:12 +0200
Message-ID: <20111019115012.GA7206@netboy.at.omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
 <cover.1318498805.git.richard.cochran@omicron.at>
 <20111019.001610.312990203017422173.davem@davemloft.net>
 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44402 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914Ab1JSLuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 07:50:09 -0400
Received: by yxp4 with SMTP id 4so1574337yxp.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 04:50:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1319001336.4424.8.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 07:15:36AM +0200, Johannes Berg wrote:
> The only thing I'm not completely sure about is whether or not it is
> permissible to sock_hold() at that point. I'm probably just missing
> something, but: if sk_free() was called before hard_start_xmit() which
> will call skb_clone_tx_timestamp(), can we really call sock_hold()?
> 
> The reason I ask is that sock_wfree() doesn't check sk_refcnt, so if it
> is possible for sk_free() to have been called before hard_start_xmit(),
> maybe because the packet was stuck on the qdisc for a while, the socket
> won't be released (sk_free checks sk_wmem_alloc) but the sk_wfree() when
> the original skb is freed will actually free the socket, invalidating
> the clone's sk pointer *even though* we called sock_hold() right after
> making the clone.
> 
> So what guarantees that sk_refcnt is still non-zero when we make the
> clone?

In the non-qdisc path, the kernel is in a send() call, so the initial
reference taken in socket() is held.

I really don't know the qdisc code, whether it is somehow holding the
skb->sk indirectly or not.

Eric? David?

> Alternatively, should sock_wfree() check sk_refcnt?

That would presumably spoil the performance enhancement gained in
commit 2b85a34e.
