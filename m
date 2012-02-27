From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH v2 2/4] NFS: release per-net clients lock before calling PipeFS dentries creation
Date: Mon, 27 Feb 2012 15:59:23 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7E@saturn3.aculab.com>
References: <20120227155103.7941.17006.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	<neilb-l3A5Bk7waGM@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	<bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "Stanislav Kinsbursky" <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20120227155103.7941.17006.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 
>  	spin_lock(&nn->nfs_client_lock);
> -	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
> +	list_for_each_entry_safe(clp, tmp, &nn->nfs_client_list,
cl_share_link) {
>  		if (clp->rpc_ops != &nfs_v4_clientops)
>  			continue;
> +		atomic_inc(&clp->cl_count);
> +		spin_unlock(&nn->nfs_client_lock);
>  		error = __rpc_pipefs_event(clp, event, sb);
> +		nfs_put_client(clp);
>  		if (error)
>  			break;
> +		spin_lock(&nn->nfs_client_lock);
>  	}
>  	spin_unlock(&nn->nfs_client_lock);
>  	return error;

The locking doesn't look right if the loop breaks on error.
(Same applied to patch v2 1/4)

Although list_fo_each_entry_safe() allows the current entry
to be freed, I don't believe it allows the 'next' to be freed.
I doubt there is protection against that happening.

Do you need to use an atomic_inc() for cl_count.
I'd guess the nfs_client_lock is usually held?

	David


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
