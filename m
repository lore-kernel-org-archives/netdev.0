From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 22:23:53 -0700
Message-ID: <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Crestez Dan Leonard <cdleonard@gmail.com>, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36671 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbaJWFXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 01:23:55 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so384373pdj.27
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 22:23:54 -0700 (PDT)
In-Reply-To: <544886C4.4020702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 22:40 -0600, David Ahern wrote:
> On 10/22/14, 12:55 PM, Crestez Dan Leonard wrote:
> > Hello,
> >
> > It seems that the TCP MD5 feature allocates a percpu struct tcp_md5sig_pool and uses part of that memory for a scratch buffer to do crypto on. Here is the relevant code:
> 
> This is a forward port of a local change to address the problem (local 
> kernel version is 3.4 so perhaps my quick bump to top of tree is off but 
> it shows the general idea). Been on my to-do list to figure out why this 
> is needed, but it seems related to your problem:
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1bec4e76d88c..833a676bd4b0 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2941,7 +2941,7 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
>      local_bh_disable();
>      p = ACCESS_ONCE(tcp_md5sig_pool);
>      if (p)
> -       return raw_cpu_ptr(p);
> +       return __va(per_cpu_ptr_to_phys(raw_cpu_ptr(p)));
> 
>      local_bh_enable();
>      return NULL;

per_cpu_ptr_to_phys() can be pretty expensive and should not be called
in fast path.
