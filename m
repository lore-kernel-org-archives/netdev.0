From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v2 01/12] bnxt_en: Refactor rx SKB function.
Date: Thu, 2 Feb 2017 16:22:23 -0800
Message-ID: <20170202162223.1b70e664@cakuba.netronome.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
        <1486054540-366-2-git-send-email-michael.chan@broadcom.com>
        <20170202145655.6b1ae712@cakuba.netronome.com>
        <CACKFLi=-=zxXQSKViU7kgappPdedBjSum=TBiwPjKTo4ZhEY1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:41513 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751512AbdBCAWl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 19:22:41 -0500
In-Reply-To: <CACKFLi=-=zxXQSKViU7kgappPdedBjSum=TBiwPjKTo4ZhEY1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Feb 2017 15:40:19 -0800, Michael Chan wrote:
> On Thu, Feb 2, 2017 at 2:56 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> > On Thu,  2 Feb 2017 11:55:29 -0500, Michael Chan wrote:  
> >> @@ -755,8 +757,8 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
> >>
> >>  static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
> >>                                  struct bnxt_rx_ring_info *rxr, u16 cons,
> >> -                                u16 prod, u8 *data, dma_addr_t dma_addr,
> >> -                                unsigned int len)
> >> +                                u16 prod, void *data, dma_addr_t dma_addr,
> >> +                                unsigned int offset_and_len)
> >>  {
> >>       int err;
> >>       struct sk_buff *skb;
> >> @@ -776,7 +778,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
> >>       }
> >>
> >>       skb_reserve(skb, BNXT_RX_OFFSET);
> >> -     skb_put(skb, len);
> >> +     skb_put(skb, offset_and_len & 0xffff);
> >>       return skb;
> >>  }
> >>  
> >
> > Sorry to be a pain but I still don't understand (a) why you make this
> > change in the first patch if it's only needed from patch 5 on;  
> 
> Because I'm thinking ahead.  The function is now a function pointer
> and I want to make the parameter change now.

You're thinking ahead, reviewers have to guess ahead :)

> > (b) why
> > do you encode the two parameters in a single u32?  It's the seventh
> > parameter so it's going on the stack anyway, no?  
> 
> Both the length and the offset come from the hardware's rx completion
> record.  Both are u16.  The offset happens to be in the upper 16-bit
> in the hardware record.  So it is convenient to encode it like this
> and I chose to do it like this. Of course, using a separate parameter
> will also work.

Yes, I initially thought you read them out this way straight from the
descriptor but you actually combine them into this form:

+		unsigned int payload_len;
+
+		payload_len = (le32_to_cpu(rxcmp->rx_cmp_misc_v1) &
+			       RX_CMP_PAYLOAD_OFFSET) | len;
+		skb = bp->rx_skb_func(bp, rxr, cons, prod, data, dma_addr,

I don't mind though, I was just hoping this is some clever optimization
technique I could learn :)
