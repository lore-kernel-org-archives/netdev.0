From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] packet: avoid out of bounds read in round robin fanout
Date: Wed, 17 Jun 2015 15:09:28 +0300
Message-ID: <55816378.1020602@cogentembedded.com>
References: <1434488879-10663-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com
To: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:36753 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827AbbFQMJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 08:09:30 -0400
Received: by lbbqq2 with SMTP id qq2so30150872lbb.3
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 05:09:29 -0700 (PDT)
In-Reply-To: <1434488879-10663-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/17/2015 12:07 AM, Willem de Bruijn wrote:

> From: Willem de Bruijn <willemb@google.com>

> PACKET_FANOUT_LB computes f->rr_cur such that it is modulo
> f->num_members. It returns the old value unconditionally, but
> f->num_members may have changed since the last store. This can be
> fixed with

>    -        return cur
>    +        return cur < num ? : 0;

> When modifying the logic, simplify it further by replacing the loop
> with an unconditional atomic increment.

> Fixes: dc99f600698d ("packet: Add fanout support.")
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>   net/packet/af_packet.c | 19 ++-----------------
>   1 file changed, 2 insertions(+), 17 deletions(-)

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index b5989c6..efd35e8 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
[...]
> @@ -1293,13 +1283,8 @@ static unsigned int fanout_demux_lb(struct packet_fanout *f,
>   				    struct sk_buff *skb,
>   				    unsigned int num)
>   {
> -	int cur, old;
> -
> -	cur = atomic_read(&f->rr_cur);
> -	while ((old = atomic_cmpxchg(&f->rr_cur, cur,
> -				     fanout_rr_next(f, num))) != cur)
> -		cur = old;
> -	return cur;
> +	unsigned int val = atomic_inc_return(&f->rr_cur);

    Please insert an empty line after declaration, as it was before your patch.

> +	return val % num;
>   }
[...]

WBR, Sergei
