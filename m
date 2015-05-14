From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: fix warnings in rollover lock
 contention
Date: Thu, 14 May 2015 08:33:54 -0700
Message-ID: <1431617634.27831.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431614560-8866-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33676 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932997AbbENPd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 11:33:57 -0400
Received: by pdbnk13 with SMTP id nk13so90667575pdb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 08:33:56 -0700 (PDT)
In-Reply-To: <1431614560-8866-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 10:42 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Avoid two xchg calls whose return values were unused, causing this
> warning on some architectures:
> 
>     warning: value computed is not used [-Wunused-value]
>     #define xchg(ptr,x) ((__typeof__(*(ptr)))\
>         __xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
>                        ^
>     net/packet/af_packet.c:1314:3: note: in expansion of macro 'xchg'
>     xchg(&po->pressure, !has_room);
> 
> The relevant variable is a hint to avoid lock contention. It is
> allowed to be imprecise (race).
> 
> Still, when rewriting this, also convert to use explicit atomic ops
> and remove a race by switching to atomic_cmpxchg. A rerun of the
> experiment from the original patch did not show this to cause
> significant cache line contention. Another non-atomic conditional
> clear remains in packet_poll, and is safe.
> 
> Fixes: 2ccdbaa6d55b ("packet: rollover lock contention avoidance")
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/packet/af_packet.c | 12 ++++++------
>  net/packet/internal.h  |  2 +-
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 31d5856..ac1a589 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1310,8 +1310,7 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
>  	}
>  
>  	has_room = ret == ROOM_NORMAL;
> -	if (po->pressure == has_room)
> -		xchg(&po->pressure, !has_room);
> +	if (atomic_cmpxchg(&po->pressure, has_room, !has_room)) {}
>  

This makes no sense to me.

I thought you wanted to avoid dirtying the cache line.

No atomic op can help the race here.
