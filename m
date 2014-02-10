From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v3 net 7/9] bridge: Properly check if local fdb entry
 can be deleted in br_fdb_delete_by_port
Date: Mon, 10 Feb 2014 12:37:04 -0500
Message-ID: <52F90E40.5000900@redhat.com>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1391759306-24956-8-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300AbaBJRhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 12:37:11 -0500
In-Reply-To: <1391759306-24956-8-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2014 02:48 AM, Toshiaki Makita wrote:
> br_fdb_delete_by_port() doesn't care about vlan and mac address of the
> bridge device.
> 
> As the check is almost the same as mac address changing, slightly modify
> fdb_delete_local() and use it.
> 
> Note that we can always set added_by_user to 0 in fdb_delete_local() because
> - br_fdb_delete_by_port() calls fdb_delete_local() for local entries
>   regardless of its added_by_user. In this case, we have to check if another
>   port has the same address and vlan, and if found, we have to create the
>   entry (by changing dst). This is kernel-added entry, not user-added.
> - br_fdb_changeaddr() doesn't call fdb_delete_local() for user-added entry.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  net/bridge/br_fdb.c | 25 ++++++-------------------
>  1 file changed, 6 insertions(+), 19 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 15bf13d..43e54d1 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -103,6 +103,7 @@ static void fdb_delete_local(struct net_bridge *br,
>  		if (op != p && ether_addr_equal(op->dev->dev_addr, addr) &&
>  		    (!vid || nbp_vlan_find(op, vid))) {
>  			f->dst = op;
> +			f->added_by_user = 0;
>  			return;
>  		}
>  	}
> @@ -111,6 +112,7 @@ static void fdb_delete_local(struct net_bridge *br,
>  	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
>  	    (!vid || br_vlan_find(br, vid))) {
>  		f->dst = NULL;
> +		f->added_by_user = 0;
>  		return;
>  	}
>  
> @@ -261,26 +263,11 @@ void br_fdb_delete_by_port(struct net_bridge *br,
>  
>  			if (f->is_static && !do_all)
>  				continue;
> -			/*
> -			 * if multiple ports all have the same device address
> -			 * then when one port is deleted, assign
> -			 * the local entry to other port
> -			 */
> -			if (f->is_local) {
> -				struct net_bridge_port *op;
> -				list_for_each_entry(op, &br->port_list, list) {
> -					if (op != p &&
> -					    ether_addr_equal(op->dev->dev_addr,
> -							     f->addr.addr)) {
> -						f->dst = op;
> -						f->added_by_user = 0;
> -						goto skip_delete;
> -					}
> -				}
> -			}
>  
> -			fdb_delete(br, f);
> -		skip_delete: ;
> +			if (f->is_local)
> +				fdb_delete_local(br, p, f);
> +			else
> +				fdb_delete(br, f);
>  		}
>  	}
>  	spin_unlock_bh(&br->hash_lock);
> 
