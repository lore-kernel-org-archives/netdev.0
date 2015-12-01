From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] openvswitch: properly refcount vport-vxlan module
Date: Tue, 01 Dec 2015 13:03:57 +0100
Message-ID: <1448971437.3330290.454583417.56E794A4@webmail.messagingengine.com>
References: <2658801f06f24c242c40f223b1164e61be44974a.1448882748.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:52945 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754895AbbLAMD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 07:03:58 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 0F84C20889
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 07:03:58 -0500 (EST)
In-Reply-To: <2658801f06f24c242c40f223b1164e61be44974a.1448882748.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Paolo,

On Mon, Nov 30, 2015, at 12:31, Paolo Abeni wrote:
> After 614732eaa12d, no refcount is maintained for the vport-vxlan module.
> This allows the userspace to remove such module while vport-vxlan
> devices still exist, which leads to later oops.
> 
> v1 -> v2:
>  - move vport 'owner' initialization in ovs_vport_ops_register()
>    and make such function a macro
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/openvswitch/vport-geneve.c | 1 -
>  net/openvswitch/vport-gre.c    | 1 -
>  net/openvswitch/vport.c        | 4 ++--
>  net/openvswitch/vport.h        | 8 +++++++-
>  4 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/net/openvswitch/vport-geneve.c
> b/net/openvswitch/vport-geneve.c
> index efb736b..e41cd12 100644
> --- a/net/openvswitch/vport-geneve.c
> +++ b/net/openvswitch/vport-geneve.c
> @@ -117,7 +117,6 @@ static struct vport_ops ovs_geneve_vport_ops = {
>  	.destroy	= ovs_netdev_tunnel_destroy,
>  	.get_options	= geneve_get_options,
>  	.send		= dev_queue_xmit,
> -       .owner          = THIS_MODULE,
>  };
>  
>  static int __init ovs_geneve_tnl_init(void)
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> index c3257d7..7f8897f 100644
> --- a/net/openvswitch/vport-gre.c
> +++ b/net/openvswitch/vport-gre.c
> @@ -89,7 +89,6 @@ static struct vport_ops ovs_gre_vport_ops = {
>  	.create		= gre_create,
>  	.send		= dev_queue_xmit,
>  	.destroy	= ovs_netdev_tunnel_destroy,
> -       .owner          = THIS_MODULE,
>  };
>  
>  static int __init ovs_gre_tnl_init(void)
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index e194c10a..31cbc8c 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -71,7 +71,7 @@ static struct hlist_head *hash_bucket(const struct net
> *net, const char *name)
>  	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
>  }
>  
> -int ovs_vport_ops_register(struct vport_ops *ops)
> +int __ovs_vport_ops_register(struct vport_ops *ops)
>  {
>  	int err = -EEXIST;
>  	struct vport_ops *o;
> @@ -87,7 +87,7 @@ errout:
>  	ovs_unlock();
>  	return err;
>  }
> -EXPORT_SYMBOL_GPL(ovs_vport_ops_register);
> +EXPORT_SYMBOL_GPL(__ovs_vport_ops_register);
>  
>  void ovs_vport_ops_unregister(struct vport_ops *ops)
>  {
> diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
> index bdfd82a..8ea3a96 100644
> --- a/net/openvswitch/vport.h
> +++ b/net/openvswitch/vport.h
> @@ -196,7 +196,13 @@ static inline const char *ovs_vport_name(struct
> vport *vport)
>  	return vport->dev->name;
>  }
>  
> -int ovs_vport_ops_register(struct vport_ops *ops);
> +int __ovs_vport_ops_register(struct vport_ops *ops);
> +#define ovs_vport_ops_register(ops)            \
> +       ({                                      \
> +               (ops)->owner = THIS_MODULE;     \
> +               __ovs_vport_ops_register(ops);  \
> +       })
> +
>  void ovs_vport_ops_unregister(struct vport_ops *ops);

This doesn't look correct (the fault is not your patch).

The register function adds the list_head of the ops struct on a list
without increasing the module reference counter. Thus the module could
be removed and the list walk would walk across the unloaded data section
left over by the module. Does a kmemdup make sense here and a later free
in the unregister function? We test type first and then only touch
functions after getting module refcnt, so it would appear safe to me
then.

Thanks,
Hannes
