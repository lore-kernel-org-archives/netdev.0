From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] net: reset gso header when the copied skb is linearized
Date: Tue, 26 Oct 2010 17:25:11 -0200
Message-ID: <20101026192511.GA3494@redhat.com>
References: <1288045398-3110-1-git-send-email-fleitner@redhat.com>
 <20101026.113157.233700961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756257Ab0JZTZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 15:25:20 -0400
Content-Disposition: inline
In-Reply-To: <20101026.113157.233700961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 11:31:57AM -0700, David Miller wrote:
> From: Flavio Leitner <fleitner@redhat.com>
> Date: Mon, 25 Oct 2010 20:23:18 -0200
> 
> > The gso header is incorrect when the copied skb is
> > linearized. This patch creates another helper function
> > to copy the gso header when it is appropriated
> > 
> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> 
> I don't understand why the GSO information should be
> omitted just because we are creating a linearlized
> version of the SKB?

If I understand that correctly, the gso_segs is the number
of GSO segments which are divided in non-linear way. When the
copy is made using that function, the skb turns into a big
one segment inlined. So, the idea of segments is lost and
I'm not seeing how it is going to be divided again. 
Later the NIC drives does, for example:

drivers/net/e1000/e1000_main.c
...
                if (cleaned) {
                        struct sk_buff *skb = buffer_info->skb;
                        unsigned int segs, bytecount;
                        segs = skb_shinfo(skb)->gso_segs ?: 1;
                        /* multiply data chunks by size of * headers */
                        bytecount = ((segs - 1) * skb_headlen(skb)) +
                                    skb->len;
                        total_tx_packets += segs;
                        total_tx_bytes += bytecount;
                }
...

The bytecount there will be wrong because it will multiply 
the old gso_segs X skb_headlen(skb) which will be the entire
skb as the payload is inlined.

I see that there are some places checking for skb_is_gso()
before do something or calculating using that math above.

> The packet still could have a larger than MSS size,
> and thus be composed of multiple actual segments for
> the network.

hopefully I answered this too in my previous comment

thanks,
-- 
Flavio
