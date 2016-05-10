From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: refresh skb timestamp at retransmit time
Date: Tue, 10 May 2016 08:51:37 -0700
Message-ID: <1462895497.23934.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462852516.23934.46.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAK6E8=eGaBL9O55xCbtoZuuisvUGF5NRv6qV5bbvQB-JFw6Zjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32982 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbcEJPvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 11:51:39 -0400
Received: by mail-pf0-f169.google.com with SMTP id 206so7296798pfu.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 08:51:39 -0700 (PDT)
In-Reply-To: <CAK6E8=eGaBL9O55xCbtoZuuisvUGF5NRv6qV5bbvQB-JFw6Zjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-10 at 08:01 -0700, Yuchung Cheng wrote:
> On Mon, May 9, 2016 at 8:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > In the very unlikely case __tcp_retransmit_skb() can not use the cloning
> > done in tcp_transmit_skb(), we need to refresh skb_mstamp before doing
> > the copy and transmit, otherwise TCP TS val will be an exact copy of
> > original transmit.
> >
> > Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Yuchung Cheng <ycheng@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> 
> Nice catch Eric. Recovery algorithm like RACK definitely requires this
> patch b/c it relies on skb mstamps.
> does the failure usually occur under memory stress?

For x86, the NET_IP_ALIGN is 0, so the only 'problem' would happen
for devices with big MTU but no SG support.

In the normal case, we allocate small skb->head skbs
(SKB_WITH_OVERHEAD(2048 - MAX_TCP_HEADER) in select_size()

So this bug should not happen for most devices.

RACK will be better, but I was also wondering if PAWS checks on receiver
could drop all subsequent retransmits and we would have a TCP stalled
connection ? That would be a more serious bug.


For arches with NET_IP_ALIGN==2, the bug would be possible if the
receiver is playing games by partially acking the packets we send.
