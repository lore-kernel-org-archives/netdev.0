From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net (v2)
Date: Fri, 07 Mar 2008 08:24:34 -0500
Message-ID: <1204896274.1397.403.camel@moss-spartans.epoch.ncsc.mil>
References: <47CFB6CA.8090001@openvz.org>
	 <1204821325.1397.298.camel@moss-spartans.epoch.ncsc.mil>
	 <47D01F98.5010609@openvz.org>
	 <1204832619.1397.354.camel@moss-spartans.epoch.ncsc.mil>
	 <47D12EF8.8010801@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	James Morris <jmorris@namei.org>,
	Eric Paris <eparis@parisplace.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie.ncsc.mil ([144.51.88.131]:38316 "EHLO zombie.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbYCGN2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 08:28:23 -0500
In-Reply-To: <47D12EF8.8010801@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-03-07 at 15:03 +0300, Pavel Emelyanov wrote:
> [snip]
> 
> >>> Does this break SELinux labeling of /proc/net inodes and thus its access
> >>> controls on them?
> >> It should not, since the proc_dir_etries are still organized in
> >> a required hierarchy.
> > 
> > Unfortunately, it does break selinux labeling of /proc/net inodes.
> > Easily seen by running ls -ZR /proc/net before and after the patch is
> > applied and comparing the results.  
> > 
> > Also, as a separate issue, a "find /proc/self/net ..." will show that
> > the hard link count is wrong for it.
> 
> Oops... I've checked this thing explicitly before sending, but it looks
> like I used too old find version. I.e. 4.1.20 worked OK, but 4.2.23
> reported the nlink discrepancy.
> 
> Anyway, this is fixed now (see below). I override the getattr method for
> /proc/net directory and update one from the net->proc_net entry, which 
> is calculated correctly.
> 
> > Currently the inodes get labeled by selinux_proc_get_sid() by walking up
> > the proc_dir_entry tree to generate a name and prefix matching that name
> > in policy.  Before the patch, we'd get names like "//net/tcp", i.e.
> > relative to the root of proc (the extra leading slash is due to the
> > earlier proc net rewrite which also broke selinux until we adjusted it
> > to ignore it).  After the patch, we just get "//tcp", which is ambiguous
> > since we would also get that for a /proc/tcp inode if one existed.
> 
> OK, got it. Is it good if we used to get the //net/tcp, but will /net/tcp
> (without the double slash)? The patch below does exactly this. It initializes
> the name for the net->proc_net entry and makes its parent be proc_root.
> 
> Can you Ack this patch, so that I can merge it with the original one and 
> re-post the combined v3?

Thanks, ls -ZR /proc/net now yields the same output before and after the
patch.

Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

> 
> > Not trying to obstruct your proc net improvements, but just want to make
> > sure that selinux doesn't get broken in the process.
> 
> diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
> index 18d413c..4caa5f7 100644
> --- a/fs/proc/proc_net.c
> +++ b/fs/proc/proc_net.c
> @@ -96,8 +96,27 @@ static struct dentry *proc_tgid_net_lookup(struct inode *dir,
>  	return de;
>  }
>  
> +static int proc_tgid_net_getattr(struct vfsmount *mnt, struct dentry *dentry,
> +		struct kstat *stat)
> +{
> +	struct inode *inode = dentry->d_inode;
> +	struct net *net;
> +
> +	net = get_proc_task_net(inode);
> +
> +	generic_fillattr(inode, stat);
> +
> +	if (net != NULL) {
> +		stat->nlink = net->proc_net->nlink;
> +		put_net(net);
> +	}
> +
> +	return 0;
> +}
> +
>  const struct inode_operations proc_net_inode_operations = {
>  	.lookup		= proc_tgid_net_lookup,
> +	.getattr	= proc_tgid_net_getattr,
>  };
>  
>  static int proc_tgid_net_readdir(struct file *filp, void *dirent,
> @@ -162,6 +181,10 @@ static __net_init int proc_net_ns_init(struct net *net)
>  		goto out;
>  
>  	netd->data = net;
> +	netd->nlink = 2;
> +	netd->name = "net";
> +	netd->namelen = 3;
> +	netd->parent = &proc_root;
>  
>  	err = -EEXIST;
>  	net_statd = proc_net_mkdir(net, "stat", netd);
-- 
Stephen Smalley
National Security Agency

