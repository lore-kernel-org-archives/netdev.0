From: Waiman Long <longman@redhat.com>
Subject: Re: [PATCH net 1/2] vxlan: fix hlist corruption
Date: Sun, 2 Jul 2017 16:06:10 -0400
Message-ID: <38e4eb5a-2d9e-4f38-f043-42a1dd449bfb@redhat.com>
References: <cover.1499014738.git.jbenc@redhat.com>
 <61fd10b88f9eeab8f95a3a73f7e27358fcdcd781.1499014738.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
        pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60282 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751876AbdGBUGM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Jul 2017 16:06:12 -0400
In-Reply-To: <61fd10b88f9eeab8f95a3a73f7e27358fcdcd781.1499014738.git.jbenc@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2017 01:00 PM, Jiri Benc wrote:
> It's not a good idea to add the same hlist_node to two different hash lists.
> This leads to various hard to debug memory corruptions.
>
> Fixes: b1be00a6c39f ("vxlan: support both IPv4 and IPv6 sockets in a single vxlan device")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/vxlan.c | 30 ++++++++++++++++++++----------
>  include/net/vxlan.h | 10 +++++++++-
>  2 files changed, 29 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 5fa798a5c9a6..c4e540126258 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -228,15 +228,15 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, sa_family_t family,
>  
>  static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, __be32 vni)
>  {
> -	struct vxlan_dev *vxlan;
> +	struct vxlan_dev_node *node;
>  
>  	/* For flow based devices, map all packets to VNI 0 */
>  	if (vs->flags & VXLAN_F_COLLECT_METADATA)
>  		vni = 0;
>  
> -	hlist_for_each_entry_rcu(vxlan, vni_head(vs, vni), hlist) {
> -		if (vxlan->default_dst.remote_vni == vni)
> -			return vxlan;
> +	hlist_for_each_entry_rcu(node, vni_head(vs, vni), hlist) {
> +		if (node->vxlan->default_dst.remote_vni == vni)
> +			return node->vxlan;
>  	}
>  
>  	return NULL;
> @@ -2365,17 +2365,22 @@ static void vxlan_vs_del_dev(struct vxlan_dev *vxlan)
>  	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
>  
>  	spin_lock(&vn->sock_lock);
> -	hlist_del_init_rcu(&vxlan->hlist);
> +	hlist_del_init_rcu(&vxlan->hlist4.hlist);
> +#if IS_ENABLED(CONFIG_IPV6)
> +	hlist_del_init_rcu(&vxlan->hlist6.hlist);
> +#endif
>  	spin_unlock(&vn->sock_lock);
>  }
>  
> -static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
> +static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan,
> +			     struct vxlan_dev_node *node)
>  {
>  	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
>  	__be32 vni = vxlan->default_dst.remote_vni;
>  
> +	node->vxlan = vxlan;
>  	spin_lock(&vn->sock_lock);
> -	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
> +	hlist_add_head_rcu(&node->hlist, vni_head(vs, vni));
>  	spin_unlock(&vn->sock_lock);
>  }
>  
> @@ -2819,6 +2824,7 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
>  {
>  	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
>  	struct vxlan_sock *vs = NULL;
> +	struct vxlan_dev_node *node;
>  
>  	if (!vxlan->cfg.no_share) {
>  		spin_lock(&vn->sock_lock);
> @@ -2836,12 +2842,16 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
>  	if (IS_ERR(vs))
>  		return PTR_ERR(vs);
>  #if IS_ENABLED(CONFIG_IPV6)
> -	if (ipv6)
> +	if (ipv6) {
>  		rcu_assign_pointer(vxlan->vn6_sock, vs);
> -	else
> +		node = &vxlan->hlist6;
> +	} else
>  #endif
> +	{
>  		rcu_assign_pointer(vxlan->vn4_sock, vs);
> -	vxlan_vs_add_dev(vs, vxlan);
> +		node = &vxlan->hlist4;
> +	}
> +	vxlan_vs_add_dev(vs, vxlan, node);
>  	return 0;
>  }
>  
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index 49a59202f85e..da7d6b89df77 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -221,9 +221,17 @@ struct vxlan_config {
>  	bool			no_share;
>  };
>  
> +struct vxlan_dev_node {
> +	struct hlist_node hlist;
> +	struct vxlan_dev *vxlan;
> +};
> +
>  /* Pseudo network device */
>  struct vxlan_dev {
> -	struct hlist_node hlist;	/* vni hash table */
> +	struct vxlan_dev_node hlist4;	/* vni hash table for IPv4 socket */
> +#if IS_ENABLED(CONFIG_IPV6)
> +	struct vxlan_dev_node hlist6;	/* vni hash table for IPv6 socket */
> +#endif
>  	struct list_head  next;		/* vxlan's per namespace list */
>  	struct vxlan_sock __rcu *vn4_sock;	/* listening socket for IPv4 */
>  #if IS_ENABLED(CONFIG_IPV6)

I didn't see any init code for hlist4 and hlist6. Is vxlan_dev going to
be *zalloc'ed so that they are guaranteed to be NULL? If not, you may
need to add  init code as not both hlists will be hashed and so one of
them may contain invalid data.

-Longman
