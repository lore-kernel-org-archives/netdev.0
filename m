From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net v2] l2tp: fix race condition in l2tp_tunnel_delete
Date: Tue, 19 Sep 2017 18:43:37 +0200
Message-ID: <20170919164337.zn3p6ikwsgnw7ba6@alphalink.fr>
References: <6bfc5aceda47773af4c75fe7e0e3c0d255a2342d.1505828155.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
        Tom Parkin <tparkin@katalix.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:37692 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdISQnn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:43:43 -0400
Content-Disposition: inline
In-Reply-To: <6bfc5aceda47773af4c75fe7e0e3c0d255a2342d.1505828155.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 03:40:40PM +0200, Sabrina Dubroca wrote:
> If we try to delete the same tunnel twice, the first delete operation
> does a lookup (l2tp_tunnel_get), finds the tunnel, calls
> l2tp_tunnel_delete, which queues it for deletion by
> l2tp_tunnel_del_work.
> 
> The second delete operation also finds the tunnel and calls
> l2tp_tunnel_delete. If the workqueue has already fired and started
> running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
> same tunnel a second time, and try to free the socket again.
> 
> Add a dead flag to prevent firing the workqueue twice. Then we can
> remove the check of queue_work's result that was meant to prevent that
> race but doesn't.
> 
> Also check the flag in the tunnel lookup functions, to avoid returning a
> tunnel that is already scheduled for destruction.
> 
> Reproducer:
> 
>     ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000 local 192.168.0.2 remote 192.168.0.1 encap udp udp_sport 5000 udp_dport 6000
>     ip l2tp add session name l2tp1 tunnel_id 3000 session_id 1000 peer_session_id 2000
>     ip link set l2tp1 up
>     ip l2tp del tunnel tunnel_id 3000
>     ip l2tp del tunnel tunnel_id 3000
> 
> Fixes: f8ccac0e4493 ("l2tp: put tunnel socket release on a workqueue")
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> v2: as Tom Parkin explained, we can't remove the tunnel from the
>     per-net list from netlink. v2 uses only a dead flag, and adds
>     corresponding checks during lookups
> 
>  net/l2tp/l2tp_core.c | 18 +++++++++---------
>  net/l2tp/l2tp_core.h |  5 ++++-
>  2 files changed, 13 insertions(+), 10 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index ee485df73ccd..3891f0260f2b 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -203,7 +203,8 @@ struct l2tp_tunnel *l2tp_tunnel_get(const struct net *net, u32 tunnel_id)
>  
>  	rcu_read_lock_bh();
>  	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
> -		if (tunnel->tunnel_id == tunnel_id) {
> +		if (tunnel->tunnel_id == tunnel_id &&
> +		    !test_bit(0, &tunnel->dead)) {
>  			l2tp_tunnel_inc_refcount(tunnel);
>  			rcu_read_unlock_bh();
>  
> @@ -390,7 +391,8 @@ struct l2tp_tunnel *l2tp_tunnel_find(const struct net *net, u32 tunnel_id)
>  
>  	rcu_read_lock_bh();
>  	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
> -		if (tunnel->tunnel_id == tunnel_id) {
> +		if (tunnel->tunnel_id == tunnel_id &&
> +		    !test_bit(0, &tunnel->dead)) {
>  			rcu_read_unlock_bh();
>  			return tunnel;
>  		}
> @@ -409,7 +411,7 @@ struct l2tp_tunnel *l2tp_tunnel_find_nth(const struct net *net, int nth)
>  
>  	rcu_read_lock_bh();
>  	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
> -		if (++count > nth) {
> +		if (++count > nth && !test_bit(0, &tunnel->dead)) {
>  			rcu_read_unlock_bh();
>  			return tunnel;
>  		}
> 
I don't get why you're checking the dead flag in l2tp_tunnel_{get,find}*().
Since it can be set concurrently right after test_bit(), it doesn't
protect the caller from getting a tunnel that is being removed by
l2tp_tunnel_delete().
Or have I missed something?
