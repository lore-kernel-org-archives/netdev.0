From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 4/5] NFS: remove RPC PipeFS mount point reference
 from blocklayout routines
Date: Wed, 11 Jan 2012 13:33:13 -0500
Message-ID: <1326306793.20284.3.camel@lade.trondhjem.org>
References: <20120110130323.1672.97025.stgit@localhost6.localdomain6>
	 <20120110130440.1672.43785.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120110130440.1672.43785.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-10 at 17:04 +0400, Stanislav Kinsbursky wrote: 
> This is a cleanup patch. We don't need this reference anymore, because
> blocklayout pipes dentries now creates and destroys in per-net operations and
> on PipeFS mount/umount notification.
> Note that nfs4blocklayout_register_net() now returns 0 instead of -ENOENT in
> case of PipeFS superblock absence. This is ok, because blocklayout pipe dentry
> will be created on PipeFS mount event.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> ---
>  fs/nfs/blocklayout/blocklayout.c |    9 +--------
>  1 files changed, 1 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 322d920..2c70202 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -1034,7 +1034,7 @@ static struct dentry *nfs4blocklayout_register_net(struct net *net,
>  
>  	pipefs_sb = rpc_get_sb_net(net);
>  	if (!pipefs_sb)
> -		return ERR_PTR(-ENOENT);
> +		return 0;

This looks like a typo of some sort. The caller in
nfs4blocklayout_net_init() checks for IS_ERR(), not NULL. I'll just
remove this hunk...

> 	dentry = nfs4blocklayout_register_sb(pipefs_sb, pipe);
>  	rpc_put_sb_net(net);
>  	return dentry;
> @@ -1085,7 +1085,6 @@ static struct pernet_operations nfs4blocklayout_net_ops = {
>  
>  static int __init nfs4blocklayout_init(void)
>  {
> -	struct vfsmount *mnt;
>  	int ret;
>  
>  	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
> @@ -1095,12 +1094,6 @@ static int __init nfs4blocklayout_init(void)
>  		goto out;
>  
>  	init_waitqueue_head(&bl_wq);
> -
> -	mnt = rpc_get_mount();
> -	if (IS_ERR(mnt)) {
> -		ret = PTR_ERR(mnt);
> -		goto out_remove;
> -	}
>  	ret = rpc_pipefs_notifier_register(&nfs4blocklayout_block);
>  	if (ret)
>  		goto out_remove;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
