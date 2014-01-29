From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/ipv4: Use non-atomic allocation of udp offloads
 structure instance
Date: Wed, 29 Jan 2014 08:20:11 -0800
Message-ID: <1391012411.28432.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391011739-8597-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39988 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbaA2QUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 11:20:12 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so1862377pde.6
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 08:20:12 -0800 (PST)
In-Reply-To: <1391011739-8597-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-29 at 18:08 +0200, Or Gerlitz wrote:
> Since udp_add_offload() can be called from non-sleepable context e.g
> under this call tree from the vxlan driver use case:
> 
>   vxlan_socket_create() <-- holds the spinlock
>   -> vxlan_notify_add_rx_port()
>      -> udp_add_offload()  <-- schedules
> 
> we should allocate the udp_offloads structure in atomic manner.
> 
> Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  net/ipv4/udp_offload.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 25f5cee..2ffea6f 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -101,7 +101,7 @@ out:
>  int udp_add_offload(struct udp_offload *uo)
>  {
>  	struct udp_offload_priv __rcu **head = &udp_offload_base;
> -	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_KERNEL);
> +	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_ATOMIC);
>  
>  	if (!new_offload)
>  		return -ENOMEM;

Could you also fix all the rcu_dereference() calls ?

Try CONFIG_PROVE_RCU=y
