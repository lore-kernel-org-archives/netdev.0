From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] vxlan: eliminate cached dst leak
Date: Tue, 30 May 2017 10:34:48 +0200
Message-ID: <1496133288.2432.7.camel@redhat.com>
References: <20170529172557.7065-1-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Lance Richardson <lrichard@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36608 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750896AbdE3Ieu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 04:34:50 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5889480F6C
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 08:34:50 +0000 (UTC)
In-Reply-To: <20170529172557.7065-1-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-29 at 13:25 -0400, Lance Richardson wrote:
> After commit 0c1d70af924b ("net: use dst_cache for vxlan device"),
> cached dst entries could be leaked when more than one remote was
> present for a given vxlan_fdb entry, causing subsequent netns
> operations to block indefinitely and "unregister_netdevice: waiting
> for lo to become free." messages to appear in the kernel log.
> 
> Fix by properly releasing cached dst and freeing resources in this
> case.
> 
> Fixes: commit 0c1d70af924b ("net: use dst_cache for vxlan device")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
>  drivers/net/vxlan.c | 20 +++++++++++++++++---
>  1 file changed, 17 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 328b471..5c1d69e 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -740,6 +740,22 @@ static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
>  	call_rcu(&f->rcu, vxlan_fdb_free);
>  }
>  
> +static void vxlan_dst_free(struct rcu_head *head)
> +{
> +	struct vxlan_rdst *rd = container_of(head, struct vxlan_rdst, rcu);
> +
> +	dst_cache_destroy(&rd->dst_cache);
> +	kfree(rd);
> +}
> +
> +static void vxlan_fdb_dst_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f,
> +				  struct vxlan_rdst *rd)
> +{
> +	list_del_rcu(&rd->list);
> +	vxlan_fdb_notify(vxlan, f, rd, RTM_DELNEIGH);
> +	call_rcu(&rd->rcu, vxlan_dst_free);
> +}
> +
>  static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
>  			   union vxlan_addr *ip, __be16 *port, __be32 *src_vni,
>  			   __be32 *vni, u32 *ifindex)
> @@ -864,9 +880,7 @@ static int __vxlan_fdb_delete(struct vxlan_dev *vxlan,
>  	 * otherwise destroy the fdb entry
>  	 */
>  	if (rd && !list_is_singular(&f->remotes)) {
> -		list_del_rcu(&rd->list);
> -		vxlan_fdb_notify(vxlan, f, rd, RTM_DELNEIGH);
> -		kfree_rcu(rd, rcu);
> +		vxlan_fdb_dst_destroy(vxlan, f, rd);
>  		goto out;
>  	}
>  

LGTM, thanks Lance!

Acked-by: Paolo Abeni <pabeni@redhat.com>
