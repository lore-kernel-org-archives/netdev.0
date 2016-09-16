From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCHv3 next 3/3] ipvlan: Introduce l3s mode
Date: Thu, 15 Sep 2016 19:49:16 -0600
Message-ID: <037780fb-984c-cc69-969e-2c98bc406dc9@cumulusnetworks.com>
References: <1473984847-32243-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34212 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753174AbcIPBtT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 21:49:19 -0400
Received: by mail-pf0-f169.google.com with SMTP id p64so22216537pfb.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 18:49:18 -0700 (PDT)
In-Reply-To: <1473984847-32243-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/16 6:14 PM, Mahesh Bandewar wrote:
> diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
> index 695a5dc9ace3..371f4548c42d 100644
> --- a/drivers/net/ipvlan/ipvlan.h
> +++ b/drivers/net/ipvlan/ipvlan.h
> @@ -23,11 +23,13 @@
>  #include <linux/if_vlan.h>
>  #include <linux/ip.h>
>  #include <linux/inetdevice.h>
> +#include <linux/netfilter.h>
>  #include <net/ip.h>
>  #include <net/ip6_route.h>
>  #include <net/rtnetlink.h>
>  #include <net/route.h>
>  #include <net/addrconf.h>
> +#include <net/l3mdev.h>
>  
>  #define IPVLAN_DRV	"ipvlan"
>  #define IPV_DRV_VER	"0.1"
> @@ -96,6 +98,7 @@ struct ipvl_port {
>  	struct work_struct	wq;
>  	struct sk_buff_head	backlog;
>  	int			count;
> +	bool			hooks_attached;

With a refcnt on the hook registration you don't need this bool and removing simplifies the set_mode logic.


> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 18b4e8c7f68a..aca690f41559 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c

....

> +static void ipvlan_unregister_nf_hook(void)
> +{
> +	BUG_ON(!ipvl_nf_hook_refcnt);

not a panic() worthy issue. just a pr_warn or WARN_ON_ONCE should be ok.
