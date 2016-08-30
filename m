From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] l2tp: fix use-after-free during module unload
Date: Tue, 30 Aug 2016 20:51:03 +0300
Message-ID: <1083fbde-2227-2539-f855-a6311d20f813@cogentembedded.com>
References: <f30d3c9f96a7de81af18061ac61a2d24ef179bf8.1472557704.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35251 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933146AbcH3RvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:51:08 -0400
Received: by mail-lf0-f50.google.com with SMTP id f93so19368260lfi.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:51:07 -0700 (PDT)
In-Reply-To: <f30d3c9f96a7de81af18061ac61a2d24ef179bf8.1472557704.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/30/2016 05:05 PM, Sabrina Dubroca wrote:

> Tunnel deletion is delayed by both a workqueue (l2tp_tunnel_delete -> wq
>  -> l2tp_tunnel_del_work) and RCU (sk_destruct -> RCU ->
> l2tp_tunnel_destruct).
>
> By the time l2tp_tunnel_destruct() runs to destroy the tunnel and finish
> destroying the socket, the private data reserved via the net_generic
> mechanism has already been freed, but l2tp_tunnel_destruct() actually
> uses this data.
>
> Make sure tunnel deletion for the netns has completed before returning
> from l2tp_net_exit() by first flushing the tunnel removal workqueue, and

    The patch tells me the function is named l2tp_exit_net(). :-)

> then waiting for RCU callbacks to complete.
>
> Fixes: 167eb17e0b17 ("l2tp: create tunnel sockets in the right namespace")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>  net/l2tp/l2tp_core.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 1e40dacaa137..a2ed3bda4ddc 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1855,6 +1855,9 @@ static __net_exit void l2tp_exit_net(struct net *net)
>  		(void)l2tp_tunnel_delete(tunnel);
>  	}
>  	rcu_read_unlock_bh();
> +
> +	flush_workqueue(l2tp_wq);
> +	rcu_barrier();
>  }
>
>  static struct pernet_operations l2tp_net_ops = {

MBR, Sergei
