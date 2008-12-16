From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 4/7] fs: Introduce SINGLE dentries for pipes,
	socket, anon fd
Date: Tue, 16 Dec 2008 13:40:33 -0800
Message-ID: <20081216214033.GO6681@linux.vnet.ibm.com>
References: <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <493100B0.6090104@cosmosbay.com> <494196AA.6080002@cosmosbay.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <494196AA.6080002-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 11, 2008 at 11:39:38PM +0100, Eric Dumazet wrote:
> Sockets, pipes and anonymous fds have interesting properties.
> 
> Like other files, they use a dentry and an inode.
> 
> But dentries for these kind of files are not hashed into dcache,
> since there is no way someone can lookup such a file in the vfs tree.
> (/proc/{pid}/fd/{number} uses a different mechanism)
> 
> Still, allocating and freeing such dentries are expensive processes,
> because we currently take dcache_lock inside d_alloc(), d_instantiate(),
> and dput(). This lock is very contended on SMP machines.
> 
> This patch defines a new DCACHE_SINGLE flag, to mark a dentry as
> a single one (for sockets, pipes, anonymous fd), and a new
> d_alloc_single(const struct qstr *name, struct inode *inode)
> method, called by the three subsystems.
> 
> Internally, dput() can take a fast path to dput_single() for
> SINGLE dentries. No more atomic_dec_and_lock()
> for such dentries.
> 
> 
> Differences betwen an SINGLE dentry and a normal one are :
> 
> 1) SINGLE dentry has the DCACHE_SINGLE flag
> 2) SINGLE dentry's parent is itself (DCACHE_DISCONNECTED)
> This to avoid taking a reference on sb 'root' dentry, shared
> by too many dentries.
> 3) They are not hashed into global hash table (DCACHE_UNHASHED)
> 4) Their d_alias list is empty
> 
> ("socketallocbench -n 8" bench result : from 25s to 19.9s)

Acked-by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

> Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
> ---
>  fs/anon_inodes.c       |   16 ------------
>  fs/dcache.c            |   51 +++++++++++++++++++++++++++++++++++++++
>  fs/pipe.c              |   23 +----------------
>  include/linux/dcache.h |    9 ++++++
>  net/socket.c           |   24 +-----------------
>  5 files changed, 65 insertions(+), 58 deletions(-)
> 
> diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
> index 3662dd4..8bf83cb 100644
> --- a/fs/anon_inodes.c
> +++ b/fs/anon_inodes.c
> @@ -33,23 +33,12 @@ static int anon_inodefs_get_sb(struct file_system_type *fs_type, int flags,
>  			     mnt);
>  }
> 
> -static int anon_inodefs_delete_dentry(struct dentry *dentry)
> -{
> -	/*
> -	 * We faked vfs to believe the dentry was hashed when we created it.
> -	 * Now we restore the flag so that dput() will work correctly.
> -	 */
> -	dentry->d_flags |= DCACHE_UNHASHED;
> -	return 1;
> -}
> -
>  static struct file_system_type anon_inode_fs_type = {
>  	.name		= "anon_inodefs",
>  	.get_sb		= anon_inodefs_get_sb,
>  	.kill_sb	= kill_anon_super,
>  };
>  static struct dentry_operations anon_inodefs_dentry_operations = {
> -	.d_delete	= anon_inodefs_delete_dentry,
>  };
> 
>  /**
> @@ -92,7 +81,7 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
>  	this.name = name;
>  	this.len = strlen(name);
>  	this.hash = 0;
> -	dentry = d_alloc(anon_inode_mnt->mnt_sb->s_root, &this);
> +	dentry = d_alloc_single(&this, anon_inode_inode);
>  	if (!dentry)
>  		goto err_put_unused_fd;
> 
> @@ -104,9 +93,6 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
>  	atomic_inc(&anon_inode_inode->i_count);
> 
>  	dentry->d_op = &anon_inodefs_dentry_operations;
> -	/* Do not publish this dentry inside the global dentry hash table */
> -	dentry->d_flags &= ~DCACHE_UNHASHED;
> -	d_instantiate(dentry, anon_inode_inode);
> 
>  	error = -ENFILE;
>  	file = alloc_file(anon_inode_mnt, dentry,
> diff --git a/fs/dcache.c b/fs/dcache.c
> index f463a81..af3bfb3 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -219,6 +219,23 @@ static struct dentry *d_kill(struct dentry *dentry)
>   */
> 
>  /*
> + * special version of dput() for pipes/sockets/anon.
> + * These dentries are not present in hash table, we can avoid
> + * taking/dirtying dcache_lock
> + */
> +static void dput_single(struct dentry *dentry)
> +{
> +	struct inode *inode;
> +
> +	if (!atomic_dec_and_test(&dentry->d_count))
> +		return;
> +	inode = dentry->d_inode;
> +	if (inode)
> +		iput(inode);
> +	d_free(dentry);
> +}
> +
> +/*
>   * dput - release a dentry
>   * @dentry: dentry to release 
>   *
> @@ -234,6 +251,11 @@ void dput(struct dentry *dentry)
>  {
>  	if (!dentry)
>  		return;
> +	/*
> +	 * single dentries (sockets/pipes/anon) fast path
> +	 */
> +	if (dentry->d_flags & DCACHE_SINGLE)
> +		return dput_single(dentry);
> 
>  repeat:
>  	if (atomic_read(&dentry->d_count) == 1)
> @@ -1119,6 +1141,35 @@ struct dentry * d_alloc_root(struct inode * root_inode)
>  	return res;
>  }
> 
> +/**
> + * d_alloc_single - allocate SINGLE dentry
> + * @name: dentry name, given in a qstr structure
> + * @inode: inode to allocate the dentry for
> + *
> + * Allocate an SINGLE dentry for the inode given. The inode is
> + * instantiated and returned. %NULL is returned if there is insufficient
> + * memory.
> + * - SINGLE dentries have themselves as a parent.
> + * - SINGLE dentries are not hashed into global hash table
> + * - their d_alias list is empty
> + */
> +struct dentry *d_alloc_single(const struct qstr *name, struct inode *inode)
> +{
> +	struct dentry *entry;
> +
> +	entry = d_alloc(NULL, name);
> +	if (entry) {
> +		entry->d_sb = inode->i_sb;
> +		entry->d_parent = entry;
> +		entry->d_flags |= DCACHE_SINGLE | DCACHE_DISCONNECTED;
> +		entry->d_inode = inode;
> +		fsnotify_d_instantiate(entry, inode);
> +		security_d_instantiate(entry, inode);
> +	}
> +	return entry;
> +}
> +
> +
>  static inline struct hlist_head *d_hash(struct dentry *parent,
>  					unsigned long hash)
>  {
> diff --git a/fs/pipe.c b/fs/pipe.c
> index 7aea8b8..4de6dd5 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -849,17 +849,6 @@ void free_pipe_info(struct inode *inode)
>  }
> 
>  static struct vfsmount *pipe_mnt __read_mostly;
> -static int pipefs_delete_dentry(struct dentry *dentry)
> -{
> -	/*
> -	 * At creation time, we pretended this dentry was hashed
> -	 * (by clearing DCACHE_UNHASHED bit in d_flags)
> -	 * At delete time, we restore the truth : not hashed.
> -	 * (so that dput() can proceed correctly)
> -	 */
> -	dentry->d_flags |= DCACHE_UNHASHED;
> -	return 0;
> -}
> 
>  /*
>   * pipefs_dname() is called from d_path().
> @@ -871,7 +860,6 @@ static char *pipefs_dname(struct dentry *dentry, char *buffer, int buflen)
>  }
> 
>  static struct dentry_operations pipefs_dentry_operations = {
> -	.d_delete	= pipefs_delete_dentry,
>  	.d_dname	= pipefs_dname,
>  };
> 
> @@ -918,7 +906,7 @@ struct file *create_write_pipe(int flags)
>  	struct inode *inode;
>  	struct file *f;
>  	struct dentry *dentry;
> -	struct qstr name = { .name = "" };
> +	static const struct qstr name = { .name = "" };
> 
>  	err = -ENFILE;
>  	inode = get_pipe_inode();
> @@ -926,18 +914,11 @@ struct file *create_write_pipe(int flags)
>  		goto err;
> 
>  	err = -ENOMEM;
> -	dentry = d_alloc(pipe_mnt->mnt_sb->s_root, &name);
> +	dentry = d_alloc_single(&name, inode);
>  	if (!dentry)
>  		goto err_inode;
> 
>  	dentry->d_op = &pipefs_dentry_operations;
> -	/*
> -	 * We dont want to publish this dentry into global dentry hash table.
> -	 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
> -	 * This permits a working /proc/$pid/fd/XXX on pipes
> -	 */
> -	dentry->d_flags &= ~DCACHE_UNHASHED;
> -	d_instantiate(dentry, inode);
> 
>  	err = -ENFILE;
>  	f = alloc_file(pipe_mnt, dentry, FMODE_WRITE, &write_pipefifo_fops);
> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
> index a37359d..ca8d269 100644
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -176,6 +176,14 @@ d_iput:		no		no		no       yes
>  #define DCACHE_UNHASHED		0x0010	
> 
>  #define DCACHE_INOTIFY_PARENT_WATCHED	0x0020 /* Parent inode is watched */
> +#define DCACHE_SINGLE		0x0040
> +	/*
> +	 * socket, pipe or anonymous fd dentry
> +	 * - SINGLE dentries have themselves as a parent.
> +	 * - SINGLE dentries are not hashed into global hash table
> +	 * - Their d_alias list is empty
> +	 * - They dont need dcache_lock synchronization
> +	 */
> 
>  extern spinlock_t dcache_lock;
>  extern seqlock_t rename_lock;
> @@ -235,6 +243,7 @@ extern void shrink_dcache_sb(struct super_block *);
>  extern void shrink_dcache_parent(struct dentry *);
>  extern void shrink_dcache_for_umount(struct super_block *);
>  extern int d_invalidate(struct dentry *);
> +extern struct dentry *d_alloc_single(const struct qstr *, struct inode *);
> 
>  /* only used at mount-time */
>  extern struct dentry * d_alloc_root(struct inode *);
> diff --git a/net/socket.c b/net/socket.c
> index 92764d8..353c928 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -308,18 +308,6 @@ static struct file_system_type sock_fs_type = {
>  	.kill_sb =	kill_anon_super,
>  };
> 
> -static int sockfs_delete_dentry(struct dentry *dentry)
> -{
> -	/*
> -	 * At creation time, we pretended this dentry was hashed
> -	 * (by clearing DCACHE_UNHASHED bit in d_flags)
> -	 * At delete time, we restore the truth : not hashed.
> -	 * (so that dput() can proceed correctly)
> -	 */
> -	dentry->d_flags |= DCACHE_UNHASHED;
> -	return 0;
> -}
> -
>  /*
>   * sockfs_dname() is called from d_path().
>   */
> @@ -330,7 +318,6 @@ static char *sockfs_dname(struct dentry *dentry, char *buffer, int buflen)
>  }
> 
>  static struct dentry_operations sockfs_dentry_operations = {
> -	.d_delete = sockfs_delete_dentry,
>  	.d_dname  = sockfs_dname,
>  };
> 
> @@ -372,20 +359,13 @@ static int sock_alloc_fd(struct file **filep, int flags)
>  static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
>  {
>  	struct dentry *dentry;
> -	struct qstr name = { .name = "" };
> +	static const struct qstr name = { .name = "" };
> 
> -	dentry = d_alloc(sock_mnt->mnt_sb->s_root, &name);
> +	dentry = d_alloc_single(&name, SOCK_INODE(sock));
>  	if (unlikely(!dentry))
>  		return -ENOMEM;
> 
>  	dentry->d_op = &sockfs_dentry_operations;
> -	/*
> -	 * We dont want to push this dentry into global dentry hash table.
> -	 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
> -	 * This permits a working /proc/$pid/fd/XXX on sockets
> -	 */
> -	dentry->d_flags &= ~DCACHE_UNHASHED;
> -	d_instantiate(dentry, SOCK_INODE(sock));
> 
>  	sock->file = file;
>  	init_file(file, sock_mnt, dentry, FMODE_READ | FMODE_WRITE,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
