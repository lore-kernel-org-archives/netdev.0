From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net-rfs: fix false sharing accessing sd->input_queue_head
Date: Tue, 26 Apr 2016 15:55:27 -0700
Message-ID: <CALx6S34-mbnBJcMvdZd869-dvgygkygMAZ6dNCKgGCt7atGbJA@mail.gmail.com>
References: <1461709807.5535.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36554 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbcDZWz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 18:55:28 -0400
Received: by mail-ig0-f180.google.com with SMTP id u10so56822615igr.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 15:55:28 -0700 (PDT)
In-Reply-To: <1461709807.5535.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 3:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> sd->input_queue_head is incremented for each processed packet
> in process_backlog(), and read from other cpus performing
> Out Of Order avoidance in get_rps_cpu()
>
> Moving this field in a separate cache line keeps it mostly
> hot for the cpu in process_backlog(), as other cpus will
> only read it.
>
> In a stress test, process_backlog() was consuming 6.80 % of cpu cycles,
> and the patch reduced the cost to 0.65 %
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Very nice!

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  include/linux/netdevice.h |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 18d8394f2e5d..934ca866562d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2747,11 +2747,15 @@ struct softnet_data {
>         struct sk_buff          *completion_queue;
>
>  #ifdef CONFIG_RPS
> -       /* Elements below can be accessed between CPUs for RPS */
> +       /* input_queue_head should be written by cpu owning this struct,
> +        * and only read by other cpus. Worth using a cache line.
> +        */
> +       unsigned int            input_queue_head ____cacheline_aligned_in_smp;
> +
> +       /* Elements below can be accessed between CPUs for RPS/RFS */
>         struct call_single_data csd ____cacheline_aligned_in_smp;
>         struct softnet_data     *rps_ipi_next;
>         unsigned int            cpu;
> -       unsigned int            input_queue_head;
>         unsigned int            input_queue_tail;
>  #endif
>         unsigned int            dropped;
>
>
