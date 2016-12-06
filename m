From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Free the port memory
 directly with kfree instead of kfree_rcu
Date: Mon, 05 Dec 2016 22:25:11 -0800
Message-ID: <1481005511.18162.564.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480998547-9013-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36542 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbcLFGZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 01:25:13 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so18843319pgx.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 22:25:13 -0800 (PST)
In-Reply-To: <1480998547-9013-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 12:29 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> There is no one which may reference the "port" in ipvlan_port_create
> when netdev_rx_handler_register failed. So it could free it directly
> with kfree instead of kfree_rcu.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/ipvlan/ipvlan_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index c6aa667..1a601151 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -128,7 +128,7 @@ static int ipvlan_port_create(struct net_device *dev)
>  	return 0;
>  
>  err:
> -	kfree_rcu(port, rcu);
> +	kfree(port);
>  	return err;
>  }
>  

This looks a partial patch.

If you really care, why don't you also replace the kfree_rcu() in
ipvlan_port_destroy() ?



diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 05a62d2216c54651f6158c35d446d2e395b38dc3..031093e1c25f55244e6bdfde4ebeb65c0f2f10c1 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -97,7 +97,6 @@ struct ipvl_port {
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
 	int			count;
-	struct rcu_head		rcu;
 };
 
 static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 5430460167b5e8945d29a3febdd324461bf5af5c..ffe8994e64fc1791ef07d80ad2340bc82d541bba 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -128,7 +128,7 @@ static int ipvlan_port_create(struct net_device *dev)
 	return 0;
 
 err:
-	kfree_rcu(port, rcu);
+	kfree(port);
 	return err;
 }
 
@@ -145,7 +145,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	netdev_rx_handler_unregister(dev);
 	cancel_work_sync(&port->wq);
 	__skb_queue_purge(&port->backlog);
-	kfree_rcu(port, rcu);
+	kfree(port);
 }
 
 #define IPVLAN_FEATURES \
