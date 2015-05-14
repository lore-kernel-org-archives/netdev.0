From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rocker: fix a neigh entry leak issue
Date: Thu, 14 May 2015 07:06:22 -0700
Message-ID: <1431612382.27831.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431587190-28901-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35508 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933275AbbENOGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 10:06:24 -0400
Received: by igbyr2 with SMTP id yr2so167819599igb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 07:06:24 -0700 (PDT)
In-Reply-To: <1431587190-28901-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 15:06 +0800, Ying Xue wrote:
> Once we get a neighbour through looking up arp cache or creating a
> new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
> already taken. But we don't put the refcount again after it's used,
> which make the neighbour entry leaked.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 1fc006b..7504540 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3053,6 +3053,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
>  	else
>  		neigh_event_send(n, NULL);
>  
> +	neigh_release(n);
>  	return err;
>  }
>  

I do not think this fix is complete.

neigh_create() can return an error, and we'll crash.

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index f0a9cb44be6bedc2171f6c9f79200cfa5d0bb0fa..ff0befbd8b4351c6f8fef93513967d5450d29e64 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3037,11 +3037,11 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
 	int err = 0;
 
-	if (!n)
+	if (!n) {
 		n = neigh_create(&arp_tbl, &ip_addr, dev);
-	if (!n)
-		return -ENOMEM;
-
+		if (IS_ERR(n))
+			return PTR_ERR(n);
+	}
 	/* If the neigh is already resolved, then go ahead and
 	 * install the entry, otherwise start the ARP process to
 	 * resolve the neigh.
