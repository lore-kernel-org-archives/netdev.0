From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 11:27:26 +0200
Message-ID: <1502702846.8411.25.camel@redhat.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Macieira, Thiago" <thiago.macieira@intel.com>,
        willemdebruijn.kernel@gmail.com
To: Matthew Dawson <matthew@mjdsystems.ca>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752613AbdHNJ12 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 05:27:28 -0400
In-Reply-To: <20170814055259.31078-1-matthew@mjdsystems.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-14 at 01:52 -0400, Matthew Dawson wrote:
> Due to commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac ("udp: remove
> headers from UDP packets before queueing"), when udp packets are being
> peeked the requested extra offset is always 0 as there is no need to skip
> the udp header.  However, when the offset is 0 and the next skb is
> of length 0, it is only returned once.  The behaviour can be seen with
> the following python script:
> 
> #!/usr/bin/env python3
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
> After the call, the offset is set to 0 if negative to ensure all further
> calculations are correct.
> 
> Also simplify the if condition in __skb_try_recv_from_queue.  If _off is
> greater then 0, and off is greater then or equal to skb->len, then (_off ||
> skb->len) must always be true assuming skb->len >= 0 is always true.
> 
> Also remove a redundant check around a call to sk_peek_offset in af_unix.c,
> as it double checked if MSG_PEEK was set in the flags.
> 
> Signed-off-by: Matthew Dawson <matthew@mjdsystems.ca>
> ---
>  include/net/sock.h  | 4 +---
>  net/core/datagram.c | 4 ++--
>  net/ipv4/udp.c      | 4 ++++
>  net/ipv6/udp.c      | 4 ++++
>  net/unix/af_unix.c  | 8 +++++---
>  5 files changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 7c0632c7e870..aeeec62992ca 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -507,9 +507,7 @@ int sk_set_peek_off(struct sock *sk, int val);
>  static inline int sk_peek_offset(struct sock *sk, int flags)
>  {
>  	if (unlikely(flags & MSG_PEEK)) {
> -		s32 off = READ_ONCE(sk->sk_peek_off);
> -		if (off >= 0)
> -			return off;
> +		return READ_ONCE(sk->sk_peek_off);
>  	}
>  
>  	return 0;

You probably want/must also update sk_set_peek_off() to allow negative
values, elsewhere this will break as soon as the user will do
SOL_SOCKET/SO_PEEK_OFF.

I'm wondering adding an explicit SOCK_PEEK_OFF/MSG_PEEK_OFF socket flag
would help simplyifing the code: no need for negative offset; set such
flag when SOL_SOCKET/SO_PEEK_OFF with a non negative value is called
(and clear it when a negative value is used), forward such flag to
__skb_try_recv_datagram/__skb_try_recv_from_queue and use it to select
the proper peek behaviour.

Paolo
