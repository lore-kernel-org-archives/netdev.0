From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: fix kfree static array pointer in
 ipv4_sysctl_exit_net
Date: Thu, 08 May 2014 05:34:45 -0700
Message-ID: <1399552485.7973.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <536B34FD.8030601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:49427 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbaEHMes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 08:34:48 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so2835928pab.1
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 05:34:48 -0700 (PDT)
In-Reply-To: <536B34FD.8030601@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-08 at 15:40 +0800, Wang Weidong wrote:
> In ipv4_sysctl_init_net, we don't kmemdup a sysctl_table for init_net,
> so init_net->ipv4.ipv4_hdr->ctl_table_arg points to ipv4_net_table which
> is a static array pointer. So when do ipv4_sysctl_exit_net, it will
> free the ipv4_net_table for init_net.
> 
> So add a check net_namespace init_net before kfree the sysctl_table.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/ipv4/sysctl_net_ipv4.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 44eba05..2825577 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -891,7 +891,8 @@ static __net_exit void ipv4_sysctl_exit_net(struct net *net)
>  
>  	table = net->ipv4.ipv4_hdr->ctl_table_arg;
>  	unregister_net_sysctl_table(net->ipv4.ipv4_hdr);
> -	kfree(table);
> +	if (!net_eq(net, &init_net))
> +		kfree(table);
>  }
>  
>  static __net_initdata struct pernet_operations ipv4_sysctl_ops = {

Could you explain how you can trigger this case, calling
ipv4_sysctl_exit_net() with net == &init_net ?

This would be a bug, your patch would try to hide it maybe ?
