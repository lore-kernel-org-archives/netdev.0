From: David Ahern <dsahern@gmail.com>
Subject: Re: [Patch net] ipv6: reorder ip6_route_dev_notifier after
 ipv6_dev_notf
Date: Thu, 4 May 2017 08:04:51 -0600
Message-ID: <a127b7fe-82a7-53e9-8df4-704f1b295ada@gmail.com>
References: <1493874452-3050-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32939 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754983AbdEDOEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 10:04:53 -0400
Received: by mail-pf0-f193.google.com with SMTP id b23so2237248pfc.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 07:04:53 -0700 (PDT)
In-Reply-To: <1493874452-3050-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 11:07 PM, Cong Wang wrote:
> For each netns (except init_net), we initialize its null entry
> in 3 places:
> 
> 1) The template itself, as we use kmemdup()
> 2) Code around dst_init_metrics() in ip6_route_net_init()
> 3) ip6_route_dev_notify(), which is supposed to initialize it after
> loopback registers
> 
> Unfortunately the last one still happens in a wrong order because
> we expect to initialize net->ipv6.ip6_null_entry->rt6i_idev to
> net->loopback_dev's idev, so we have to do that after we add
> idev to it. However, this notifier has priority == 0 same as
> ipv6_dev_notf, and ipv6_dev_notf is registered after
> ip6_route_dev_notifier so it is called actually after
> ip6_route_dev_notifier.
> 
> Fix it by specifying a smaller priority for ip6_route_dev_notifier.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 2f11366..4dbf7e2 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -4024,7 +4024,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
>  
>  static struct notifier_block ip6_route_dev_notifier = {
>  	.notifier_call = ip6_route_dev_notify,
> -	.priority = 0,
> +	.priority = -10, /* Must be called after addrconf_notify!! */
>  };
>  
>  void __init ip6_route_init_special_entries(void)
> 

And I see a refcnt problem with this change:

root@kenny-jessie2:~# unshare -n
root@kenny-jessie2:~# logout
root@kenny-jessie2:~# unshare -n

Message from syslogd@kenny-jessie2 at May  4 07:04:38 ...
 kernel:[   62.581552] unregister_netdevice: waiting for lo to become
free. Usage count = 1
