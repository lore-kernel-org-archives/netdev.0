From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: fix behavior of wrong checksums
Date: Mon, 01 Jun 2015 23:38:10 -0700
Message-ID: <1433227090.1895.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433002613.7456.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150531.214251.957902561372382056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34751 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbFBGiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 02:38:13 -0400
Received: by ieczm2 with SMTP id zm2so126353690iec.1
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 23:38:12 -0700 (PDT)
In-Reply-To: <20150531.214251.957902561372382056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-05-31 at 21:42 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 30 May 2015 09:16:53 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > We have two problems in UDP stack related to bogus checksums :
> > 
> > 1) We return -EAGAIN to application even if receive queue is not empty.
> >    This breaks applications using edge trigger epoll()
> > 
> > 2) Under UDP flood, we can loop forever without yielding to other
> >    processes, potentially hanging the host, especially on non SMP.
> > 
> > 
> > This patch is an attempt to make things better.
> > 
> > We might in the future add extra support for rt applications
> > wanting to better control time spent doing a recv() in a hostile
> > environment. For example we could validate checksums before queuing
> > packets in socket receive queue.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Yeah this looks correct, applied and queued up for -stable.
> 
> Thanks!

Thanks David

It seems MSG_PEEK support is broken with checksums and truncated data:

Multiple threads could operate on same skb and
__udp_lib_checksum_complete() / __skb_checksum_complete() can do bad
things.

Tom, any idea how this could be fixed ? It looks you added this bug in
3.16


        /*
         * If checksum is needed at all, try to do it while copying the
         * data.  If the data is truncated, or if we only want a partial
         * coverage checksum (UDP-Lite), do it before the copy.
         */

        if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
                if (udp_lib_checksum_complete(skb))
                        goto csum_copy_err;
        }


...

__sum16 __skb_checksum_complete(struct sk_buff *skb)
{
        __wsum csum;
        __sum16 sum;

        csum = skb_checksum(skb, 0, skb->len, 0);

        /* skb->csum holds pseudo checksum */
        sum = csum_fold(csum_add(skb->csum, csum));
        if (likely(!sum)) {
                if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
                    !skb->csum_complete_sw)
                        netdev_rx_csum_fault(skb->dev);
        }

        /* Save full packet checksum */
        skb->csum = csum;
        skb->ip_summed = CHECKSUM_COMPLETE;
        skb->csum_complete_sw = 1;
        skb->csum_valid = !sum;

        return sum;
}


Maybe adding a 'readonly' bool param to __skb_checksum_complete() ?
