From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 16:35:34 -0700
Message-ID: <20070423163534.9b6bfe6a.akpm@linux-foundation.org>
References: <20070423151240.0e8cabed.akpm@linux-foundation.org>
	<20070423.151531.70219647.davem@davemloft.net>
	<20070423153714.71b9d99e.akpm@linux-foundation.org>
	<20070423.154509.116354989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59082 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754533AbXDWXg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 19:36:28 -0400
In-Reply-To: <20070423.154509.116354989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Apr 2007 15:45:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 23 Apr 2007 15:37:14 -0700
> 
> > So I think we did a bit of TCP chatter then no UDP at all?
> > 
> > It's interesting that the test machine can see other people's DNS queries
> > go past.
> 
> It's mysterious alright.
> 
> I can't say that the UDP's are going out corrupted because tcpdump
> seems to decode the DNS queries just fine.  Hmmm, if you're sending
> this out on the broken machine we can't rule out corrupted checksums.
> 
> And if tcpdump doesn't see the UDP replies it means that it isn't even
> reaching the device, let alone the stack.  At least that rules out
> the stack dropping UDP packets for some reason.
> 
> It's possible we've stuffed up some expectation the e1000 driver
> has for TX checksum offload.  Turn off TX checksums with
> "ethtool -K eth0 tx off" and see if that makes the problem
> go away.  Next, try "ethtool -K eth0 rx off".
> 
> I suspect skb_transport_offset() might be wrong for UDP packets
> for some reason, as that's what drivers/net/e1000/e1000_main.c
> e1000_tx_csum() depend upon.
> 
> Either that or some error in Herbert's recent checksum offload
> handling changes, such as, in fact I am highly suspicious of
> the second change listed below, you may want to try reverting
> just that one:

Bingo.

> commit 8952d6c988ec31070732117f353666a4b9a09fea
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Mon Apr 9 11:59:39 2007 -0700
> 
>     [NET]: Treat CHECKSUM_PARTIAL as CHECKSUM_UNNECESSARY
>     
>     When a transmitted packet is looped back directly, CHECKSUM_PARTIAL
>     maps to the semantics of CHECKSUM_UNNECESSARY.  Therefore we should
>     treat it as such in the stack.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> commit 7f8be19f5a5737ce6ad670756183235c71b560bb
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Mon Apr 9 11:59:07 2007 -0700
> 
>     [NET]: Use csum_start offset instead of skb_transport_header
>     
>     The skb transport pointer is currently used to specify the start
>     of the checksum region for transmit checksum offload.  Unfortunately,
>     the same pointer is also used during receive side processing.
>     
>     This creates a problem when we want to retransmit a received
>     packet with partial checksums since the skb transport pointer
>     would be overwritten.
>     
>     This patch solves this problem by creating a new 16-bit csum_start
>     offset value to replace the skb transport header for the purpose
>     of checksums.  This offset is calculated from skb->head so that
>     it does not have to change when skb->data changes.
>     
>     No extra space is required since csum_offset itself fits within
>     a 16-bit word so we can use the other 16 bits for csum_start.
>     
>     For backwards compatibility, just before we push a packet with
>     partial checksums off into the device driver, we set the skb
>     transport header to what it would have been under the old scheme.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Reverting both 8952d6c988ec31070732117f353666a4b9a09fea and
7f8be19f5a5737ce6ad670756183235c71b560bb fixes it.  Reverting only
7f8be19f5a5737ce6ad670756183235c71b560bb also fixes it.

Thanks.
