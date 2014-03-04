From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt context.
Date: Mon, 3 Mar 2014 20:23:03 -0800
Message-ID: <CAM_iQpUo7LDcXqKxpZwKjx_KX6R2hVcyHx3GJnYxEg+9Nez0Rg@mail.gmail.com>
References: <874n3fow2i.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Satyam Sharma <satyam.sharma@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:51439 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755944AbaCDEXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 23:23:06 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so4260319oah.15
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 20:23:04 -0800 (PST)
In-Reply-To: <874n3fow2i.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 3, 2014 at 12:40 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>  net/core/netpoll.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index a664f7829a6d..a1877621bf31 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -330,7 +330,7 @@ repeat:
>                 skb = skb_dequeue(&skb_pool);
>
>         if (!skb) {
> -               if (++count < 10) {
> +               if (++count < 10 && !in_irq()) {
>                         netpoll_poll_dev(np->dev);

This looks like a workaround.

Here ou are trying to avoid calling netpoll_poll_dev()
in IRQ context, but it has a side effect for netpoll_send_udp()
which could possibly return early after find_skb().

Also, netpoll_poll_dev() does more than just calling driver
poll method, I am not sure if it is safe to skip it either.

netpoll code needs to rewrite.

Thanks.
