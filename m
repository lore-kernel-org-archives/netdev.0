From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH v2] net: tipc: Convert timers to use timer_setup()
Date: Tue, 31 Oct 2017 07:14:20 +0000
Message-ID: <AM4PR07MB17146B505C31DD782450257E9A5E0@AM4PR07MB1714.eurprd07.prod.outlook.com>
References: <20171030210645.GA57228@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ying Xue <ying.xue@windriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030210645.GA57228@beast>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked.

///jon


> -----Original Message-----
> From: Kees Cook [mailto:keescook@chromium.org]
> Sent: Monday, October 30, 2017 22:07
> To: David S. Miller <davem@davemloft.net>
> Cc: Jon Maloy <jon.maloy@ericsson.com>; Ying Xue
> <ying.xue@windriver.com>; netdev@vger.kernel.org; tipc-
> discussion@lists.sourceforge.net; linux-kernel@vger.kernel.org
> Subject: [PATCH v2] net: tipc: Convert timers to use timer_setup()
>=20
> In preparation for unconditionally passing the struct timer_list pointer =
to all
> timer callbacks, switch to using the new timer_setup() and from_timer() t=
o
> pass the timer pointer explicitly.
>=20
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: tipc-discussion@lists.sourceforge.net
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> Rebased on commit 0d5fcebf3c37 ("tipc: refactor tipc_sk_timeout()
> function").
> ---
>  net/tipc/discover.c |  6 +++---
>  net/tipc/monitor.c  |  6 +++---
>  net/tipc/node.c     |  8 ++++----
>  net/tipc/socket.c   | 10 +++++-----
>  net/tipc/subscr.c   |  6 +++---
>  5 files changed, 18 insertions(+), 18 deletions(-)
>=20
> diff --git a/net/tipc/discover.c b/net/tipc/discover.c index
> 02462d67d191..92e4828c6b09 100644
> --- a/net/tipc/discover.c
> +++ b/net/tipc/discover.c
> @@ -224,9 +224,9 @@ void tipc_disc_remove_dest(struct tipc_link_req
> *req)
>   *
>   * Called whenever a link setup request timer associated with a bearer
> expires.
>   */
> -static void disc_timeout(unsigned long data)
> +static void disc_timeout(struct timer_list *t)
>  {
> -	struct tipc_link_req *req =3D (struct tipc_link_req *)data;
> +	struct tipc_link_req *req =3D from_timer(req, t, timer);
>  	struct sk_buff *skb;
>  	int max_delay;
>=20
> @@ -292,7 +292,7 @@ int tipc_disc_create(struct net *net, struct
> tipc_bearer *b,
>  	req->num_nodes =3D 0;
>  	req->timer_intv =3D TIPC_LINK_REQ_INIT;
>  	spin_lock_init(&req->lock);
> -	setup_timer(&req->timer, disc_timeout, (unsigned long)req);
> +	timer_setup(&req->timer, disc_timeout, 0);
>  	mod_timer(&req->timer, jiffies + req->timer_intv);
>  	b->link_req =3D req;
>  	*skb =3D skb_clone(req->buf, GFP_ATOMIC); diff --git
> a/net/tipc/monitor.c b/net/tipc/monitor.c index
> 9e109bb1a207..b9c32557d73c 100644
> --- a/net/tipc/monitor.c
> +++ b/net/tipc/monitor.c
> @@ -578,9 +578,9 @@ void tipc_mon_get_state(struct net *net, u32 addr,
>  	read_unlock_bh(&mon->lock);
>  }
>=20
> -static void mon_timeout(unsigned long m)
> +static void mon_timeout(struct timer_list *t)
>  {
> -	struct tipc_monitor *mon =3D (void *)m;
> +	struct tipc_monitor *mon =3D from_timer(mon, t, timer);
>  	struct tipc_peer *self;
>  	int best_member_cnt =3D dom_size(mon->peer_cnt) - 1;
>=20
> @@ -623,7 +623,7 @@ int tipc_mon_create(struct net *net, int bearer_id)
>  	self->is_up =3D true;
>  	self->is_head =3D true;
>  	INIT_LIST_HEAD(&self->list);
> -	setup_timer(&mon->timer, mon_timeout, (unsigned long)mon);
> +	timer_setup(&mon->timer, mon_timeout, 0);
>  	mon->timer_intv =3D msecs_to_jiffies(MON_TIMEOUT + (tn->random
> & 0xffff));
>  	mod_timer(&mon->timer, jiffies + mon->timer_intv);
>  	return 0;
> diff --git a/net/tipc/node.c b/net/tipc/node.c index
> 89f8ac73bf65..009a81631280 100644
> --- a/net/tipc/node.c
> +++ b/net/tipc/node.c
> @@ -153,7 +153,7 @@ static void tipc_node_link_down(struct tipc_node *n,
> int bearer_id,
>  				bool delete);
>  static void node_lost_contact(struct tipc_node *n, struct sk_buff_head
> *inputq);  static void tipc_node_delete(struct tipc_node *node); -static =
void
> tipc_node_timeout(unsigned long data);
> +static void tipc_node_timeout(struct timer_list *t);
>  static void tipc_node_fsm_evt(struct tipc_node *n, int evt);  static str=
uct
> tipc_node *tipc_node_find(struct net *net, u32 addr);  static void
> tipc_node_put(struct tipc_node *node); @@ -361,7 +361,7 @@ struct
> tipc_node *tipc_node_create(struct net *net, u32 addr, u16 capabilities)
>  		goto exit;
>  	}
>  	tipc_node_get(n);
> -	setup_timer(&n->timer, tipc_node_timeout, (unsigned long)n);
> +	timer_setup(&n->timer, tipc_node_timeout, 0);
>  	n->keepalive_intv =3D U32_MAX;
>  	hlist_add_head_rcu(&n->hash, &tn-
> >node_htable[tipc_hashfn(addr)]);
>  	list_for_each_entry_rcu(temp_node, &tn->node_list, list) { @@ -
> 500,9 +500,9 @@ void tipc_node_remove_conn(struct net *net, u32 dnode,
> u32 port)
>=20
>  /* tipc_node_timeout - handle expiration of node timer
>   */
> -static void tipc_node_timeout(unsigned long data)
> +static void tipc_node_timeout(struct timer_list *t)
>  {
> -	struct tipc_node *n =3D (struct tipc_node *)data;
> +	struct tipc_node *n =3D from_timer(n, t, timer);
>  	struct tipc_link_entry *le;
>  	struct sk_buff_head xmitq;
>  	int bearer_id;
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c index
> ea61c32f6b80..5d18c0caa92b 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -125,7 +125,7 @@ static void tipc_sock_destruct(struct sock *sk);  sta=
tic
> int tipc_release(struct socket *sock);  static int tipc_accept(struct soc=
ket
> *sock, struct socket *new_sock, int flags,
>  		       bool kern);
> -static void tipc_sk_timeout(unsigned long data);
> +static void tipc_sk_timeout(struct timer_list *t);
>  static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
>  			   struct tipc_name_seq const *seq);  static int
> tipc_sk_withdraw(struct tipc_sock *tsk, uint scope, @@ -464,7 +464,7 @@
> static int tipc_sk_create(struct net *net, struct socket *sock,
>  		      NAMED_H_SIZE, 0);
>=20
>  	msg_set_origport(msg, tsk->portid);
> -	setup_timer(&sk->sk_timer, tipc_sk_timeout, (unsigned long)tsk);
> +	timer_setup(&sk->sk_timer, tipc_sk_timeout, 0);
>  	sk->sk_shutdown =3D 0;
>  	sk->sk_backlog_rcv =3D tipc_sk_backlog_rcv;
>  	sk->sk_rcvbuf =3D sysctl_tipc_rmem[1];
> @@ -2530,14 +2530,14 @@ static int tipc_shutdown(struct socket *sock, int
> how)
>  	return res;
>  }
>=20
> -static void tipc_sk_timeout(unsigned long data)
> +static void tipc_sk_timeout(struct timer_list *t)
>  {
> -	struct tipc_sock *tsk =3D (struct tipc_sock *)data;
> +	struct sock *sk =3D from_timer(sk, t, sk_timer);
> +	struct tipc_sock *tsk =3D tipc_sk(sk);
>  	u32 peer_port =3D tsk_peer_port(tsk);
>  	u32 peer_node =3D tsk_peer_node(tsk);
>  	u32 own_node =3D tsk_own_node(tsk);
>  	u32 own_port =3D tsk->portid;
> -	struct sock *sk =3D &tsk->sk;
>  	struct net *net =3D sock_net(sk);
>  	struct sk_buff *skb =3D NULL;
>=20
> diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c index
> be3d9e3183dc..251065dfd8df 100644
> --- a/net/tipc/subscr.c
> +++ b/net/tipc/subscr.c
> @@ -133,9 +133,9 @@ void tipc_subscrp_report_overlap(struct
> tipc_subscription *sub, u32 found_lower,
>  				node);
>  }
>=20
> -static void tipc_subscrp_timeout(unsigned long data)
> +static void tipc_subscrp_timeout(struct timer_list *t)
>  {
> -	struct tipc_subscription *sub =3D (struct tipc_subscription *)data;
> +	struct tipc_subscription *sub =3D from_timer(sub, t, timer);
>  	struct tipc_subscriber *subscriber =3D sub->subscriber;
>=20
>  	spin_lock_bh(&subscriber->lock);
> @@ -303,7 +303,7 @@ static void tipc_subscrp_subscribe(struct net *net,
> struct tipc_subscr *s,
>  	tipc_subscrb_get(subscriber);
>  	spin_unlock_bh(&subscriber->lock);
>=20
> -	setup_timer(&sub->timer, tipc_subscrp_timeout, (unsigned
> long)sub);
> +	timer_setup(&sub->timer, tipc_subscrp_timeout, 0);
>  	timeout =3D htohl(sub->evt.s.timeout, swap);
>=20
>  	if (timeout !=3D TIPC_WAIT_FOREVER)
> --
> 2.7.4
>=20
>=20
> --
> Kees Cook
> Pixel Security
