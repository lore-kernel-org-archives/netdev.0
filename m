From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: core: Traverse the adjacency list from
 first entry
Date: Wed, 26 Oct 2016 09:05:35 -0600
Message-ID: <0ddd89b6-a9ec-29b5-2e0a-18d11fac5e4e@cumulusnetworks.com>
References: <1477463962-2802-1-git-send-email-idosch@idosch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>
To: idosch@idosch.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33861 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932601AbcJZPFi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 11:05:38 -0400
Received: by mail-pf0-f170.google.com with SMTP id n85so24738458pfi.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 08:05:38 -0700 (PDT)
In-Reply-To: <1477463962-2802-1-git-send-email-idosch@idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/16 12:39 AM, idosch@idosch.org wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> netdev_next_lower_dev() returns NULL when we finished traversing the
> adjacency list ('iter' points to the list's head). Therefore, we must
> start traversing the list from the first entry and not its head.
> 
> Fixes: 1a3f060c1a47 ("net: Introduce new api for walking upper and lower devices")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> ---
>  net/core/dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f55fb45..d9c937f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5419,7 +5419,7 @@ int netdev_walk_all_lower_dev(struct net_device *dev,
>  	struct list_head *iter;
>  	int ret;
>  
> -	for (iter = &dev->adj_list.lower,
> +	for (iter = dev->adj_list.lower.next,
>  	     ldev = netdev_next_lower_dev(dev, &iter);
>  	     ldev;
>  	     ldev = netdev_next_lower_dev(dev, &iter)) {
> 

How about this instead? It keeps the 3 walk functions in sync modulo the rcu reference:


diff --git a/net/core/dev.c b/net/core/dev.c
index f55fb4536016..6aa43cd8cbb5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5400,12 +5400,12 @@ static struct net_device *netdev_next_lower_dev(struct net_device *dev,
 {
	struct netdev_adjacent *lower;

-	lower = list_entry(*iter, struct netdev_adjacent, list);
+	lower = list_entry((*iter)->next, struct netdev_adjacent, list);

 	if (&lower->list == &dev->adj_list.lower)
 		return NULL;

-	*iter = lower->list.next;
+	*iter = &lower->list;

 	return lower->dev;
 }
