From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net v2] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Fri, 18 Aug 2017 13:52:54 -0400
Message-ID: <CAF=yD-Jup=gjVpvwuRZ4r_x7j+7_+p-GBLAYGVvoUU49Q9LTFQ@mail.gmail.com>
References: <20170818021157.20070-1-matthew@mjdsystems.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>,
        Paolo Abeni <pabeni@redhat.com>
To: Matthew Dawson <matthew@mjdsystems.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33832 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdHRRxf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:53:35 -0400
Received: by mail-oi0-f46.google.com with SMTP id x3so103851147oia.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 10:53:35 -0700 (PDT)
In-Reply-To: <20170818021157.20070-1-matthew@mjdsystems.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 10:11 PM, Matthew Dawson <matthew@mjdsystems.ca> wrote:
> Due to commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac ("udp: remove
> headers from UDP packets before queueing"), when udp packets are being
> peeked the requested extra offset is always 0 as there is no need to skip
> the udp header.  However, when the offset is 0 and the next skb is
> of length 0, it is only returned once.  The behaviour can be seen with
> the following python script:
>
> from socket import *;
> f=socket(AF_INET6, SOCK_DGRAM | SOCK_NONBLOCK, 0);
> g=socket(AF_INET6, SOCK_DGRAM | SOCK_NONBLOCK, 0);
> f.bind(('::', 0));
> addr=('::1', f.getsockname()[1]);
> g.sendto(b'', addr)
> g.sendto(b'b', addr)
> print(f.recvfrom(10, MSG_PEEK));
> print(f.recvfrom(10, MSG_PEEK));
>
> Where the expected output should be the empty string twice.
>
> Instead, make sk_peek_offset return negative values, and pass those values
> to __skb_try_recv_datagram/__skb_try_recv_from_queue.  If the passed offset
> to __skb_try_recv_from_queue is negative, the checked skb is never skipped.
> __skb_try_recv_from_queue will then ensure the offset is reset back to 0
> if a peek is requested without an offset, unless no packets are found.
>
> Also simplify the if condition in __skb_try_recv_from_queue.  If _off is
> greater then 0, and off is greater then or equal to skb->len, then
> (_off || skb->len) must always be true assuming skb->len >= 0 is always
> true.
>
> Also remove a redundant check around a call to sk_peek_offset in af_unix.c,
> as it double checked if MSG_PEEK was set in the flags.
>
> V2:
>  - Moved the negative fixup into __skb_try_recv_from_queue, and remove now
> redundant checks
>  - Fix peeking in udp{,v6}_recvmsg to report the right value when the
> offset is 0
>
> Signed-off-by: Matthew Dawson <matthew@mjdsystems.ca>

Acked-by: Willem de Bruijn <willemb@google.com>
