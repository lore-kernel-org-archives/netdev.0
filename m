From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: bond_alb: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Wed, 27 Aug 2014 08:15:38 -0700
Message-ID: <1409152538.3173.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140827141827.GA11520@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140827141827.GA11520@ada>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-08-27 at 17:18 +0300, Andreea-Cristina Bernat wrote:
> The "curr_active_slave" local variable obtained through the rcu_dereference()
> call it is not dereferenced in the rest of the function.
> Therefore, it is recommended to use rcu_access_pointer() instead of
> rcu_dereference().
> This patch makes the replacement.
> 
> The first step to detect this was made with the following Coccinelle semantic
> patch:
> @@
> identifier p;
> @@
> 
> * p = rcu_dereference(...)
> ... when any
>     when != p
> (
> * if( (<+...p...+>) ) { ... }
> |
> * while( (<+...p...+>) ) { ... }
> )
> ... when != p
> 
> After the analysis of the output, the change was made manually.
> 
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
> ---
>  drivers/net/bonding/bond_alb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 1319c5b..6621ac2 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -659,7 +659,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>  
>  	_lock_rx_hashtbl(bond);
>  
> -	curr_active_slave = rcu_dereference(bond->curr_active_slave);
> +	curr_active_slave = rcu_access_pointer(bond->curr_active_slave);
>  
>  	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
>  	client_info = &(bond_info->rx_hashtbl[hash_index]);


This is very error prone, for little immediate gain.

What prevents future changes to deref the pointer without sparse or
lockdep support, other than careful code review ?

I would use the __rcu attribute and eventually add _noderef suffix to
the variable name.

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 73c21e233131..4ddccc72db62 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -657,13 +657,14 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct arp_pkt *arp = arp_pkt(skb);
-	struct slave *assigned_slave, *curr_active_slave;
+	struct slave *assigned_slave;
+	struct slave __rcu *curr_active_slave;
 	struct rlb_client_info *client_info;
 	u32 hash_index = 0;
 
 	_lock_rx_hashtbl(bond);
 
-	curr_active_slave = rcu_dereference(bond->curr_active_slave);
+	curr_active_slave = bond->curr_active_slave;
 
 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
