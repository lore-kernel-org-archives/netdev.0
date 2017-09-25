From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net v2] l2tp: fix race condition in l2tp_tunnel_delete
Date: Mon, 25 Sep 2017 14:33:55 +0200
Message-ID: <20170925123355.a6qof4ovgr6ksx3s@alphalink.fr>
References: <6bfc5aceda47773af4c75fe7e0e3c0d255a2342d.1505828155.git.sd@queasysnail.net>
 <20170919164337.zn3p6ikwsgnw7ba6@alphalink.fr>
 <20170922161624.GA31500@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
        Tom Parkin <tparkin@katalix.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:50561 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932814AbdIYMd7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 08:33:59 -0400
Content-Disposition: inline
In-Reply-To: <20170922161624.GA31500@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 06:16:24PM +0200, Sabrina Dubroca wrote:
> 2017-09-19, 18:43:37 +0200, Guillaume Nault wrote:
> > On Tue, Sep 19, 2017 at 03:40:40PM +0200, Sabrina Dubroca wrote:
> > > If we try to delete the same tunnel twice, the first delete operation
> > > does a lookup (l2tp_tunnel_get), finds the tunnel, calls
> > > l2tp_tunnel_delete, which queues it for deletion by
> > > l2tp_tunnel_del_work.
> > > 
> > > The second delete operation also finds the tunnel and calls
> > > l2tp_tunnel_delete. If the workqueue has already fired and started
> > > running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
> > > same tunnel a second time, and try to free the socket again.
> > > 
> > > Add a dead flag to prevent firing the workqueue twice. Then we can
> > > remove the check of queue_work's result that was meant to prevent that
> > > race but doesn't.
> > > 
> > > Also check the flag in the tunnel lookup functions, to avoid returning a
> > > tunnel that is already scheduled for destruction.
> > > 
> > > Reproducer:
> > > 
> > >     ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000 local 192.168.0.2 remote 192.168.0.1 encap udp udp_sport 5000 udp_dport 6000
> > >     ip l2tp add session name l2tp1 tunnel_id 3000 session_id 1000 peer_session_id 2000
> > >     ip link set l2tp1 up
> > >     ip l2tp del tunnel tunnel_id 3000
> > >     ip l2tp del tunnel tunnel_id 3000
> > > 
> > > Fixes: f8ccac0e4493 ("l2tp: put tunnel socket release on a workqueue")
> > > Reported-by: Jianlin Shi <jishi@redhat.com>
> > > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > > ---
> > > v2: as Tom Parkin explained, we can't remove the tunnel from the
> > >     per-net list from netlink. v2 uses only a dead flag, and adds
> > >     corresponding checks during lookups
> > > 
> > >  net/l2tp/l2tp_core.c | 18 +++++++++---------
> > >  net/l2tp/l2tp_core.h |  5 ++++-
> > >  2 files changed, 13 insertions(+), 10 deletions(-)
> > > 
> > > diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> > > index ee485df73ccd..3891f0260f2b 100644
> > > --- a/net/l2tp/l2tp_core.c
> > > +++ b/net/l2tp/l2tp_core.c
> > > @@ -203,7 +203,8 @@ struct l2tp_tunnel *l2tp_tunnel_get(const struct net *net, u32 tunnel_id)
> > >  
> > >  	rcu_read_lock_bh();
> > >  	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
> > > -		if (tunnel->tunnel_id == tunnel_id) {
> > > +		if (tunnel->tunnel_id == tunnel_id &&
> > > +		    !test_bit(0, &tunnel->dead)) {
> > >  			l2tp_tunnel_inc_refcount(tunnel);
> > >  			rcu_read_unlock_bh();
> > >  
> > > @@ -390,7 +391,8 @@ struct l2tp_tunnel *l2tp_tunnel_find(const struct net *net, u32 tunnel_id)
> > >  
> > >  	rcu_read_lock_bh();
> > >  	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
> > > -		if (tunnel->tunnel_id == tunnel_id) {
> > > +		if (tunnel->tunnel_id == tunnel_id &&
> > > +		    !test_bit(0, &tunnel->dead)) {
> > >  			rcu_read_unlock_bh();
> > >  			return tunnel;
> > >  		}
> > > @@ -409,7 +411,7 @@ struct l2tp_tunnel *l2tp_tunnel_find_nth(const struct net *net, int nth)
> > >  
> > >  	rcu_read_lock_bh();
> > >  	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
> > > -		if (++count > nth) {
> > > +		if (++count > nth && !test_bit(0, &tunnel->dead)) {
> > >  			rcu_read_unlock_bh();
> > >  			return tunnel;
> > >  		}
> > > 
> > I don't get why you're checking the dead flag in l2tp_tunnel_{get,find}*().
> > Since it can be set concurrently right after test_bit(), it doesn't
> > protect the caller from getting a tunnel that is being removed by
> > l2tp_tunnel_delete().
> > Or have I missed something?
> 
> You're right.
> 
> Then I would try going back to essentially v1, but keeping code to
> remove the tunnel from the list in l2tp_tunnel_destruct if it's not
> dead yet.
> 
> What do you think?
> 
My main question was more about why do you feel the need for preventing
other parts of the code from accessing dead tunnels? The TOCTOU issue
was just there to illustrate the fact that it couldn't be implemented
this easily.

My reasonning is that a tunnel may already be in use when
l2tp_tunnel_delete() is called. So any function using tunnels must
already work properly on dying tunnels, because l2tp_tunnel_delete()
might kill them concurrently. Getting a dying tunnel from
l2tp_tunnel_get() or having the tunnel killed by l2tp_tunnel_delete()
while in use should make no difference, as long as the user properly
holds a reference. Of course we have the problem of l2tp_tunnel_find*()
which is racy wrt. tunnel reference counting, but I'm going to continue
converting these users to the safe l2tp_tunnel_get() lookup function.

Of course, making dying tunnels inaccessible makes sense but, unless
I've missed something, it looks more like cleanup/optimisation than bug
fixing.

So what about using your v2 patch, but without the ->dead flag test in
l2tp_tunnel_get() and l2tp_tunnel_find*()?


Now for some more context, I think tunnel creation and deletion will
need to be reworked. Tunnels should be removed from the pernet list by
l2tp_udp_encap_destroy() for L2TP over UDP, and by
l2tp_ip_destroy_sock() or l2tp_ip6_destroy_sock() for L2TP over IP.

Then we could stop hooking on ->sk_destruct(), because the
l2tp_tunnel_closeall() call found in l2tp_tunnel_destruct() is already
useless (if it actually had to remove sessions, it could sleep while in
atomic context, because ->sk_destruct() is now invoked through
call_rcu() for UDP sockets).

And we should break the tight coupling of the l2tp_tunnel structure
with the tunnel socket. This situation, where they dereference one
another without any protection, complicates the deletion process.
Protecting the socket and the tunnel's structure pointers with RCU
would certainly allow for simpler deletion code.

All in all, your last patch makes a lot of sense in this bigger
picture, but for now I'd rather go for simply preventing queueing
l2tp_tunnel_del_work() twice. Unless required for accurately fixing the
current issue, I think removing tunnels in l2tp_tunnel_delete() would fit
better in a different series.

> 
> -------- 8< --------
> 
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index ee485df73ccd..63cd1f30ac7d 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1234,6 +1234,23 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
>  }
>  EXPORT_SYMBOL_GPL(l2tp_xmit_skb);
>  
> +static bool __l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
> +{
> +	struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
> +	bool ret = false;
> +
> +	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
> +	if (!tunnel->dead) {
> +		tunnel->dead = 1;
> +		list_del_rcu(&tunnel->list);
> +		atomic_dec(&l2tp_tunnel_count);
> +		ret = true;
> +	}
> +	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
> +
> +	return ret;
> +}
> +
>  /*****************************************************************************
>   * Tinnel and session create/destroy.
>   *****************************************************************************/
> @@ -1245,7 +1262,6 @@ EXPORT_SYMBOL_GPL(l2tp_xmit_skb);
>  static void l2tp_tunnel_destruct(struct sock *sk)
>  {
>  	struct l2tp_tunnel *tunnel = l2tp_tunnel(sk);
> -	struct l2tp_net *pn;
>  
>  	if (tunnel == NULL)
>  		goto end;
> @@ -1270,11 +1286,7 @@ static void l2tp_tunnel_destruct(struct sock *sk)
>  	sk->sk_user_data = NULL;
>  
>  	/* Remove the tunnel struct from the tunnel list */
> -	pn = l2tp_pernet(tunnel->l2tp_net);
> -	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
> -	list_del_rcu(&tunnel->list);
> -	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
> -	atomic_dec(&l2tp_tunnel_count);
> +	__l2tp_tunnel_delete(tunnel);
>  
>  	l2tp_tunnel_closeall(tunnel);
>  
> @@ -1685,14 +1697,12 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
>  
>  /* This function is used by the netlink TUNNEL_DELETE command.
>   */
> -int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
> +void l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
>  {
> -	l2tp_tunnel_inc_refcount(tunnel);
> -	if (false == queue_work(l2tp_wq, &tunnel->del_work)) {
> -		l2tp_tunnel_dec_refcount(tunnel);
> -		return 1;
> +	if (__l2tp_tunnel_delete(tunnel)) {
> +		l2tp_tunnel_inc_refcount(tunnel);
> +		queue_work(l2tp_wq, &tunnel->del_work);
>  	}
> -	return 0;
>  }
>  EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
>  
> diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
> index a305e0c5925a..173e68bb8119 100644
> --- a/net/l2tp/l2tp_core.h
> +++ b/net/l2tp/l2tp_core.h
> @@ -160,6 +160,8 @@ struct l2tp_tunnel_cfg {
>  
>  struct l2tp_tunnel {
>  	int			magic;		/* Should be L2TP_TUNNEL_MAGIC */
> +	int			dead;
> +
>  	struct rcu_head rcu;
>  	rwlock_t		hlist_lock;	/* protect session_hlist */
>  	bool			acpt_newsess;	/* Indicates whether this
> @@ -254,7 +256,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id,
>  		       u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg,
>  		       struct l2tp_tunnel **tunnelp);
>  void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
> -int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
> +void l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
>  struct l2tp_session *l2tp_session_create(int priv_size,
>  					 struct l2tp_tunnel *tunnel,
>  					 u32 session_id, u32 peer_session_id,
> 
> 
> -- 
> Sabrina
