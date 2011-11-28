From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Mon, 28 Nov 2011 13:31:42 -0800
Message-ID: <20111128133142.46998873@nehalam.linuxnetplumber.net>
References: <igorm@etf.rs>
	<1322511796-6908-1-git-send-email-igorm@etf.rs>
	<1322511796-6908-2-git-send-email-igorm@etf.rs>
	<1322512426.2970.15.camel@edumazet-laptop>
	<1322515010.2970.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56794 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322Ab1K1Vbp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 16:31:45 -0500
In-Reply-To: <1322515010.2970.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Nov 2011 22:16:50 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 28 novembre 2011 =E0 21:33 +0100, Eric Dumazet a =E9crit :
> > Le lundi 28 novembre 2011 =E0 21:23 +0100, igorm@etf.rs a =E9crit :
> > > From: Igor Maravic <igorm@etf.rs>
> > >=20
> > > Problem with setting netstamp_needed as jump_label_key is that
> > > it inc/dec, functions net_enable_timestamp/net_disable_timestamp,
> > > are called from interrupts.
> > >=20
> > > That can cause DEADLOCK, because jump_label_{inc, dec} are using =
mutex locking,
> > > that may sleep.
> > >=20
> > > Signed-off-by: Igor Maravic <igorm@etf.rs>
> > >=20
> >=20
> > Come on, we can find another way to handle this :)
> >=20
> > Its net-next, we are allowed to try to find something better.
> >=20
>=20
> Could you test following patch ?
>=20
> Thanks
>=20
> [PATCH net-next] net: dont call jump_label_dec from irq context
>=20
> Igor Maravic reported an error caused by jump_label_dec() being calle=
d
> from IRQ context :
>=20
>  BUG: sleeping function called from invalid context at kernel/mutex.c=
:271
>  in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper
>  1 lock held by swapper/0:
>   #0:  (&n->timer){+.-...}, at: [<ffffffff8107ce90>] call_timer_fn+0x=
0/0x340
>  Pid: 0, comm: swapper Not tainted 3.2.0-rc2-net-next-mpls+ #1
> Call Trace:
>  <IRQ>  [<ffffffff8104f417>] __might_sleep+0x137/0x1f0
>  [<ffffffff816b9a2f>] mutex_lock_nested+0x2f/0x370
>  [<ffffffff810a89fd>] ? trace_hardirqs_off+0xd/0x10
>  [<ffffffff8109a37f>] ? local_clock+0x6f/0x80
>  [<ffffffff810a90a5>] ? lock_release_holdtime.part.22+0x15/0x1a0
>  [<ffffffff81557929>] ? sock_def_write_space+0x59/0x160
>  [<ffffffff815e936e>] ? arp_error_report+0x3e/0x90
>  [<ffffffff810969cd>] atomic_dec_and_mutex_lock+0x5d/0x80
>  [<ffffffff8112fc1d>] jump_label_dec+0x1d/0x50
>  [<ffffffff81566525>] net_disable_timestamp+0x15/0x20
>  [<ffffffff81557a75>] sock_disable_timestamp+0x45/0x50
>  [<ffffffff81557b00>] __sk_free+0x80/0x200
>  [<ffffffff815578d0>] ? sk_send_sigurg+0x70/0x70
>  [<ffffffff815e936e>] ? arp_error_report+0x3e/0x90
>  [<ffffffff81557cba>] sock_wfree+0x3a/0x70
>  [<ffffffff8155c2b0>] skb_release_head_state+0x70/0x120
>  [<ffffffff8155c0b6>] __kfree_skb+0x16/0x30
>  [<ffffffff8155c119>] kfree_skb+0x49/0x170
>  [<ffffffff815e936e>] arp_error_report+0x3e/0x90
>  [<ffffffff81575bd9>] neigh_invalidate+0x89/0xc0
>  [<ffffffff81578dbe>] neigh_timer_handler+0x9e/0x2a0
>  [<ffffffff81578d20>] ? neigh_update+0x640/0x640
>  [<ffffffff81073558>] __do_softirq+0xc8/0x3a0
>=20
> Since jump_label_{inc|dec} must be called from process context only,
> we must defer jump_label_dec() if net_disable_timestamp() is called
> from interrupt context.
>=20
> Reported-by: Igor Maravic <igorm@etf.rs>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/dev.c                 |   23 +++++++++++++++++++++++
>  net/ipv4/netfilter/ip_queue.c  |    6 ++++--
>  net/ipv6/netfilter/ip6_queue.c |    5 ++++-
>  3 files changed, 31 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8afb244..de5266c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1443,15 +1443,38 @@ int call_netdevice_notifiers(unsigned long va=
l, struct net_device *dev)
>  EXPORT_SYMBOL(call_netdevice_notifiers);
> =20
>  static struct jump_label_key netstamp_needed __read_mostly;
> +#ifdef HAVE_JUMP_LABEL
> +/* We are not allowed to call jump_label_dec() from irq context
> + * If net_disable_timestamp() is called from irq context, defer the
> + * jump_label_dec() calls.
> + */
> +static atomic_t netstamp_needed_deferred;
> +#endif
> =20
>  void net_enable_timestamp(void)
>  {
> +#ifdef HAVE_JUMP_LABEL
> +	int deferred =3D atomic_xchg(&netstamp_needed_deferred, 0);
> +
> +	if (deferred) {
> +		while (--deferred)
> +			jump_label_dec(&netstamp_needed);
> +		return;
> +	}
> +#endif
> +	WARN_ON(in_interrupt());
>  	jump_label_inc(&netstamp_needed);
>  }
>  EXPORT_SYMBOL(net_enable_timestamp);
> =20
>  void net_disable_timestamp(void)
>  {
> +#ifdef HAVE_JUMP_LABEL
> +	if (in_interrupt()) {
> +		atomic_inc(&netstamp_needed_deferred);
> +		return;
> +	}
> +#endif
>  	jump_label_dec(&netstamp_needed);
>  }
>  EXPORT_SYMBOL(net_disable_timestamp);
> diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_qu=
eue.c
> index e59aabd..a057fe6 100644
> --- a/net/ipv4/netfilter/ip_queue.c
> +++ b/net/ipv4/netfilter/ip_queue.c
> @@ -404,6 +404,7 @@ __ipq_rcv_skb(struct sk_buff *skb)
>  	int status, type, pid, flags;
>  	unsigned int nlmsglen, skblen;
>  	struct nlmsghdr *nlh;
> +	bool enable_timestamp =3D false;
> =20
>  	skblen =3D skb->len;
>  	if (skblen < sizeof(*nlh))
> @@ -441,12 +442,13 @@ __ipq_rcv_skb(struct sk_buff *skb)
>  			RCV_SKB_FAIL(-EBUSY);
>  		}
>  	} else {
> -		net_enable_timestamp();
> +		enable_timestamp =3D true;
>  		peer_pid =3D pid;
>  	}
> =20
>  	spin_unlock_bh(&queue_lock);
> -
> +	if (enable_timestamp)
> +		net_enable_timestamp();
>  	status =3D ipq_receive_peer(NLMSG_DATA(nlh), type,
>  				  nlmsglen - NLMSG_LENGTH(0));
>  	if (status < 0)
> diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_=
queue.c
> index e63c397..fb80a23 100644
> --- a/net/ipv6/netfilter/ip6_queue.c
> +++ b/net/ipv6/netfilter/ip6_queue.c
> @@ -405,6 +405,7 @@ __ipq_rcv_skb(struct sk_buff *skb)
>  	int status, type, pid, flags;
>  	unsigned int nlmsglen, skblen;
>  	struct nlmsghdr *nlh;
> +	bool enable_timestamp =3D false;
> =20
>  	skblen =3D skb->len;
>  	if (skblen < sizeof(*nlh))
> @@ -442,11 +443,13 @@ __ipq_rcv_skb(struct sk_buff *skb)
>  			RCV_SKB_FAIL(-EBUSY);
>  		}
>  	} else {
> -		net_enable_timestamp();
> +		enable_timestamp =3D true;
>  		peer_pid =3D pid;
>  	}
> =20
>  	spin_unlock_bh(&queue_lock);
> +	if (enable_timestamp)
> +		net_enable_timestamp();
> =20
>  	status =3D ipq_receive_peer(NLMSG_DATA(nlh), type,
>  				  nlmsglen - NLMSG_LENGTH(0));

Why not just change the jump_label_key to a spin_lock? I can't see that=
 it is held
long enough to make mutex of any benefit.
