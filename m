From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Tue, 28 May 2013 08:22:37 -0700
Message-ID: <20130528082237.101a1213@nehalam.linuxnetplumber.net>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:52500 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934329Ab3E1PWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 11:22:42 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so8028784pbc.4
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 08:22:41 -0700 (PDT)
In-Reply-To: <1369739242-5944-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 May 2013 19:07:22 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> In commit 553675fb5e9ce3d71a (vxlan: listen on multiple ports),
> we use kfree_rcu() to free ->vn_sock, but a) there is no use
> of RCU API to access this filed, b) RCU is not enough to do refcnt
> here, because in vxlan_leave_group() we drop RTNL lock before
> locking the socket, it could be possible that this field is
> freed during this period.
> 
> So, instead making things complex, just do basic refcnt for
> the ->vn_sock, like we do for others.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 5ed64d4..73a674e 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -83,9 +83,8 @@ static unsigned int vxlan_net_id;
>  /* per UDP socket information */
>  struct vxlan_sock {
>  	struct hlist_node hlist;
> -	struct rcu_head	  rcu;
>  	struct work_struct del_work;
> -	unsigned int	  refcnt;
> +	atomic_t	  refcnt;
>  	struct socket	  *sock;
>  	struct hlist_head vni_list[VNI_HASH_SIZE];
>  };
> @@ -164,14 +163,30 @@ static inline struct hlist_head *vs_head(struct net *net, __be16 port)
>  	return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
>  }
>  
> +static inline void vxlan_sock_get(struct vxlan_sock *vs)
> +{
> +	atomic_inc(&vs->refcnt);
> +}
> +
> +static inline void vxlan_sock_put(struct vxlan_sock *vs)
> +{
> +	if (atomic_dec_and_test(&vs->refcnt)) {
> +		hlist_del_rcu(&vs->hlist);
> +		schedule_work(&vs->del_work);
> +	}
> +}
> +
> +
>  /* Find VXLAN socket based on network namespace and UDP port */
>  static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
>  {
>  	struct vxlan_sock *vs;
>  
>  	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
> +		vxlan_sock_get(vs);
>  		if (inet_sk(vs->sock->sk)->inet_sport == port)
>  			return vs;
> +		vxlan_sock_put(vs);
>  	}
>  	return NULL;
>  }
> @@ -187,10 +202,13 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
>  		return NULL;
>  
>  	hlist_for_each_entry_rcu(vxlan, vni_head(vs, id), hlist) {
> -		if (vxlan->default_dst.remote_vni == id)
> +		if (vxlan->default_dst.remote_vni == id) {
> +			vxlan_sock_put(vs);
>  			return vxlan;
> +		}
>  	}
>  
> +	vxlan_sock_put(vs);
>  	return NULL;
>  }
>  
> @@ -926,7 +944,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
>  	return false;
>  }
>  
> -static void vxlan_sock_put(struct sk_buff *skb)
> +static void vxlan_sock_destructor(struct sk_buff *skb)
>  {
>  	sock_put(skb->sk);
>  }
> @@ -940,7 +958,7 @@ static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
>  	skb_orphan(skb);
>  	sock_hold(sk);
>  	skb->sk = sk;
> -	skb->destructor = vxlan_sock_put;
> +	skb->destructor = vxlan_sock_destructor;
>  }
>  
>  /* Compute source port for outgoing packet
> @@ -1255,10 +1273,14 @@ static int vxlan_open(struct net_device *dev)
>  	struct vxlan_dev *vxlan = netdev_priv(dev);
>  	int err;
>  
> +	vxlan_sock_get(vxlan->vn_sock);
> +
>  	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
>  		err = vxlan_join_group(dev);
> -		if (err)
> +		if (err) {
> +			vxlan_sock_put(vxlan->vn_sock);
>  			return err;
> +		}
>  	}
>  
>  	if (vxlan->age_interval)
> @@ -1294,6 +1316,8 @@ static int vxlan_stop(struct net_device *dev)
>  
>  	del_timer_sync(&vxlan->age_timer);
>  
> +	vxlan_sock_put(vxlan->vn_sock);
> +
>  	vxlan_flush(vxlan);
>  
>  	return 0;
> @@ -1447,7 +1471,7 @@ static void vxlan_del_work(struct work_struct *work)
>  	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
>  
>  	sk_release_kernel(vs->sock->sk);
> -	kfree_rcu(vs, rcu);
> +	kfree(vs);
>  }
>  
>  /* Create new listen socket if needed */
> @@ -1503,7 +1527,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
>  	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
>  	udp_encap_enable();
>  
> -	vs->refcnt = 1;
> +	atomic_set(&vs->refcnt, 1);
>  	return vs;
>  }
>  
> @@ -1592,9 +1616,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>  	}
>  
>  	vs = vxlan_find_port(net, vxlan->dst_port);
> -	if (vs)
> -		++vs->refcnt;
> -	else {
> +	if (!vs) {
>  		/* Drop lock because socket create acquires RTNL lock */
>  		rtnl_unlock();
>  		vs = vxlan_socket_create(net, vxlan->dst_port);
> @@ -1610,12 +1632,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>  
>  	err = register_netdevice(dev);
>  	if (err) {
> -		if (--vs->refcnt == 0) {
> -			rtnl_unlock();
> -			sk_release_kernel(vs->sock->sk);
> -			kfree(vs);
> -			rtnl_lock();
> -		}
> +		vxlan_sock_put(vs);
>  		return err;
>  	}
>  
> @@ -1634,10 +1651,7 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
>  	list_del(&vxlan->next);
>  	unregister_netdevice_queue(dev, head);
>  
> -	if (--vs->refcnt == 0) {
> -		hlist_del_rcu(&vs->hlist);
> -		schedule_work(&vs->del_work);
> -	}
> +	vxlan_sock_put(vs);
>  }
>  
>  static size_t vxlan_get_size(const struct net_device *dev)

Not needed all access is under RTNL
