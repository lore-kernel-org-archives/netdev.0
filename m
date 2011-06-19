From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 1/2] proc: Generalize proc inode allocation
Date: Sun, 19 Jun 2011 09:20:14 -0500
Message-ID: <20110619142014.GA4694@mail.hallyn.com>
References: <20110521093936.GA3015@p183>
 <m11uzsxdty.fsf@fess.ebiederm.org>
 <20110521223054.GA3198@p183>
 <m1vcx3r3o5.fsf@fess.ebiederm.org>
 <20110523014303.GA2351982@jupiter.n2.diac24.net>
 <20110523014751.GB2351982@jupiter.n2.diac24.net>
 <m1wrgkavbm.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>,
	linux-kernel@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1wrgkavbm.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> 
> Generalize the proc inode allocation so that it can be
> used without having to having to create a proc_dir_entry.
> 
> This will allow namespace file descriptors to remain light
> weight entitities but still have the same inode number
> when the backing namespace is the same.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Serge Hallyn <serge@hallyn.com>

> ---
> 
> Baring problems in review I plan to merge these patches
> via my linux-2.6-nsfd tree.
> 
>  fs/proc/generic.c       |   26 +++++++++++++-------------
>  include/linux/proc_fs.h |   10 ++++++++++
>  2 files changed, 23 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/proc/generic.c b/fs/proc/generic.c
> index f1637f1..65416a1 100644
> --- a/fs/proc/generic.c
> +++ b/fs/proc/generic.c
> @@ -350,14 +350,14 @@ static DEFINE_SPINLOCK(proc_inum_lock); /* protects the above */
>   * Return an inode number between PROC_DYNAMIC_FIRST and
>   * 0xffffffff, or zero on failure.
>   */
> -static unsigned int get_inode_number(void)
> +int proc_alloc_inum(unsigned int *inum)
>  {
>  	unsigned int i;
>  	int error;
>  
>  retry:
> -	if (ida_pre_get(&proc_inum_ida, GFP_KERNEL) == 0)
> -		return 0;
> +	if (!ida_pre_get(&proc_inum_ida, GFP_KERNEL))
> +		return -ENOMEM;
>  
>  	spin_lock(&proc_inum_lock);
>  	error = ida_get_new(&proc_inum_ida, &i);
> @@ -365,18 +365,19 @@ retry:
>  	if (error == -EAGAIN)
>  		goto retry;
>  	else if (error)
> -		return 0;
> +		return error;
>  
>  	if (i > UINT_MAX - PROC_DYNAMIC_FIRST) {
>  		spin_lock(&proc_inum_lock);
>  		ida_remove(&proc_inum_ida, i);
>  		spin_unlock(&proc_inum_lock);
> -		return 0;
> +		return -ENOSPC;
>  	}
> -	return PROC_DYNAMIC_FIRST + i;
> +	*inum = PROC_DYNAMIC_FIRST + i;
> +	return 0;
>  }
>  
> -static void release_inode_number(unsigned int inum)
> +void proc_free_inum(unsigned int inum)
>  {
>  	spin_lock(&proc_inum_lock);
>  	ida_remove(&proc_inum_ida, inum - PROC_DYNAMIC_FIRST);
> @@ -554,13 +555,12 @@ static const struct inode_operations proc_dir_inode_operations = {
>  
>  static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp)
>  {
> -	unsigned int i;
>  	struct proc_dir_entry *tmp;
> +	int ret;
>  	
> -	i = get_inode_number();
> -	if (i == 0)
> -		return -EAGAIN;
> -	dp->low_ino = i;
> +	ret = proc_alloc_inum(&dp->low_ino);
> +	if (ret)
> +		return ret;
>  
>  	if (S_ISDIR(dp->mode)) {
>  		if (dp->proc_iops == NULL) {
> @@ -766,7 +766,7 @@ EXPORT_SYMBOL(proc_create_data);
>  
>  static void free_proc_entry(struct proc_dir_entry *de)
>  {
> -	release_inode_number(de->low_ino);
> +	proc_free_inum(de->low_ino);
>  
>  	if (S_ISLNK(de->mode))
>  		kfree(de->data);
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index e7576cf..3067b44 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -175,6 +175,8 @@ extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
>  
>  extern struct file *proc_ns_fget(int fd);
>  
> +extern int proc_alloc_inum(unsigned int *pino);
> +extern void proc_free_inum(unsigned int inum);
>  #else
>  
>  #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
> @@ -229,6 +231,14 @@ static inline struct file *proc_ns_fget(int fd)
>  	return ERR_PTR(-EINVAL);
>  }
>  
> +static inline int proc_alloc_inum(unsigned int *inum)
> +{
> +	*inum = 1;
> +	return 0;
> +}
> +static inline void proc_free_inum(unsigned int inum)
> +{
> +}
>  #endif /* CONFIG_PROC_FS */
>  
>  #if !defined(CONFIG_PROC_KCORE)
> -- 
> 1.7.5.1.217.g4e3aa
> 
