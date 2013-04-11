From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] tcp: Reallocate headroom if it would overflow csum_start
Date: Thu, 11 Apr 2013 16:41:43 +0400
Message-ID: <5166AF87.1000404@cogentembedded.com>
References: <c35c262084e8907098dc2db5ea9690d2119b4916.1365678820.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:59270 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab3DKMmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 08:42:47 -0400
Received: by mail-la0-f46.google.com with SMTP id ea20so1433928lab.19
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 05:42:46 -0700 (PDT)
In-Reply-To: <c35c262084e8907098dc2db5ea9690d2119b4916.1365678820.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11-04-2013 15:19, Thomas Graf wrote:

> If a TCP retransmission gets partially ACKed and collapsed multiple
> times it is possible for the headroom to grow beyond 64K which will
> overflow the 16bit skb->csum_start which is based on the start of
> the headroom. It has been observed rarely in the wild with IPoIB due
> to the 64K MTU.

> Verify if the acking and collapsing resulted in a headroom exceeding
> what csum_start can cover and reallocate the headroom if so.

> LLNL has been running the patch for a while and has not seen the
> problem occur since.

> A big thank you to Jim Foraker <foraker1@llnl.gov> and the team at
> LLNL for helping out with the investigation and testing.

> Reported-by: Jim Foraker <foraker1@llnl.gov>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
[...]

    Minor formatting nit.

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index b44cf81..bf6ceb7 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2388,8 +2388,11 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
>   	 */
>   	TCP_SKB_CB(skb)->when = tcp_time_stamp;
>
> -	/* make sure skb->data is aligned on arches that require it */
> -	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3))) {
> +	/* make sure skb->data is aligned on arches that require it
> +	 * and check if ack-trimming & collapsing extended the headroom
> +	 * beyond what csum_start can cover. */

    The preferred multi-line comment style in the networking code:

/* bla
  * bla
  */

WBR, Sergei
