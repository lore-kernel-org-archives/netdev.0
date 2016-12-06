From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 06:34:41 -0800
Message-ID: <1481034881.18162.577.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481017989.6225.21.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32887 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753266AbcLFOeo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 09:34:44 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so20067807pgd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 06:34:43 -0800 (PST)
In-Reply-To: <1481017989.6225.21.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 10:53 +0100, Paolo Abeni wrote:
> Hi Eric,

> I don't understand why we can avoid setting skb->peek if len > 0. I
> think that will change the kernel behavior if:
> - peek with offset is set
> - 3 skbs with len > 0 are enqueued
> - the u/s peek (with offset) the second one
> - the u/s disable peeking with offset and peeks 2 more skbs.
> 
> With the current code in the last step the u/s is going to peek the 1#
> and the 3# skbs, after this patch will peek the 1# and the 2#. Am I
> missing something ? Probably the new behavior is more correct, but still
> is a change. 
> 
> I gave this a run in my test bed on top of your udp-related patches I
> see additional ~3 improvement in the udp flood scenario, and a bit more
> in the un-contended scenario.
> 
> Thank you,

MSG_PEEK always grab the first skb in queue, regardless of its
skb->peeked status.

Unless an offset (given in bytes) is given. Then we skip X bytes in the
queue, again regardless of skb->peeked bit.

skb->peeked is _needed_ to avoid peeking the same 0-byte skb over and
over, since user land could not skip it, as the offset to skip skbs is
computed by sum ( lengthes). An infinite loop of recvmsg() would happen,
stuck on the same skb.

For regular non 0-bytes payload, we can skip over them without even
looking at skb->peeked.

Initially, skb->peeked was only a (bad) way to make sure UDP would
increment its stats only for non peeked messages. We can implement that
using at MSG_PEEK flag.
