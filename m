From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Wed, 07 Dec 2016 07:59:32 -0800
Message-ID: <1481126372.4930.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481049061.7129.18.camel@redhat.com>
         <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481051786.7129.22.camel@redhat.com>
         <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481093247.18162.637.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481097428.5535.12.camel@redhat.com>
         <1481120956.4930.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33695 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932228AbcLGQAe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 11:00:34 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so23894193pgd.0
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 08:00:34 -0800 (PST)
In-Reply-To: <1481120956.4930.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 06:29 -0800, Eric Dumazet wrote:

> Keeping frag_list means you keep one sk_buff per segment, so this really
> looks like a legacy UDP server (like a DNS server) wont benefit from
> this anyway.

I played with the idea of preparing the skb for minimal overhead for the
process doing udp_recvmsg().

If socket is under pressure, softirq handler(s) can try to pull in
skb->head the payload of the packet if it fits.

Meaning the softirq handler can free/reuse the page fragment
immediately, instead of letting udp_recvmsg() do this hundreds of usec
later.

( Sort of copybreak, but without reallocating skb->head )

Gains :
- We reduce skb->truesize and thus can store more packets per SO_RCVBUF
 KB
- We avoid a cache line misses at copyout() time and consume_skb() time,
and avoid one put_page() with potential alien freeing on NUMA hosts.
