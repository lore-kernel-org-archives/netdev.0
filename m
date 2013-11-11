From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP performance regression
Date: Sun, 10 Nov 2013 22:54:13 -0800
Message-ID: <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	 <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.29720.673157.151074@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sujith Manoharan <sujith@msujith.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:45925 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab3KKGyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:54:15 -0500
Received: by mail-pb0-f53.google.com with SMTP id up7so4824483pbc.12
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 22:54:15 -0800 (PST)
In-Reply-To: <21120.29720.673157.151074@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 11:37 +0530, Sujith Manoharan wrote:
> Eric Dumazet wrote:
> > I am afraid this commit shows bugs in various network drivers.
> > 
> > All drivers doing TX completion using a timer are buggy.
> > 
> > Holding skb 10 ms before TX completion is totally wrong and must be fixed.
> > 
> > If really NIC is not able to trigger an interrupt after TX completion, then
> > driver should call skb_orphan() in its ndo_start_xmit()
> 
> 802.11 AMPDU formation is done in the TX completion path in ath9k.
> 
> Incoming frames are added to a software queue and the TX completion
> tasklet checks if enough frames are available to form an aggregate and
> if so, forms new aggregates and transmits them.
> 

Hmm... apparently ath9k uses :

#define ATH_AMPDU_LIMIT_MAX        (64 * 1024 - 1)

And mentions a 4ms time frame :

max_4ms_framelen = ATH_AMPDU_LIMIT_MAX;

So prior to "tcp: TSQ can use a dynamic limit", the ~128KB bytes TCP
could queue per TCP socket on qdisc/NIC would happen to please ath9k

ath9k can set rts_aggr_limit to 8*1024 :

 if (AR_SREV_9160_10_OR_LATER(ah) || AR_SREV_9100(ah))
  pCap->rts_aggr_limit = ATH_AMPDU_LIMIT_MAX; 
 else
  pCap->rts_aggr_limit = (8 * 1024);

> There is no timer involved, but the completion routine is rather heavy.
> Many wireless drivers handle 802.11 aggregation in this way:
> ath9k, ath9k_htc, ath10k etc.
> 

A timer would be definitely needed, and it should be rather small (1 or
2 ms)

If TCP socket is application limited, it seems ath9k can delay the last
block by a too long time.
