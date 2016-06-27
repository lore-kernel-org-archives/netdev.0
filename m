From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Mon, 27 Jun 2016 11:31:01 -0700
Message-ID: <CAM_iQpU8H-decpeKbFd05Wt9mWsdpb+Yp=VLNrTHv8gPnJCWbQ@mail.gmail.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com> <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36019 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbcF0SbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:31:22 -0400
Received: by mail-qk0-f195.google.com with SMTP id r136so12860721qke.3
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:31:21 -0700 (PDT)
In-Reply-To: <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 9:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 5c7ed147449c1b7ba029b12e033ad779a631460a..fddc0ab799996c1df82cb05dba03271b773e3b2d 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2969,8 +2969,18 @@ static void __tcp_alloc_md5sig_pool(void)
>                 return;
>
>         for_each_possible_cpu(cpu) {
> +               void *scratch = per_cpu(tcp_md5sig_pool, cpu).scratch;
>                 struct ahash_request *req;
>
> +               if (!scratch) {
> +                       scratch = kmalloc_node(sizeof(union tcp_md5sum_block) +
> +                                              sizeof(struct tcphdr),
> +                                              GFP_KERNEL,
> +                                              cpu_to_node(cpu));
> +                       if (!scratch)
> +                               return;
> +                       per_cpu(tcp_md5sig_pool, cpu).scratch = scratch;
> +               }
>                 if (per_cpu(tcp_md5sig_pool, cpu).md5_req)
>                         continue;

Not a problem of your patch, but it seems these allocations never
get freed once we start using tcp md5. Maybe we should free them
when the last socket using tcp md5 is gone?
