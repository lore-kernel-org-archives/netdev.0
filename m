From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: rps: Add the rfs_needed check when record
 flow hash
Date: Thu, 25 May 2017 07:55:03 -0700
Message-ID: <1495724103.6465.98.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1495611359-118199-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35168 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757320AbdEYOzH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 10:55:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id u26so39786100pfd.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 07:55:07 -0700 (PDT)
In-Reply-To: <1495611359-118199-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-24 at 15:35 +0800, gfree.wind@vip.163.com wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
> 
> There are two spots which invoke the sock_rps_record_flow_hash, one is
> sock_rps_record_flow which has already checked rfs_needed. But the other
> is tun_flow_update which doesn't check if the rfs is enabled.
> 
> Now rename the original function sock_rps_record_flow_hash to
> _sock_rps_record_flow_hash, and add one helper func which checks the
> rfs_needed.
> 
> The perf result of two functions is following.
> When rfs is disabled, it could enhance 58% performance with checking
> rfs_needed.
> When rfs is enabled, the performanc is lower than current about 29%.
> 
> Because the RFS is disabled by default. I think it is useful to tun
> driver.
> 
> The follow is test statistics.

> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> ---
>  include/net/sock.h | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 3467d9e..584bb9a 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -910,7 +910,7 @@ static inline void sk_incoming_cpu_update(struct sock *sk)
>  	sk->sk_incoming_cpu = raw_smp_processor_id();
>  }
>  
> -static inline void sock_rps_record_flow_hash(__u32 hash)
> +static inline void _sock_rps_record_flow_hash(__u32 hash)
>  {
>  #ifdef CONFIG_RPS
>  	struct rps_sock_flow_table *sock_flow_table;
> @@ -922,6 +922,14 @@ static inline void sock_rps_record_flow_hash(__u32 hash)
>  #endif
>  }
>  
> +static inline void sock_rps_record_flow_hash(__u32 hash)
> +{
> +#ifdef CONFIG_RPS
> +	if (static_key_false(&rfs_needed))
> +		_sock_rps_record_flow_hash(hash);
> +#endif

Seems that after your patch, sock_rps_record_flow_hash() is no longer
needed/used.
